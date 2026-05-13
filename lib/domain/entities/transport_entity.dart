/// GPS location snapshot for a school bus.
class BusLocation {
  const BusLocation({
    required this.busId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.speedKmh,
    this.heading,
    this.nextStopName,
    this.etaMinutes,
  });

  final String busId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? speedKmh;

  /// Compass heading in degrees (0–360).
  final double? heading;
  final String? nextStopName;
  final int? etaMinutes;

  factory BusLocation.fromJson(Map<String, dynamic> json) => BusLocation(
    busId: json['bus_id'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    timestamp: DateTime.parse(json['timestamp'] as String),
    speedKmh: (json['speed_kmh'] as num?)?.toDouble(),
    heading: (json['heading'] as num?)?.toDouble(),
    nextStopName: json['next_stop_name'] as String?,
    etaMinutes: json['eta_minutes'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'bus_id': busId,
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': timestamp.toIso8601String(),
    'speed_kmh': speedKmh,
    'heading': heading,
    'next_stop_name': nextStopName,
    'eta_minutes': etaMinutes,
  };
}

/// A stop on a bus route.
class BusStop {
  const BusStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.sequence,
    this.scheduledTime,
    this.reached = false,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;

  /// Order of this stop in the route.
  final int sequence;
  final String? scheduledTime;
  final bool reached;

  factory BusStop.fromJson(Map<String, dynamic> json) => BusStop(
    id: json['id'] as String,
    name: json['name'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    sequence: (json['sequence'] as int?) ?? 0,
    scheduledTime: json['scheduled_time'] as String?,
    reached: (json['reached'] as bool?) ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'sequence': sequence,
    'scheduled_time': scheduledTime,
    'reached': reached,
  };
}
