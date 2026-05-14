import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/providers/data_sync_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/warden_lodge_providers.dart';
import '../widgets/warden_portal_bar_actions.dart';

class WardenNightPatrolScreen extends ConsumerWidget {
  const WardenNightPatrolScreen({super.key});

  String _label(String key, AppLocalizations l10n) {
    switch (key) {
      case 'gates_locked':
        return l10n.wardenPatrolGates;
      case 'mess_kitchen_closed':
        return l10n.wardenPatrolMess;
      case 'fire_panel_ok':
        return l10n.wardenPatrolFire;
      case 'common_area_lights':
        return l10n.wardenPatrolLights;
      case 'silent_hours_announced':
        return l10n.wardenPatrolQuiet;
      case 'first_aid_unlocked':
        return l10n.wardenPatrolFirstAid;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(wardenPatrolChecklistProvider);
    final keys = items.keys.toList()..sort();

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(
              title: Text(l10n.wardenPatrolTitle),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              actions: const [
                WardenPortalBarActions(),
                SizedBox(width: AppSpacing.sm),
              ],
            ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            l10n.wardenPatrolSubtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...keys.map(
            (k) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: NcCard(
                child: SwitchListTile.adaptive(
                  value: items[k] ?? false,
                  onChanged: (v) {
                    MockData.setWardenPatrolItem(k, v);
                    ref.read(dataSyncProvider.notifier).bump();
                  },
                  title: Text(_label(k, l10n)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
