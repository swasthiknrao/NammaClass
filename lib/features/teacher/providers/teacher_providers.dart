import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/providers/data_sync_provider.dart';
import '../models/timeline_models.dart';

// ── Attendance mark state ──────────────────────────────────────────────────────
class AttendanceMarkState {
  const AttendanceMarkState({
    this.records = const {},
    this.isSaving = false,
    this.saved = false,
  });

  final Map<String, String> records; // studentId → 'P' | 'A' | 'L'
  final bool isSaving;
  final bool saved;

  AttendanceMarkState copyWith({
    Map<String, String>? records,
    bool? isSaving,
    bool? saved,
  }) {
    return AttendanceMarkState(
      records: records ?? this.records,
      isSaving: isSaving ?? this.isSaving,
      saved: saved ?? this.saved,
    );
  }
}

class AttendanceMarkNotifier extends StateNotifier<AttendanceMarkState> {
  AttendanceMarkNotifier(this._ref) : super(const AttendanceMarkState()) {
    _initAll();
  }

  final Ref _ref;

  void _initAll() {
    final records = <String, String>{};
    for (final s in MockData.students.where((s) => s.classSection == '8-A')) {
      records[s.id] = 'P';
    }
    state = state.copyWith(records: records);
  }

  void markAll(String status) {
    state = state.copyWith(
      records: {for (final k in state.records.keys) k: status},
      saved: false,
    );
  }

  void mark(String studentId, String status) {
    state = state.copyWith(
      records: {...state.records, studentId: status},
      saved: false,
    );
  }

  Future<void> submit() async {
    state = state.copyWith(isSaving: true);
    await Future.delayed(const Duration(milliseconds: 300));
    _writeAttendanceToMockData();
    _ref.read(dataSyncProvider.notifier).bump();
    state = state.copyWith(isSaving: false, saved: true);
  }

  void _writeAttendanceToMockData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final statuses = state.records.values;
    final total = statuses.length;
    if (total == 0) return;

    final present = statuses.where((v) => v == 'P').length;
    final absent = statuses.where((v) => v == 'A').length;
    final leave = statuses.where((v) => v == 'L').length;

    String dayStatus;
    if (present >= absent && present >= leave) {
      dayStatus = 'present';
    } else if (leave > absent) {
      dayStatus = 'leave';
    } else {
      dayStatus = 'absent';
    }

    final periods = dayStatus == 'present'
        ? (MockData.timetable[_weekdayName(today.weekday)] ??
                  const <MockPeriod>[])
              .map((p) => p.subject)
              .toList()
        : <String>[];

    final updated = MockAttendanceDay(
      date: today,
      status: dayStatus,
      periods: periods,
    );

    MockData.attendance =
        MockData.attendance
            .where(
              (d) =>
                  !(d.date.year == today.year &&
                      d.date.month == today.month &&
                      d.date.day == today.day),
            )
            .toList()
          ..add(updated)
          ..sort((a, b) => a.date.compareTo(b.date));
  }

  String _weekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return 'Monday';
    }
  }
}

// ── Teacher providers ──────────────────────────────────────────────────────────
final teacherStudentsProvider = FutureProvider<List<MockStudent>>((ref) async {
  ref.watch(dataSyncProvider);
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.students;
});

final teacherTimetableProvider = FutureProvider<Map<String, List<MockPeriod>>>((
  ref,
) async {
  ref.watch(dataSyncProvider);
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.timetable;
});

final attendanceMarkProvider =
    StateNotifierProvider<AttendanceMarkNotifier, AttendanceMarkState>((ref) {
      ref.watch(dataSyncProvider);
      return AttendanceMarkNotifier(ref);
    });

final teacherDiaryProvider = FutureProvider<List<MockDiaryEntry>>((ref) async {
  ref.watch(dataSyncProvider);
  await Future.delayed(const Duration(milliseconds: 150));
  return MockData.diary;
});

class TeacherTimelineState {
  const TeacherTimelineState({
    this.items = const [],
    this.dependencies = const [],
    this.zoom = TimelineZoom.day,
    this.expandedNodeIds = const {},
    this.searchQuery = '',
    this.statusFilter = const {},
    this.assigneeFilter = const {},
    this.featureFilter = const {},
    this.linkMode = false,
    this.selectedTaskId,
  });

  final List<TeacherTimelineItem> items;
  final List<TimelineDependency> dependencies;
  final TimelineZoom zoom;
  final Set<String> expandedNodeIds;
  final String searchQuery;
  final Set<TimelineTaskStatus> statusFilter;
  final Set<String> assigneeFilter;
  final Set<String> featureFilter;
  final bool linkMode;
  final String? selectedTaskId;

  TeacherTimelineState copyWith({
    List<TeacherTimelineItem>? items,
    List<TimelineDependency>? dependencies,
    TimelineZoom? zoom,
    Set<String>? expandedNodeIds,
    String? searchQuery,
    Set<TimelineTaskStatus>? statusFilter,
    Set<String>? assigneeFilter,
    Set<String>? featureFilter,
    bool? linkMode,
    String? selectedTaskId,
    bool clearSelectedTask = false,
  }) {
    return TeacherTimelineState(
      items: items ?? this.items,
      dependencies: dependencies ?? this.dependencies,
      zoom: zoom ?? this.zoom,
      expandedNodeIds: expandedNodeIds ?? this.expandedNodeIds,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      assigneeFilter: assigneeFilter ?? this.assigneeFilter,
      featureFilter: featureFilter ?? this.featureFilter,
      linkMode: linkMode ?? this.linkMode,
      selectedTaskId: clearSelectedTask
          ? null
          : (selectedTaskId ?? this.selectedTaskId),
    );
  }
}

