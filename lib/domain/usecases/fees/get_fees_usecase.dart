import '../../../core/models/result.dart';
import '../../entities/fee_installment_entity.dart';
import '../../repositories/fees_repository.dart';

class GetFeesUseCase {
  GetFeesUseCase(this._repository);

  final FeesRepository _repository;

  Future<Result<List<FeeInstallmentEntity>>> execute({
    required String tenantId,
    required String studentId,
  }) {
    return _repository.getFeesForStudent(
      tenantId: tenantId,
      studentId: studentId,
    );
  }
}
