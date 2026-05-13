import 'package:flutter/material.dart';

import '../../../../domain/entities/timetable_period_definition.dart';
import '../timetable_limits.dart';
import 'timetable_bell_math.dart';

/// Named bell layouts; [buildSchedule] respects current column count.
enum TimetableBellPreset {
  standard,
  intensive,
  labFocused,
  flexible,
  traditional,
  modern,
  collegePattern,
  universityStyle,
  schoolStyle,
}

extension TimetableBellPresetX on TimetableBellPreset {
  String get title {
    switch (this) {
      case TimetableBellPreset.standard:
        return 'Standard';
      case TimetableBellPreset.intensive:
        return 'Intensive';
      case TimetableBellPreset.labFocused:
        return 'Lab focused';
      case TimetableBellPreset.flexible:
        return 'Flexible';
      case TimetableBellPreset.traditional:
        return 'Traditional';
      case TimetableBellPreset.modern:
        return 'Modern';
      case TimetableBellPreset.collegePattern:
        return 'College';
      case TimetableBellPreset.universityStyle:
        return 'University';
      case TimetableBellPreset.schoolStyle:
        return 'School';
    }
  }

  String subtitleFor(int periodCount) {
    final n = periodCount.clamp(1, kTimetablePeriodHardCap);
    switch (this) {
      case TimetableBellPreset.standard:
        return '$n×50 · 5 gap · lunch 40';
      case TimetableBellPreset.intensive:
        return '$n×45 · tighter lunch';
      case TimetableBellPreset.labFocused:
        return '$n×60 · wider gaps';
      case TimetableBellPreset.flexible:
        return '$n×60 · mid-morning lunch';
      case TimetableBellPreset.traditional:
        return '$n×48 · classic day';
      case TimetableBellPreset.modern:
        return '$n×45 · fewer long gaps';
      case TimetableBellPreset.collegePattern:
        return '$n periods · short/long + lunch';
      case TimetableBellPreset.universityStyle:
        return '$n periods · longer breaks';
      case TimetableBellPreset.schoolStyle:
        return '$n periods · stepped breaks';
    }
  }

  /// Backwards-compatible short subtitle (assumes 8 periods).
  String get subtitle => subtitleFor(8);

  IconData get icon {
    switch (this) {
      case TimetableBellPreset.standard:
        return Icons.school;
      case TimetableBellPreset.intensive:
        return Icons.speed;
      case TimetableBellPreset.labFocused:
        return Icons.science;
      case TimetableBellPreset.flexible:
        return Icons.tune;
      case TimetableBellPreset.traditional:
        return Icons.history_edu;
      case TimetableBellPreset.modern:
        return Icons.trending_up;
      case TimetableBellPreset.collegePattern:
        return Icons.account_balance;
      case TimetableBellPreset.universityStyle:
        return Icons.menu_book;
      case TimetableBellPreset.schoolStyle:
        return Icons.class_;
    }
  }

  List<TimetablePeriodDefinition> buildSchedule({int periodCount = 8}) {
    final n = periodCount.clamp(1, kTimetablePeriodHardCap);
    final lunchAfter = n > 1 ? (4).clamp(1, n - 1) : 1;
    switch (this) {
      case TimetableBellPreset.standard:
        return generatePeriodScheduleSimple(
          dayStart: const TimeOfDay(hour: 8, minute: 50),
          periodCount: n,
          periodLengthMinutes: 50,
          gapMinutes: 5,
          longPauseMinutes: 40,
          longPauseAfterPeriod: lunchAfter,
          hasLongPause: true,
        );
      case TimetableBellPreset.intensive:
        return generatePeriodScheduleSimple(
          dayStart: const TimeOfDay(hour: 8, minute: 0),
          periodCount: n,
          periodLengthMinutes: 45,
          gapMinutes: 5,
          longPauseMinutes: 30,
          longPauseAfterPeriod: n > 5 ? 5 : lunchAfter,
          hasLongPause: true,
        );
      case TimetableBellPreset.labFocused:
        return generatePeriodScheduleSimple(
          dayStart: const TimeOfDay(hour: 9, minute: 0),
          periodCount: n,
          periodLengthMinutes: 60,
          gapMinutes: 10,
          longPauseMinutes: 45,
          longPauseAfterPeriod: n > 3 ? 3 : lunchAfter,
          hasLongPause: true,
        );
      case TimetableBellPreset.flexible:
        return generatePeriodScheduleSimple(
          dayStart: const TimeOfDay(hour: 9, minute: 30),
          periodCount: n,
          periodLengthMinutes: 60,
          gapMinutes: 10,
          longPauseMinutes: 30,
          longPauseAfterPeriod: n > 3 ? 3 : lunchAfter,
          hasLongPause: true,
        );
      case TimetableBellPreset.traditional:
        return generatePeriodScheduleSimple(
          dayStart: const TimeOfDay(hour: 8, minute: 0),
          periodCount: n,
          periodLengthMinutes: 48,
          gapMinutes: 5,
          longPauseMinutes: 50,
          longPauseAfterPeriod: lunchAfter,
          hasLongPause: true,
        );
      case TimetableBellPreset.modern:
        return generatePeriodScheduleSimple(
          dayStart: const TimeOfDay(hour: 9, minute: 0),
          periodCount: n,
          periodLengthMinutes: 45,
          gapMinutes: 10,
          longPauseMinutes: 45,
          longPauseAfterPeriod: lunchAfter,
          hasLongPause: true,
        );
      case TimetableBellPreset.collegePattern:
        return generatePeriodScheduleComplex(
          dayStart: const TimeOfDay(hour: 8, minute: 50),
          periodCount: n,
          periodLengthMinutes: 50,
          shortBreakMinutes: 5,
          longBreakMinutes: 10,
          longBreakEveryPeriods: 2,
          hasLunch: true,
          lunchAfterPeriod: lunchAfter,
          lunchGapMinutes: 40,
        );
      case TimetableBellPreset.universityStyle:
        return generatePeriodScheduleComplex(
          dayStart: const TimeOfDay(hour: 9, minute: 0),
          periodCount: n,
          periodLengthMinutes: 60,
          shortBreakMinutes: 10,
          longBreakMinutes: 20,
          longBreakEveryPeriods: 2,
          hasLunch: true,
          lunchAfterPeriod: n > 3 ? 3 : lunchAfter,
          lunchGapMinutes: 60,
        );
      case TimetableBellPreset.schoolStyle:
        return generatePeriodScheduleComplex(
          dayStart: const TimeOfDay(hour: 8, minute: 0),
          periodCount: n,
          periodLengthMinutes: 40,
          shortBreakMinutes: 5,
          longBreakMinutes: 12,
          longBreakEveryPeriods: 2,
          hasLunch: true,
          lunchAfterPeriod: lunchAfter,
          lunchGapMinutes: 30,
        );
    }
  }
}
