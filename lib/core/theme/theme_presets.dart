import 'package:flutter/material.dart';

import '../../domain/entities/theme_tokens.dart';

/// A fully-specified theme preset: brand colors + layout tokens.
class AppThemePreset {
  const AppThemePreset({
    required this.id,
    required this.name,
    required this.emoji,
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundLight,
    required this.backgroundDark,
    required this.tokens,
    this.description = '',
  });

  final String id;
  final String name;
  final String emoji;
  final Color primaryColor;
  final Color accentColor;
  final Color backgroundLight;
  final Color backgroundDark;
  final ThemeTokens tokens;
  final String description;

  /// Convenience: swatch for preview gradients
  List<Color> get gradient => [primaryColor, accentColor];
}

/// All built-in presets. First entry is the default.
class AppThemePresets {
  AppThemePresets._();

  static const oceanBlue = AppThemePreset(
    id: 'ocean_blue',
    name: 'Ocean Blue',
    emoji: '🌊',
    primaryColor: Color(0xFF1B4F72),
    accentColor: Color(0xFFE67E22),
    backgroundLight: Color(0xFFF4F6F7),
    backgroundDark: Color(0xFF121212),
    description: 'Classic deep navy with warm amber — the original NammaClass.',
    tokens: ThemeTokens(
      presetId: 'ocean_blue',
      density: 'comfortable',
      radiusScale: 1.0,
      motionLevel: 'normal',
    ),
  );

  static const forestGreen = AppThemePreset(
    id: 'forest_green',
    name: 'Forest Green',
    emoji: '🌿',
    primaryColor: Color(0xFF1A6B3C),
    accentColor: Color(0xFF27AE60),
    backgroundLight: Color(0xFFF0F7F2),
    backgroundDark: Color(0xFF0D1F14),
    description: 'Fresh botanical greens with spacious, airy layouts.',
    tokens: ThemeTokens(
      presetId: 'modern_university',
      density: 'comfortable',
      radiusScale: 1.4,
      motionLevel: 'normal',
    ),
  );

  static const crimsonRed = AppThemePreset(
    id: 'crimson_red',
    name: 'Crimson Red',
    emoji: '🔴',
    primaryColor: Color(0xFF922B21),
    accentColor: Color(0xFFE74C3C),
    backgroundLight: Color(0xFFFDF4F3),
    backgroundDark: Color(0xFF1A0A09),
    description: 'Bold and energetic — compact layout for power users.',
    tokens: ThemeTokens(
      presetId: 'neo_minimal',
      density: 'compact',
      radiusScale: 0.8,
      motionLevel: 'reduced',
    ),
  );

  static const royalPurple = AppThemePreset(
    id: 'royal_purple',
    name: 'Royal Purple',
    emoji: '💜',
    primaryColor: Color(0xFF5B2C8D),
    accentColor: Color(0xFF9B59B6),
    backgroundLight: Color(0xFFF5F0FB),
    backgroundDark: Color(0xFF130B1F),
    description: 'Elegant regal purple with modern rounded corners.',
    tokens: ThemeTokens(
      presetId: 'modern_university',
      density: 'comfortable',
      radiusScale: 1.3,
      motionLevel: 'normal',
    ),
  );

  static const solarOrange = AppThemePreset(
    id: 'solar_orange',
    name: 'Solar Orange',
    emoji: '☀️',
    primaryColor: Color(0xFFB7500C),
    accentColor: Color(0xFFF39C12),
    backgroundLight: Color(0xFFFEF8F2),
    backgroundDark: Color(0xFF1A0D04),
    description: 'Warm sunshine palette with clean minimal edges.',
    tokens: ThemeTokens(
      presetId: 'neo_minimal',
      density: 'comfortable',
      radiusScale: 0.85,
      motionLevel: 'normal',
    ),
  );

  static const midnightSteel = AppThemePreset(
    id: 'midnight_steel',
    name: 'Midnight Steel',
    emoji: '🌙',
    primaryColor: Color(0xFF2C3E50),
    accentColor: Color(0xFF3498DB),
    backgroundLight: Color(0xFFF2F4F6),
    backgroundDark: Color(0xFF0A0E14),
    description: 'Corporate steel-blue with premium elevated cards.',
    tokens: ThemeTokens(
      presetId: 'corporate_premium',
      density: 'comfortable',
      radiusScale: 1.0,
      motionLevel: 'normal',
    ),
  );

  static const List<AppThemePreset> all = [
    oceanBlue,
    forestGreen,
    crimsonRed,
    royalPurple,
    solarOrange,
    midnightSteel,
  ];

  static AppThemePreset byId(String id) {
    return all.firstWhere((p) => p.id == id, orElse: () => oceanBlue);
  }
}
