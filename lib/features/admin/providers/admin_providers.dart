import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/providers/data_sync_provider.dart';
import 'staff_notifier.dart';

/// Fills missing keys when `dashboard_kpis` in the mock bundle is `{}` or partial.
const _dashboardKpiDefaults = <String, dynamic>{
  'totalStudents': 0,
  'presentToday': 0,
  'absentToday': 0,
  'totalStaff': 0,
  'feesCollectedPercent': 0,
  'feesCollectedPaise': 0,
  'feesPendingPaise': 0,
  'attendancePercent': 0,
  'newAdmissions': 0,
  'pendingApprovals': 0,
};

Map<String, dynamic> _dashboardKpisMerged(Map<String, dynamic> raw) {
  final out = Map<String, dynamic>.from(_dashboardKpiDefaults);
  raw.forEach((k, v) {
    if (v != null) out[k] = v;
  });
  return out;
}

final adminDashboardKpisProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  ref.watch(dataSyncProvider);
  await Future.delayed(const Duration(milliseconds: 150));
  return _dashboardKpisMerged(MockData.dashboardKpis);
});

final adminStudentsProvider = FutureProvider<List<MockStudent>>((ref) async {
  ref.watch(dataSyncProvider);
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.students;
});

/// Staff list with add support. Used by WebStaffScreen and admin team roster.
final adminStaffProvider = Provider<AsyncValue<List<MockStaffMember>>>((ref) {
  return ref.watch(staffNotifierProvider);
});

final adminNoticesProvider = FutureProvider<List<MockNotice>>((ref) async {
  ref.watch(dataSyncProvider);
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.notices;
});

// Approvals mock
class MockApproval {
  const MockApproval({
    required this.id,
    required this.type,
    required this.requestedBy,
    required this.details,
    required this.date,
    required this.status,
  });
  final String id;
  final String type;
  final String requestedBy;
  final String details;
  final DateTime date;
  final String status;
}

final adminApprovalsProvider = FutureProvider<List<MockApproval>>((ref) async {
  ref.watch(dataSyncProvider);
  await Future.delayed(const Duration(milliseconds: 150));
  return [];
});
