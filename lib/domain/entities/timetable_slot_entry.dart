/// One cell in the class timetable grid (mock-backed).
class TimetableSlotEntry {
  const TimetableSlotEntry({
    required this.subject,
    required this.facultyId,
    required this.facultyName,
    this.isLab = false,
    this.labSpan = 1,
  });

  final String subject;
  final String facultyId;
  final String facultyName;
  final bool isLab;
  final int labSpan;

  TimetableSlotEntry copyWith({
    String? subject,
    String? facultyId,
    String? facultyName,
    bool? isLab,
    int? labSpan,
  }) {
    return TimetableSlotEntry(
      subject: subject ?? this.subject,
      facultyId: facultyId ?? this.facultyId,
      facultyName: facultyName ?? this.facultyName,
      isLab: isLab ?? this.isLab,
      labSpan: labSpan ?? this.labSpan,
    );
  }
}
