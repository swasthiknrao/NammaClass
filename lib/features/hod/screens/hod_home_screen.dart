import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../routing/app_routes.dart';

/// Mobile-first department dashboard for HOD — department-focused layout
/// with staff, leave approvals, and class-wise student metrics.
class HodHomeScreen extends ConsumerWidget {
  const HodHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final students = MockData.students;
    final classes = students.map((s) => s.classSection).toSet().toList()
      ..sort();
    final deptStaff = MockData.staff.where(
      (s) => s.department == MockData.hodDepartment,
    );
    final leaveRequests = MockData.staffLeaveRequests
        .where(
          (l) =>
              l.department == MockData.hodDepartment && l.status == 'pending',
        )
        .toList();
    final presentToday = (students.length * 0.92).round();
    final today = _dayName();
    final periods = MockData.timetable[today] ?? [];
    final classCounts = _countByClass(students, classes);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          if (ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar != true)
            SliverAppBar(
              expandedHeight: 110,
              floating: true,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text(
                'Department',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(Icons.more_horiz, color: AppColors.textSecondary),
                  onPressed: () {},
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Colors.white,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.md,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${user?.name ?? 'HOD'} • ${MockData.hodDepartment}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            AppConstants.schoolName,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Horizontal stat chips (different from Exam Controller)
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _HodStatChip(
                          '${students.length}',
                          'Students',
                          Icons.people,
                          AppColors.teal,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _HodStatChip(
                          '$presentToday',
                          'Present',
                          Icons.check_circle,
                          AppColors.success,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _HodStatChip(
                          '${deptStaff.length}',
                          'Dept Staff',
                          Icons.badge,
                          AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _HodStatChip(
                          '${leaveRequests.length}',
                          'Leave Pending',
                          Icons.pending_actions,
                          leaveRequests.isEmpty
                              ? AppColors.textSecondary
                              : AppColors.warning,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Pending leave approvals (HOD-specific)
                  if (leaveRequests.isNotEmpty) ...[
                    _SectionHeader(
                      'Leave Approvals',
                      onSeeAll: () => context.go(AppRoutes.adminApprovals),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...leaveRequests
                        .take(2)
                        .map(
                          (l) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _LeaveRequestCard(leave: l),
                          ),
                        ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Students by class — bar style
                  _SectionHeader('Students by Class', onSeeAll: null),
                  const SizedBox(height: AppSpacing.sm),
                  NcCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: classes.take(6).map((c) {
                        final count = classCounts[c] ?? 0;
                        final maxCount = classCounts.values.isEmpty
                            ? 1
                            : classCounts.values.reduce(
                                (a, b) => a > b ? a : b,
                              );
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 56,
                                child: Text(
                                  c,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: count / maxCount,
                                    minHeight: 20,
                                    backgroundColor: AppColors.teal.withValues(
                                      alpha: 0.15,
                                    ),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      c == classes.first
                                          ? AppColors.teal
                                          : AppColors.teal.withValues(
                                              alpha: 0.6,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                '$count',
                                style: AppTypography.labelMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Today's schedule
                  _SectionHeader(
                    'Today\'s Schedule',
                    onSeeAll: () => context.go(AppRoutes.webTimetable),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (periods.isEmpty)
                    NcCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Center(
                        child: Text(
                          'No classes today',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    ...periods
                        .take(4)
                        .map(
                          (p) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _ScheduleCard(
                              time: p.startTime,
                              title: p.subject,
                              duration: '45 min',
                              location: p.teacher,
                            ),
                          ),
                        ),
                  const SizedBox(height: AppSpacing.lg),

                  // Quick actions — department-focused
                  _SectionHeader('Quick Actions', onSeeAll: null),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.table_chart,
                          label: 'Timetable',
                          onTap: () => context.go(AppRoutes.webTimetable),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.grade,
                          label: 'Marks Entry',
                          onTap: () => context.go(AppRoutes.webMarksEntry),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (leaveRequests.isNotEmpty)
                    _ActionCard(
                      icon: Icons.approval,
                      label: 'Approve Leave',
                      onTap: () => context.go(AppRoutes.adminApprovals),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  NcCard(
                    child: InkWell(
                      onTap: () => context.go(AppRoutes.webTimetable),
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.teal.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.sm,
                                ),
                              ),
                              child: Icon(
                                Icons.calendar_view_week,
                                color: AppColors.teal,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Full Department Timetable',
                                    style: AppTypography.labelMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'View complete schedule on web',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _countByClass(List<dynamic> students, List<String> classes) {
    final m = <String, int>{};
    for (final c in classes) {
      m[c] = students.where((s) => s.classSection == c).length;
    }
    return m;
  }

  String _dayName() {
    const days = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[DateTime.now().weekday];
  }
}

class _HodStatChip extends StatelessWidget {
  const _HodStatChip(this.value, this.label, this.icon, this.color);

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      child: SizedBox(
        width: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaveRequestCard extends StatelessWidget {
  const _LeaveRequestCard({required this.leave});

  final MockStaffLeaveRequest leave;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppSpacing.sm),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leave.staffName,
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${leave.type} • ${leave.workingDays} day(s)',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${AppFormatters.formatDate(leave.fromDate)} – ${AppFormatters.formatDate(leave.toDate)}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, {this.onSeeAll});
  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (onSeeAll != null)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSeeAll,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 14, color: AppColors.teal),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.time,
    required this.title,
    required this.duration,
    required this.location,
  });
  final String time;
  final String title;
  final String duration;
  final String location;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppSpacing.sm),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Text(
                      time,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$duration • $location',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
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
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.teal, size: 24),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  label,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
