import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/providers/data_sync_provider.dart';

class StaffNotifier extends StateNotifier<AsyncValue<List<MockStaffMember>>> {
  StaffNotifier(this._ref) : super(const AsyncValue.loading()) {
    _load();
    _ref.listen<int>(dataSyncProvider, (previous, next) {
      state = AsyncValue.data(List.from(MockData.staff));
    });
  }

  final Ref _ref;

  /// Departments with no staff yet (session-only).
  final List<String> _extraDepartments = [];

  List<String> get extraDepartments => List.unmodifiable(_extraDepartments);

  void _emit() {
    state = AsyncValue.data(List.from(MockData.staff));
    _ref.read(dataSyncProvider.notifier).bump();
  }

  void _load() async {
    await Future.delayed(const Duration(milliseconds: 150));
    state = AsyncValue.data(List.from(MockData.staff));
  }

  /// Distinct department labels from staff + empty buckets.
  List<String> allDepartments() {
    final fromStaff = state.valueOrNull?.map((e) => e.department).toSet() ?? {};
    final merged = {...fromStaff, ..._extraDepartments};
    final list = merged.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  void addDepartmentBucket(String name) {
    final n = name.trim();
    if (n.isEmpty) return;
    if (!_extraDepartments.contains(n) &&
        !(state.valueOrNull ?? []).any((e) => e.department == n)) {
      _extraDepartments.add(n);
    }
    _emit();
  }

  void removeDepartmentBucket(String name) {
    _extraDepartments.remove(name);
    _emit();
  }

  int staffCountInDepartment(String department) {
    return (state.valueOrNull ?? [])
        .where((e) => e.department == department)
        .length;
  }

  void add(MockStaffMember member) {
    MockData.staff.add(member);
    _emit();
  }

  void remove(String id) {
    MockData.staff.removeWhere((m) => m.id == id);
    _emit();
  }

  void update(MockStaffMember member) {
    final i = MockData.staff.indexWhere((m) => m.id == member.id);
    if (i < 0) return;
    MockData.staff[i] = member;
    _emit();
  }

  void moveMembersToDepartment(Set<String> ids, String newDepartment) {
    if (ids.isEmpty) return;
    final dept = newDepartment.trim();
    if (dept.isEmpty) return;
    for (var i = 0; i < MockData.staff.length; i++) {
      final m = MockData.staff[i];
      if (ids.contains(m.id)) {
        MockData.staff[i] = m.copyWith(department: dept);
      }
    }
    _emit();
  }

  /// Reassigns everyone in [department] to [targetDepartment], then drops the empty bucket if any.
  Future<void> dissolveDepartment({
    required String department,
    required String targetDepartment,
  }) async {
    final t = targetDepartment.trim();
    if (t.isEmpty) return;
    for (var i = 0; i < MockData.staff.length; i++) {
      final m = MockData.staff[i];
      if (m.department == department) {
        MockData.staff[i] = m.copyWith(department: t);
      }
    }
    _extraDepartments.remove(department);
    _emit();
  }
}

final staffNotifierProvider =
    StateNotifierProvider<StaffNotifier, AsyncValue<List<MockStaffMember>>>(
      (ref) => StaffNotifier(ref),
    );
