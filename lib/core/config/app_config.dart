/// Central configuration for breakpoints, layout, and feature flags.
/// Change values here to affect the entire app.
class AppConfig {
  AppConfig._();

  // Breakpoints (logical pixels)
  static const double breakpointXs = 0;
  static const double breakpointSm = 600;
  static const double breakpointMd = 900;
  static const double breakpointLg = 1200;
  static const double breakpointXl = 1600;

  /// Max width for content on large screens (web/desktop). Content is centered.
  static const double maxContentWidth = 1400;

  /// Default animation durations in milliseconds.
  static const int animationDurationShort = 150;
  static const int animationDurationMedium = 250;
  static const int animationDurationLong = 350;

  /// Corner radius scale (used with spacing scale for consistency).
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
}
