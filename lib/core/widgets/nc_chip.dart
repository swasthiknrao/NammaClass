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
  const NcStatusChip({super.key, required this.type, this.label});

  final NcChipType type;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon, defaultLabel) = _config(type);
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
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.xxl),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
