import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/extensions/context_extensions.dart';

/// Breakpoint enum for layout decisions.
enum LayoutBreakpoint {
  xs,
  sm,
  md,
  lg,
  xl,
}

/// Builds layout based on current breakpoint. Use for responsive UIs.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.builder,
    this.orientation,
  });

  final Widget Function(
    BuildContext context,
    LayoutBreakpoint breakpoint,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) builder;

  /// If set, only rebuild when orientation matches (portrait/landscape).
  final Orientation? orientation;

  static LayoutBreakpoint breakpointForWidth(double width) {
    if (width >= AppConfig.breakpointXl) return LayoutBreakpoint.xl;
    if (width >= AppConfig.breakpointLg) return LayoutBreakpoint.lg;
    if (width >= AppConfig.breakpointMd) return LayoutBreakpoint.md;
    if (width >= AppConfig.breakpointSm) return LayoutBreakpoint.sm;
    return LayoutBreakpoint.xs;
  }

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    final breakpoint = breakpointForWidth(width);
    final isMobile = breakpoint == LayoutBreakpoint.xs || breakpoint == LayoutBreakpoint.sm;
    final isTablet = breakpoint == LayoutBreakpoint.md;
    final isDesktop = breakpoint == LayoutBreakpoint.lg || breakpoint == LayoutBreakpoint.xl;

    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(context, breakpoint, isMobile, isTablet, isDesktop);
      },
    );
  }
}
