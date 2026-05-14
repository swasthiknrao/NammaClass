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
import '../providers/driver_provider.dart';
import '../widgets/driver_portal_bar_actions.dart';

class DriverVehicleChecklistScreen extends ConsumerWidget {
  const DriverVehicleChecklistScreen({super.key});

  String _label(AppLocalizations l10n, String key) {
    switch (key) {
      case 'tyres':
        return l10n.driverChecklistTyres;
      case 'lights':
        return l10n.driverChecklistLights;
      case 'brakes':
        return l10n.driverChecklistBrakes;
      case 'mirrors':
        return l10n.driverChecklistMirrors;
      case 'fire_extinguisher':
        return l10n.driverChecklistFireExtinguisher;
      case 'first_aid':
        return l10n.driverChecklistFirstAid;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(driverVehicleChecklistProvider);
    final keys = items.keys.toList()..sort();

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(
              title: Text(l10n.driverVehicleChecklistTitle),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              actions: const [
                DriverPortalBarActions(),
                SizedBox(width: AppSpacing.sm),
              ],
            ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            l10n.driverVehicleChecklistIntro,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...keys.map(
            (k) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: NcCard(
                child: CheckboxListTile(
                  value: items[k] ?? false,
                  onChanged: (v) {
                    MockData.setDriverVehicleChecklistItem(k, v ?? false);
                    ref.read(dataSyncProvider.notifier).bump();
                  },
                  title: Text(_label(l10n, k)),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
