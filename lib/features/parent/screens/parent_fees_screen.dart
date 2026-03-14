import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../providers/parent_providers.dart';

class ParentFeesScreen extends ConsumerWidget {
  const ParentFeesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feesAsync = ref.watch(parentFeesProvider);

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(title: const Text('Fees & Payment')),
      backgroundColor: Colors.transparent,
      body: feesAsync.when(
        loading: () =>
            const Padding(padding: EdgeInsets.all(16), child: NcShimmerList()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (fees) {
          final totalPaise = fees.fold(0, (sum, f) => sum + f.amountPaise);
          final paidPaise = fees
              .where((f) => f.status == 'paid')
              .fold(0, (sum, f) => sum + f.amountPaise);
          final pendingPaise = totalPaise - paidPaise;
          final hasOverdue = fees.any((f) => f.status == 'overdue');

          return Column(
            children: [
              // Balance card
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: NcCard(
                  gradient: LinearGradient(
                    colors: hasOverdue
                        ? [AppColors.error, const Color(0xFFCB4335)]
                        : [AppColors.success, AppColors.teal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Outstanding Balance',
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        AppFormatters.formatPaise(pendingPaise),
                        style: AppTypography.displayMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          _BalanceStat(
                            'Total',
                            AppFormatters.formatPaise(totalPaise),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          _BalanceStat(
                            'Paid',
                            AppFormatters.formatPaise(paidPaise),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Tab bar — Pending / Paid / All
              DefaultTabController(
                length: 3,
                child: Expanded(
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: 'Pending'),
                          Tab(text: 'Paid'),
                          Tab(text: 'All'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _FeeList(
                              fees: fees
                                  .where((f) => f.status != 'paid')
                                  .toList(),
                            ),
                            _FeeList(
                              fees: fees
                                  .where((f) => f.status == 'paid')
                                  .toList(),
                            ),
                            _FeeList(fees: fees),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Pay all footer
              if (pendingPaise > 0)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  color: AppColors.card,
                  child: NcPrimaryButton(
                    label:
                        'Pay All — ${AppFormatters.formatPaise(pendingPaise)}',
                    fullWidth: true,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Payment gateway integration coming soon!',
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  const _BalanceStat(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: Colors.white70),
        ),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}

class _FeeList extends StatelessWidget {
  const _FeeList({required this.fees});
  final List fees;

  @override
  Widget build(BuildContext context) {
    if (fees.isEmpty) {
      return const Center(child: Text('No records'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: fees.length,
      itemBuilder: (ctx, i) {
        final fee = fees[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: NcCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fee.label, style: AppTypography.labelLarge),
                      Text(
                        'Due: ${AppFormatters.formatDate(fee.dueDate)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (fee.paidDate != null)
                        Text(
                          'Paid: ${AppFormatters.formatDate(fee.paidDate!)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppFormatters.formatPaise(fee.amountPaise as int),
                      style: AppTypography.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    NcStatusChip(type: _chipType(fee.status as String)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  NcChipType _chipType(String status) {
    switch (status) {
      case 'paid':
        return NcChipType.paid;
      case 'overdue':
        return NcChipType.overdue;
      default:
        return NcChipType.pending;
    }
  }
}
