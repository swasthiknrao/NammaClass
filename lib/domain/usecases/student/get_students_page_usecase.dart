import '../../../core/models/result.dart';
import '../../repositories/student_repository.dart';

class GetStudentsPageUseCase {
  GetStudentsPageUseCase(this._repository);

  final StudentRepository _repository;

  Future<Result<StudentPage>> execute({
    required int limit,
    required int offset,
    String? classSection,
  }) {
    return _repository.getStudents(
      limit: limit,
      offset: offset,
      classSection: classSection,
    );
  }
}
