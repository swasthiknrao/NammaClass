import 'package:flutter/material.dart';

/// Surfaces and accents for timetable admin — aligned with app [ColorScheme]
/// (tenant preset: dark greys + orange accent via [ColorScheme.secondary]).
abstract final class TimetableUiTokens {
  static ColorScheme _scheme(BuildContext context) =>
      Theme.of(context).colorScheme;

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Deepest chrome (page / wells).
  static Color bg(BuildContext context) =>
      _scheme(context).surfaceContainerHighest;

  /// Card / panel surface.
  static Color card(BuildContext context) => _scheme(context).surface;

  /// Inset panel inside a card.
  static Color cardMuted(BuildContext context) {
    final base = card(context);
    final t = _isDark(context) ? 0.14 : 0.06;
    return Color.lerp(base, Colors.black, t) ?? base;
  }

  static Color textPrimary(BuildContext context) => _scheme(context).onSurface;

  static Color textMuted(BuildContext context) =>
      _scheme(context).onSurfaceVariant;

  /// Brand warm accent (default preset: orange).
  static Color accent(BuildContext context) => _scheme(context).secondary;

  /// Primary brand (e.g. navy) — use for paired contrast with accent.
  static Color primary(BuildContext context) => _scheme(context).primary;

  static LinearGradient cardGradient(BuildContext context) {
    final c = card(context);
    final lift = _isDark(context) ? 0.05 : 0.1;
    final depth = _isDark(context) ? 0.12 : 0.04;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(c, Colors.white, lift)!,
        Color.lerp(c, Colors.black, depth)!,
      ],
    );
  }

  static LinearGradient heroGradient(BuildContext context) {
    final a = accent(context);
    final b = bg(context);
    final m = cardMuted(context);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color.lerp(m, a, 0.1)!, Color.lerp(b, a, 0.06)!],
    );
  }

  static BoxDecoration sectionShell(
    BuildContext context, {
    double radius = 18,
  }) {
    final a = accent(context);
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: cardGradient(context),
      border: Border.all(color: a.withValues(alpha: 0.22)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: _isDark(context) ? 0.45 : 0.12),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: a.withValues(alpha: 0.06),
          blurRadius: 0,
          spreadRadius: 0,
          offset: Offset.zero,
        ),
      ],
    );
  }

  static BoxDecoration heroShell(BuildContext context, {double radius = 20}) {
    final a = accent(context);
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: heroGradient(context),
      border: Border.all(color: a.withValues(alpha: 0.25)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: _isDark(context) ? 0.35 : 0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration innerWell(BuildContext context, {double radius = 14}) {
    final a = accent(context);
    return BoxDecoration(
      color: bg(context),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: a.withValues(alpha: 0.14)),
    );
  }

  static ThemeData sliderTheme(BuildContext context) {
    final a = accent(context);
    final t = textMuted(context);
    return Theme.of(context).copyWith(
      sliderTheme: SliderThemeData(
        activeTrackColor: a.withValues(alpha: 0.85),
        inactiveTrackColor: t.withValues(alpha: 0.35),
        thumbColor: a,
        overlayColor: a.withValues(alpha: 0.18),
        trackHeight: 3.5,
        valueIndicatorColor: a,
        showValueIndicator: ShowValueIndicator.onlyForDiscrete,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return Colors.white;
          return t;
        }),
        trackColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) {
            return a.withValues(alpha: 0.45);
          }
          return t.withValues(alpha: 0.15);
        }),
        trackOutlineColor: WidgetStateProperty.all(a.withValues(alpha: 0.35)),
      ),
    );
  }
}