class TeacherTimelineNotifier extends StateNotifier<TeacherTimelineState> {
  TeacherTimelineNotifier() : super(const TeacherTimelineState()) {
    _initialize();
  }

  void _initialize() {
    final items = buildTeacherTimelineItems();
    final dependencies = <TimelineDependency>[];
    for (final item in items.where((e) => e.type == TimelineNodeType.task)) {
      for (final dep in item.dependencyIds) {
        dependencies.add(
          TimelineDependency(fromTaskId: dep, toTaskId: item.id),
        );
      }
    }
    final expanded = {
      for (final item in items.where((e) => e.type != TimelineNodeType.task))
        item.id,
    };
    state = state.copyWith(
      items: items,
      dependencies: dependencies,
      expandedNodeIds: expanded,
    );
  }

  void setZoom(TimelineZoom zoom) => state = state.copyWith(zoom: zoom);

  void toggleNode(String nodeId) {
    final next = {...state.expandedNodeIds};
    if (next.contains(nodeId)) {
      next.remove(nodeId);
    } else {
      next.add(nodeId);
    }
    state = state.copyWith(expandedNodeIds: next);
  }

  void setSearchQuery(String query) =>
      state = state.copyWith(searchQuery: query);

  void setStatusFilter(Set<TimelineTaskStatus> filters) =>
      state = state.copyWith(statusFilter: filters);

  void setAssigneeFilter(Set<String> filters) =>
      state = state.copyWith(assigneeFilter: filters);

  void setFeatureFilter(Set<String> filters) =>
      state = state.copyWith(featureFilter: filters);

  void setLinkMode(bool enabled) => state = state.copyWith(linkMode: enabled);

  void selectTask(String? taskId) =>
      state = state.copyWith(selectedTaskId: taskId);

  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      statusFilter: <TimelineTaskStatus>{},
      assigneeFilter: <String>{},
      featureFilter: <String>{},
    );
  }

  void moveTask(String taskId, Duration delta) {
    final items = state.items.map((item) {
      if (item.id != taskId) return item;
      return item.copyWith(
        startDate: item.startDate.add(delta),
        endDate: item.endDate.add(delta),
      );
    }).toList();
    state = state.copyWith(items: items);
    _propagateDependencyShift(taskId, delta);
  }

  void resizeTask(String taskId, {Duration? startDelta, Duration? endDelta}) {
    final items = state.items.map((item) {
      if (item.id != taskId) return item;
      final nextStart = item.startDate.add(startDelta ?? Duration.zero);
      final nextEnd = item.endDate.add(endDelta ?? Duration.zero);
      if (!nextEnd.isAfter(nextStart)) return item;
      return item.copyWith(startDate: nextStart, endDate: nextEnd);
    }).toList();
    state = state.copyWith(items: items);
  }

  void linkDependency(String fromTaskId, String toTaskId) {
    if (fromTaskId == toTaskId) return;
    final exists = state.dependencies.any(
      (d) => d.fromTaskId == fromTaskId && d.toTaskId == toTaskId,
    );
    if (exists) return;
    final candidate = [
      ...state.dependencies,
      TimelineDependency(fromTaskId: fromTaskId, toTaskId: toTaskId),
    ];
    if (_createsCycle(candidate)) return;
    state = state.copyWith(dependencies: candidate);
  }

  void unlinkDependency(String fromTaskId, String toTaskId) {
    state = state.copyWith(
      dependencies: state.dependencies
          .where((d) => !(d.fromTaskId == fromTaskId && d.toTaskId == toTaskId))
          .toList(),
    );
  }

  bool _createsCycle(List<TimelineDependency> deps) {
    final graph = <String, List<String>>{};
    for (final d in deps) {
      graph.putIfAbsent(d.fromTaskId, () => []).add(d.toTaskId);
    }
    final visiting = <String>{};
    final visited = <String>{};

    bool dfs(String node) {
      if (visiting.contains(node)) return true;
      if (visited.contains(node)) return false;
      visiting.add(node);
      for (final nxt in graph[node] ?? const <String>[]) {
        if (dfs(nxt)) return true;
      }
      visiting.remove(node);
      visited.add(node);
      return false;
    }

    for (final node in graph.keys) {
      if (dfs(node)) return true;
    }
    return false;
  }

  void _propagateDependencyShift(String rootTaskId, Duration delta) {
    if (delta == Duration.zero) return;
    final queue = <String>[rootTaskId];
    final shifted = <String>{};
    final downstream = <String>{};
    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      for (final dep in state.dependencies.where(
        (d) => d.fromTaskId == current,
      )) {
        if (downstream.add(dep.toTaskId)) {
          queue.add(dep.toTaskId);
        }
      }
    }
    if (downstream.isEmpty) return;

    final items = state.items.map((item) {
      if (!downstream.contains(item.id) || shifted.contains(item.id))
        return item;
      shifted.add(item.id);
      return item.copyWith(
        startDate: item.startDate.add(delta),
        endDate: item.endDate.add(delta),
      );
    }).toList();
    state = state.copyWith(items: items);
  }
}

final teacherTimelineProvider =
    StateNotifierProvider<TeacherTimelineNotifier, TeacherTimelineState>((ref) {
      ref.watch(dataSyncProvider);
      return TeacherTimelineNotifier();
    });
