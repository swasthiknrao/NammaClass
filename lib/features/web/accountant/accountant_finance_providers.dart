import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/providers/data_sync_provider.dart';

/// Optional override for finance period (`YYYY-MM`). `null` → bundle default or today.
final accountantPeriodSelectionProvider = StateProvider<String?>((ref) => null);

String _ymNow() {
  final n = DateTime.now();
  return '${n.year.toString().padLeft(4, '0')}-${n.month.toString().padLeft(2, '0')}';
}

int _int(dynamic v, [int d = 0]) {
  if (v == null) return d;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('$v') ?? d;
}

/// Active finance month for accountant surfaces.
final accountantFinancePeriodProvider = Provider<String>((ref) {
  ref.watch(dataSyncProvider);
  final sel = ref.watch(accountantPeriodSelectionProvider);
  if (sel != null && sel.isNotEmpty) return sel;
  final fromSnap = MockData.financeSnapshot['period'] as String?;
  return fromSnap ?? _ymNow();
});

/// Pending + overdue totals from [MockData.fees] (live).
final accountantFeesRollupProvider = Provider<({int pending, int overdue})>((
  ref,
) {
  ref.watch(dataSyncProvider);
  var pending = 0;
  var overdue = 0;
  for (final f in MockData.fees) {
    if (f.status == 'pending') pending += f.amountPaise;
    if (f.status == 'overdue') overdue += f.amountPaise;
  }
  return (pending: pending, overdue: overdue);
});

class FeeAgingBucket {
  const FeeAgingBucket(this.label, this.amountPaise);
  final String label;
  final int amountPaise;
}

/// Simple aging buckets from installment due dates vs today.
final feeAgingSummaryProvider = Provider<List<FeeAgingBucket>>((ref) {
  ref.watch(dataSyncProvider);
  final now = DateTime.now();
  var current = 0;
  var d1to30 = 0;
  var d31to60 = 0;
  var d61plus = 0;
  for (final f in MockData.fees) {
    if (f.status == 'paid') continue;
    final due = f.dueDate;
    final days = now.difference(due).inDays;
    if (days <= 0) {
      current += f.amountPaise;
    } else if (days <= 30) {
      d1to30 += f.amountPaise;
    } else if (days <= 60) {
      d31to60 += f.amountPaise;
    } else {
      d61plus += f.amountPaise;
    }
  }
  return [
    FeeAgingBucket('Current / not due', current),
    FeeAgingBucket('1–30 days past due', d1to30),
    FeeAgingBucket('31–60 days past due', d31to60),
    FeeAgingBucket('61+ days past due', d61plus),
  ];
});

/// Net payroll liability for [period] — pending payslips only.
final payrollLiabilityForPeriodProvider = Provider.family<int, String>((
  ref,
  period,
) {
  ref.watch(dataSyncProvider);
  var sum = 0;
  for (final p in MockData.payslips) {
    if (p.month != period) continue;
    if (p.status.toLowerCase() != 'pending') continue;
    sum += p.netPaise;
  }
  return sum;
});

/// Income ledger lines filtered by `period`.
final ledgerIncomeLinesForPeriodProvider =
    Provider.family<List<Map<String, dynamic>>, String>((ref, period) {
      ref.watch(dataSyncProvider);
      return MockData.financeIncomeLines
          .where((e) => '${e['period'] ?? ''}' == period)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    });

/// Expense ledger lines filtered by `period`.
final ledgerExpenseLinesForPeriodProvider =
    Provider.family<List<Map<String, dynamic>>, String>((ref, period) {
      ref.watch(dataSyncProvider);
      return MockData.financeExpenseLines
          .where((e) => '${e['period'] ?? ''}' == period)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    });

final expensePipelineProvider = Provider<List<Map<String, dynamic>>>((ref) {
  ref.watch(dataSyncProvider);
  return MockData.financeExpensePipeline
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
});

final financeExceptionsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  ref.watch(dataSyncProvider);
  return MockData.financeExceptions
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
});

final financeCollectionEventsProvider = Provider<List<Map<String, dynamic>>>((
  ref,
) {
  ref.watch(dataSyncProvider);
  return MockData.financeCollectionEvents
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
});

final financePendingByClassProvider = Provider<List<Map<String, dynamic>>>((
  ref,
) {
  ref.watch(dataSyncProvider);
  return MockData.financePendingByClass
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
});

final financeBudgetVsActualProvider = Provider<List<Map<String, dynamic>>>((
  ref,
) {
  ref.watch(dataSyncProvider);
  return MockData.financeBudgetVsActual
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
});

final financeMonthCloseItemsProvider = Provider<List<Map<String, dynamic>>>((
  ref,
) {
  ref.watch(dataSyncProvider);
  return MockData.financeMonthCloseItems
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
});

/// Collection trend in paise (7 points) from snapshot; empty → zeros.
final collectionTrendPaiseProvider = Provider<List<int>>((ref) {
  ref.watch(dataSyncProvider);
  final raw = MockData.financeSnapshot['collection_trend_paise'];
  if (raw is List) {
    return raw.map((e) => _int(e)).toList();
  }
  return const [];
});

/// Normalized 0–100 series for sparkline / line chart.
List<double> normalizeTrendToHundred(List<int> paise) {
  if (paise.isEmpty) return const [];
  final max = paise.reduce((a, b) => a > b ? a : b);
  if (max <= 0) return List<double>.filled(paise.length, 0);
  return paise.map((v) => (v / max) * 100).toList();
}
