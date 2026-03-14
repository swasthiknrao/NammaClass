import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';

class DriverRouteScreen extends ConsumerStatefulWidget {
  const DriverRouteScreen({super.key});

  @override
  ConsumerState<DriverRouteScreen> createState() => _DriverRouteScreenState();
}

class _DriverRouteScreenState extends ConsumerState<DriverRouteScreen> {
  bool _tripStarted = false;
  final List<MockBusStop> _stops = MockData.busStops;

  int get _visitedCount => _stops.where((s) => s.isVisited).length;

  void _markVisited(MockBusStop stop) {
    setState(() => stop.isVisited = !stop.isVisited);
  }

  void _triggerSos() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.error,
        title: const Text(
          '🚨 Send SOS Alert',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will immediately alert the transport manager and principal with your current location.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🚨 SOS alert sent to transport manager!'),
                  backgroundColor: AppColors.error,
                  duration: Duration(seconds: 4),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.error,
            ),
            child: const Text('Send SOS'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Route 3 — Jayanagar',
          style: AppTypography.titleMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // SOS button — ALWAYS visible, cannot be obscured
          TextButton.icon(
            onPressed: _triggerSos,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
      body: Column(
        children: [
          // Map placeholder (CustomPaint)
          Container(
            height: MediaQuery.sizeOf(context).height * 0.35,
            color: const Color(0xFFE8EDF0),
            child: CustomPaint(
              painter: _RoutePainter(_stops),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.map, size: 48, color: AppColors.primary),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Live Route Map',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'GPS tracking active',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Route progress bar
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
                      'Progress: $_visitedCount/${_stops.length} stops',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${(_visitedCount / _stops.length * 100).round()}% complete',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: _visitedCount / _stops.length,
                  backgroundColor: AppColors.divider,
                  color: AppColors.teal,
                ),
              ],
            ),
          ),

          // Start/End trip
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
                      setState(() => _tripStarted = !_tripStarted);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _tripStarted
                                ? 'Trip started — GPS broadcasting'
                                : 'Trip ended. Report submitted.',
                          ),
                          backgroundColor: _tripStarted
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: _tripStarted
                          ? AppColors.error
                          : AppColors.success,
                    ),
                    icon: Icon(_tripStarted ? Icons.stop : Icons.play_arrow),
                    label: Text(_tripStarted ? 'End Trip' : 'Start Trip'),
                  ),
                ),
              ],
            ),
          ),

          // Stop list
          Expanded(
            child: DraggableScrollableSheet(
              initialChildSize: 1.0,
              minChildSize: 0.5,
              maxChildSize: 1.0,
              builder: (ctx, scrollCtrl) => ListView.separated(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: _stops.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.xs),
                itemBuilder: (_, i) => _StopTile(
                  stop: _stops[i],
                  index: i + 1,
                  onMark: () => _markVisited(_stops[i]),
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
    required this.onMark,
  });
  final MockBusStop stop;
  final int index;
  final VoidCallback onMark;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      color: stop.isVisited ? AppColors.success.withValues(alpha: 0.05) : null,
      child: Row(
        children: [
          // Stop number badge
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
                  'ETA: ${stop.eta}  ·  ${stop.studentCount} students',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!stop.isVisited && stop.studentCount > 0)
            ElevatedButton.icon(
              onPressed: onMark,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.navigation, size: 14),
              label: const Text('Navigate', style: TextStyle(fontSize: 12)),
            )
          else if (stop.isVisited)
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
