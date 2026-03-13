import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/nc_avatar.dart';
import '../../../core/widgets/nc_async_error.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../routing/app_routes.dart';
import '../providers/student_providers.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  static const _weekdays = [
    '',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final attendanceAsync = ref.watch(studentAttendanceProvider);
    final timetableAsync = ref.watch(studentTimetableProvider);
    final homeworkAsync = ref.watch(studentHomeworkProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.teal, AppColors.primary],
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
                                'Hello, ${(user?.name ?? 'Student').split(' ').first}!',
                                style: AppTypography.headlineMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Class ${user?.classSection ?? '8-A'}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Wallet chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '₹350',
                                style: AppTypography.labelMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        NcAvatar(
                          name: user?.name ?? 'S',
                          radius: 18,
                          showBorder: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => context.go(AppRoutes.notifications),
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Attendance pie
                  Row(
                    children: [
                      // Pie chart
                      attendanceAsync.when(
                        data: (attendance) {
                          final present = attendance
                              .where((a) => a.status == 'present')
                              .length;
                          final total = attendance
                              .where((a) => a.status != 'holiday')
                              .length;
                          final pct = total > 0 ? present / total : 0.0;
                          return Expanded(
                            child: NcCard(
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: PieChart(
                                      PieChartData(
                                        sections: [
                                          PieChartSectionData(
                                            value: pct * 100,
                                            color: AppColors.success,
                                            radius: 12,
                                            title: '',
                                          ),
                                          PieChartSectionData(
                                            value: (1 - pct) * 100,
                                            color: AppColors.background,
                                            radius: 12,
                                            title: '',
                                          ),
                                        ],
                                        centerSpaceRadius: 22,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pct.asPercent,
                                        style: AppTypography.headlineMedium
                                            .copyWith(color: AppColors.success),
                                      ),
                                      Text(
                                        'Attendance',
                                        style: AppTypography.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        loading: () => Expanded(child: NcShimmerStatCard()),
                        error: (e, _) => const SizedBox.shrink(),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: NcCard(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.library_books,
                                color: AppColors.teal,
                                size: 28,
                              ),
                              Text(
                                '2',
                                style: AppTypography.headlineMedium.copyWith(
                                  color: AppColors.teal,
                                ),
                              ),
                              Text('Books Due', style: AppTypography.bodySmall),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Food / Canteen quick access
                  NcCard(
                    onTap: () => context.go(AppRoutes.studentCanteen),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            color: AppColors.success,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Canteen & Food',
                                style: AppTypography.titleSmall,
                              ),
                              Text(
                                'Order meals, view combos, manage subscription',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Food / Canteen quick access
                  NcCard(
                    onTap: () => context.go(AppRoutes.studentCanteen),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            color: AppColors.success,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Canteen & Food',
                                style: AppTypography.titleSmall,
                              ),
                              Text(
                                'Order meals, view combos, manage subscription',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Today's timetable — creative layout + attendance status
                  _TodaysTimetableSection(
                    timetableAsync: timetableAsync,
                    attendanceAsync: attendanceAsync,
                    weekdays: _weekdays,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Homework due card
                  homeworkAsync.when(
                    data: (diary) {
                      final pending = diary
                          .where((d) => !d.completed)
                          .take(2)
                          .toList();
                      if (pending.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Homework Due',
                            style: AppTypography.headlineSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          ...pending.map(
                            (d) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.xs,
                              ),
                              child: NcCard(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 40,
                                      color: d.subject.subjectColor,
                                      margin: const EdgeInsets.only(
                                        right: AppSpacing.sm,
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            d.subject,
                                            style: AppTypography.labelMedium,
                                          ),
                                          Text(
                                            d.homework,
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => NcShimmerCard(),
                    error: (e, _) =>
                        const NcAsyncError(message: 'Unable to load homework'),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Today's Timetable: creative layout + attendance in periods ──────────────────

class _TodaysTimetableSection extends StatelessWidget {
  const _TodaysTimetableSection({
    required this.timetableAsync,
    required this.attendanceAsync,
    required this.weekdays,
  });

  final AsyncValue<Map<String, List<MockPeriod>>> timetableAsync;
  final AsyncValue<List<MockAttendanceDay>> attendanceAsync;
  final List<String> weekdays;

  @override
  Widget build(BuildContext context) {
    return timetableAsync.when(
      loading: () => const NcShimmerCard(),
      error: (_, __) => const SizedBox.shrink(),
      data: (timetable) {
        final now = DateTime.now();
        final todayName = weekdays[now.weekday];
        final periods = timetable[todayName] ?? [];
        if (periods.isEmpty) {
          return NcCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(
                    Icons.event_busy_rounded,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    "No classes scheduled for $todayName",
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.teal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.today_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        todayName,
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Today's schedule",
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            attendanceAsync.when(
              data: (attendanceList) {
                MockAttendanceDay? todayRecord;
                for (final a in attendanceList) {
                  if (a.date.year == now.year &&
                      a.date.month == now.month &&
                      a.date.day == now.day) {
                    todayRecord = a;
                    break;
                  }
                }
                return _TimetablePeriodList(
                  periods: periods,
                  todayRecord: todayRecord,
                  now: now,
                );
              },
              loading: () => _TimetablePeriodList(
                periods: periods,
                todayRecord: null,
                now: now,
              ),
              error: (_, __) => _TimetablePeriodList(
                periods: periods,
                todayRecord: null,
                now: now,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TimetablePeriodList extends StatelessWidget {
  const _TimetablePeriodList({
    required this.periods,
    required this.todayRecord,
    required this.now,
  });

  final List<MockPeriod> periods;
  final MockAttendanceDay? todayRecord;
  final DateTime now;

  bool _isPeriodOver(String endTime) {
    final parts = endTime.split(':');
    if (parts.length < 2) return false;
    final endHour = int.tryParse(parts[0]) ?? 0;
    final endMin = int.tryParse(parts[1]) ?? 0;
    final end = DateTime(now.year, now.month, now.day, endHour, endMin);
    return now.isAfter(end);
  }

  String _periodAttendanceStatus(MockPeriod p) {
    if (todayRecord == null) return 'pending';
    if (todayRecord!.status == 'holiday') return 'holiday';
    if (todayRecord!.status == 'leave') return 'leave';
    if (todayRecord!.status == 'absent') return 'absent';
    if (todayRecord!.status == 'present' &&
        todayRecord!.periods.contains(p.subject)) {
      return 'present';
    }
    return 'absent';
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: periods.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final p = periods[i];
        final status = _periodAttendanceStatus(p);
        final isOver = _isPeriodOver(p.endTime);

        return _PeriodCard(period: p, attendanceStatus: status, isOver: isOver);
      },
    );
  }
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({
    required this.period,
    required this.attendanceStatus,
    required this.isOver,
  });

  final MockPeriod period;
  final String attendanceStatus;
  final bool isOver;

  @override
  Widget build(BuildContext context) {
    final color = period.subject.subjectColor;
    // Attendance status: Present / Absent / Leave / Pending (not "done" — that's separate)
    Color statusBg;
    Color statusFg;
    String statusText;
    IconData statusIcon;

    switch (attendanceStatus) {
      case 'present':
        statusBg = AppColors.successBg;
        statusFg = AppColors.success;
        statusText = 'Present';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'absent':
        statusBg = AppColors.errorBg;
        statusFg = AppColors.error;
        statusText = 'Absent';
        statusIcon = Icons.cancel_rounded;
        break;
      case 'leave':
        statusBg = AppColors.leaveBg;
        statusFg = AppColors.purple;
        statusText = 'Leave';
        statusIcon = Icons.event_busy_rounded;
        break;
      case 'holiday':
        statusBg = AppColors.warningBg;
        statusFg = AppColors.warning;
        statusText = 'Holiday';
        statusIcon = Icons.celebration_rounded;
        break;
      default:
        statusBg = AppColors.background;
        statusFg = AppColors.textSecondary;
        statusText = 'Pending';
        statusIcon = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${period.period}',
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      period.subject,
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        period.subject.subjectCode,
                        style: AppTypography.labelSmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${period.startTime} – ${period.endTime} · ${period.teacher}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Attendance status chip: Present / Absent / Leave / Pending (clear label)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: statusFg.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 14, color: statusFg),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: AppTypography.labelSmall.copyWith(
                    color: statusFg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Separate small "Over" only when period has ended (time, not attendance)
          if (isOver) ...[
            const SizedBox(width: 6),
            Text(
              'Over',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
