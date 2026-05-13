import 'package:flutter/material.dart';

import '../../../../domain/entities/timetable_period_definition.dart';
import '../timetable_limits.dart';

/// Labels like the legacy ERP: `8:50`, `1:05` (12-hour style, no AM/PM).
String formatBellLabel(TimeOfDay t) {
  var h = t.hour;
  if (h > 12) {
    h -= 12;
  } else if (h == 0) {
    h = 12;
  }
  return '$h:${t.minute.toString().padLeft(2, '0')}';
}

TimeOfDay _addMinutes(TimeOfDay start, int minutes) {
  final base = DateTime(2000, 1, 1, start.hour, start.minute);
  final d = base.add(Duration(minutes: minutes));
  return TimeOfDay(hour: d.hour, minute: d.minute);
}

/// Converts a bell string to minutes from midnight, nudging forward in 12h steps
/// until [notBefore] is satisfied (handles afternoon `1:05` after morning slots).
int? bellsToMinutes(String raw, {required int notBefore}) {
  final s = raw.trim();
  final parts = s.split(':');
  if (parts.length != 2) return null;
  var h = int.tryParse(parts[0].trim());
  final m = int.tryParse(parts[1].trim());
  if (h == null || m == null || m < 0 || m > 59) return null;
  if (h > 23) return null;
  var candidate = h * 60 + m;
  for (var i = 0; i < 4 && candidate < notBefore; i++) {
    candidate += 12 * 60;
  }
  if (candidate < notBefore) return null;
  return candidate;
}

/// Span in minutes from first period start to last period end; null if parse fails.
int? daySpanMinutes(List<TimetablePeriodDefinition> periods) {
  if (periods.isEmpty) return null;
  var cursor = 0;
  int? firstStart;
  int? lastEnd;
  for (final p in periods) {
    final s = bellsToMinutes(p.startLabel, notBefore: cursor);
    if (s == null) return null;
    final e = bellsToMinutes(p.endLabel, notBefore: s + 1);
    if (e == null || e < s) return null;
    firstStart ??= s;
    lastEnd = e;
    cursor = e;
  }
  if (firstStart == null || lastEnd == null) return null;
  return lastEnd - firstStart;
}

/// Durations (minutes) per period for flex timeline; null if parse fails for that row.
List<int?> periodDurationsMinutes(List<TimetablePeriodDefinition> periods) {
  var cursor = 0;
  final out = <int?>[];
  for (final p in periods) {
    final s = bellsToMinutes(p.startLabel, notBefore: cursor);
    final e = bellsToMinutes(p.endLabel, notBefore: (s ?? cursor) + 1);
    if (s == null || e == null || e < s) {
      out.add(null);
      cursor = s ?? cursor;
      continue;
    }
    out.add(e - s);
    cursor = e;
  }
  return out;
}

int _periodLengthAt(
  int index,
  int defaultLength,
  List<int?>? customDurationMinutes,
) {
  if (customDurationMinutes == null ||
      index < 0 ||
      index >= customDurationMinutes.length) {
    return defaultLength;
  }
  final c = customDurationMinutes[index];
  return c ?? defaultLength;
}

/// Uniform period length + one normal gap + optional long pause (e.g. lunch).
/// [periodCount] must be >= 1. When [periodCount] == 1, long pause is ignored.
List<TimetablePeriodDefinition> generatePeriodScheduleSimple({
  required TimeOfDay dayStart,
  required int periodCount,
  required int periodLengthMinutes,
  required int gapMinutes,
  required int longPauseMinutes,
  int longPauseAfterPeriod = 4,
  bool hasLongPause = true,
  List<int?>? customDurationMinutes,
}) {
  final n = periodCount.clamp(1, kTimetablePeriodHardCap);
  final out = <TimetablePeriodDefinition>[];
  var cursor = dayStart;
  for (var i = 0; i < n; i++) {
    final start = cursor;
    final len = _periodLengthAt(i, periodLengthMinutes, customDurationMinutes);
    final end = _addMinutes(start, len);
    out.add(
      TimetablePeriodDefinition(
        index: i,
        label: 'Period ${i + 1}',
        startLabel: formatBellLabel(start),
        endLabel: formatBellLabel(end),
      ),
    );
    if (i == n - 1) break;
    var gap = gapMinutes;
    if (n > 1 &&
        hasLongPause &&
        longPauseAfterPeriod >= 1 &&
        longPauseAfterPeriod <= n - 1 &&
        i == longPauseAfterPeriod - 1) {
      gap = longPauseMinutes;
    }
    cursor = _addMinutes(end, gap);
  }
  return out;
}

