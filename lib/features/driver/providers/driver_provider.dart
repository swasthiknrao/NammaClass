import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/providers/data_sync_provider.dart';

final driverBusStopsProvider = Provider<List<MockBusStop>>((ref) {
  ref.watch(dataSyncProvider);
  return List.from(MockData.busStops);
});

final driverStopStudentsProvider = Provider<Map<String, List<String>>>((ref) {
  ref.watch(dataSyncProvider);
  return Map.from(MockData.driverStopStudents);
});
