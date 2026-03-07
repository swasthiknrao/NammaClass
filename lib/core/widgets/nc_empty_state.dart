import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'nc_button.dart';

/// Empty state with canvas illustration, Poppins heading, Inter body, optional CTA.
class NcEmptyState extends StatelessWidget {
  const NcEmptyState({
    super.key,
    required this.title,
    this.body,
    this.subtitle,
    this.icon,
    this.illustration = NcIllustration.general,
    this.ctaLabel,
    this.onCta,
  });

  final String title;
  final String? body;

  /// Alias for [body] — used in some screens.
  final String? subtitle;

  /// Optional icon override (unused visually — illustration takes precedence).
  final IconData? icon;
  final NcIllustration illustration;
  final String? ctaLabel;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _IllustrationWidget(type: illustration),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTypography.headlineMedium,
              textAlign: TextAlign.center,
            ),
            if (body != null || subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                body ?? subtitle!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (ctaLabel != null) ...[
              const SizedBox(height: AppSpacing.lg),
              NcPrimaryButton(label: ctaLabel!, onPressed: onCta),
            ],
          ],
        ),
      ),
    );
  }
}

enum NcIllustration {
  general,
  noData,
  noMessages,
  noNotifications,
  success,
  error,
}

class _IllustrationWidget extends StatelessWidget {
  const _IllustrationWidget({required this.type});
  final NcIllustration type;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: CustomPaint(painter: _IllustrationPainter(type: type)),
    );
  }
}

class _IllustrationPainter extends CustomPainter {
  const _IllustrationPainter({required this.type});
  final NcIllustration type;

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = AppColors.primary.withValues(alpha: 0.08);
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      bgPaint,
    );

    final iconPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.28;

    switch (type) {
      case NcIllustration.noMessages:
        _drawChat(canvas, center, r, iconPaint);
      case NcIllustration.noNotifications:
        _drawBell(canvas, center, r, iconPaint);
      case NcIllustration.success:
        _drawCheck(
          canvas,
          center,
          r,
          Paint()..color = AppColors.success.withValues(alpha: 0.5),
        );
      case NcIllustration.error:
        _drawX(
          canvas,
          center,
          r,
          Paint()..color = AppColors.error.withValues(alpha: 0.5),
        );
      default:
        _drawClipboard(canvas, center, r, iconPaint);
    }
  }

  void _drawClipboard(Canvas canvas, Offset center, double r, Paint p) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: r * 1.4, height: r * 1.8),
      const Radius.circular(6),
    );
    canvas.drawRRect(rect, p);
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - r * 0.4 + i * r * 0.35),
          width: r * 0.9,
          height: r * 0.12,
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.8),
      );
    }
  }

  void _drawChat(Canvas canvas, Offset center, double r, Paint p) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy - 4),
            width: r * 1.8,
            height: r * 1.3,
          ),
          const Radius.circular(10),
        ),
      )
      ..moveTo(center.dx - 10, center.dy + r * 0.55)
      ..lineTo(center.dx - 20, center.dy + r * 1.0)
      ..lineTo(center.dx + 5, center.dy + r * 0.55);
    canvas.drawPath(path, p);
  }

  void _drawBell(Canvas canvas, Offset center, double r, Paint p) {
    final path = Path()
      ..moveTo(center.dx, center.dy - r)
      ..cubicTo(
        center.dx + r,
        center.dy - r,
        center.dx + r,
        center.dy + r * 0.3,
        center.dx + r * 0.7,
        center.dy + r * 0.6,
      )
      ..lineTo(center.dx - r * 0.7, center.dy + r * 0.6)
      ..cubicTo(
        center.dx - r,
        center.dy + r * 0.3,
        center.dx - r,
        center.dy - r,
        center.dx,
        center.dy - r,
      );
    canvas.drawPath(path, p);
    canvas.drawCircle(Offset(center.dx, center.dy + r * 0.85), r * 0.2, p);
  }

  void _drawCheck(Canvas canvas, Offset center, double r, Paint p) {
    canvas.drawCircle(center, r, p);
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(center.dx - r * 0.45, center.dy)
      ..lineTo(center.dx - r * 0.1, center.dy + r * 0.4)
      ..lineTo(center.dx + r * 0.5, center.dy - r * 0.35);
    canvas.drawPath(path, linePaint);
  }

  void _drawX(Canvas canvas, Offset center, double r, Paint p) {
    canvas.drawCircle(center, r, p);
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx - r * 0.4, center.dy - r * 0.4),
      Offset(center.dx + r * 0.4, center.dy + r * 0.4),
      linePaint,
    );
    canvas.drawLine(
      Offset(center.dx + r * 0.4, center.dy - r * 0.4),
      Offset(center.dx - r * 0.4, center.dy + r * 0.4),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
