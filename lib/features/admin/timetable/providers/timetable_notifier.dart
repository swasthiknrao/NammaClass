import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/class_section_meta.dart';
import '../../../../domain/entities/timetable_period_definition.dart';
import '../../../../domain/entities/timetable_slot_entry.dart';
import '../timetable_limits.dart';
import '../utils/timetable_bell_math.dart';

const kTeacherDemoId = 'usr_teacher_001';
const kTeacherDemoName = 'Priya Sharma';

/// Mon–Sun grid rows.
const int kTimetableDayCount = 7;

/// Default period template (aligned with legacy ERP slots).
List<TimetablePeriodDefinition> _defaultPeriods() => const [
  TimetablePeriodDefinition(
    index: 0,
    label: 'Period 1',
    startLabel: '8:50',
    endLabel: '9:40',
  ),
  TimetablePeriodDefinition(
    index: 1,
    label: 'Period 2',
    startLabel: '9:45',
    endLabel: '10:35',
  ),
  TimetablePeriodDefinition(
    index: 2,
    label: 'Period 3',
    startLabel: '10:40',
    endLabel: '11:30',
  ),
  TimetablePeriodDefinition(
    index: 3,
    label: 'Period 4',
    startLabel: '11:35',
    endLabel: '12:25',
  ),
  TimetablePeriodDefinition(
    index: 4,
    label: 'Period 5',
    startLabel: '1:05',
    endLabel: '1:55',
  ),
  TimetablePeriodDefinition(
    index: 5,
    label: 'Period 6',
    startLabel: '2:00',
    endLabel: '2:50',
  ),
  TimetablePeriodDefinition(
    index: 6,
    label: 'Period 7',
    startLabel: '2:55',
    endLabel: '3:45',
  ),
  TimetablePeriodDefinition(
    index: 7,
    label: 'Period 8',
    startLabel: '3:50',
    endLabel: '4:40',
  ),
];

const _dayKeys = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

class TimetableState {
  const TimetableState({
    required this.classSections,
    required this.selectedClassSection,
    required this.periods,
    required this.gridByClass,
    this.metaBySection = const {},
    List<bool>? workingWeekdays,
    List<int>? periodsPerDay,
    this.usePerDayCounts = false,
  }) : _workingWeekdaysStorage = workingWeekdays,
       _periodsPerDayStorage = periodsPerDay;

  final List<String> classSections;
  final String selectedClassSection;
  final List<TimetablePeriodDefinition> periods;

  /// Optional display names keyed by [classSections] id.
  final Map<String, ClassSectionMeta> metaBySection;

  /// Dropdown / header label for a section id.
  String labelForSection(String sectionId) {
    final m = metaBySection[sectionId];
    if (m == null) return sectionId;
    return m.dropdownLabel;
  }

  /// Mon..Sun — toggles for teaching days (summary / UX).
  ///
  /// Backed by nullable storage so **hot reload** (or any stale instance) never
  /// yields a null/bad-length list at the type level — we coerce here.
  final List<bool>? _workingWeekdaysStorage;

  /// Period slots used per day (<= [periods.length]); extra columns are unused.
  final List<int>? _periodsPerDayStorage;

  List<bool> get workingWeekdays {
    final raw = _workingWeekdaysStorage;
    if (raw == null || raw.length != kTimetableDayCount) {
      return [true, true, true, true, true, false, false];
    }
    return List<bool>.from(raw);
  }

  List<int> get periodsPerDay {
    final raw = _periodsPerDayStorage;
    final cap = periods.length.clamp(1, kTimetablePeriodHardCap);
    if (raw == null || raw.length != kTimetableDayCount) {
      return List<int>.filled(kTimetableDayCount, cap);
    }
    return [for (final c in raw) c.clamp(1, cap)];
  }

  /// When false, [periodsPerDay] is kept in sync (same count every day).
  final bool usePerDayCounts;

  /// classSection -> dayIndex (0..6) -> periodIndex -> slot (null = free)
  final Map<String, List<List<TimetableSlotEntry?>>> gridByClass;

  int get maxPeriodsConfigured =>
      periodsPerDay.fold<int>(0, (a, b) => a > b ? a : b);

  TimetableState copyWith({
    List<String>? classSections,
    String? selectedClassSection,
    List<TimetablePeriodDefinition>? periods,
    Map<String, List<List<TimetableSlotEntry?>>>? gridByClass,
    Map<String, ClassSectionMeta>? metaBySection,
    List<bool>? workingWeekdays,
    List<int>? periodsPerDay,
    bool? usePerDayCounts,
  }) {
    return TimetableState(
      classSections: classSections ?? this.classSections,
      selectedClassSection: selectedClassSection ?? this.selectedClassSection,
      periods: periods ?? this.periods,
      gridByClass: gridByClass ?? this.gridByClass,
      metaBySection: metaBySection ?? this.metaBySection,
      workingWeekdays: workingWeekdays ?? _workingWeekdaysStorage,
      periodsPerDay: periodsPerDay ?? _periodsPerDayStorage,
      usePerDayCounts: usePerDayCounts ?? this.usePerDayCounts,
    );
  }

