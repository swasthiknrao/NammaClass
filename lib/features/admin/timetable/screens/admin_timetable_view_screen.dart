import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/portal_capabilities.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/screen_size.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/shell_layout_scope.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/timetable_notifier.dart';
import '../widgets/timetable_week_grid.dart';

class AdminTimetableViewScreen extends ConsumerWidget {
  const AdminTimetableViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);
    final readOnlyInstitutionView = _isTimetableReadOnlyInstitutionView(role);
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
              readOnlyInstitutionView
                  ? 'No classes scheduled yet. Contact your administrator '
                        'to set up the timetable.'
                  : 'No classes yet. Create a class from Timetable (day), '
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
            if (readOnlyInstitutionView) ...[
              _ReadOnlyBanner(),
              const SizedBox(height: AppSpacing.md),
            ],
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
              readOnlyInstitutionView
                  ? 'Period times follow your published timetable. '
                        'Structural changes require an administrator.'
                  : 'Period times follow your Timetable settings.',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  /// Principal (and any role without structure edit): week grid only.
  static bool _isTimetableReadOnlyInstitutionView(UserRole? role) {
    if (role == null) return false;
    final canEdit = PortalCapabilityRegistry.hasCapability(
      role,
      PortalCapability.timetableStructureEdit,
    );
    final canView = PortalCapabilityRegistry.hasCapability(
      role,
      PortalCapability.timetableWeekGridRead,
    );
    return canView && !canEdit;
  }
}

class _ReadOnlyBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.visibility_outlined, color: scheme.primary, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Read-only view — you can review the week grid; '
                'timetable structure is managed by school operations.',
                style: AppTypography.bodySmall.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
