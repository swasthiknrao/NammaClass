import '../../core/models/result.dart';
import '../entities/attendance_entities.dart';

abstract class AttendanceRepository {
  Future<Result<List<AttendanceDayEntity>>> getAttendanceDays();

  Future<Result<bool>> submitClassAttendance({
    required String tenantId,
    required String classSection,
    required DateTime date,
    required String teacherUserId,
    required Map<String, String> recordsByStudentId,
  });
}
