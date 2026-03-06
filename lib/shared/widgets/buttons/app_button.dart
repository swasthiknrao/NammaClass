import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary, outlined, text }

enum AppButtonSize { small, medium, large }

/// Primary design-system button. Use for actions.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool loading;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = loading ? null : onPressed;

    final padding = switch (size) {
      AppButtonSize.small => const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      AppButtonSize.medium => const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      AppButtonSize.large => const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.lg,
      ),
    };

    final content = loading
        ? SizedBox(
            height: size == AppButtonSize.small ? 16 : 24,
            width: size == AppButtonSize.small ? 16 : 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _contentColor(context),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label),
            ],
          );

    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(padding: padding),
          child: content,
        );
      case AppButtonVariant.secondary:
        return FilledButton.tonal(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(padding: padding),
          child: content,
        );
      case AppButtonVariant.outlined:
        return OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(padding: padding),
          child: content,
        );
      case AppButtonVariant.text:
        return TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(padding: padding),
          child: content,
        );
    }
  }

  Color _contentColor(BuildContext context) {
    if (variant == AppButtonVariant.primary ||
        variant == AppButtonVariant.secondary) {
      return Theme.of(context).colorScheme.onPrimary;
    }
    return Theme.of(context).colorScheme.primary;
  }
}
