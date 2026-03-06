import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../theme/app_spacing.dart';

/// Breakpoint derived from screen width.
enum Breakpoint {
  xs,
  sm,
  md,
  lg,
  xl,
}

/// Extension on BuildContext for theme, media, and responsive helpers.
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  Breakpoint get breakpoint {
    final w = screenWidth;
    if (w >= AppConfig.breakpointXl) return Breakpoint.xl;
    if (w >= AppConfig.breakpointLg) return Breakpoint.lg;
    if (w >= AppConfig.breakpointMd) return Breakpoint.md;
    if (w >= AppConfig.breakpointSm) return Breakpoint.sm;
    return Breakpoint.xs;
  }

  bool get isMobile => breakpoint == Breakpoint.xs || breakpoint == Breakpoint.sm;
  bool get isTablet => breakpoint == Breakpoint.md;
  bool get isDesktop => breakpoint == Breakpoint.lg || breakpoint == Breakpoint.xl;

  /// Horizontal padding for content (uses AppSpacing).
  EdgeInsets get contentPadding => const EdgeInsets.symmetric(horizontal: AppSpacing.lg);
}