  List<List<TimetableSlotEntry?>> gridFor(String section) {
    return gridByClass[section] ?? _emptyGrid(periods.length);
  }

  static List<List<TimetableSlotEntry?>> _emptyGrid(int periodColumns) {
    return List.generate(
      kTimetableDayCount,
      (_) => List<TimetableSlotEntry?>.filled(periodColumns, null),
    );
  }
}

List<List<TimetableSlotEntry?>> _emptyGrid(int periodColumns) =>
    TimetableState._emptyGrid(periodColumns);

Map<String, List<List<TimetableSlotEntry?>>> _resizeAllGrids(
  Map<String, List<List<TimetableSlotEntry?>>> old,
  int newDays,
  int newPeriods,
) {
  return {
    for (final e in old.entries)
      e.key: List.generate(newDays, (d) {
        final oldRow = d < e.value.length
            ? e.value[d]
            : <TimetableSlotEntry?>[];
        return List.generate(newPeriods, (p) {
          if (p < oldRow.length) return oldRow[p];
          return null;
        });
      }),
  };
}

class TimetableNotifier extends StateNotifier<TimetableState> {
  TimetableNotifier()
    : super(
        TimetableState(
          classSections: const [],
          selectedClassSection: '',
          periods: _defaultPeriods(),
          gridByClass: const {},
          metaBySection: const {},
          workingWeekdays: const [true, true, true, true, true, false, false],
          periodsPerDay: const [8, 8, 8, 8, 8, 8, 8],
          usePerDayCounts: false,
        ),
      );

  static const dayLabels = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  /// Whether [day]/[period] can be edited in the day builder (working day + within day count).
  static bool isPeriodWritable(
    TimetableState s,
    int dayIndex,
    int periodIndex,
  ) {
    if (dayIndex < 0 || dayIndex >= kTimetableDayCount) return false;
    if (periodIndex < 0 || periodIndex >= s.periods.length) return false;
    if (!s.workingWeekdays[dayIndex]) return false;
    if (periodIndex >= s.periodsPerDay[dayIndex]) return false;
    return true;
  }

  /// Human-readable slot from [TimetablePeriodDefinition] (linked to settings).
  String periodTimeRange(int periodIndex) {
    if (periodIndex < 0 || periodIndex >= state.periods.length) return '';
    final e = state.periods[periodIndex];
    return '${e.startLabel} - ${e.endLabel}';
  }

  void selectClass(String section) {
    if (!state.classSections.contains(section)) return;
    state = state.copyWith(selectedClassSection: section);
  }

  void addClassSection(String section, {ClassSectionMeta? meta}) {
    final s = section.trim();
    if (s.isEmpty || state.classSections.contains(s)) return;
    final nextGrids = Map<String, List<List<TimetableSlotEntry?>>>.from(
      state.gridByClass,
    );
    nextGrids[s] = _emptyGrid(state.periods.length);
    final nextMeta = Map<String, ClassSectionMeta>.from(state.metaBySection);
    if (meta != null) {
      nextMeta[s] = meta;
    }
    state = state.copyWith(
      classSections: [...state.classSections, s],
      selectedClassSection: s,
      gridByClass: nextGrids,
      metaBySection: nextMeta,
    );
  }

  void setPeriodDefinition(int index, TimetablePeriodDefinition def) {
    final list = [...state.periods];
    if (index < 0 || index >= list.length) return;
    list[index] = def;
    state = state.copyWith(periods: list);
  }

  /// Batch replace all bell rows. Length must match current [state.periods.length]
  /// unless resizing via [applyAllPeriodsAndResize].
  void applyAllPeriods(List<TimetablePeriodDefinition> next) {
    if (next.isEmpty || next.length > kTimetablePeriodHardCap) return;
    if (next.length != state.periods.length) return;
    state = state.copyWith(periods: List<TimetablePeriodDefinition>.from(next));
  }

  /// Replace bells and resize columns to [next.length], clamping [periodsPerDay] and grids.
  void applyAllPeriodsAndResize(List<TimetablePeriodDefinition> next) {
    if (next.isEmpty || next.length > kTimetablePeriodHardCap) return;
    final newLen = next.length;
    final clamped = [for (final c in state.periodsPerDay) c.clamp(1, newLen)];
    final newGrids = _resizeAllGrids(
      state.gridByClass,
      kTimetableDayCount,
      newLen,
    );
    state = state.copyWith(
      periods: List<TimetablePeriodDefinition>.from(next),
      periodsPerDay: clamped,
      gridByClass: newGrids,
    );
  }

