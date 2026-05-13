import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_size.dart';
import '../../../routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_bottom_sheet.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../core/widgets/nc_chip.dart';
import '../providers/parent_providers.dart';

class ParentAttendanceScreen extends ConsumerWidget {
  const ParentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(parentAttendanceProvider);
    final isWide =
        ScreenSize.isDesktop(context) || ScreenSize.isTablet(context);

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(title: const Text('Attendance')),
      backgroundColor: Colors.transparent,
      body: attendanceAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (attendance) {
          final eventMap = <DateTime, String>{};
          for (final a in attendance) {
            eventMap[DateTime(a.date.year, a.date.month, a.date.day)] =
                a.status;
          }
          final present = attendance.where((a) => a.status == 'present').length;
          final absent = attendance.where((a) => a.status == 'absent').length;
          final leave = attendance.where((a) => a.status == 'leave').length;
          final total = attendance.where((a) => a.status != 'holiday').length;
          final pct = total > 0 ? present / total : 0.0;
          final child = ref.watch(parentChildProvider);

          return isWide
              ? _DesktopAttendanceLayout(
                  child: child,
                  present: present,
                  absent: absent,
                  leave: leave,
                  total: total,
                  pct: pct,
                  attendance: attendance,
                  eventMap: eventMap,
                  onDaySelected: (day) =>
                      _showDayDetails(context, attendance, day),
                  statusColor: _statusColor,
                )
              : _MobileAttendanceLayout(
                  present: present,
                  absent: absent,
                  leave: leave,
                  total: total,
                  pct: pct,
                  attendance: attendance,
                  eventMap: eventMap,
                  onDaySelected: (day) =>
                      _showDayDetails(context, attendance, day),
                  statusColor: _statusColor,
                );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.parentLeaveApply),
        icon: const Icon(Icons.event_busy),
        label: const Text('Apply Leave'),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  void _showDayDetails(
    BuildContext context,
    List<MockAttendanceDay> attendance,
    DateTime selectedDay,
  ) {
    final key = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    final found = attendance
        .where((a) => DateTime(a.date.year, a.date.month, a.date.day) == key)
        .toList();
    if (found.isEmpty) return;
    final a = found.first;
    NcBottomSheet.show(
      context,
      title: 'Period Details',
      initialChildSize: 0.4,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                NcStatusChip(type: _chipType(a.status)),
                const SizedBox(width: AppSpacing.sm),
                Text(a.status.toUpperCase(), style: AppTypography.labelLarge),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (a.periods.isNotEmpty) ...[
              Text('Periods Present:', style: AppTypography.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: a.periods.map((p) => NcChip(label: p)).toList(),
              ),
            ] else
              Text(
                'No period data available.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'present':
        return AppColors.success;
      case 'absent':
        return AppColors.error;
      case 'leave':
        return const Color(0xFF7D3C98);
      case 'holiday':
        return AppColors.warning;
      default:
        return AppColors.divider;
    }
  }

  NcChipType _chipType(String status) {
    switch (status) {
      case 'present':
        return NcChipType.present;
      case 'absent':
        return NcChipType.absent;
      case 'leave':
        return NcChipType.leave;
      default:
        return NcChipType.pending;
    }
  }
}

// ── Desktop layout ─────────────────────────────────────────────────────────────

class _DesktopAttendanceLayout extends StatelessWidget {
  const _DesktopAttendanceLayout({
    required this.child,
    required this.present,
    required this.absent,
    required this.leave,
    required this.total,
    required this.pct,
    required this.attendance,
    required this.eventMap,
    required this.onDaySelected,
    required this.statusColor,
  });
  final MockStudent? child;
  final int present;
  final int absent;
  final int leave;
  final int total;
  final double pct;
  final List<MockAttendanceDay> attendance;
  final Map<DateTime, String> eventMap;
  final ValueChanged<DateTime> onDaySelected;
  final Color Function(String) statusColor;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthName = _monthName(now.month);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hero + stats inline (fill width)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _AttendanceHeroBanner(
                  childName: child?.name ?? '—',
                  classSection: child?.classSection ?? '—',
                  monthYear: '$monthName ${now.year}',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 4,
                child: _DesktopProgressCard(
                  present: present,
                  total: total,
                  pct: pct,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Calendar + legend row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: _AttendanceCalendar(
                  eventMap: eventMap,
                  attendance: attendance,
                  onDaySelected: onDaySelected,
                  statusColor: statusColor,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _WeekInsightCard(attendance: attendance),
                    const SizedBox(height: AppSpacing.md),
                    _AttendanceStreakCard(attendance: attendance),
                    const SizedBox(height: AppSpacing.md),
                    _AttendanceTipCard(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[m - 1];
  }
}

class _AttendanceHeroBanner extends StatelessWidget {
  const _AttendanceHeroBanner({
    required this.childName,
    required this.classSection,
    required this.monthYear,
  });
  final String childName;
  final String classSection;
  final String monthYear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
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
                      'Attendance Overview',
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$childName • $classSection',
                      style: AppTypography.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.date_range_rounded,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          monthYear,
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem(this.color, this.label);
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _WeekInsightCard extends StatelessWidget {
  const _WeekInsightCard({required this.attendance});
  final List<MockAttendanceDay> attendance;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekDays = attendance.where((a) {
      final d = a.date;
      return d.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          d.isBefore(startOfWeek.add(const Duration(days: 7)));
    }).toList();
    final weekPresent = weekDays.where((a) => a.status == 'present').length;
    final weekTotal = weekDays.where((a) => a.status != 'holiday').length;
    final weekPct = weekTotal > 0 ? weekPresent / weekTotal : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.teal.withValues(alpha: 0.06),
            AppColors.teal.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: AppColors.teal,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'This Week',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            weekTotal > 0
                ? '$weekPresent of $weekTotal days present'
                : 'No data this week',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (weekTotal > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: weekPct,
                backgroundColor: AppColors.background,
                valueColor: AlwaysStoppedAnimation<Color>(
                  weekPct >= 0.85 ? AppColors.success : AppColors.teal,
                ),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AttendanceStreakCard extends StatelessWidget {
  const _AttendanceStreakCard({required this.attendance});
  final List<MockAttendanceDay> attendance;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    var streak = 0;
    for (var i = 0; i < 90; i++) {
      final d = now.subtract(Duration(days: i));
      final key = DateTime(d.year, d.month, d.day);
      final days = attendance.where((a) {
        final ad = a.date;
        return DateTime(ad.year, ad.month, ad.day) == key;
      }).toList();
      if (days.isEmpty) break;
      final day = days.first;
      if (day.status == 'holiday') continue;
      if (day.status != 'present') break;
      streak++;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.teal.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak day streak',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Consecutive presents',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceTipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Apply leave in advance for planned absences to keep records clear.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopProgressCard extends StatelessWidget {
  const _DesktopProgressCard({
    required this.present,
    required this.total,
    required this.pct,
  });
  final int present;
  final int total;
  final double pct;

  @override
  Widget build(BuildContext context) {
    final isGood = pct >= 0.85;
    final accentColor = isGood ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.06),
            accentColor.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isGood
                      ? Icons.trending_up_rounded
                      : Icons.warning_amber_rounded,
                  color: accentColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Attendance',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$present out of $total working days',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: accentColor.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(pct * 100).toStringAsFixed(1)}%',
              style: AppTypography.titleMedium.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mobile layout ─────────────────────────────────────────────────────────────

class _MobileAttendanceLayout extends StatelessWidget {
  const _MobileAttendanceLayout({
    required this.present,
    required this.absent,
    required this.leave,
    required this.total,
    required this.pct,
    required this.attendance,
    required this.eventMap,
    required this.onDaySelected,
    required this.statusColor,
  });
  final int present;
  final int absent;
  final int leave;
  final int total;
  final double pct;
  final List<MockAttendanceDay> attendance;
  final Map<DateTime, String> eventMap;
  final ValueChanged<DateTime> onDaySelected;
  final Color Function(String) statusColor;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NcCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Attendance', style: AppTypography.labelLarge),
                    Text(
                      '${(pct * 100).toStringAsFixed(1)}%',
                      style: AppTypography.headlineSmall.copyWith(
                        color: pct >= 0.85
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      pct >= 0.85 ? AppColors.success : AppColors.error,
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '$present out of $total working days',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _AttendanceCalendar(
            eventMap: eventMap,
            attendance: attendance,
            onDaySelected: onDaySelected,
            statusColor: statusColor,
          ),
        ],
      ),
    );
  }
}

// ── Shared calendar ──────────────────────────────────────────────────────────

class _AttendanceCalendar extends StatelessWidget {
  const _AttendanceCalendar({
    required this.eventMap,
    required this.attendance,
    required this.onDaySelected,
    required this.statusColor,
  });
  final Map<DateTime, String> eventMap;
  final List<MockAttendanceDay> attendance;
  final ValueChanged<DateTime> onDaySelected;
  final Color Function(String) statusColor;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthAttendance = attendance
        .where((a) => a.date.year == now.year && a.date.month == now.month)
        .toList();
    final mPresent = monthAttendance.where((a) => a.status == 'present').length;
    final mAbsent = monthAttendance.where((a) => a.status == 'absent').length;
    final mLeave = monthAttendance.where((a) => a.status == 'leave').length;
    final mHoliday = monthAttendance.where((a) => a.status == 'holiday').length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 720;
        final padding = isNarrow ? AppSpacing.md : AppSpacing.lg;

        final calendar = ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 90)),
            lastDay: DateTime.now().add(const Duration(days: 30)),
            focusedDay: DateTime.now(),
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {CalendarFormat.month: 'Month'},
            rowHeight: isNarrow ? 44 : 52,
            daysOfWeekHeight: isNarrow ? 20 : 24,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (ctx, day, events) {
                final key = DateTime(day.year, day.month, day.day);
                final status = eventMap[key];
                if (status == null) return const SizedBox.shrink();
                final color = statusColor(status);
                return Positioned(
                  bottom: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            onDaySelected: (selectedDay, _) => onDaySelected(selectedDay),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle:
                  (isNarrow
                          ? AppTypography.titleMedium
                          : AppTypography.headlineSmall)
                      .copyWith(fontWeight: FontWeight.w700),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: AppColors.primary,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: AppColors.primary,
              ),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        );

        if (isNarrow) {
          return Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: calendar),
                const SizedBox(height: AppSpacing.md),
                _CalendarSidePanel(
                  present: mPresent,
                  absent: mAbsent,
                  leave: mLeave,
                  holiday: mHoliday,
                ),
              ],
            ),
          );
        }

