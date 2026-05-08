class FeeInstallmentEntity {
  const FeeInstallmentEntity({
    required this.id,
    required this.tenantId,
    required this.label,
    required this.amountPaise,
    required this.dueDate,
    required this.status,
    this.paidDate,
    this.transactionId,
  });

  final String id;
  final String tenantId;
  final String label;
  final int amountPaise;
  final DateTime dueDate;
  final String status;
  final DateTime? paidDate;
  final String? transactionId;
}
