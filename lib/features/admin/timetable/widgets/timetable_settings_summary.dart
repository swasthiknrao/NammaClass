import 'package:flutter/material.dart';

import '../../../../domain/entities/timetable_period_definition.dart';
import '../utils/timetable_bell_math.dart';
import 'timetable_ui_tokens.dart';

/// Live summary: working days, bells, span, mini timeline, optional per-day counts.
class TimetableSettingsSummary extends StatelessWidget {
  const TimetableSettingsSummary({
    super.key,
    required this.periods,
    required this.workingWeekdays,
    required this.dayLabels,
    this.periodsPerDay,
    this.usePerDayCounts,
    this.compact = false,
  });

  final List<TimetablePeriodDefinition> periods;
  final List<bool> workingWeekdays;
  final List<String> dayLabels;
  final List<int>? periodsPerDay;
  final bool? usePerDayCounts;
  final bool compact;

  String _perDayShort() {
    if (periodsPerDay == null || periodsPerDay!.isEmpty) return '';
    final minC = periodsPerDay!.reduce((a, b) => a < b ? a : b);
    final maxC = periodsPerDay!.reduce((a, b) => a > b ? a : b);
    if (usePerDayCounts == true && minC != maxC) {
      return ' · $minC–$maxC / day';
    }
    return ' · $maxC / day';
  }

  String _perDayChipLabel() {
    final pp = periodsPerDay!;
    final minC = pp.reduce((a, b) => a < b ? a : b);
    final maxC = pp.reduce((a, b) => a > b ? a : b);
    if (usePerDayCounts == true && minC != maxC) {
      return '$minC–$maxC slots';
    }
    return '$maxC slots';
  }

  @override
  Widget build(BuildContext context) {
    final text = TimetableUiTokens.textPrimary(context);
    final accent = TimetableUiTokens.accent(context);
    final bg = TimetableUiTokens.bg(context);

    final active = workingWeekdays.where((e) => e).length;
    final dayTotal = dayLabels.length;
    final span = daySpanMinutes(periods);
    final durs = periodDurationsMinutes(periods);

    if (compact) {
      final spanShort = span == null
          ? '—'
          : (span >= 60 ? '${span ~/ 60}h ${span % 60}m' : '${span}m');
      return Material(
        color: Colors.transparent,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  size: 20,
                  color: accent.withValues(alpha: 0.95),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$active/$dayTotal days · ${periods.length} bells · $spanShort span${_perDayShort()}',
                  style: TextStyle(
                    color: text,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    String spanText;
    if (span == null) {
      spanText = 'Day span: — (edit times to compute)';
    } else {
      final h = span ~/ 60;
      final m = span % 60;
      spanText = h > 0 ? 'Day span: ${h}h ${m}m' : 'Day span: ${m}m';
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: TimetableUiTokens.cardGradient(context),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.insights_outlined,
                    color: accent.withValues(alpha: 0.95),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Week overview',
                    style: TextStyle(
                      color: text,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _chip(context, 'Teaching week', '$active / $dayTotal days'),
                  _chip(context, 'Bells', '${periods.length} periods'),
                  _chip(
                    context,
                    'Span',
                    span == null
                        ? '—'
                        : spanText.replaceFirst('Day span: ', ''),
                  ),
                  if (periodsPerDay != null && periodsPerDay!.isNotEmpty)
                    _chip(
                      context,
                      usePerDayCounts == true ? 'Per day' : 'Uniform',
                      _perDayChipLabel(),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                spanText,
                style: TextStyle(
                  color: text.withValues(alpha: 0.85),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Period share (by length)',
                style: TextStyle(
                  color: text,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: [
                      for (var i = 0; i < periods.length; i++)
                        Expanded(
                          flex: (i < durs.length ? (durs[i] ?? 1) : 1).clamp(
                            1,
                            999,
                          ),
                          child: Container(
                            color: i.isEven
                                ? accent.withValues(alpha: 0.75)
                                : accent.withValues(alpha: 0.45),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: List.generate(workingWeekdays.length, (i) {
                  final on = i < workingWeekdays.length && workingWeekdays[i];
                  final label = i < dayLabels.length ? dayLabels[i] : 'Day $i';
                  final pd = periodsPerDay != null && i < periodsPerDay!.length
                      ? periodsPerDay![i]
                      : null;
                  return Chip(
                    avatar: Icon(
                      on ? Icons.check_circle : Icons.cancel_outlined,
                      size: 16,
                      color: on
                          ? Colors.greenAccent
                          : text.withValues(alpha: 0.5),
                    ),
                    label: Text(
                      pd != null
                          ? '${label.length > 3 ? label.substring(0, 3) : label} $pd'
                          : (label.length > 3 ? label.substring(0, 3) : label),
                      style: TextStyle(
                        color: on ? text : text.withValues(alpha: 0.45),
                        fontSize: 11,
                      ),
                    ),
                    backgroundColor: on ? bg : bg.withValues(alpha: 0.5),
                    side: BorderSide(
                      color: accent.withValues(alpha: on ? 0.4 : 0.15),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String k, String v) {
    final text = TimetableUiTokens.textPrimary(context);
    final accent = TimetableUiTokens.accent(context);
    final bg = TimetableUiTokens.bg(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            k,
            style: TextStyle(color: text.withValues(alpha: 0.65), fontSize: 11),
          ),
          Text(
            v,
            style: TextStyle(
              color: text,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