        return SizedBox(
          height: 472,
          child: Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(flex: 1, child: calendar),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _CalendarSidePanel(
                    present: mPresent,
                    absent: mAbsent,
                    leave: mLeave,
                    holiday: mHoliday,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CalendarSidePanel extends StatelessWidget {
  const _CalendarSidePanel({
    required this.present,
    required this.absent,
    required this.leave,
    required this.holiday,
  });
  final int present;
  final int absent;
  final int leave;
  final int holiday;

  @override
  Widget build(BuildContext context) {
    final total = present + absent + leave;
    final pct = total > 0 ? present / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Month snapshot
        Container(
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
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'This Month',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _MiniStatRow(AppColors.success, 'Present', present),
              _MiniStatRow(AppColors.error, 'Absent', absent),
              _MiniStatRow(const Color(0xFF7D3C98), 'Leave', leave),
              _MiniStatRow(AppColors.warning, 'Holiday', holiday),
              if (total > 0) ...[
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      pct >= 0.85 ? AppColors.success : AppColors.teal,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Legend — compact
        Text(
          'Legend',
          style: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _LegendItem(AppColors.success, 'Present'),
            _LegendItem(AppColors.error, 'Absent'),
            _LegendItem(const Color(0xFF7D3C98), 'Leave'),
            _LegendItem(AppColors.warning, 'Holiday'),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // Quick tip
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(Icons.touch_app_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tap a date to view details',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniStatRow extends StatelessWidget {
  const _MiniStatRow(this.color, this.label, this.count);
  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label, style: AppTypography.bodySmall),
          const Spacer(),
          Text(
            count.toString(),
            style: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
