import '../../core/models/result.dart';
import '../entities/fee_installment_entity.dart';

abstract class FeesRepository {
  Future<Result<List<FeeInstallmentEntity>>> getFeesForStudent({
    required String tenantId,
    required String studentId,
  });

  /// Payments require connectivity — implementations must reject when offline.
  Future<Result<bool>> recordPayment({
    required String tenantId,
    required String installmentId,
    required String transactionReference,
  });
}
