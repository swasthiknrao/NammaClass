import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/shell_layout_scope.dart';

class SchoolEventsScreen extends ConsumerStatefulWidget {
  const SchoolEventsScreen({super.key});

  @override
  ConsumerState<SchoolEventsScreen> createState() => _SchoolEventsScreenState();
}

class _SchoolEventsScreenState extends ConsumerState<SchoolEventsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Set<String> _rsvpedIds = {};

  static Color _eventColor(String type) {
    switch (type) {
      case 'holiday':
        return AppColors.deepPurple;
      case 'sports':
        return AppColors.success;
      case 'pta':
        return AppColors.teal;
      case 'academic':
        return AppColors.primary;
      default:
        return AppColors.accent;
    }
  }

  List<MockEvent> _eventsForDay(DateTime day) {
    return MockData.events.where((e) => isSameDay(e.date, day)).toList();
  }

  List<MockEvent> get _selectedEvents {
    if (_selectedDay == null) return [];
    return _eventsForDay(_selectedDay!);
  }

  List<MockEvent> get _upcomingEvents {
    final now = DateTime.now();
    return MockData.events.where((e) => e.date.isAfter(now)).take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(title: const Text('Events & Calendar')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upcoming events strip
            SizedBox(
              height: 90,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: _upcomingEvents.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final e = _upcomingEvents[i];
                  final daysUntil = e.date.difference(DateTime.now()).inDays;
                  return Container(
                    width: 140,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: _eventColor(e.type).withValues(alpha: 0.1),
                      border: Border.all(
                        color: _eventColor(e.type).withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _eventColor(e.type),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$daysUntil days',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          e.title,
                          style: AppTypography.labelSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Calendar
            TableCalendar<MockEvent>(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _eventsForDay,
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.teal,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: AppTypography.titleMedium,
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return null;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: events.take(3).map((e) {
                      return Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: _eventColor(e.type),
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            // Events for selected day
            if (_selectedDay != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xs,
                ),
                child: Text(
                  AppFormatters.shortDate(_selectedDay!),
                  style: AppTypography.titleMedium,
                ),
              ),
              if (_selectedEvents.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(child: Text('No events on this day')),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: _selectedEvents.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, i) => _EventTile(
                    event: _selectedEvents[i],
                    isRsvped: _rsvpedIds.contains(_selectedEvents[i].id),
                    onRsvp: () {
                      setState(() {
                        if (_rsvpedIds.contains(_selectedEvents[i].id)) {
                          _rsvpedIds.remove(_selectedEvents[i].id);
                        } else {
                          _rsvpedIds.add(_selectedEvents[i].id);
                        }
                      });
                    },
                  ),
                ),
            ],
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({
    required this.event,
    required this.isRsvped,
    required this.onRsvp,
  });
  final MockEvent event;
  final bool isRsvped;
  final VoidCallback onRsvp;

  @override
  Widget build(BuildContext context) {
    final color = _SchoolEventsScreenState._eventColor(event.type);
    return NcCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(event.title, style: AppTypography.titleSmall),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        event.type,
                        style: TextStyle(color: color, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                if (event.venue.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        event.venue,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
                if (event.requiresRsvp) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Text(
                        '${event.rsvpCount + (isRsvped ? 1 : 0)} attending',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      FilledButton.tonal(
                        onPressed: onRsvp,
                        style: FilledButton.styleFrom(
                          backgroundColor: isRsvped
                              ? AppColors.success.withValues(alpha: 0.15)
                              : AppColors.accent.withValues(alpha: 0.15),
                          foregroundColor: isRsvped
                              ? AppColors.success
                              : AppColors.accent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          isRsvped ? 'RSVPed ✓' : 'RSVP',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
