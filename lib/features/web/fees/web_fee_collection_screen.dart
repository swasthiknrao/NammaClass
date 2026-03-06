import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../features/admin/providers/admin_providers.dart';

class WebFeeCollectionScreen extends ConsumerWidget {
  const WebFeeCollectionScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpisAsync = ref.watch(adminDashboardKpisProvider);
    final studentsAsync = ref.watch(adminStudentsProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary bar
          kpisAsync.when(
            data: (kpis) => Row(
              children: [
                Expanded(
                  child: NcCard(
                    gradient: const LinearGradient(
                      colors: AppColors.successGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Collected',
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          AppFormatters.formatPaise(
                            kpis['feesCollectedPaise'] as int,
                          ),
                          style: AppTypography.displayMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: NcCard(
                    gradient: const LinearGradient(
                      colors: AppColors.errorGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pending',
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          AppFormatters.formatPaise(
                            kpis['feesPendingPaise'] as int,
                          ),
                          style: AppTypography.displayMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: NcCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Collection Rate',
                          style: AppTypography.labelLarge,
                        ),
                        Text(
                          '${kpis['feesCollectedPercent']}%',
                          style: AppTypography.displayMedium.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            loading: () => const SizedBox(height: 80),
            error: (e, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Defaulter table
          Text('Fee Defaulters', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          studentsAsync.when(
            data: (students) {
              final defaulters = students
                  .where((s) => s.feeStatus != 'paid')
                  .toList();
              return NcCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Container(
                      color: AppColors.background,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          _HeaderCell('Student', flex: 3),
                          _HeaderCell('Class', flex: 1),
                          _HeaderCell('Status', flex: 1),
                          _HeaderCell('Action', flex: 1),
                        ],
                      ),
                    ),
                    ...defaulters.map(
                      (s) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                s.name,
                                style: AppTypography.labelMedium,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                s.classSection,
                                style: AppTypography.bodyMedium,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: NcStatusChip(
                                type: s.feeStatus == 'overdue'
                                    ? NcChipType.overdue
                                    : NcChipType.pending,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: NcPrimaryButton(
                                label: 'Collect',
                                onPressed: () {},
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const CircularProgressIndicator.adaptive(),
            error: (e, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label, {this.flex = 1});
  final String label;
  final int flex;
  @override
  Widget build(BuildContext context) => Expanded(
    flex: flex,
    child: Text(
      label,
      style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
    ),
  );
}
