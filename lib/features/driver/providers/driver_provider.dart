import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';

final driverBusStopsProvider = Provider<List<MockBusStop>>((ref) {
  return List.from(MockData.busStops);
});

final driverStopStudentsProvider = Provider<Map<String, List<String>>>((ref) {
  return Map.from(MockData.driverStopStudents);
});
