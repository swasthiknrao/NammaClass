/// Display metadata for a timetable class section (grid key stays [sectionId]).
class ClassSectionMeta {
  const ClassSectionMeta({
    required this.programName,
    required this.yearLabel,
    required this.sectionLetter,
    this.departmentName = '',
  });

  final String programName;
  final String yearLabel;
  final String sectionLetter;

  /// Academic / admin department (stream, faculty pool). Optional — helps smart picks.
  final String departmentName;

  /// e.g. "BCA VIII-A" or "BCA VIII-A · Science" when department set.
  String get dropdownLabel {
    final core = '$yearLabel-$sectionLetter';
    final p = programName.trim();
    final d = departmentName.trim();
    if (p.isEmpty && d.isEmpty) return core;
    if (p.isEmpty) return d.isEmpty ? core : '$d $core';
    if (d.isEmpty) return '$p $core';
    return '$p $core · $d';
  }
}
