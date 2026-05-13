import 'mock_bundle_storage.dart';
import 'mock_data.dart';

Future<void> loadPersistedBundleIntoMockData() async {
  final map = await loadUserBundleMap();
  MockData.applyJsonBundle(map);
}
