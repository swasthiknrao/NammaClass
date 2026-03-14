import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/theme/app_colors.dart';
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
          final total = attendance.where((a) => a.status != 'holiday').length;
          final pct = total > 0 ? present / total : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats row
                Row(
                  children: [
                    _StatCard('Present', present.toString(), AppColors.success),
                    const SizedBox(width: AppSpacing.sm),
                    _StatCard(
                      'Absent',
                      attendance
                          .where((a) => a.status == 'absent')
                          .length
                          .toString(),
                      AppColors.error,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _StatCard(
                      'Leave',
                      attendance
                          .where((a) => a.status == 'leave')
                          .length
                          .toString(),
                      AppColors.warning,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Attendance % bar
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

                // Calendar
                NcCard(
                  padding: EdgeInsets.zero,
                  child: TableCalendar(
                    firstDay: DateTime.now().subtract(const Duration(days: 90)),
                    lastDay: DateTime.now().add(const Duration(days: 30)),
                    focusedDay: DateTime.now(),
                    calendarFormat: CalendarFormat.month,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Month',
                    },
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (ctx, day, events) {
                        final key = DateTime(day.year, day.month, day.day);
                        final status = eventMap[key];
                        if (status == null) return const SizedBox.shrink();
                        final color = _statusColor(status);
                        return Positioned(
                          bottom: 4,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                    onDaySelected: (selectedDay, _) {
                      final key = DateTime(
                        selectedDay.year,
                        selectedDay.month,
                        selectedDay.day,
                      );
                      final found = attendance
                          .where(
                            (a) =>
                                DateTime(
                                  a.date.year,
                                  a.date.month,
                                  a.date.day,
                                ) ==
                                key,
                          )
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
                                  Text(
                                    a.status.toUpperCase(),
                                    style: AppTypography.labelLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              if (a.periods.isNotEmpty) ...[
                                Text(
                                  'Periods Present:',
                                  style: AppTypography.labelLarge,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Wrap(
                                  spacing: AppSpacing.xs,
                                  runSpacing: AppSpacing.xs,
                                  children: a.periods
                                      .map((p) => NcChip(label: p))
                                      .toList(),
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
                    },
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: AppTypography.headlineSmall,
                    ),
                  ),
                ),
              ],
            ),
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

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: NcCard(
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.headlineLarge.copyWith(color: color),
            ),
            Text(label, style: AppTypography.bodySmall),
          ],
        ),
      ),
    );
  }
}
