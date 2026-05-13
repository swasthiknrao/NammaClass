import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/providers/data_sync_provider.dart';

class StaffNotifier extends StateNotifier<AsyncValue<List<MockStaffMember>>> {
  StaffNotifier(this._ref) : super(const AsyncValue.loading()) {
    _load();
    _ref.listen<int>(dataSyncProvider, (_, __) {
      state = AsyncValue.data(List.from(MockData.staff));
    });
  }

  final Ref _ref;

  void _load() async {
    await Future.delayed(const Duration(milliseconds: 150));
    state = AsyncValue.data(List.from(MockData.staff));
  }

  void add(MockStaffMember member) {
    MockData.staff.add(member);
    state = AsyncValue.data(List.from(MockData.staff));
    _ref.read(dataSyncProvider.notifier).bump();
  }

  void remove(String id) {
    MockData.staff.removeWhere((m) => m.id == id);
    state = AsyncValue.data(List.from(MockData.staff));
    _ref.read(dataSyncProvider.notifier).bump();
  }
}

final staffNotifierProvider =
    StateNotifierProvider<StaffNotifier, AsyncValue<List<MockStaffMember>>>(
      (ref) => StaffNotifier(ref),
    );
