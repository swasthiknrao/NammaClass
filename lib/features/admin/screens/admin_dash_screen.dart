import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/screen_size.dart';
import '../../../core/widgets/nc_async_error.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../core/models/user_model.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../domain/entities/unavailability_request_entry.dart';
import '../../../routing/app_routes.dart';
import '../../teacher/unavailability/providers/unavailability_notifier.dart';
import '../providers/admin_providers.dart';

class AdminDashScreen extends ConsumerWidget {
  const AdminDashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpisAsync = ref.watch(adminDashboardKpisProvider);
    final approvalsAsync = ref.watch(adminApprovalsProvider);
    final studentsAsync = ref.watch(adminStudentsProvider);
    final user = ref.watch(currentUserProvider);
    final isDesktop = ScreenSize.isDesktop(context);
    final isTablet = ScreenSize.isTablet(context);

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(
              title: Text(
                user != null
                    ? 'Hello, ${user.name.split(' ').first}'
                    : 'Dashboard',
              ),
              actions: [
                if (user != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.roleLabel,
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
      backgroundColor: Colors.transparent,
      body: kpisAsync.when(
        loading: () =>
            const Padding(padding: EdgeInsets.all(16), child: NcShimmerList()),
        error: (e, _) =>
            const NcAsyncError(message: 'Unable to load dashboard'),
        data: (kpis) {
          final isPrincipal = user?.role == UserRole.principal;
          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF2F6FA), AppColors.background],
              ),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isDesktop ? AppSpacing.lg : AppSpacing.md,
                AppSpacing.md,
                isDesktop ? AppSpacing.lg : AppSpacing.md,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DashboardHero(
                    userFirstName: user?.name.split(' ').first,
                    isPrincipal: user?.role == UserRole.principal,
                  ),
                  LayoutBuilder(
                    builder: (ctx, constraints) {
                      if (isDesktop) {
                        return GridView.count(
                          crossAxisCount: 4,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: AppSpacing.md,
                          crossAxisSpacing: AppSpacing.md,
                          childAspectRatio: 2.35,
                          children: [
                            _KpiCard(
                              'Students',
                              '${kpis['totalStudents']}',
                              Icons.people_rounded,
                              AppColors.primary,
                              compact: false,
                            ),
                            _KpiCard(
                              'Present',
                              '${kpis['presentToday']}',
                              Icons.check_circle_rounded,
                              AppColors.success,
                              compact: false,
                            ),
                            _KpiCard(
                              'Absent',
                              '${kpis['absentToday']}',
                              Icons.cancel_rounded,
                              AppColors.error,
                              compact: false,
                            ),
                            _KpiCard(
                              'Staff',
                              '${kpis['totalStaff']}',
                              Icons.badge_rounded,
                              AppColors.teal,
                              compact: false,
                            ),
                          ],
                        );
                      }
                      if (isTablet) {
                        return GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: AppSpacing.md,
                          crossAxisSpacing: AppSpacing.md,
                          childAspectRatio: 2.25,
                          children: [
                            _KpiCard(
                              'Students',
                              '${kpis['totalStudents']}',
                              Icons.people_rounded,
                              AppColors.primary,
                              compact: false,
                            ),
                            _KpiCard(
                              'Present',
                              '${kpis['presentToday']}',
                              Icons.check_circle_rounded,
                              AppColors.success,
                              compact: false,
                            ),
                            _KpiCard(
                              'Absent',
                              '${kpis['absentToday']}',
                              Icons.cancel_rounded,
                              AppColors.error,
                              compact: false,
                            ),
                            _KpiCard(
                              'Staff',
                              '${kpis['totalStaff']}',
                              Icons.badge_rounded,
                              AppColors.teal,
                              compact: false,
                            ),
                          ],
                        );
                      }
                      return SizedBox(
                        height: 118,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(bottom: 4),
                          children: [
                            _KpiCard(
                              'Students',
                              '${kpis['totalStudents']}',
                              Icons.people_rounded,
                              AppColors.primary,
                              compact: true,
                            ),
                            _KpiCard(
                              'Present',
                              '${kpis['presentToday']}',
                              Icons.check_circle_rounded,
                              AppColors.success,
                              compact: true,
                            ),
                            _KpiCard(
                              'Absent',
                              '${kpis['absentToday']}',
                              Icons.cancel_rounded,
                              AppColors.error,
                              compact: true,
                            ),
                            _KpiCard(
                              'Staff',
                              '${kpis['totalStaff']}',
                              Icons.badge_rounded,
                              AppColors.teal,
                              compact: true,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  NcCard(
                    elevation: AppElevation.low,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.teal,
                                    AppColors.teal.withValues(alpha: 0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.teal.withValues(
                                      alpha: 0.35,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.grid_view_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                isPrincipal
                                    ? 'Visibility & leadership'
                                    : 'Timetable & roster',
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          isPrincipal
                              ? 'View schedules and team directory (read-only). Guardian contacts and school-wide messages are yours; timetable edits stay with admin.'
                              : 'View and edit class grids, period bells, team roster, and cover requests.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Builder(
                          builder: (ctx) {
                            final pending = ref
                                .watch(unavailabilityNotifierProvider)
                                .where(
                                  (e) =>
                                      e.status == UnavailabilityStatus.pending,
                                )
                                .length;
                            final cross = ScreenSize.isDesktop(ctx)
                                ? 4
                                : (ScreenSize.isTablet(ctx) ? 2 : 2);
                            final hubTiles = <Widget>[
                              _AdminHubTile(
                                icon: Icons.visibility_outlined,
                                label: 'View',
                                hint: 'Read-only grids',
                                color: AppColors.primary,
                                onTap: () =>
                                    context.go(AppRoutes.adminTimetableView),
                              ),
                              if (!isPrincipal) ...[
                                _AdminHubTile(
                                  icon: Icons.view_day_outlined,
                                  label: 'Day builder',
                                  hint: 'Edit by day',
                                  color: AppColors.teal,
                                  onTap: () =>
                                      context.go(AppRoutes.adminTimetableEdit),
                                ),
                                _AdminHubTile(
                                  icon: Icons.schedule_outlined,
                                  label: 'Periods',
                                  hint: 'Bells & days',
                                  color: AppColors.warning,
                                  onTap: () => context.go(
                                    AppRoutes.adminTimetableSettings,
                                  ),
                                ),
                              ],
                              _AdminHubTile(
                                icon: Icons.groups_outlined,
                                label: 'Team roster',
                                hint: isPrincipal
                                    ? 'Directory (no HR edits)'
                                    : 'Onboard & directory',
                                color: AppColors.deepPurple,
                                onTap: () => context.go(AppRoutes.adminFaculty),
                              ),
                              _AdminHubTile(
                                icon: Icons.event_busy_outlined,
                                label: pending > 0
                                    ? 'Cover ($pending)'
                                    : 'Cover',
                                hint: 'Leave approvals',
                                color: AppColors.error,
                                onTap: () => context.go(
                                  AppRoutes.adminUnavailabilityApprovals,
                                ),
                              ),
                              if (isPrincipal) ...[
                                _AdminHubTile(
                                  icon: Icons.campaign_outlined,
                                  label: 'Pulse',
                                  hint: 'Message HOD, parents, staff',
                                  color: AppColors.teal,
                                  onTap: () =>
                                      context.go(AppRoutes.adminBroadcast),
                                ),
                                _AdminHubTile(
                                  icon: Icons.contact_phone_outlined,
                                  label: 'Contacts',
                                  hint: 'Guardian phone & name',
                                  color: AppColors.primary,
                                  onTap: () => context.go(
                                    AppRoutes.principalStudentContacts,
                                  ),
                                ),
                              ],
                            ];
                            return GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: cross,
                              crossAxisSpacing: AppSpacing.md,
                              mainAxisSpacing: AppSpacing.md,
                              childAspectRatio: ScreenSize.isDesktop(ctx)
                                  ? 1.12
                                  : 1.08,
                              children: hubTiles,
                            );
                          },
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
                            Text(
                              'Fee Collection',
                              style: AppTypography.labelLarge,
                            ),
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
                            backgroundColor: Colors.transparent,
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
                    error: (e, _) =>
                        const NcAsyncError(message: 'Unable to load approvals'),
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
                                    bottom: BorderSide(
                                      color: AppColors.background,
                                    ),
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
                                        style: AppTypography.labelMedium
                                            .copyWith(
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
                    error: (e, _) =>
                        const NcAsyncError(message: 'Unable to load activity'),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({this.userFirstName, this.isPrincipal = false});

  final String? userFirstName;
  final bool isPrincipal;

  @override
  Widget build(BuildContext context) {
    final dateLine = DateFormat('EEEE · MMM d, y').format(DateTime.now());
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md + 2,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPrincipal
              ? [
                  AppColors.deepPurple,
                  Color.lerp(AppColors.deepPurple, AppColors.primary, 0.4)!,
                ]
              : [
                  AppColors.primary,
                  Color.lerp(AppColors.primary, AppColors.teal, 0.35)!,
                ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: (isPrincipal ? AppColors.deepPurple : AppColors.primary)
                .withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userFirstName != null && userFirstName!.isNotEmpty
                      ? 'Welcome back, ${userFirstName!}'
                      : (isPrincipal ? 'Principal overview' : 'Admin overview'),
                  style: AppTypography.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateLine,
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isPrincipal) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Leadership lens — visibility and approvals; HR master data stays with admin.',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            ),
            child: Icon(
              isPrincipal
                  ? Icons.workspace_premium_outlined
                  : Icons.dashboard_customize_outlined,
              color: Colors.white.withValues(alpha: 0.95),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminHubTile extends StatelessWidget {
  const _AdminHubTile({
    required this.icon,
    required this.label,
    required this.hint,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String hint;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      elevation: 0,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.14),
                color.withValues(alpha: 0.04),
              ],
            ),
            border: Border.all(color: color.withValues(alpha: 0.22)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.md,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hint,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard(
    this.label,
    this.value,
    this.icon,
    this.color, {
    required this.compact,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final inner = Container(
      margin: EdgeInsets.only(right: compact ? AppSpacing.sm : 0),
      width: compact ? 132 : null,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm : AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: color, size: compact ? 18 : 20),
              ),
              const Spacer(),
            ],
          ),
          SizedBox(height: compact ? 6 : 8),
          Text(
            value,
            style:
                (compact
                        ? AppTypography.headlineSmall
                        : AppTypography.headlineMedium)
                    .copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    return compact ? inner : SizedBox(width: double.infinity, child: inner);
  }
}