  /// [index] 0 = Monday … 6 = Sunday.
  void setWorkingDay(int index, bool enabled) {
    if (index < 0 || index >= state.workingWeekdays.length) return;
    final w = [...state.workingWeekdays];
    w[index] = enabled;
    state = state.copyWith(workingWeekdays: w);
  }

  void setUsePerDayCounts(bool value) {
    if (value == state.usePerDayCounts) return;
    if (!value) {
      final n = state.periods.length;
      final unified = List<int>.filled(kTimetableDayCount, n);
      state = state.copyWith(usePerDayCounts: false, periodsPerDay: unified);
    } else {
      state = state.copyWith(usePerDayCounts: true);
    }
  }

  /// Global mode: same period count every day; may grow/shrink bell rows.
  void setGlobalPeriodCount(int count) {
    if (state.usePerDayCounts) return;
    final n = count.clamp(1, kTimetablePeriodHardCap);
    final nextPeriods = padPeriodDefinitionsToCount(state.periods, n);
    final nextPerDay = List<int>.filled(kTimetableDayCount, n);
    final newGrids = _resizeAllGrids(state.gridByClass, kTimetableDayCount, n);
    state = state.copyWith(
      periods: nextPeriods,
      periodsPerDay: nextPerDay,
      gridByClass: newGrids,
    );
  }

  /// Per-day mode: set one day's used columns; grows [periods] if needed.
  void setPeriodsCountForDay(int dayIndex, int count) {
    if (dayIndex < 0 || dayIndex >= kTimetableDayCount) return;
    final n = count.clamp(1, kTimetablePeriodHardCap);
    final ppd = [...state.periodsPerDay];
    ppd[dayIndex] = n;
    final maxNeeded = ppd.fold<int>(0, (a, b) => a > b ? a : b);
    if (maxNeeded > state.periods.length) {
      final next = padPeriodDefinitionsToCount(state.periods, maxNeeded);
      final newGrids = _resizeAllGrids(
        state.gridByClass,
        kTimetableDayCount,
        maxNeeded,
      );
      state = state.copyWith(
        periods: next,
        periodsPerDay: ppd,
        gridByClass: newGrids,
      );
    } else {
      state = state.copyWith(periodsPerDay: ppd);
    }
  }

  /// Grow bell rows to fit max([periodsPerDay]); does not shrink automatically.
  void reconcilePeriodColumnsToMaxPerDay() {
    final maxP = state.periodsPerDay.fold<int>(0, (a, b) => a > b ? a : b);
    if (maxP == state.periods.length) return;
    if (maxP > state.periods.length) {
      final next = padPeriodDefinitionsToCount(state.periods, maxP);
      final newGrids = _resizeAllGrids(
        state.gridByClass,
        kTimetableDayCount,
        maxP,
      );
      state = state.copyWith(periods: next, gridByClass: newGrids);
    }
  }

  void setCell({
    required String classSection,
    required int dayIndex,
    required int periodIndex,
    TimetableSlotEntry? slot,
  }) {
    if (!isPeriodWritable(state, dayIndex, periodIndex)) return;
    if (dayIndex < 0 || dayIndex >= _dayKeys.length) return;
    if (periodIndex < 0 || periodIndex >= state.periods.length) return;
    final grid = state.gridByClass[classSection];
    if (grid == null) return;
    final newDay = [...grid[dayIndex]];
    newDay[periodIndex] = slot;
    final newGrid = [...grid];
    newGrid[dayIndex] = newDay;
    final map = Map<String, List<List<TimetableSlotEntry?>>>.from(
      state.gridByClass,
    );
    map[classSection] = newGrid;
    state = state.copyWith(gridByClass: map);
  }

  /// Clears continuation lab cells so editing stays consistent.
  void clearLabSpan({
    required String classSection,
    required int dayIndex,
    required int startPeriod,
    required int span,
  }) {
    for (
      var p = startPeriod;
      p < startPeriod + span && p < state.periods.length;
      p++
    ) {
      if (!isPeriodWritable(state, dayIndex, p)) continue;
      setCell(
        classSection: classSection,
        dayIndex: dayIndex,
        periodIndex: p,
        slot: null,
      );
    }
  }
}

final timetableNotifierProvider =
    StateNotifierProvider<TimetableNotifier, TimetableState>((ref) {
      return TimetableNotifier();
    });
