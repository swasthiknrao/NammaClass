import 'dart:async';

import 'mock_bundle_storage.dart';
import 'mock_data.dart';

/// Debounced writes of [MockData.exportFullBundleForJson] to local disk (IO)
/// or no-op (web stub).
class MockBundlePersistence {
  MockBundlePersistence._();
  static final MockBundlePersistence instance = MockBundlePersistence._();

  Timer? _debounce;

  void scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      await saveUserBundleMap(MockData.exportFullBundleForJson());
    });
  }

  Future<void> flushNow() async {
    _debounce?.cancel();
    await saveUserBundleMap(MockData.exportFullBundleForJson());
  }
}
