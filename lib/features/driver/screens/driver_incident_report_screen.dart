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

class DriverIncidentReportScreen extends ConsumerStatefulWidget {
  const DriverIncidentReportScreen({super.key});

  @override
  ConsumerState<DriverIncidentReportScreen> createState() =>
      _DriverIncidentReportScreenState();
}

class _DriverIncidentReportScreenState
    extends ConsumerState<DriverIncidentReportScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bus = ref.watch(driverBusInfoProvider);

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(
              title: Text(l10n.driverIncidentReportTitle),
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
          NcCard(
            child: Text(
              l10n.driverIncidentIntro,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _ctrl,
            minLines: 4,
            maxLines: 8,
            decoration: InputDecoration(
              labelText: l10n.driverIncidentHint,
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: () {
              final text = _ctrl.text.trim();
              if (text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.driverIncidentEmpty)),
                );
                return;
              }
              MockData.appendDriverTripHistory({
                'id': 'incident-${DateTime.now().millisecondsSinceEpoch}',
                'date': DateTime.now().toIso8601String(),
                'shift': 'Incident',
                'route': '${bus['route'] ?? '—'}',
                'boarded': 0,
                'total': 0,
                'status': 'Incident: $text',
              });
              ref.read(dataSyncProvider.notifier).bump();
              _ctrl.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.driverIncidentSubmitted),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(l10n.submit),
          ),
        ],
      ),
    );
  }
}
