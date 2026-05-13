import 'package:flutter/material.dart';

import '../../../../domain/entities/timetable_period_definition.dart';
import '../../../../domain/entities/timetable_slot_entry.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Read-only or tappable week grid (days × periods).
class TimetableWeekGrid extends StatelessWidget {
  const TimetableWeekGrid({
    super.key,
    required this.dayLabels,
    required this.periods,
    required this.grid,
    this.periodsPerDay,
    this.workingWeekdays,
    this.onCellTap,
    this.compact = false,
  });

  final List<String> dayLabels;
  final List<TimetablePeriodDefinition> periods;
  final List<List<TimetableSlotEntry?>> grid;

  /// When set, columns [periodsPerDay[d] .. periods.length) render disabled.
  final List<int>? periodsPerDay;

  /// When set, rows with false are dimmed; taps still follow [onCellTap] policy.
  final List<bool>? workingWeekdays;

  final void Function(int dayIndex, int periodIndex, TimetableSlotEntry? slot)?
  onCellTap;
  final bool compact;

  bool _slotEnabled(int d, int p) {
    if (p < 0 || p >= periods.length) return false;
    if (d < 0 || d >= dayLabels.length) return false;
    if (periodsPerDay != null && d < periodsPerDay!.length) {
      if (p >= periodsPerDay![d]) return false;
    }
    if (workingWeekdays != null && d < workingWeekdays!.length) {
      if (!workingWeekdays![d]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: FixedColumnWidth(compact ? 72 : 88),
        border: TableBorder.all(
          color: AppColors.divider.withValues(alpha: 0.6),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
            ),
            children: [
              _cornerCell(compact),
              ...periods.map(
                (p) => Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    compact ? '${p.index + 1}' : p.label,
                    textAlign: TextAlign.center,
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          for (var d = 0; d < dayLabels.length; d++)
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    compact ? dayLabels[d].substring(0, 3) : dayLabels[d],
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          workingWeekdays != null &&
                              d < workingWeekdays!.length &&
                              !workingWeekdays![d]
                          ? AppColors.textSecondary
                          : null,
                    ),
                  ),
                ),
                for (var p = 0; p < periods.length; p++)
                  _SlotCell(
                    slot: grid[d][p],
                    compact: compact,
                    enabled: _slotEnabled(d, p),
                    onTap: onCellTap == null || !_slotEnabled(d, p)
                        ? null
                        : () => onCellTap!(d, p, grid[d][p]),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _cornerCell(bool compact) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        compact ? 'Day' : 'Day / Period',
        style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SlotCell extends StatelessWidget {
  const _SlotCell({
    required this.slot,
    required this.compact,
    required this.enabled,
    this.onTap,
  });

  final TimetableSlotEntry? slot;
  final bool compact;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: const EdgeInsets.all(6),
      child: !enabled
          ? Text(
              '—',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary.withValues(alpha: 0.45),
              ),
            )
          : slot == null
          ? Text(
              '—',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : Opacity(
              opacity: enabled ? 1 : 0.45,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    slot!.subject,
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 2),
                    Text(
                      slot!.facultyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (slot!.isLab)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'LAB×${slot!.labSpan}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );

    final bg = enabled
        ? AppColors.card.withValues(alpha: 0.35)
        : AppColors.card.withValues(alpha: 0.12);

    if (onTap == null) {
      return DecoratedBox(
        decoration: BoxDecoration(color: bg),
        child: child,
      );
    }

    return Material(
      color: bg,
      child: InkWell(onTap: onTap, child: child),
    );
  }
}
