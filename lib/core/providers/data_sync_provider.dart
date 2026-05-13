import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock/mock_bundle_persistence.dart';

/// Global revision counter for cross-feature data synchronization.
/// Increment whenever shared mock data changes so dependent providers refresh.
class DataSyncNotifier extends StateNotifier<int> {
  DataSyncNotifier() : super(0);

  void bump() {
    state++;
    MockBundlePersistence.instance.scheduleSave();
  }
}

final dataSyncProvider = StateNotifierProvider<DataSyncNotifier, int>(
  (ref) => DataSyncNotifier(),
);
