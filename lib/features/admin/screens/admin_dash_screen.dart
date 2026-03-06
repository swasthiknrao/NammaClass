import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../../../routing/app_routes.dart';
import '../providers/admin_providers.dart';

class AdminDashScreen extends ConsumerWidget {
  const AdminDashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpisAsync = ref.watch(adminDashboardKpisProvider);
    final approvalsAsync = ref.watch(adminApprovalsProvider);
    final studentsAsync = ref.watch(adminStudentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      backgroundColor: AppColors.background,
      body: kpisAsync.when(
        loading: () =>
            const Padding(padding: EdgeInsets.all(16), child: NcShimmerList()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (kpis) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KPI horizontal scroll strip
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _KpiCard(
                      'Students',
                      '${kpis['totalStudents']}',
                      Icons.people,
                      AppColors.primary,
                    ),
                    _KpiCard(
                      'Present',
                      '${kpis['presentToday']}',
                      Icons.check_circle,
                      AppColors.success,
                    ),
                    _KpiCard(
                      'Absent',
                      '${kpis['absentToday']}',
                      Icons.cancel,
                      AppColors.error,
                    ),
                    _KpiCard(
                      'Staff',
                      '${kpis['totalStaff']}',
                      Icons.badge,
                      AppColors.teal,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // AI alert card
              NcCard(
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.accent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Insight',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                          Text(
                            'Class 8-A attendance has dropped 12% this week. Consider parent outreach.',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Fee progress
              NcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Fee Collection', style: AppTypography.labelLarge),
                        Text(
                          '${kpis['feesCollectedPercent']}%',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (kpis['feesCollectedPercent'] as num) / 100,
                        backgroundColor: AppColors.background,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.success,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Collected: ${AppFormatters.formatPaise(kpis['feesCollectedPaise'] as int)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                        Text(
                          'Pending: ${AppFormatters.formatPaise(kpis['feesPendingPaise'] as int)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Pending approvals
              approvalsAsync.when(
                data: (approvals) {
                  final pending = approvals
                      .where((a) => a.status == 'pending')
                      .toList();
                  if (pending.isEmpty) return const SizedBox.shrink();
                  return NcCard(
                    onTap: () => context.go(AppRoutes.adminApprovals),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.warningBg,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.pending_actions,
                            color: AppColors.warning,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            '${pending.length} pending approvals',
                            style: AppTypography.labelLarge,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const NcShimmerCard(),
                error: (e, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.md),

              // Class attendance table
              Text(
                'Class Attendance Summary',
                style: AppTypography.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              studentsAsync.when(
                data: (students) {
                  final sections =
                      students.map((s) => s.classSection).toSet().toList()
                        ..sort();
                  return NcCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          color: AppColors.background,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Class',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Students',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Attendance',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...sections.map((sec) {
                          final classStudents = students
                              .where((s) => s.classSection == sec)
                              .toList();
                          final avgAttendance =
                              classStudents.fold(
                                0.0,
                                (sum, s) => sum + s.attendancePercent,
                              ) /
                              classStudents.length;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppColors.background),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    sec,
                                    style: AppTypography.labelMedium,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${classStudents.length}',
                                    style: AppTypography.bodyMedium,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${(avgAttendance * 100).toStringAsFixed(1)}%',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: avgAttendance >= 0.85
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
                loading: () => const NcShimmerCard(),
                error: (e, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      width: 120,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border(bottom: BorderSide(color: color, width: 3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const Spacer(),
            ],
          ),
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
