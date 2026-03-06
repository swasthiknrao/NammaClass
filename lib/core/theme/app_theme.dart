import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';
import '../config/app_config.dart';

/// Central theme. Use AppTheme.light and AppTheme.dark in MaterialApp.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: AppColors.primaryLight,
      onPrimary: AppColors.onPrimaryLight,
      primaryContainer: AppColors.primaryContainerLight,
      secondary: AppColors.secondaryLight,
      onSecondary: AppColors.onSecondaryLight,
      secondaryContainer: AppColors.secondaryContainerLight,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.onSurfaceLight,
      surfaceContainerHighest: AppColors.surfaceContainerLight,
      error: AppColors.errorLight,
      onError: AppColors.onErrorLight,
      outline: AppColors.outlineLight,
    );

    final textTheme = TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.onSurfaceLight),
      displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.onSurfaceLight),
      displaySmall: AppTypography.displaySmall.copyWith(color: AppColors.onSurfaceLight),
      headlineLarge: AppTypography.headlineLarge.copyWith(color: AppColors.onSurfaceLight),
      headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColors.onSurfaceLight),
      headlineSmall: AppTypography.headlineSmall.copyWith(color: AppColors.onSurfaceLight),
      titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.onSurfaceLight),
      titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.onSurfaceLight),
      titleSmall: AppTypography.titleSmall.copyWith(color: AppColors.onSurfaceLight),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.onSurfaceLight),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceLight),
      bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariantLight),
      labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.onSurfaceLight),
      labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.onSurfaceVariantLight),
      labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariantLight),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: AppColors.surfaceContainerLight,
        foregroundColor: AppColors.onSurfaceLight,
        titleTextStyle: AppTypography.titleLarge.copyWith(color: AppColors.onSurfaceLight),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.radiusMd)),
        color: AppColors.surfaceContainerLight,
        margin: const EdgeInsets.all(AppSpacing.sm),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConfig.radiusMd)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.radiusMd),
          borderSide: const BorderSide(color: AppColors.outlineLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.radiusMd),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.radiusMd),
          borderSide: const BorderSide(color: AppColors.errorLight),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariantLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.radiusMd)),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.radiusMd)),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      scaffoldBackgroundColor: AppColors.surfaceLight,
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.primaryDark,
      onPrimary: AppColors.onPrimaryDark,
      primaryContainer: AppColors.primaryContainerDark,
      secondary: AppColors.secondaryDark,
      onSecondary: AppColors.onSecondaryDark,
      secondaryContainer: AppColors.secondaryContainerDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.onSurfaceDark,
      surfaceContainerHighest: AppColors.surfaceContainerDark,
      error: AppColors.errorDark,
      onError: AppColors.onErrorDark,
      outline: AppColors.outlineDark,
    );

    final textTheme = TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.onSurfaceDark),
      displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.onSurfaceDark),
      displaySmall: AppTypography.displaySmall.copyWith(color: AppColors.onSurfaceDark),
      headlineLarge: AppTypography.headlineLarge.copyWith(color: AppColors.onSurfaceDark),
      headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColors.onSurfaceDark),
      headlineSmall: AppTypography.headlineSmall.copyWith(color: AppColors.onSurfaceDark),
      titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.onSurfaceDark),
      titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.onSurfaceDark),
      titleSmall: AppTypography.titleSmall.copyWith(color: AppColors.onSurfaceDark),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.onSurfaceDark),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceDark),
      bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariantDark),
      labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.onSurfaceDark),
      labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.onSurfaceVariantDark),
      labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariantDark),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: AppColors.surfaceContainerDark,
        foregroundColor: AppColors.onSurfaceDark,
        titleTextStyle: AppTypography.titleLarge.copyWith(color: AppColors.onSurfaceDark),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.radiusMd)),
        color: AppColors.surfaceContainerDark,
        margin: const EdgeInsets.all(AppSpacing.sm),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConfig.radiusMd)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.radiusMd),
          borderSide: const BorderSide(color: AppColors.outlineDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.radiusMd),
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.radiusMd),
          borderSide: const BorderSide(color: AppColors.errorDark),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariantDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.radiusMd)),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.radiusMd)),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      scaffoldBackgroundColor: AppColors.surfaceDark,
    );
  }
}
