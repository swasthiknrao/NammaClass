import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_avatar.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../core/widgets/nc_button.dart';
import '../providers/teacher_providers.dart';

(int, int) _presentAbsentCounts(Map<String, String> records) {
  var present = 0;
  var absent = 0;
  for (final v in records.values) {
    if (v == 'P') present++;
    if (v == 'A') absent++;
  }
  return (present, absent);
}

class AttendanceMarkScreen extends ConsumerWidget {
  const AttendanceMarkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(attendanceMarkProvider.notifier);
    final students = MockData.students
        .where((s) => s.classSection == '8-A')
        .toList();

    final (presentCount, absentCount) = ref.watch(
      attendanceMarkProvider.select((s) => _presentAbsentCounts(s.records)),
    );
    final (saved, isSaving) = ref.watch(
      attendanceMarkProvider.select((s) => (s.saved, s.isSaving)),
    );

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(title: const Text('Mark Attendance')),
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Sticky class/period selector
          Container(
            color: AppColors.card,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: '8-A',
                    decoration: const InputDecoration(
                      labelText: 'Class',
                      isDense: true,
                    ),
                    items: ['8-A', '8-B', '9-A', '9-B']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (_) {},
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: '1',
                    decoration: const InputDecoration(
                      labelText: 'Period',
                      isDense: true,
                    ),
                    items: ['1', '2', '3', '4', '5', '6', '7', '8']
                        .map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text('Period $p'),
                          ),
                        )
                        .toList(),
                    onChanged: (_) {},
                  ),
                ),
              ],
            ),
          ),

          // Mark All Present bar
          Container(
            color: AppColors.successBg,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$presentCount present, $absentCount absent',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => notifier.markAll('P'),
                  child: const Text('Mark All Present'),
                ),
              ],
            ),
          ),

          // Student list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: students.length,
              itemBuilder: (ctx, i) {
                return _AttendanceStudentRow(student: students[i]);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        color: AppColors.card,
        child: saved
            ? const NcPrimaryButton(
                label: '✓ Attendance Saved',
                color: AppColors.success,
              )
            : NcPrimaryButton(
                label: 'Submit Attendance',
                fullWidth: true,
                loading: isSaving,
                onPressed: () => notifier.submit(),
              ),
      ),
    );
  }
}

class _AttendanceStudentRow extends ConsumerWidget {
  const _AttendanceStudentRow({required this.student});

  final MockStudent student;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(
      attendanceMarkProvider.select((s) => s.records[student.id] ?? 'P'),
    );
    final notifier = ref.read(attendanceMarkProvider.notifier);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                student.rollNo,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            NcAvatar(name: student.name, radius: 16),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(student.name, style: AppTypography.labelMedium),
            ),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'P',
                  label: Text('P'),
                  icon: Icon(Icons.check, size: 14),
                ),
                ButtonSegment(
                  value: 'A',
                  label: Text('A'),
                  icon: Icon(Icons.close, size: 14),
                ),
                ButtonSegment(
                  value: 'L',
                  label: Text('L'),
                  icon: Icon(Icons.event_busy, size: 14),
                ),
              ],
              selected: {status},
              onSelectionChanged: (v) => notifier.mark(student.id, v.first),
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
