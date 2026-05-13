import '../../core/mock/mock_data.dart';
import '../../domain/entities/student_entity.dart';

MockStudent mockStudentFromEntity(StudentEntity e) {
  return MockStudent(
    id: e.id,
    name: e.name,
    rollNo: e.rollNo,
    classSection: e.classSection,
    attendancePercent: e.attendancePercent,
    avatarUrl: e.avatarUrl,
    parentName: e.parentName,
    parentPhone: e.parentPhone,
    feeStatus: e.feeStatus,
  );
}
