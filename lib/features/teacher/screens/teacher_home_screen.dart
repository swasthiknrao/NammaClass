import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/screen_size.dart';
import '../../../core/widgets/nc_avatar.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../core/widgets/notification_icon_button.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../routing/app_routes.dart';

class TeacherHomeScreen extends ConsumerWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final today = _dayName();
    final periods = MockData.timetable[today] ?? [];
    final isWide =
        ScreenSize.isDesktop(context) || ScreenSize.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: isWide
          ? _DesktopTeacherHome(user: user, periods: periods, dayName: today)
          : _MobileTeacherHome(user: user, periods: periods),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.teacherAttendance),
        icon: const Icon(Icons.how_to_reg_rounded),
        label: const Text('Mark Attendance'),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  static String _dayName() {
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

// ── Desktop layout ───────────────────────────────────────────────────────────

class _DesktopTeacherHome extends StatelessWidget {
  const _DesktopTeacherHome({
    required this.user,
    required this.periods,
    required this.dayName,
  });
  final dynamic user;
  final List<MockPeriod> periods;
  final String dayName;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero + stats row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _TeacherHeroBanner(user: user, dayName: dayName),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Expanded(
                      child: _TeacherStatCard(
                        'Students',
                        '35',
                        Icons.groups_rounded,
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _TeacherStatCard(
                        'Present',
                        '32',
                        Icons.check_circle_rounded,
                        AppColors.success,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _TeacherStatCard(
                        'Pending HW',
                        '3',
                        Icons.assignment_late_rounded,
                        AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Schedule + tasks row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(
                      'Today\'s Schedule',
                      Icons.calendar_today_rounded,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _DesktopPeriodGrid(periods: periods),
                    const SizedBox(height: AppSpacing.lg),
                    _TaskBanner(
                      icon: Icons.edit_note_rounded,
                      message: '3 diary entries pending for today',
                      actionLabel: 'Fill',
                      color: AppColors.warning,
                      onTap: () => context.go(AppRoutes.teacherDiary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _TaskBanner(
                      icon: Icons.how_to_reg_rounded,
                      message: 'Attendance for Period 1 not marked yet',
                      actionLabel: 'Mark',
                      color: AppColors.error,
                      onTap: () => context.go(AppRoutes.teacherAttendance),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(flex: 1, child: _QuickActionsCard()),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeacherHeroBanner extends StatelessWidget {
  const _TeacherHeroBanner({required this.user, required this.dayName});
  final dynamic user;
  final String dayName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
            AppColors.teal,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Good morning!',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.name ?? 'Teacher',
                  style: AppTypography.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.classSection != null
                      ? 'Class Teacher • ${user!.classSection}'
                      : 'Teacher',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    dayName,
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          NcAvatar(name: user?.name ?? 'T', radius: 28, showBorder: true),
        ],
      ),
    );
  }
}

class _TeacherStatCard extends StatelessWidget {
  const _TeacherStatCard(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, this.icon);
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DesktopPeriodGrid extends StatelessWidget {
  const _DesktopPeriodGrid({required this.periods});
  final List<MockPeriod> periods;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: periods.map((p) {
        final color = p.subject.subjectColor;
        return SizedBox(
          width: 140,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Period ${p.period}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  p.subject,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  p.startTime,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TaskBanner extends StatelessWidget {
  const _TaskBanner({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String message;
  final String actionLabel;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                color.withValues(alpha: 0.12),
                color.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.labelLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Text(
                  actionLabel,
                  style: AppTypography.labelMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.teal.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Quick actions',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _QuickActionTile(
            icon: Icons.how_to_reg_rounded,
            label: 'Mark Attendance',
            onTap: () => context.go(AppRoutes.teacherAttendance),
          ),
          _QuickActionTile(
            icon: Icons.edit_note_rounded,
            label: 'Fill Diary',
            onTap: () => context.go(AppRoutes.teacherDiary),
          ),
          _QuickActionTile(
            icon: Icons.groups_rounded,
            label: 'My Students',
            onTap: () => context.go(AppRoutes.teacherStudents),
          ),
          _QuickActionTile(
            icon: Icons.calendar_month_rounded,
            label: 'Week timetable',
            onTap: () => context.go(AppRoutes.teacherTimetable),
          ),
          _QuickActionTile(
            icon: Icons.event_busy_rounded,
            label: 'Mark unavailable',
            onTap: () => context.go(AppRoutes.teacherUnavailability),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Mobile layout ───────────────────────────────────────────────────────────

class _MobileTeacherHome extends StatelessWidget {
  const _MobileTeacherHome({required this.user, required this.periods});
  final dynamic user;
  final List<MockPeriod> periods;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar != true)
          SliverAppBar(
            expandedHeight: 130,
            floating: true,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good morning!',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                user?.name ?? 'Teacher',
                                style: AppTypography.headlineLarge.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                user?.classSection != null
                                    ? 'Class Teacher — ${user!.classSection}'
                                    : 'Teacher',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                        NcAvatar(
                          name: user?.name ?? 'T',
                          radius: 22,
                          showBorder: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [const NotificationIconButton(iconColor: Colors.white)],
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _StatCard(
                      'Students',
                      '35',
                      Icons.groups_rounded,
                      AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _StatCard(
                      'Present',
                      '32',
                      Icons.check_circle_rounded,
                      AppColors.success,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _StatCard(
                      'Pending HW',
                      '3',
                      Icons.assignment_late_rounded,
                      AppColors.warning,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.go(AppRoutes.teacherTimetable),
                        icon: const Icon(
                          Icons.calendar_month_outlined,
                          size: 18,
                        ),
                        label: const Text('Timetable'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            context.go(AppRoutes.teacherUnavailability),
                        icon: const Icon(Icons.event_busy_outlined, size: 18),
                        label: const Text('Unavailable'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text("Today's Schedule", style: AppTypography.headlineSmall),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: periods.length,
                    itemBuilder: (ctx, i) {
                      final p = periods[i];
                      final color = p.subject.subjectColor;
                      return Container(
                        margin: const EdgeInsets.only(right: AppSpacing.sm),
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        width: 110,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
                            left: BorderSide(color: color, width: 4),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Period ${p.period}',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              p.subject,
                              style: AppTypography.labelMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              p.startTime,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _TaskBanner(
                  icon: Icons.edit_note_rounded,
                  message: '3 diary entries pending for today',
                  actionLabel: 'Fill',
                  color: AppColors.warning,
                  onTap: () => context.go(AppRoutes.teacherDiary),
                ),
                const SizedBox(height: AppSpacing.sm),
                _TaskBanner(
                  icon: Icons.how_to_reg_rounded,
                  message: 'Attendance for Period 1 not marked yet',
                  actionLabel: 'Mark',
                  color: AppColors.error,
                  onTap: () => context.go(AppRoutes.teacherAttendance),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: NcCard(
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.headlineMedium.copyWith(color: color),
            ),
            Text(
              label,
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
