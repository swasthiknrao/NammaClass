import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/screen_size.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/shell_layout_scope.dart';
import '../providers/timetable_notifier.dart';
import '../widgets/timetable_week_grid.dart';

class AdminTimetableViewScreen extends ConsumerWidget {
  const AdminTimetableViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = ref.watch(timetableNotifierProvider);
    if (tt.classSections.isEmpty) {
      return Scaffold(
        appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
            ? null
            : AppBar(title: const Text('Timetable (view)')),
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No classes yet. Create a class from Timetable (day), '
              'then return here for the week grid.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    final grid = tt.gridFor(tt.selectedClassSection);
    final isWide =
        ScreenSize.isDesktop(context) || ScreenSize.isTablet(context);

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(title: const Text('Timetable (view)')),
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Class timetable', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: tt.classSections
                  .map(
                    (c) => ChoiceChip(
                      label: Text(tt.labelForSection(c)),
                      selected: c == tt.selectedClassSection,
                      onSelected: (_) => ref
                          .read(timetableNotifierProvider.notifier)
                          .selectClass(c),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            NcCard(
              padding: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TimetableWeekGrid(
                  dayLabels: TimetableNotifier.dayLabels,
                  periods: tt.periods,
                  grid: grid,
                  periodsPerDay: tt.periodsPerDay,
                  workingWeekdays: tt.workingWeekdays,
                  compact: !isWide,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Period times follow your Timetable settings.',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
