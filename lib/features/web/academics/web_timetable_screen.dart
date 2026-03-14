import 'package:flutter/material.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';

class WebTimetableScreen extends StatefulWidget {
  const WebTimetableScreen({super.key});

  @override
  State<WebTimetableScreen> createState() => _WebTimetableScreenState();
}

class _WebTimetableScreenState extends State<WebTimetableScreen> {
  bool _viewWeek = true;

  @override
  Widget build(BuildContext context) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    final periods = List.generate(8, (i) => 'Period ${i + 1}');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DropdownButton<String>(
                value: '8-A',
                items: ['8-A', '8-B', '9-A', '9-B', '10-A']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (_) {},
              ),
              const SizedBox(width: AppSpacing.lg),
              // Week / Day toggle
              NcChip(
                label: 'Week',
                selected: _viewWeek,
                onTap: () => setState(() => _viewWeek = true),
              ),
              const SizedBox(width: AppSpacing.xs),
              NcChip(
                label: 'Day',
                selected: !_viewWeek,
                onTap: () => setState(() => _viewWeek = false),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.auto_awesome, size: 16),
                label: const Text('AI Generate'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _viewWeek
              ? _WeekView(days: days, periods: periods)
              : _DayView(days: days, periods: periods),
        ],
      ),
    );
  }
}

class _WeekView extends StatelessWidget {
  const _WeekView({required this.days, required this.periods});

  final List<String> days;
  final List<String> periods;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      padding: EdgeInsets.zero,
      child: Table(
        border: TableBorder.all(color: AppColors.divider, width: 1),
        columnWidths: const {0: FixedColumnWidth(80)},
        children: [
          TableRow(
            decoration: const BoxDecoration(color: AppColors.primary),
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('', style: TextStyle(color: Colors.white)),
              ),
              ...days.map(
                (d) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    d,
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          ...periods.asMap().entries.map(
            (e) => TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    e.value,
                    style: AppTypography.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                ...days.map((day) {
                  final dayPeriods = MockData.timetable[day] ?? [];
                  final period = e.key < dayPeriods.length
                      ? dayPeriods[e.key]
                      : null;
                  return Container(
                    padding: const EdgeInsets.all(8),
                    color: period?.subject.subjectColor.withValues(alpha: 0.08),
                    child: period != null
                        ? Column(
                            children: [
                              Text(
                                period.subject,
                                style: AppTypography.labelSmall.copyWith(
                                  color: period.subject.subjectColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                period.teacher.split(' ').first,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : const Center(
                            child: Text(
                              '—',
                              style: TextStyle(color: AppColors.divider),
                            ),
                          ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayView extends StatelessWidget {
  const _DayView({required this.days, required this.periods});

  final List<String> days;
  final List<String> periods;

  @override
  Widget build(BuildContext context) {
    const weekdays = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final today = DateTime.now();
    final displayDay = weekdays[today.weekday];
    final dayPeriods = MockData.timetable[displayDay] ?? [];

    return NcCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(displayDay, style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          if (dayPeriods.isEmpty)
            Text(
              'No classes scheduled',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            ...dayPeriods.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 48,
                      decoration: BoxDecoration(
                        color: p.subject.subjectColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.subject, style: AppTypography.labelMedium),
                          Text(
                            '${p.startTime} – ${p.endTime} · ${p.teacher}',
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
    );
  }
}
