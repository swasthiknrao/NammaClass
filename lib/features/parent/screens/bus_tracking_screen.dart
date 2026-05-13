import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/providers/data_sync_provider.dart';
import '../../../core/utils/launch_utils.dart';
import '../../../core/utils/screen_size.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/shell_layout_scope.dart';

String _busTxt(Map<String, dynamic> bus, String key, {String fallback = '—'}) {
  final v = bus[key];
  if (v == null) return fallback;
  final s = v.toString();
  return s.isEmpty ? fallback : s;
}

class BusTrackingScreen extends ConsumerWidget {
  const BusTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(dataSyncProvider);
    final bus = MockData.busInfo;
    final isDesktop = ScreenSize.isDesktop(context);

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(title: const Text('Live Bus Tracking')),
      backgroundColor: Colors.transparent,
      body: isDesktop
          ? _DesktopBusLayout(bus: bus)
          : _MobileBusLayout(bus: bus),
    );
  }
}

// ── Desktop: side-by-side layout ───────────────────────────────────────────────

class _DesktopBusLayout extends StatelessWidget {
  const _DesktopBusLayout({required this.bus});
  final Map<String, dynamic> bus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 7, child: _MapArea()),
        Container(
          width: 380,
          decoration: BoxDecoration(
            color: AppColors.card,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(-4, 0),
              ),
            ],
          ),
          child: _InfoCardsPanel(bus: bus),
        ),
      ],
    );
  }
}

class _InfoCardsPanel extends StatelessWidget {
  const _InfoCardsPanel({required this.bus});
  final Map<String, dynamic> bus;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _RouteEtaCard(bus: bus),
        const SizedBox(height: AppSpacing.md),
        _DriverCard(bus: bus),
        const SizedBox(height: AppSpacing.md),
        _SosButton(),
      ],
    );
  }
}

class _RouteEtaCard extends StatelessWidget {
  const _RouteEtaCard({required this.bus});
  final Map<String, dynamic> bus;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF1B4F72), Color(0xFF117A65)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.directions_bus_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _busTxt(bus, 'route'),
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _busTxt(bus, 'busNumber'),
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Next: ${_busTxt(bus, 'nextStop')}',
                            style: AppTypography.labelMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _busTxt(bus, 'etaMinutes', fallback: '—'),
                    style: AppTypography.headlineLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'min',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.bus});
  final Map<String, dynamic> bus;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.teal.withValues(alpha: 0.15),
            child: Text(
              () {
                final n = _busTxt(bus, 'driverName');
                return (n.isEmpty || n == '—') ? '?' : n.substring(0, 1);
              }(),
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.teal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _busTxt(bus, 'driverName'),
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
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
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => launchTel(
                context,
                phone: (bus['driverPhone'] ?? '—').toString(),
                fallbackSnackBar: 'Cannot launch dialer',
              ),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.call_rounded,
                      size: 18,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Call',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SosButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => launchTel(
          context,
          phone: '112',
          fallbackSnackBar: 'Cannot launch emergency dialer',
        ),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.error.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emergency_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'SOS Emergency',
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _MapPainter(),
        );
      },
    );
  }
}

// ── Mobile: draggable bottom sheet ─────────────────────────────────────────────

class _MobileBusLayout extends StatelessWidget {
  const _MobileBusLayout({required this.bus});
  final Map<String, dynamic> bus;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size(
            MediaQuery.sizeOf(context).width,
            MediaQuery.sizeOf(context).height * 0.6,
          ),
          painter: _MapPainter(),
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.45,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          builder: (ctx, scrollCtrl) => Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _RouteEtaCard(bus: bus),
                const SizedBox(height: AppSpacing.md),
                _DriverCard(bus: bus),
                const SizedBox(height: AppSpacing.md),
                _SosButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background gradient
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bgGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [const Color(0xFFE3F2FD), const Color(0xFFE8F5E9)],
    );
    canvas.drawRect(bgRect, Paint()..shader = bgGradient.createShader(bgRect));

    // Subtle grid
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    const gridStep = 40.0;
    for (var x = 0.0; x <= size.width; x += gridStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y <= size.height; y += gridStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Roads
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..strokeWidth = 14
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
      ..color = AppColors.primary.withValues(alpha: 0.9)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
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

    // Bus marker (current location)
    final busCenter = Offset(size.width * 0.55, size.height * 0.39);
    final busOuter = Paint()..color = AppColors.accent.withValues(alpha: 0.3);
    canvas.drawCircle(busCenter, 18, busOuter);
    final busMid = Paint()..color = AppColors.accent;
    canvas.drawCircle(busCenter, 14, busMid);
    final busInner = Paint()..color = Colors.white;
    canvas.drawCircle(busCenter, 10, busInner);

    // Next stop marker (orange ring)
    final nextCenter = Offset(size.width * 0.25, size.height * 0.4);
    final nextRing = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(nextCenter, 12, nextRing);
    final nextFill = Paint()..color = AppColors.accent;
    canvas.drawCircle(nextCenter, 6, nextFill);

    // Destination marker (red)
    final destCenter = Offset(size.width * 0.85, size.height * 0.55);
    final destOuter = Paint()..color = AppColors.error.withValues(alpha: 0.3);
    canvas.drawCircle(destCenter, 14, destOuter);
    final destPaint = Paint()..color = AppColors.error;
    canvas.drawCircle(destCenter, 10, destPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
