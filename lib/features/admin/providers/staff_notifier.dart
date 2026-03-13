import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';

class StaffNotifier extends StateNotifier<AsyncValue<List<MockStaffMember>>> {
  StaffNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  void _load() async {
    await Future.delayed(const Duration(milliseconds: 150));
    state = AsyncValue.data(List.from(MockData.staff));
  }

  void add(MockStaffMember member) {
    state.whenData((list) {
      state = AsyncValue.data([...list, member]);
    });
  }

  void remove(String id) {
    state.whenData((list) {
      state = AsyncValue.data(list.where((m) => m.id != id).toList());
    });
  }
}

final staffNotifierProvider =
    StateNotifierProvider<StaffNotifier, AsyncValue<List<MockStaffMember>>>(
      (ref) => StaffNotifier(),
    );
