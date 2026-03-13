import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Standardised Card wrapper — NcCard.
class NcCard extends StatelessWidget {
  const NcCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.border,
    this.margin,
    this.gradient,
    this.elevation,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final BoxBorder? border;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      child: child,
    );

    if (gradient != null) {
      return Container(
        margin: margin,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: border,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: onTap != null ? InkWell(onTap: onTap, child: content) : content,
      );
    }

    final surfaceColor =
        color ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardDark
            : AppColors.card);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: elevation != null ? elevation! * 2 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? Material(
              color: surfaceColor,
              child: InkWell(
                onTap: onTap,
                splashColor: AppColors.primary.withValues(alpha: 0.08),
                highlightColor: AppColors.primary.withValues(alpha: 0.04),
                child: content,
              ),
            )
          : content,
    );
  }
}
