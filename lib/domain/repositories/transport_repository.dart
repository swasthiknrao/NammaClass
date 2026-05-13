import '../entities/transport_entity.dart';

/// Contract for bus location and route data.
abstract class TransportRepository {
  /// Returns the latest GPS location for [busId].
  /// Poll this every 10 seconds when the parent is viewing the map.
  Future<BusLocation> getBusLocation(String busId);

  /// Returns all stops on the route for [busId] in sequence order.
  Future<List<BusStop>> getRouteStops(String busId);
}
