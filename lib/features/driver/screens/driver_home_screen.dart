import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/providers/data_sync_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/launch_utils.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../l10n/app_localizations.dart';
import '../../../routing/app_routes.dart';
import '../providers/driver_provider.dart';
import '../widgets/driver_portal_bar_actions.dart';
import '../widgets/driver_sos_dialog.dart';

class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({super.key});

  static String _busTxt(
    Map<String, dynamic> bus,
    String key, {
    String fb = '—',
  }) {
    final v = bus[key];
    if (v == null) return fb;
    final s = v.toString();
    return s.isEmpty ? fb : s;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final bus = ref.watch(driverBusInfoProvider);
    final stops = ref.watch(driverBusStopsProvider);
    MockBusStop? next;
    for (final s in stops) {
      if (!s.isVisited) {
        next = s;
        break;
      }
    }
    final n = next;

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(
              title: Text(l10n.driverHomeTitle),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              actions: [
                const DriverPortalBarActions(),
                TextButton.icon(
                  onPressed: () => showDriverSosDialog(context, ref),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.emergency, size: 18),
                  label: const Text(
                    'SOS',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          NcCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.driverTodaySummary,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(_busTxt(bus, 'route'), style: AppTypography.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  '${l10n.driverBusNumberLabel}: ${_busTxt(bus, 'busNumber')}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 18, color: AppColors.teal),
                    const SizedBox(width: 6),
                    Text(
                      '${l10n.driverMorningStart}: ${_busTxt(bus, 'morning_start')}  ·  '
                      '${l10n.driverEveningStart}: ${_busTxt(bus, 'evening_start')}',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          NcCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.driverNextStopLabel,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.teal,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  n != null ? n.name : l10n.driverNoUpcomingStop,
                  style: AppTypography.titleMedium,
                ),
                if (n != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.driverEtaLabel}: ${n.eta}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (n.lat != null && n.lng != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.tonalIcon(
                        onPressed: () => launchMapsGeo(
                          context,
                          latitude: n.lat!,
                          longitude: n.lng!,
                        ),
                        icon: const Icon(Icons.map_outlined, size: 20),
                        label: Text(l10n.driverOpenInMaps),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          NcCard(
            color: AppColors.warning.withValues(alpha: 0.08),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.wb_cloudy_outlined, color: AppColors.warning),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.driverSafetyTip,
                        style: AppTypography.labelMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _busTxt(
                          bus,
                          'safety_tip',
                          fb: l10n.driverSafetyTipFallback,
                        ),
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
          const SizedBox(height: AppSpacing.md),
          _DelayCard(bus: bus),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile.adaptive(
            value: (bus['share_live_trip'] == true),
            onChanged: (v) {
              MockData.mergeBusInfo({'share_live_trip': v});
              ref.read(dataSyncProvider.notifier).bump();
            },
            title: Text(l10n.driverShareLiveTrip),
            subtitle: Text(
              l10n.driverShareLiveTripSubtitle,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            secondary: const Icon(Icons.location_searching),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.driverQuickLinks,
            style: AppTypography.titleSmall.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            leading: Icon(Icons.map_outlined, color: AppColors.primary),
            title: Text(l10n.driverOpenFullRoute),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(AppRoutes.driverRoute),
          ),
          ListTile(
            leading: Icon(Icons.groups_outlined, color: AppColors.teal),
            title: Text(l10n.driverStudentRoster),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(AppRoutes.driverStudents),
          ),
          ListTile(
            leading: Icon(Icons.history, color: AppColors.deepPurple),
            title: Text(l10n.driverTripHistory),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(AppRoutes.driverTripHistory),
          ),
          ListTile(
            leading: Icon(Icons.fact_check_outlined, color: AppColors.success),
            title: Text(l10n.driverVehicleChecklist),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(AppRoutes.driverVehicleChecklist),
          ),
          ListTile(
            leading: Icon(
              Icons.report_problem_outlined,
              color: AppColors.error,
            ),
            title: Text(l10n.driverIncidentReport),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(AppRoutes.driverIncidentReport),
          ),
          ListTile(
            leading: Icon(Icons.call_outlined, color: AppColors.accent),
            title: Text(l10n.driverCallOffice),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => launchTel(
              context,
              phone: _busTxt(bus, 'transport_office_phone', fb: '08025551234'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DelayCard extends ConsumerStatefulWidget {
  const _DelayCard({required this.bus});
  final Map<String, dynamic> bus;

  @override
  ConsumerState<_DelayCard> createState() => _DelayCardState();
}

class _DelayCardState extends ConsumerState<_DelayCard> {
  double _minutes = 5;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final delay = (widget.bus['delay_minutes'] as num?)?.toInt() ?? 0;

    return NcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timer_outlined, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.driverReportDelay,
                  style: AppTypography.titleSmall,
                ),
              ),
              if (delay > 0)
                Chip(
                  label: Text('+$delay min'),
                  backgroundColor: AppColors.warning.withValues(alpha: 0.2),
                ),
            ],
          ),
          if (delay > 0 &&
              (widget.bus['delay_reason']?.toString().isNotEmpty ?? false))
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${widget.bus['delay_reason']}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          Slider(
            value: _minutes.clamp(1, 60),
            min: 1,
            max: 60,
            divisions: 59,
            label: '${_minutes.round()} min',
            onChanged: (v) => setState(() => _minutes = v),
          ),
          Text(
            l10n.driverDelayMinutesLabel(_minutes.round()),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final mins = _minutes.round();
                final baseEta =
                    (widget.bus['etaMinutes'] as num?)?.toInt() ?? 12;
                MockData.mergeBusInfo({
                  'delay_minutes': mins,
                  'delay_reason': l10n.driverDelayDefaultReason,
                  'etaMinutes': baseEta + mins,
                });
                ref.read(dataSyncProvider.notifier).bump();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.driverDelayUpdatedSnack(mins))),
                );
              },
              child: Text(l10n.driverApplyDelay),
            ),
          ),
        ],
      ),
    );
  }
}
