import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum NcChipType {
  present,
  absent,
  pending,
  leave,
  active,
  inactive,
  paid,
  overdue,
  partial,
}

/// BRD Section 1.4 — StatusChip with colour coding.
class NcStatusChip extends StatelessWidget {
  const NcStatusChip({super.key, this.type, this.label, this.color});

  final NcChipType? type;
  final String? label;

  /// Optional color override — when provided, renders a plain colored chip instead of type-based colors.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (color != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color!.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.xxl),
          border: Border.all(color: color!.withValues(alpha: 0.4)),
        ),
        child: Text(
          label ?? (type?.name ?? ''),
          style: AppTypography.labelMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    final (bg, fg, icon, defaultLabel) = _config(type ?? NcChipType.pending);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.xxl),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label ?? defaultLabel,
            style: AppTypography.labelMedium.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static (Color, Color, IconData, String) _config(NcChipType type) {
    switch (type) {
      case NcChipType.present:
        return (
          AppColors.successBg,
          AppColors.success,
          Icons.check_circle,
          'Present',
        );
      case NcChipType.active:
        return (
          AppColors.successBg,
          AppColors.success,
          Icons.check_circle,
          'Active',
        );
      case NcChipType.paid:
        return (
          AppColors.successBg,
          AppColors.success,
          Icons.check_circle,
          'Paid',
        );
      case NcChipType.absent:
        return (AppColors.errorBg, AppColors.error, Icons.cancel, 'Absent');
      case NcChipType.inactive:
        return (AppColors.errorBg, AppColors.error, Icons.cancel, 'Inactive');
      case NcChipType.overdue:
        return (AppColors.errorBg, AppColors.error, Icons.schedule, 'Overdue');
      case NcChipType.pending:
        return (
          AppColors.warningBg,
          AppColors.warning,
          Icons.schedule,
          'Pending',
        );
      case NcChipType.partial:
        return (
          const Color(0xFFE8F4F8),
          AppColors.teal,
          Icons.remove_circle_outline,
          'Partial',
        );
      case NcChipType.leave:
        return (
          AppColors.leaveBg,
          const Color(0xFF7D3C98),
          Icons.event_busy,
          'Leave',
        );
    }
  }
}

/// Simple text chip for categories/filters
class NcChip extends StatelessWidget {
  const NcChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  /// When provided, overrides the chip background with a tinted version of this color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color;
    final bgColor = effectiveColor != null
        ? effectiveColor.withValues(alpha: 0.12)
        : (selected ? AppColors.primary : AppColors.background);
    final fgColor =
        effectiveColor ?? (selected ? Colors.white : AppColors.textSecondary);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.xxl),
          border: Border.all(
            color:
                effectiveColor ??
                (selected ? AppColors.primary : AppColors.divider),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: fgColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: fgColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
