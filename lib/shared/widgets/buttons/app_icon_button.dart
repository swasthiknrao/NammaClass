import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// Icon-only button. Use for toolbar actions.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final child = Icon(icon, size: 24);
    final button = filled
        ? FilledButton.tonal(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(AppSpacing.sm),
              minimumSize: const Size(48, 48),
            ),
            child: child,
          )
        : IconButton(
            onPressed: onPressed,
            icon: child,
          );
    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
