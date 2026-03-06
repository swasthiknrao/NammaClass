import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';

/// Shimmer effect for skeleton loaders.
class _ShimmerPainter extends CustomPainter {
  _ShimmerPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-1.0 + progress * 2, 0),
        end: Alignment(progress * 2, 0),
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.6),
          color.withValues(alpha: 0.3),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter old) => old.progress != progress;
}

/// Single skeleton box (rectangle with optional border radius).
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    final borderRadius =
        widget.borderRadius ?? BorderRadius.circular(AppConfig.radiusSm);
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: borderRadius,
          child: CustomPaint(
            painter: _ShimmerPainter(progress: _animation.value, color: color),
            child: child,
          ),
        );
      },
      child: SizedBox(width: widget.width, height: widget.height),
    );
  }
}
