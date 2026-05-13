import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/tenant_profile.dart';

/// Rich mini-app mockup for theme preview.
/// On very wide parents, height grows and width caps so the preview never
/// looks like a crushed ribbon.
class LiveThemePreviewCard extends StatelessWidget {
  const LiveThemePreviewCard({
    super.key,
    required this.profile,
    this.height = 200,
  });

  final TenantProfile profile;

  /// Minimum / baseline height; actual height may be larger on wide layouts.
  final double height;

  @override
  Widget build(BuildContext context) {
    final primary = Color(profile.primaryColorValue);
    final accent = Color(profile.accentColorValue);
    final tokens = profile.themeTokens;
    final name = profile.institutionName.isEmpty
        ? 'Your College'
        : profile.institutionName;

    final previewTheme = AppTheme.buildLight(
      primary: primary,
      accent: accent,
      tokens: tokens,
    );

    return Theme(
      data: previewTheme,
      child: Builder(
        builder: (ctx) {
          final cs = Theme.of(ctx).colorScheme;
          return LayoutBuilder(
            builder: (context, constraints) {
              final parentW = constraints.maxWidth;
              final isWide = parentW >= 520;
              // Cap width on desktop so the mockup reads like a focused panel.
              final contentW = isWide
                  ? math.min(parentW, 440.0)
                  : parentW.clamp(0.0, double.infinity);
              // Grow height with width so KPI + progress are never paper-thin.
              final layoutH = math.max(
                height,
                math.min(320.0, math.max(200.0, contentW * 0.52)),
              );

              final preview = _LivePreviewInterior(
                layoutH: layoutH,
                contentW: contentW,
                primary: primary,
                accent: accent,
                surface: cs.surface,
                onSurface: cs.onSurface,
                name: name,
              );

              if (!isWide || contentW >= parentW - 1) {
                return SizedBox(
                  width: parentW,
                  height: layoutH,
                  child: preview,
                );
              }

              return SizedBox(
                width: parentW,
                height: layoutH,
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: primary.withValues(alpha: 0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: SizedBox(
                        width: contentW,
                        height: layoutH,
                        child: preview,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _LivePreviewInterior extends StatelessWidget {
  const _LivePreviewInterior({
    required this.layoutH,
    required this.contentW,
    required this.primary,
    required this.accent,
    required this.surface,
    required this.onSurface,
    required this.name,
  });

  final double layoutH;
  final double contentW;
  final Color primary;
  final Color accent;
  final Color surface;
  final Color onSurface;
  final String name;

  @override
  Widget build(BuildContext context) {
    final headerH = layoutH * 0.30;
    final navH = layoutH * 0.14;
    final scale = (layoutH / 200).clamp(0.85, 1.35);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: layoutH,
        width: contentW,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(child: Container(color: surface)),

            // Header gradient
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: headerH,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primary,
                      Color.lerp(primary, accent, 0.55) ?? accent,
                      Color.lerp(accent, primary, 0.25) ?? accent,
                    ],
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: math.min(16, contentW * 0.04),
                  vertical: 8 * scale,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 28 * scale,
                      height: 28 * scale,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'A',
                          style: TextStyle(
                            fontSize: 13 * scale,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8 * scale),
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: 22 * scale,
                      height: 22 * scale,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.notifications_rounded,
                        size: 11 * scale,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // KPI row — overlaps header slightly
            Positioned(
              top: layoutH * 0.18,
              left: AppSpacing.sm,
              right: AppSpacing.sm,
              child: _KpiRow(
                primary: primary,
                accent: accent,
                surface: surface,
                scale: scale,
              ),
            ),

            // Progress + filler above nav
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              top: layoutH * 0.42,
              bottom: navH + 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProgressLine(
                    label: 'Attendance',
                    value: 0.78,
                    valueLabel: '78%',
                    color: primary,
                    onSurface: onSurface,
                    scale: scale,
                  ),
                  SizedBox(height: 10 * scale),
                  _ProgressLine(
                    label: 'Assignments',
                    value: 0.55,
                    valueLabel: '55%',
                    color: accent,
                    onSurface: onSurface,
                    scale: scale,
                  ),
                  const Spacer(),
                  // Decorative mini sparkline (fills dead space on tall/wide layouts)
                  SizedBox(
                    height: 22 * scale,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _SparklinePainter(
                        primary: primary,
                        accent: accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom nav
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: navH,
              child: Container(
                decoration: BoxDecoration(
                  color: surface,
                  border: Border(
                    top: BorderSide(
                      color: primary.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavDot(
                      icon: Icons.dashboard_rounded,
                      active: true,
                      primary: primary,
                      scale: scale,
                    ),
                    _NavDot(
                      icon: Icons.school_rounded,
                      active: false,
                      primary: primary,
                      scale: scale,
                    ),
                    _NavDot(
                      icon: Icons.people_rounded,
                      active: false,
                      primary: primary,
                      scale: scale,
                    ),
                    _NavDot(
                      icon: Icons.settings_rounded,
                      active: false,
                      primary: primary,
                      scale: scale,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({
    required this.label,
    required this.value,
    required this.valueLabel,
    required this.color,
    required this.onSurface,
    required this.scale,
  });

  final String label;
  final double value;
  final String valueLabel;
  final Color color;
  final Color onSurface;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6 * scale,
              height: 6 * scale,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: 5 * scale),
            Text(
              label,
              style: TextStyle(
                fontSize: 9 * scale,
                fontWeight: FontWeight.w600,
                color: onSurface.withValues(alpha: 0.6),
              ),
            ),
            const Spacer(),
            Text(
              valueLabel,
              style: TextStyle(
                fontSize: 9 * scale,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 4 * scale),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: math.max(5, 5 * scale),
          ),
        ),
      ],
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.primary, required this.accent});

  final Color primary;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final pts = <Offset>[
      Offset(0, size.height * 0.75),
      Offset(size.width * 0.15, size.height * 0.45),
      Offset(size.width * 0.3, size.height * 0.6),
      Offset(size.width * 0.45, size.height * 0.25),
      Offset(size.width * 0.6, size.height * 0.4),
      Offset(size.width * 0.75, size.height * 0.15),
      Offset(size.width * 0.88, size.height * 0.35),
      Offset(size.width, size.height * 0.2),
    ];
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [
          primary.withValues(alpha: 0.85),
          accent.withValues(alpha: 0.85),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, paint);
    canvas.drawCircle(pts.last, 3.5, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.primary != primary || old.accent != accent;
}

class _KpiRow extends StatelessWidget {
  const _KpiRow({
    required this.primary,
    required this.accent,
    required this.surface,
    required this.scale,
  });

  final Color primary;
  final Color accent;
  final Color surface;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      (label: 'Students', value: '1.2k', color: primary),
      (label: 'Courses', value: '48', color: accent),
      (label: 'Staff', value: '86', color: Color.lerp(primary, accent, 0.5) ?? primary),
    ];
    final vPad = math.max(10.0, 8 * scale);
    final hPad = math.max(8.0, 6 * scale);
    return Row(
      children: tiles.asMap().entries.map((e) {
        final t = e.value;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              left: e.key == 0 ? 0 : 4,
              right: e.key == tiles.length - 1 ? 0 : 4,
            ),
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(10 + scale),
              boxShadow: [
                BoxShadow(
                  color: t.color.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border(left: BorderSide(color: t.color, width: 3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.value,
                  style: TextStyle(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w800,
                    color: t.color,
                    height: 1,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  t.label,
                  style: TextStyle(
                    fontSize: math.max(8, 8 * scale),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _NavDot extends StatelessWidget {
  const _NavDot({
    required this.icon,
    required this.active,
    required this.primary,
    required this.scale,
  });

  final IconData icon;
  final bool active;
  final Color primary;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14 * scale,
          color: active ? primary : const Color(0xFFBBBBBB),
        ),
        if (active)
          Container(
            margin: EdgeInsets.only(top: 2 * scale),
            width: 4 * scale,
            height: 4 * scale,
            decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
          ),
      ],
    );
  }
}
