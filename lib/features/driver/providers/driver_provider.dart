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

final driverBusInfoProvider = Provider<Map<String, dynamic>>((ref) {
  ref.watch(dataSyncProvider);
  return Map<String, dynamic>.from(MockData.busInfo);
});

final driverAbsentStudentsProvider = Provider<List<String>>((ref) {
  ref.watch(dataSyncProvider);
  return List.from(MockData.driverAbsentStudentNames);
});

final driverTripHistoryProvider = Provider<List<Map<String, dynamic>>>((ref) {
  ref.watch(dataSyncProvider);
  return List.from(MockData.driverTripHistory);
});

final driverVehicleChecklistProvider = Provider<Map<String, bool>>((ref) {
  ref.watch(dataSyncProvider);
  return Map.from(MockData.driverVehicleChecklist);
});

/// Roster excluding students marked absent for transport today.
final driverExpectedRosterProvider = Provider<Map<String, List<String>>>((ref) {
  ref.watch(dataSyncProvider);
  final absent = MockData.driverAbsentStudentNames.toSet();
  final raw = MockData.driverStopStudents;
  return raw.map(
    (stop, names) =>
        MapEntry(stop, names.where((n) => !absent.contains(n)).toList()),
  );
});
