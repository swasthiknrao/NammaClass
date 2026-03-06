import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';

class BusTrackingScreen extends StatelessWidget {
  const BusTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bus = MockData.busInfo;

    return Scaffold(
      appBar: AppBar(title: const Text('Live Bus Tracking')),
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Map placeholder
          CustomPaint(
            size: Size(
              MediaQuery.sizeOf(context).width,
              MediaQuery.sizeOf(context).height * 0.6,
            ),
            painter: _MapPainter(),
          ),

          // Draggable info sheet
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.3,
            maxChildSize: 0.85,
            builder: (ctx, scrollCtrl) => Container(
              decoration: const BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12)],
              ),
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ETA card
                  NcCard(
                    gradient: const LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.directions_bus,
                          color: Colors.white,
                          size: 40,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bus['route'] as String,
                                style: AppTypography.labelLarge.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                bus['busNumber'] as String,
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                'Next: ${bus['nextStop']}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '${bus['etaMinutes']}',
                              style: AppTypography.displayMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'min',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Driver info
                  NcCard(
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppColors.teal,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bus['driverName'] as String,
                                style: AppTypography.labelLarge,
                              ),
                              Text(
                                'Driver',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.call, size: 16),
                          label: const Text('Call'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // SOS
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.emergency),
                    label: const Text('SOS Emergency'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.error,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFE8F4F8);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    // Roads
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.3, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.7, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.7),
      roadPaint,
    );

    // Route polyline
    final routePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final routePath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.2)
      ..cubicTo(
        size.width * 0.1,
        size.height * 0.4,
        size.width * 0.3,
        size.height * 0.4,
        size.width * 0.3,
        size.height * 0.4,
      )
      ..cubicTo(
        size.width * 0.5,
        size.height * 0.4,
        size.width * 0.6,
        size.height * 0.35,
        size.width * 0.7,
        size.height * 0.38,
      )
      ..cubicTo(
        size.width * 0.85,
        size.height * 0.4,
        size.width * 0.9,
        size.height * 0.45,
        size.width * 0.85,
        size.height * 0.55,
      );
    canvas.drawPath(routePath, routePaint);

    // Bus icon
    final busPaint = Paint()..color = AppColors.accent;
    canvas.drawCircle(
      Offset(size.width * 0.55, size.height * 0.39),
      12,
      busPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.55, size.height * 0.39),
      10,
      Paint()..color = Colors.white,
    );

    // Destination marker
    final destPaint = Paint()..color = AppColors.error;
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.55),
      8,
      destPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
