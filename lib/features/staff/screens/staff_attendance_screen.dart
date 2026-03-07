import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';
import '../providers/staff_providers.dart';

class StaffAttendanceScreen extends ConsumerStatefulWidget {
  const StaffAttendanceScreen({super.key});

  @override
  ConsumerState<StaffAttendanceScreen> createState() =>
      _StaffAttendanceScreenState();
}

class _StaffAttendanceScreenState extends ConsumerState<StaffAttendanceScreen> {
  bool _isCheckedIn = true;
  bool _isWithinGeofence = true;
  DateTime _focusedDay = DateTime.now();

  Color _statusColor(String status) {
    switch (status) {
      case 'present':
        return AppColors.success;
      case 'absent':
        return AppColors.error;
      case 'leave':
      case 'half_day':
        return AppColors.warning;
      case 'on_duty':
        return AppColors.teal;
      default:
        return AppColors.background;
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceAsync = ref.watch(staffAttendanceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Attendance')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location status
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: _isWithinGeofence
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.xs),
                border: Border.all(
                  color: _isWithinGeofence
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: _isWithinGeofence
                        ? AppColors.success
                        : AppColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    _isWithinGeofence
                        ? '📍 You are within campus'
                        : '📍 You are outside campus boundary',
                    style: AppTypography.bodySmall.copyWith(
                      color: _isWithinGeofence
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Current status card
            NcCard(
              gradient: LinearGradient(
                colors: [AppColors.teal, AppColors.teal.withValues(alpha: 0.7)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isCheckedIn ? 'Checked In ✓' : 'Not Checked In',
                    style: AppTypography.headlineSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  if (_isCheckedIn) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Check-in time: 8:32 AM',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      'Duration: 4h 12m',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.verified,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Location verified',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Late arrival warning
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber,
                    color: AppColors.warning,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'You checked in 12 minutes late today.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Check in/out button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isWithinGeofence
                    ? () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(
                              _isCheckedIn
                                  ? 'Confirm Check Out'
                                  : 'Confirm Check In',
                            ),
                            content: Text(
                              _isCheckedIn
                                  ? 'Checking out at 1:44 PM — confirm?'
                                  : 'Check in now at campus?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  setState(() => _isCheckedIn = !_isCheckedIn);
                                },
                                child: Text(
                                  _isCheckedIn ? 'Check Out' : 'Check In',
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: _isCheckedIn
                      ? AppColors.error
                      : AppColors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: Icon(_isCheckedIn ? Icons.logout : Icons.login),
                label: Text(_isCheckedIn ? 'Check Out' : 'Check In Now'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Monthly calendar
            Text('Monthly Attendance', style: AppTypography.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            attendanceAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const Text('Error loading attendance'),
              data: (days) => TableCalendar<MockStaffAttendanceDay>(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now(),
                focusedDay: _focusedDay,
                eventLoader: (day) =>
                    days.where((d) => isSameDay(d.date, day)).toList(),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (ctx, day, events) {
                    if (events.isEmpty) return null;
                    final status = events.first.status;
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _statusColor(status),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
                onPageChanged: (focused) =>
                    setState(() => _focusedDay = focused),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: AppTypography.titleSmall,
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Summary stats
            Text('This Month', style: AppTypography.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                _StatBox('22', 'Present', AppColors.success),
                _StatBox('1', 'Absent', AppColors.error),
                _StatBox('2', 'On-Duty', AppColors.teal),
                _StatBox('1', 'Half Day', AppColors.warning),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox(this.value, this.label, this.color);
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.xs),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.titleMedium.copyWith(
                color: color,
                fontFamily: 'JetBrainsMono',
              ),
            ),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
