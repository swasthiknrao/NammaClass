import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/screen_size.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/shell_layout_scope.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../admin/timetable/providers/timetable_notifier.dart';

/// Week view filtered to the signed-in teacher's slots (mock timetable).
class TeacherMyTimetableScreen extends ConsumerWidget {
  const TeacherMyTimetableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final uid = user?.id ?? '';
    final tt = ref.watch(timetableNotifierProvider);
    final isWide =
        ScreenSize.isDesktop(context) || ScreenSize.isTablet(context);

    final rows = <Widget>[];
    for (var d = 0; d < TimetableNotifier.dayLabels.length; d++) {
      final chips = <Widget>[];
      for (final section in tt.classSections) {
        final grid = tt.gridFor(section);
        for (var p = 0; p < tt.periods.length; p++) {
          if (!TimetableNotifier.isPeriodWritable(tt, d, p)) continue;
          final slot = grid[d][p];
          if (slot != null && slot.facultyId == uid) {
            final pd = tt.periods[p];
            chips.add(
              Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 8),
                child: Chip(
                  avatar: Icon(
                    Icons.school,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    '$section · ${pd.label} — ${slot.subject}',
                    style: AppTypography.labelSmall,
                  ),
                ),
              ),
            );
          }
        }
      }
      rows.add(
        NcCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TimetableNotifier.dayLabels[d],
                style: AppTypography.titleSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (chips.isEmpty)
                Text(
                  'No classes',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                )
              else
                Wrap(children: chips),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(title: const Text('My timetable')),
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 960 : double.infinity),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text(
                user != null ? '${user.name} — weekly load' : 'Sign in to view',
                style: AppTypography.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              ...rows,
            ],
          ),
        ),
      ),
    );
  }
}
