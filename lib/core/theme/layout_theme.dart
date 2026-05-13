import 'package:flutter/material.dart';

/// Layout personality driven by the selected theme preset.
/// Consumed via [Theme.of(context).extension<LayoutTheme>()].
///
/// Presets translate to these layout personalities:
///   ocean_blue       → FloatingPill  (current default)
///   forest_green     → Spacious      (wide cards, large radius, extra gaps)
///   crimson_red      → Compact       (dense, straight nav, tight tiles)
///   royal_purple     → Rounded       (pill labels, icon-only rail feel)
///   solar_orange     → Minimal       (flat transparent nav, outlined cards)
///   midnight_steel   → Corporate     (top-style tabs, heavy shadow, bar nav)
class LayoutTheme extends ThemeExtension<LayoutTheme> {
  const LayoutTheme({
    required this.navStyle,
    required this.cardStyle,
    required this.navCornerRadius,
    required this.cardCornerRadius,
    required this.cardElevation,
    required this.cardPaddingH,
    required this.cardPaddingV,
    required this.itemSpacing,
    required this.sectionSpacing,
    required this.showNavLabels,
    required this.navFloating,
    required this.appBarStyle,
    required this.listTilePaddingH,
    required this.listTilePaddingV,
    required this.fabShape,
  });

  /// Bottom-nav presentation style
  final NavStyle navStyle;

  /// Card visual style
  final CardStyle cardStyle;

  /// Corner radius of the bottom nav container
  final double navCornerRadius;

  /// Corner radius for cards (overrides ThemeData.cardTheme per-widget)
  final double cardCornerRadius;

  /// Card elevation
  final double cardElevation;

  /// Horizontal padding inside cards
  final double cardPaddingH;

  /// Vertical padding inside cards
  final double cardPaddingV;

  /// Vertical gap between cards / list items
  final double itemSpacing;

  /// Vertical gap between sections
  final double sectionSpacing;

  /// Whether to show text labels in bottom nav
  final bool showNavLabels;

  /// Whether the bottom nav bar floats (padded, rounded) or is flush
  final bool navFloating;

  /// AppBar gradient style
  final AppBarStyle appBarStyle;

  /// Horizontal padding inside ListTile
  final double listTilePaddingH;

  /// Vertical padding inside ListTile
  final double listTilePaddingV;

  /// FAB shape index (0=circle, 1=rounded square, 2=extended pill)
  final int fabShape;

  // ── Preset factories ────────────────────────────────────────────────────

  static const floatingPill = LayoutTheme(
    navStyle: NavStyle.floatingPill,
    cardStyle: CardStyle.elevated,
    navCornerRadius: 22,
    cardCornerRadius: 14,
    cardElevation: 2,
    cardPaddingH: 16,
    cardPaddingV: 14,
    itemSpacing: 10,
    sectionSpacing: 24,
    showNavLabels: true,
    navFloating: true,
    appBarStyle: AppBarStyle.solid,
    listTilePaddingH: 16,
    listTilePaddingV: 10,
    fabShape: 0,
  );

  static const spacious = LayoutTheme(
    navStyle: NavStyle.floatingPill,
    cardStyle: CardStyle.elevated,
    navCornerRadius: 32,
    cardCornerRadius: 24,
    cardElevation: 3,
    cardPaddingH: 20,
    cardPaddingV: 18,
    itemSpacing: 16,
    sectionSpacing: 32,
    showNavLabels: true,
    navFloating: true,
    appBarStyle: AppBarStyle.gradient,
    listTilePaddingH: 20,
    listTilePaddingV: 14,
    fabShape: 2,
  );

  static const compact = LayoutTheme(
    navStyle: NavStyle.straightBar,
    cardStyle: CardStyle.outlined,
    navCornerRadius: 0,
    cardCornerRadius: 6,
    cardElevation: 0,
    cardPaddingH: 12,
    cardPaddingV: 8,
    itemSpacing: 4,
    sectionSpacing: 14,
    showNavLabels: true,
    navFloating: false,
    appBarStyle: AppBarStyle.solid,
    listTilePaddingH: 12,
    listTilePaddingV: 6,
    fabShape: 1,
  );

  static const rounded = LayoutTheme(
    navStyle: NavStyle.floatingRail,
    cardStyle: CardStyle.elevated,
    navCornerRadius: 40,
    cardCornerRadius: 28,
    cardElevation: 2,
    cardPaddingH: 18,
    cardPaddingV: 14,
    itemSpacing: 12,
    sectionSpacing: 28,
    showNavLabels: false,
    navFloating: true,
    appBarStyle: AppBarStyle.gradient,
    listTilePaddingH: 16,
    listTilePaddingV: 12,
    fabShape: 0,
  );

