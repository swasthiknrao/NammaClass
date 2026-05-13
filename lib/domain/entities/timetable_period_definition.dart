/// One row in the school bell / period schedule (mock-backed).
class TimetablePeriodDefinition {
  const TimetablePeriodDefinition({
    required this.index,
    required this.label,
    required this.startLabel,
    required this.endLabel,
  });

  final int index;
  final String label;
  final String startLabel;
  final String endLabel;

  TimetablePeriodDefinition copyWith({
    int? index,
    String? label,
    String? startLabel,
    String? endLabel,
  }) {
    return TimetablePeriodDefinition(
      index: index ?? this.index,
      label: label ?? this.label,
      startLabel: startLabel ?? this.startLabel,
      endLabel: endLabel ?? this.endLabel,
    );
  }
}
