import 'package:dio/dio.dart';

import '../../core/config/env_config.dart';
import '../../core/services/app_logger.dart';
import '../../domain/entities/transport_entity.dart';
import '../../domain/repositories/transport_repository.dart';

class TransportRepositoryImpl implements TransportRepository {
  TransportRepositoryImpl(this._dio);

  final Dio _dio;

  // Mock bus location — Bengaluru coordinates
  static BusLocation _mockLocation(String busId) => BusLocation(
    busId: busId,
    latitude: 12.9716 + (busId.hashCode % 10) * 0.001,
    longitude: 77.5946 + (busId.hashCode % 10) * 0.001,
    timestamp: DateTime.now(),
    speedKmh: 28.5,
    heading: 45.0,
    nextStopName: 'Koramangala 5th Block',
    etaMinutes: 4,
  );

  static final List<BusStop> _mockStops = [
    BusStop(
      id: 's1',
      name: 'College Gate',
      latitude: 12.9716,
      longitude: 77.5946,
      sequence: 1,
      scheduledTime: '07:30',
      reached: true,
    ),
    BusStop(
      id: 's2',
      name: 'Koramangala 5th Block',
      latitude: 12.9352,
      longitude: 77.6245,
      sequence: 2,
      scheduledTime: '07:45',
    ),
    BusStop(
      id: 's3',
      name: 'HSR Layout Sector 1',
      latitude: 12.9116,
      longitude: 77.6474,
      sequence: 3,
      scheduledTime: '07:55',
    ),
    BusStop(
      id: 's4',
      name: 'BTM Layout Bus Stand',
      latitude: 12.9166,
      longitude: 77.6101,
      sequence: 4,
      scheduledTime: '08:05',
    ),
    BusStop(
      id: 's5',
      name: 'Jayanagar 4th Block',
      latitude: 12.9279,
      longitude: 77.5937,
      sequence: 5,
      scheduledTime: '08:15',
    ),
  ];

  @override
  Future<BusLocation> getBusLocation(String busId) async {
    if (EnvConfig.apiBaseUrl.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      return _mockLocation(busId);
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/transport/bus/$busId/location',
      );
      return BusLocation.fromJson(response.data!);
    } on DioException catch (e) {
      AppLogger.instance.error(
        'TransportRepository: getBusLocation',
        e,
        e.stackTrace,
      );
      return _mockLocation(busId);
    }
  }

  @override
  Future<List<BusStop>> getRouteStops(String busId) async {
    if (EnvConfig.apiBaseUrl.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      return _mockStops;
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        '/transport/bus/$busId/stops',
      );
      return (response.data ?? [])
          .map((e) => BusStop.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger.instance.error(
        'TransportRepository: getRouteStops',
        e,
        e.stackTrace,
      );
      return _mockStops;
    }
  }
}
