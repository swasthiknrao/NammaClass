import '../../core/models/result.dart';
import '../entities/student_entity.dart';

class StudentPage {
  const StudentPage({
    required this.items,
    required this.offset,
    required this.hasMore,
  });

  final List<StudentEntity> items;
  final int offset;
  final bool hasMore;
}

abstract class StudentRepository {
  Future<Result<StudentPage>> getStudents({
    required int limit,
    required int offset,
    String? classSection,
  });
}
