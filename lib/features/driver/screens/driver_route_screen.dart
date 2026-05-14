import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/providers/data_sync_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/launch_utils.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/driver_provider.dart';
import '../widgets/driver_portal_bar_actions.dart';
import '../widgets/driver_sos_dialog.dart';

class DriverRouteScreen extends ConsumerStatefulWidget {
  const DriverRouteScreen({super.key});

  @override
  ConsumerState<DriverRouteScreen> createState() => _DriverRouteScreenState();
}

class _DriverRouteScreenState extends ConsumerState<DriverRouteScreen> {
  int _visitedCount(List<MockBusStop> stops) =>
      stops.where((s) => s.isVisited).length;

  void _syncNextStop() {
    final stops = MockData.busStops;
    String nextLabel;
    if (stops.every((s) => s.isVisited)) {
      nextLabel = 'Route complete';
    } else {
      final n = stops.firstWhere((s) => !s.isVisited);
      nextLabel = n.name;
    }
    MockData.mergeBusInfo({'nextStop': nextLabel});
    ref.read(dataSyncProvider.notifier).bump();
  }

  void _toggleVisited(MockBusStop stop) {
    setState(() => stop.isVisited = !stop.isVisited);
    _syncNextStop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stops = ref.watch(driverBusStopsProvider);
    final bus = ref.watch(driverBusInfoProvider);
    final routeTitle = bus['route']?.toString() ?? l10n.driverRouteTitle;
    final tripActive = bus['trip_active'] == true;

    final total = stops.length;
    final visited = _visitedCount(stops);
    final progress = total == 0 ? 0.0 : visited / total;

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(
              title: Text(
                routeTitle,
                style: AppTypography.titleMedium.copyWith(color: Colors.white),
              ),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              actions: [
                const DriverPortalBarActions(),
                TextButton.icon(
                  onPressed: () => showDriverSosDialog(context, ref),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  icon: const Icon(Icons.emergency, size: 18),
                  label: Text(
                    l10n.driverSosShort,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.sizeOf(context).height * 0.35,
            color: const Color(0xFFE8EDF0),
            child: CustomPaint(
              painter: _RoutePainter(stops),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.map, size: 48, color: AppColors.primary),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.driverLiveRouteMap,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      l10n.driverGpsTrackingActive,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            color: AppColors.card,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      total == 0
                          ? l10n.driverNoStopsOnRoute
                          : l10n.driverProgressStops(visited, total),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      total == 0
                          ? '—'
                          : l10n.driverProgressPercent(
                              (progress * 100).round(),
                            ),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: total == 0 ? 0.0 : progress,
                  backgroundColor: AppColors.divider,
                  color: AppColors.teal,
                ),
              ],
            ),
          ),
          Container(
            color: AppColors.card,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      final next = !tripActive;
                      MockData.mergeBusInfo({'trip_active': next});
                      ref.read(dataSyncProvider.notifier).bump();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            next
                                ? l10n.driverTripStartedSnack
                                : l10n.driverTripEndedSnack,
                          ),
                          backgroundColor: next
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: tripActive
                          ? AppColors.error
                          : AppColors.success,
                    ),
                    icon: Icon(tripActive ? Icons.stop : Icons.play_arrow),
                    label: Text(
                      tripActive ? l10n.driverEndTrip : l10n.driverStartTrip,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: stops.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.alt_route_rounded,
                            size: 56,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.45,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            l10n.driverNoRouteStopsYet,
                            style: AppTypography.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            l10n.driverNoRouteStopsBody,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : DraggableScrollableSheet(
                    initialChildSize: 1.0,
                    minChildSize: 0.5,
                    maxChildSize: 1.0,
                    builder: (ctx, scrollCtrl) => ListView.separated(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: stops.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.xs),
                      itemBuilder: (_, i) => _StopTile(
                        stop: stops[i],
                        index: i + 1,
                        l10n: l10n,
                        onToggleVisited: () => _toggleVisited(stops[i]),
                        onOpenMaps: stops[i].lat != null && stops[i].lng != null
                            ? () => launchMapsGeo(
                                context,
                                latitude: stops[i].lat!,
                                longitude: stops[i].lng!,
                              )
                            : null,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StopTile extends StatelessWidget {
  const _StopTile({
    required this.stop,
    required this.index,
    required this.l10n,
    required this.onToggleVisited,
    this.onOpenMaps,
  });
  final MockBusStop stop;
  final int index;
  final AppLocalizations l10n;
  final VoidCallback onToggleVisited;
  final VoidCallback? onOpenMaps;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      color: stop.isVisited ? AppColors.success.withValues(alpha: 0.05) : null,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: stop.isVisited ? AppColors.success : AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: stop.isVisited
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stop.name, style: AppTypography.labelMedium),
                Text(
                  l10n.driverStopEtaStudents(stop.eta, stop.studentCount),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!stop.isVisited) ...[
            if (onOpenMaps != null)
              IconButton(
                tooltip: l10n.driverOpenInMaps,
                onPressed: onOpenMaps,
                icon: const Icon(Icons.map_outlined, color: AppColors.teal),
              ),
            TextButton(
              onPressed: onToggleVisited,
              child: Text(l10n.driverMarkArrived),
            ),
          ] else
            const Icon(Icons.check_circle, color: AppColors.success),
        ],
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  _RoutePainter(this.stops);
  final List<MockBusStop> stops;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.4)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()..style = PaintingStyle.fill;

    if (stops.isEmpty) return;
    final spacing = size.width / (stops.length + 1);
    final points = List.generate(
      stops.length,
      (i) => Offset(spacing * (i + 1), size.height * 0.5),
    );

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }

    for (int i = 0; i < points.length; i++) {
      dotPaint.color = stops[i].isVisited
          ? AppColors.success
          : AppColors.primary;
      canvas.drawCircle(points[i], 8, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_RoutePainter oldDelegate) => true;
}
