import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';

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
  AttendanceMarkNotifier() : super(const AttendanceMarkState()) {
    _initAll();
  }

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
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(isSaving: false, saved: true);
  }
}

// ── Teacher providers ──────────────────────────────────────────────────────────
final teacherStudentsProvider = FutureProvider<List<MockStudent>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 700));
  return MockData.students;
});

final teacherTimetableProvider = FutureProvider<Map<String, List<MockPeriod>>>((
  ref,
) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return MockData.timetable;
});

final attendanceMarkProvider =
    StateNotifierProvider<AttendanceMarkNotifier, AttendanceMarkState>(
      (ref) => AttendanceMarkNotifier(),
    );

final teacherDiaryProvider = FutureProvider<List<MockDiaryEntry>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 600));
  return MockData.diary;
});
