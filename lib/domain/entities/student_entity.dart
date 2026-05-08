/// Pure domain student — mirrors MockStudent fields + tenant scope.
class StudentEntity {
  const StudentEntity({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.rollNo,
    required this.classSection,
    required this.attendancePercent,
    this.avatarUrl,
    this.parentName,
    this.parentPhone,
    this.feeStatus = 'paid',
  });

  final String id;
  final String tenantId;
  final String name;
  final String rollNo;
  final String classSection;
  final double attendancePercent;
  final String? avatarUrl;
  final String? parentName;
  final String? parentPhone;
  final String feeStatus;
}
