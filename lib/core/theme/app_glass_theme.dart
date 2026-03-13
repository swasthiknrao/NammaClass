import 'package:flutter/material.dart';

/// Background gradients for NammaClass app shell.
/// Kept in app_glass_theme for backward compatibility; glass effects removed.
class AppGlassTheme {
  AppGlassTheme._();

  /// Light mode gradient: soft light grays.
  static const LinearGradient backgroundGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF4F6F7), Color(0xFFE8ECF0)],
  );

  /// Dark mode gradient: deep slate tones.
  static const LinearGradient backgroundGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF020617)],
  );
}
