import 'package:flutter/material.dart';

/// NammaClass brand color palette — exact BRD Section 1.1 tokens.
class AppColors {
  AppColors._();

  // Primary brand
  static const Color primary = Color(0xFF1B4F72);
  static const Color primaryDark = Color(0xFF163A57); // ~15% darker
  static const Color accent = Color(0xFFE67E22);
  static const Color success = Color(0xFF1E8449);
  static const Color teal = Color(0xFF117A65);
  static const Color error = Color(0xFF922B21);
  static const Color warning = Color(0xFFD4A017);

  // Surfaces
  static const Color background = Color(0xFFF4F6F7);
  static const Color card = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFCCCCCC);
  static const Color sidebarBg = Color(0xFF0D2137);

  // Text
  static const Color textPrimary = Color(0xFF1C2833);
  static const Color textSecondary = Color(0xFF5D6D7E);
  static const Color textDisabled = Color(0xFFAAAAAA);

  // Shimmer
  static const Color shimmerBase = Color(0xFFE8ECEF);
  static const Color shimmerHighlight = Color(0xFFF8F9FA);

  // Status chip backgrounds
  static const Color successBg = Color(0xFFD5F5E3);
  static const Color errorBg = Color(0xFFFDECEA);
  static const Color warningBg = Color(0xFFFEF9E7);
  static const Color leaveBg = Color(0xFFE8DAEF);

  // Extended palette — used in Part 2 screens
  static const Color purple = Color(0xFF7D3C98);
  static const Color deepPurple = Color(0xFF7D3C98);

  // Gradients
  static const List<Color> primaryGradient = [primary, teal];
  static const List<Color> accentGradient = [accent, Color(0xFFF39C12)];
  static const List<Color> successGradient = [success, teal];
  static const List<Color> errorGradient = [error, Color(0xFFCB4335)];

  // Shadow definitions (Phase 4A)
  static BoxShadow get shadowSm => BoxShadow(
    color: Colors.black.withValues(alpha: 0.08),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );
  static BoxShadow get shadowMd => BoxShadow(
    color: Colors.black.withValues(alpha: 0.12),
    blurRadius: 16,
    offset: const Offset(0, 4),
  );
  static BoxShadow get shadowLg => BoxShadow(
    color: Colors.black.withValues(alpha: 0.16),
    blurRadius: 32,
    offset: const Offset(0, 8),
  );

  // Dark theme variants
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFE8E8E8);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color dividerDark = Color(0xFF3A3A3A);
}
