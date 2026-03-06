import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Primary action button — 48dp, AppRadius.sm, primaryColor background.
class NcPrimaryButton extends StatelessWidget {
  const NcPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.fullWidth = false,
    this.icon,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool fullWidth;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    Widget child = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator.adaptive(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: AppTypography.labelLarge.copyWith(color: Colors.white),
              ),
            ],
          );

    final btn = ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppColors.primary,
        disabledBackgroundColor: AppColors.textDisabled,
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
      ),
      child: child,
    );

    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

/// Secondary action button — outlined, 48dp, primaryColor border.
class NcSecondaryButton extends StatelessWidget {
  const NcSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.fullWidth = false,
    this.icon,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool fullWidth;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    Widget child = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator.adaptive(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(c),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: c),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(label, style: AppTypography.labelLarge.copyWith(color: c)),
            ],
          );

    final btn = OutlinedButton(
      onPressed: loading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: c, width: 1.5),
        foregroundColor: c,
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
      ),
      child: child,
    );

    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}