  static const minimal = LayoutTheme(
    navStyle: NavStyle.transparent,
    cardStyle: CardStyle.outlined,
    navCornerRadius: 16,
    cardCornerRadius: 8,
    cardElevation: 0,
    cardPaddingH: 14,
    cardPaddingV: 12,
    itemSpacing: 8,
    sectionSpacing: 20,
    showNavLabels: true,
    navFloating: false,
    appBarStyle: AppBarStyle.transparent,
    listTilePaddingH: 14,
    listTilePaddingV: 10,
    fabShape: 1,
  );

  static const corporate = LayoutTheme(
    navStyle: NavStyle.tabBar,
    cardStyle: CardStyle.shadow,
    navCornerRadius: 0,
    cardCornerRadius: 10,
    cardElevation: 4,
    cardPaddingH: 16,
    cardPaddingV: 14,
    itemSpacing: 8,
    sectionSpacing: 20,
    showNavLabels: true,
    navFloating: false,
    appBarStyle: AppBarStyle.solid,
    listTilePaddingH: 16,
    listTilePaddingV: 12,
    fabShape: 1,
  );

  // ── Preset lookup ───────────────────────────────────────────────────────

  static const Map<String, LayoutTheme> _byPresetId = {
    'ocean_blue': floatingPill,
    'forest_green': spacious,
    'crimson_red': compact,
    'royal_purple': rounded,
    'solar_orange': minimal,
    'midnight_steel': corporate,
  };

  static LayoutTheme forPreset(String presetId) =>
      _byPresetId[presetId] ?? floatingPill;

  // ── ThemeExtension ──────────────────────────────────────────────────────

  @override
  LayoutTheme copyWith({
    NavStyle? navStyle,
    CardStyle? cardStyle,
    double? navCornerRadius,
    double? cardCornerRadius,
    double? cardElevation,
    double? cardPaddingH,
    double? cardPaddingV,
    double? itemSpacing,
    double? sectionSpacing,
    bool? showNavLabels,
    bool? navFloating,
    AppBarStyle? appBarStyle,
    double? listTilePaddingH,
    double? listTilePaddingV,
    int? fabShape,
  }) => LayoutTheme(
    navStyle: navStyle ?? this.navStyle,
    cardStyle: cardStyle ?? this.cardStyle,
    navCornerRadius: navCornerRadius ?? this.navCornerRadius,
    cardCornerRadius: cardCornerRadius ?? this.cardCornerRadius,
    cardElevation: cardElevation ?? this.cardElevation,
    cardPaddingH: cardPaddingH ?? this.cardPaddingH,
    cardPaddingV: cardPaddingV ?? this.cardPaddingV,
    itemSpacing: itemSpacing ?? this.itemSpacing,
    sectionSpacing: sectionSpacing ?? this.sectionSpacing,
    showNavLabels: showNavLabels ?? this.showNavLabels,
    navFloating: navFloating ?? this.navFloating,
    appBarStyle: appBarStyle ?? this.appBarStyle,
    listTilePaddingH: listTilePaddingH ?? this.listTilePaddingH,
    listTilePaddingV: listTilePaddingV ?? this.listTilePaddingV,
    fabShape: fabShape ?? this.fabShape,
  );

  @override
  LayoutTheme lerp(LayoutTheme? other, double t) {
    if (other == null) return this;
    return LayoutTheme(
      navStyle: t < 0.5 ? navStyle : other.navStyle,
      cardStyle: t < 0.5 ? cardStyle : other.cardStyle,
      navCornerRadius: _blend(navCornerRadius, other.navCornerRadius, t),
      cardCornerRadius: _blend(cardCornerRadius, other.cardCornerRadius, t),
      cardElevation: _blend(cardElevation, other.cardElevation, t),
      cardPaddingH: _blend(cardPaddingH, other.cardPaddingH, t),
      cardPaddingV: _blend(cardPaddingV, other.cardPaddingV, t),
      itemSpacing: _blend(itemSpacing, other.itemSpacing, t),
      sectionSpacing: _blend(sectionSpacing, other.sectionSpacing, t),
      showNavLabels: t < 0.5 ? showNavLabels : other.showNavLabels,
      navFloating: t < 0.5 ? navFloating : other.navFloating,
      appBarStyle: t < 0.5 ? appBarStyle : other.appBarStyle,
      listTilePaddingH: _blend(listTilePaddingH, other.listTilePaddingH, t),
      listTilePaddingV: _blend(listTilePaddingV, other.listTilePaddingV, t),
      fabShape: t < 0.5 ? fabShape : other.fabShape,
    );
  }

  double _blend(double a, double b, double t) => a + (b - a) * t;
}

enum NavStyle {
  floatingPill, // Ocean Blue  — floating rounded container, labels
  floatingRail, // Royal Purple — floating icon-only bar
  straightBar, // Crimson Red  — flush bar at bottom, labels
  transparent, // Solar Orange — no container background
  tabBar, // Midnight Steel — M2-style tab indicators
}

enum CardStyle {
  elevated, // default — shadow + fill
  outlined, // thin border, no shadow
  shadow, // heavy shadow, high elevation
}

enum AppBarStyle {
  solid, // flat primary colour
  gradient, // gradient primary → accent
  transparent, // transparent appbar
}
