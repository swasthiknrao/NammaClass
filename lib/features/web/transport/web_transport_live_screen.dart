import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';

class WebTransportLiveScreen extends ConsumerStatefulWidget {
  const WebTransportLiveScreen({super.key});

  @override
  ConsumerState<WebTransportLiveScreen> createState() =>
      _WebTransportLiveScreenState();
}

class _WebTransportLiveScreenState
    extends ConsumerState<WebTransportLiveScreen> {
  int _selectedBusIndex = 0;

  final _buses = [
    _BusStatus(
      'Route 3',
      'Venkat Reddy',
      'KA-01-MH-2345',
      'Running',
      3,
      6,
      34,
      false,
    ),
    _BusStatus(
      'Route 7',
      'Raju Sharma',
      'KA-01-MB-6789',
      'Delayed',
      5,
      8,
      42,
      false,
    ),
    _BusStatus(
      'Route 12',
      'Mohan Das',
      'KA-01-MC-3456',
      'SOS',
      2,
      10,
      38,
      true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final sosBus = _buses.firstWhere(
      (b) => b.isSos,
      orElse: () => _BusStatus('', '', '', '', 0, 0, 0, false),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SOS alert banner
        if (sosBus.route.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            color: AppColors.error,
            child: Row(
              children: [
                const Icon(Icons.emergency, color: Colors.white),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '🚨 SOS ALERT: ${sosBus.route} (${sosBus.vehicleNo}) | Driver: ${sosBus.driverName} | Tap to acknowledge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(
                      () => _buses.firstWhere((b) => b.isSos).isSos = false,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'SOS acknowledged. Transport team notified.',
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.error,
                  ),
                  child: const Text('Acknowledge'),
                ),
              ],
            ),
          ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Map area (70%)
                Expanded(
                  flex: 7,
                  child: NcCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Live Map', style: AppTypography.titleMedium),
                        const SizedBox(height: AppSpacing.sm),
                        Expanded(
                          child: CustomPaint(
                            painter: _LiveMapPainter(_buses, _selectedBusIndex),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.map,
                                    size: 64,
                                    color: AppColors.primary,
                                  ),
                                  Text(
                                    'Live GPS Map',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Text(
                                    '${_buses.length} buses tracked in real-time',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Legend
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _LegendItem(AppColors.success, 'Morning'),
                            const SizedBox(width: AppSpacing.md),
                            _LegendItem(AppColors.accent, 'Evening'),
                            const SizedBox(width: AppSpacing.md),
                            _LegendItem(AppColors.textSecondary, 'Idle'),
                            const SizedBox(width: AppSpacing.md),
                            _LegendItem(AppColors.error, 'SOS'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Bus list (30%)
                SizedBox(
                  width: 280,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Active Buses', style: AppTypography.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      ..._buses.asMap().entries.map((entry) {
                        final i = entry.key;
                        final bus = entry.value;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedBusIndex = i),
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: _selectedBusIndex == i
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : AppColors.card,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.sm,
                              ),
                              border: Border.all(
                                color: bus.isSos
                                    ? AppColors.error
                                    : (_selectedBusIndex == i
                                          ? AppColors.primary
                                          : AppColors.divider),
                                width: bus.isSos ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.directions_bus,
                                      color: _busColor(bus.status),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        bus.route,
                                        style: AppTypography.labelMedium,
                                      ),
                                    ),
                                    NcChip(
                                      label: bus.status,
                                      color: _busColor(bus.status),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  bus.driverName,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  bus.vehicleNo,
                                  style: AppTypography.bodySmall.copyWith(
                                    fontFamily: 'JetBrainsMono',
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${bus.stopsCompleted}/${bus.totalStops} stops',
                                      style: AppTypography.bodySmall,
                                    ),
                                    Text(
                                      '${bus.students} students',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.teal,
                                      ),
                                    ),
                                  ],
                                ),
                                LinearProgressIndicator(
                                  value: bus.stopsCompleted / bus.totalStops,
                                  backgroundColor: AppColors.divider,
                                  color: _busColor(bus.status),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _busColor(String status) {
    switch (status) {
      case 'Running':
        return AppColors.success;
      case 'Delayed':
        return AppColors.warning;
      case 'SOS':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _BusStatus {
  _BusStatus(
    this.route,
    this.driverName,
    this.vehicleNo,
    this.status,
    this.stopsCompleted,
    this.totalStops,
    this.students,
    this.isSos,
  );
  final String route;
  final String driverName;
  final String vehicleNo;
  final String status;
  final int stopsCompleted;
  final int totalStops;
  final int students;
  bool isSos;
}

class _LegendItem extends StatelessWidget {
  const _LegendItem(this.color, this.label);
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.bodySmall),
      ],
    );
  }
}

class _LiveMapPainter extends CustomPainter {
  _LiveMapPainter(this.buses, this.selectedIndex);
  final List<_BusStatus> buses;
  final int selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < buses.length; i++) {
      final x = size.width * (0.3 + i * 0.2);
      final y = size.height * (0.4 + (i % 2 == 0 ? 0.1 : -0.1));
      paint.color = buses[i].isSos ? AppColors.error : AppColors.success;
      canvas.drawCircle(Offset(x, y), i == selectedIndex ? 16 : 10, paint);
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'R${i + 3}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(x - 8, y - 7));
    }
  }

  @override
  bool shouldRepaint(_LiveMapPainter old) => true;
}
