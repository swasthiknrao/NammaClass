import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_avatar.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../../../features/admin/providers/admin_providers.dart';

class WebStudentsScreen extends ConsumerWidget {
  const WebStudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(adminStudentsProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter bar
          Row(
            children: [
              SizedBox(
                width: 280,
                child: SearchBar(
                  hintText: 'Search students…',
                  leading: const Icon(Icons.search),
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 16),
                  ),
                  backgroundColor: const WidgetStatePropertyAll(AppColors.card),
                  elevation: const WidgetStatePropertyAll(0),
                  side: const WidgetStatePropertyAll(
                    BorderSide(color: AppColors.divider),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ...['All Classes', 'Active', 'Fee Overdue'].map(
                (f) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: NcChip(label: f, selected: f == 'All Classes'),
                ),
              ),
              const Spacer(),
              NcPrimaryButton(
                label: 'Add Student',
                icon: Icons.add,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Data table
          Expanded(
            child: studentsAsync.when(
              loading: () => const NcShimmerList(itemCount: 8),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (students) => NcCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      color: AppColors.background,
                      child: Row(
                        children: [
                          const SizedBox(width: 36),
                          _HeaderCell('Name', flex: 3),
                          _HeaderCell('Roll No', flex: 1),
                          _HeaderCell('Class', flex: 1),
                          _HeaderCell('Attendance', flex: 1),
                          _HeaderCell('Fee Status', flex: 1),
                          _HeaderCell('Actions', flex: 1),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.separated(
                        itemCount: students.length,
                        separatorBuilder: (_, i) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final s = students[i];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            child: Row(
                              children: [
                                Checkbox(value: false, onChanged: (_) {}),
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    children: [
                                      NcAvatar(name: s.name, radius: 16),
                                      const SizedBox(width: AppSpacing.xs),
                                      Expanded(
                                        child: Text(
                                          s.name,
                                          style: AppTypography.labelMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    s.rollNo,
                                    style: AppTypography.bodyMedium,
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
                                  child: Text(
                                    '${(s.attendancePercent * 100).round()}%',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: s.attendancePercent >= 0.85
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: NcStatusChip(
                                    type: s.feeStatus == 'paid'
                                        ? NcChipType.paid
                                        : s.feeStatus == 'overdue'
                                        ? NcChipType.overdue
                                        : NcChipType.pending,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.visibility_outlined,
                                          size: 18,
                                        ),
                                        onPressed: () {},
                                        tooltip: 'View',
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 18,
                                        ),
                                        onPressed: () {},
                                        tooltip: 'Edit',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    // Footer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      color: AppColors.background,
                      child: Row(
                        children: [
                          Text(
                            'Showing ${students.length} students',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {},
                            child: const Text('← Previous'),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Next →'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
