enum UnavailabilityStatus { pending, approved, rejected }

class UnavailabilityRequestEntry {
  const UnavailabilityRequestEntry({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.date,
    required this.periodLabels,
    required this.reason,
    this.status = UnavailabilityStatus.pending,
  });

  final String id;
  final String staffId;
  final String staffName;
  final DateTime date;
  final List<String> periodLabels;
  final String reason;
  final UnavailabilityStatus status;

  UnavailabilityRequestEntry copyWith({UnavailabilityStatus? status}) {
    return UnavailabilityRequestEntry(
      id: id,
      staffId: staffId,
      staffName: staffName,
      date: date,
      periodLabels: periodLabels,
      reason: reason,
      status: status ?? this.status,
    );
  }
}
