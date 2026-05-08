/// Daily attendance summary (parent/student calendar).
class AttendanceDayEntity {
  const AttendanceDayEntity({
    required this.tenantId,
    required this.date,
    required this.status,
    this.periods = const [],
  });

  final String tenantId;
  final DateTime date;
  final String status;
  final List<String> periods;
}

/// Single mark for batch class attendance (teacher flow).
class ClassAttendanceMarkEntity {
  const ClassAttendanceMarkEntity({
    required this.studentId,
    required this.statusCode,
    required this.clientUuid,
  });

  final String studentId;

  /// 'P' | 'A' | 'L'
  final String statusCode;
  final String clientUuid;
}
