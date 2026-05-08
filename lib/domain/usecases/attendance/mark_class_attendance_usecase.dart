import '../../../core/models/result.dart';
import '../../repositories/attendance_repository.dart';

class MarkClassAttendanceParams {
  MarkClassAttendanceParams({
    required this.tenantId,
    required this.classSection,
    required this.date,
    required this.teacherUserId,
    required this.recordsByStudentId,
  });

  final String tenantId;
  final String classSection;
  final DateTime date;
  final String teacherUserId;
  final Map<String, String> recordsByStudentId;
}

class MarkClassAttendanceUseCase {
  MarkClassAttendanceUseCase(this._repository);

  final AttendanceRepository _repository;

  Future<Result<bool>> execute(MarkClassAttendanceParams params) {
    final day = DateTime(params.date.year, params.date.month, params.date.day);
    if (day.isAfter(DateTime.now())) {
      return Future<Result<bool>>.value(
        const ResultError('Cannot mark attendance for future dates'),
      );
    }
    return _repository.submitClassAttendance(
      tenantId: params.tenantId,
      classSection: params.classSection,
      date: day,
      teacherUserId: params.teacherUserId,
      recordsByStudentId: params.recordsByStudentId,
    );
  }
}