/// Short / long / lunch gaps between consecutive periods.
/// When lunch and a long break coincide, lunch wins (matches common ERP UX).
List<TimetablePeriodDefinition> generatePeriodScheduleComplex({
  required TimeOfDay dayStart,
  required int periodCount,
  required int periodLengthMinutes,
  required int shortBreakMinutes,
  required int longBreakMinutes,
  required int longBreakEveryPeriods,
  required bool hasLunch,
  required int lunchAfterPeriod,
  required int lunchGapMinutes,
  List<int?>? customDurationMinutes,
}) {
  final n = periodCount.clamp(1, kTimetablePeriodHardCap);
  final every = longBreakEveryPeriods.clamp(1, n);
  final out = <TimetablePeriodDefinition>[];
  var cursor = dayStart;
  for (var i = 0; i < n; i++) {
    final start = cursor;
    final len = _periodLengthAt(i, periodLengthMinutes, customDurationMinutes);
    final end = _addMinutes(start, len);
    out.add(
      TimetablePeriodDefinition(
        index: i,
        label: 'Period ${i + 1}',
        startLabel: formatBellLabel(start),
        endLabel: formatBellLabel(end),
      ),
    );
    if (i == n - 1) break;
    int gap = shortBreakMinutes;
    if (hasLunch &&
        lunchAfterPeriod >= 1 &&
        lunchAfterPeriod <= n - 1 &&
        i == lunchAfterPeriod - 1) {
      gap = lunchGapMinutes;
    } else if (every > 0 && (i + 1) % every == 0) {
      gap = longBreakMinutes;
    }
    cursor = _addMinutes(end, gap);
  }
  return out;
}

/// Grow or shrink [current] to [targetCount] rows; new rows get plausible times
/// after the last valid period (5 min gap + 45 min lesson).
List<TimetablePeriodDefinition> padPeriodDefinitionsToCount(
  List<TimetablePeriodDefinition> current,
  int targetCount,
) {
  final n = targetCount.clamp(0, kTimetablePeriodHardCap);
  if (n == 0) return [];
  if (current.length >= n) {
    return [
      for (var i = 0; i < n; i++)
        current[i].copyWith(index: i, label: 'Period ${i + 1}'),
    ];
  }
  final out = <TimetablePeriodDefinition>[
    for (var i = 0; i < current.length; i++)
      current[i].copyWith(index: i, label: 'Period ${i + 1}'),
  ];
  var cursor = const TimeOfDay(hour: 9, minute: 0);
  if (out.isNotEmpty) {
    final last = out.last;
    final e = bellsToMinutes(last.endLabel, notBefore: 0);
    if (e != null) {
      final base = DateTime(2000, 1, 1).add(Duration(minutes: e));
      cursor = _addMinutes(TimeOfDay(hour: base.hour, minute: base.minute), 5);
    }
  }
  while (out.length < n) {
    final i = out.length;
    final start = cursor;
    final end = _addMinutes(start, 45);
    out.add(
      TimetablePeriodDefinition(
        index: i,
        label: 'Period ${i + 1}',
        startLabel: formatBellLabel(start),
        endLabel: formatBellLabel(end),
      ),
    );
    cursor = _addMinutes(end, 5);
  }
  return out;
}

/// Generates 8 uniform periods (legacy helper).
List<TimetablePeriodDefinition> generateEightPeriodTemplate({
  required TimeOfDay dayStart,
  required int periodLengthMinutes,
  required int gapMinutes,
  required int longPauseMinutes,
  int longPauseAfterPeriod = 4,
  bool hasLongPause = true,
}) {
  return generatePeriodScheduleSimple(
    dayStart: dayStart,
    periodCount: 8,
    periodLengthMinutes: periodLengthMinutes,
    gapMinutes: gapMinutes,
    longPauseMinutes: longPauseMinutes,
    longPauseAfterPeriod: longPauseAfterPeriod,
    hasLongPause: hasLongPause,
  );
}

/// Short / long / lunch gaps — 8 periods (legacy helper).
List<TimetablePeriodDefinition> generateEightPeriodComplex({
  required TimeOfDay dayStart,
  required int periodLengthMinutes,
  required int shortBreakMinutes,
  required int longBreakMinutes,
  required int longBreakEveryPeriods,
  required bool hasLunch,
  required int lunchAfterPeriod,
  required int lunchGapMinutes,
}) {
  return generatePeriodScheduleComplex(
    dayStart: dayStart,
    periodCount: 8,
    periodLengthMinutes: periodLengthMinutes,
    shortBreakMinutes: shortBreakMinutes,
    longBreakMinutes: longBreakMinutes,
    longBreakEveryPeriods: longBreakEveryPeriods,
    hasLunch: hasLunch,
    lunchAfterPeriod: lunchAfterPeriod,
    lunchGapMinutes: lunchGapMinutes,
  );
}
