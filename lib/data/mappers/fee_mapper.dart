import '../mock/mock_data.dart';
import '../../domain/entities/fee_installment_entity.dart';

MockFeeInstallment mockFeeFromEntity(FeeInstallmentEntity e) {
  return MockFeeInstallment(
    id: e.id,
    label: e.label,
    amountPaise: e.amountPaise,
    dueDate: e.dueDate,
    status: e.status,
    paidDate: e.paidDate,
    transactionId: e.transactionId,
  );
}
