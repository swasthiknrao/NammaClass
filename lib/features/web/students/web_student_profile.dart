import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_avatar.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';

class WebStudentProfile extends StatelessWidget {
  const WebStudentProfile({super.key, required this.studentId});
  final String studentId;

  @override
  Widget build(BuildContext context) {
    final student = MockData.students.firstWhere(
      (s) => s.id == studentId,
      orElse: () => MockData.students.first,
    );

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left panel — 300px
          SizedBox(
            width: 280,
            child: Column(
              children: [
                NcCard(
                  child: Column(
                    children: [
                      NcAvatar(name: student.name, radius: 48),
                      const SizedBox(height: AppSpacing.sm),
                      Text(student.name, style: AppTypography.headlineMedium),
                      Text(
                        student.classSection,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Roll: ${student.rollNo}',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      NcStatusChip(
                        type: student.feeStatus == 'paid'
                            ? NcChipType.paid
                            : student.feeStatus == 'overdue'
                            ? NcChipType.overdue
                            : NcChipType.pending,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                NcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Parent Info', style: AppTypography.labelLarge),
                      const Divider(),
                      _InfoRow('Parent', student.parentName ?? 'N/A'),
                      _InfoRow('Phone', student.parentPhone ?? 'N/A'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),

          // Right panel — tabbed
          Expanded(
            child: DefaultTabController(
              length: 6,
              child: Column(
                children: [
                  const TabBar(
                    isScrollable: true,
                    tabs: [
                      Tab(text: 'Overview'),
                      Tab(text: 'Attendance'),
                      Tab(text: 'Academics'),
                      Tab(text: 'Fees'),
                      Tab(text: 'Activities'),
                      Tab(text: 'Documents'),
                    ],
                    tabAlignment: TabAlignment.start,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Overview
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: GridView.count(
                            crossAxisCount: 3,
                            childAspectRatio: 2,
                            mainAxisSpacing: AppSpacing.sm,
                            crossAxisSpacing: AppSpacing.sm,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _StatCard(
                                'Attendance',
                                '${(student.attendancePercent * 100).round()}%',
                                AppColors.success,
                              ),
                              _StatCard(
                                'Fee Status',
                                student.feeStatus.toUpperCase(),
                                student.feeStatus == 'paid'
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                              _StatCard('Books Issued', '2', AppColors.teal),
                              _StatCard('Homework Due', '3', AppColors.warning),
                              _StatCard(
                                'Class Rank',
                                '#${(student.rollNo.hashCode % 20) + 1}',
                                AppColors.primary,
                              ),
                              _StatCard(
                                'Days Present',
                                '${(student.attendancePercent * 180).round()}',
                                AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                        // Placeholder tabs
                        ...List.generate(
                          5,
                          (i) => const Center(child: Text('Data loading…')),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(value, style: AppTypography.labelMedium),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(color: color),
          ),
          Text(label, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}
