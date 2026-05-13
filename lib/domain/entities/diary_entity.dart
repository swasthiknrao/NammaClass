/// A single subject entry in the class diary for a given date.
class DiaryEntry {
  const DiaryEntry({
    required this.id,
    required this.date,
    required this.subject,
    required this.classwork,
    required this.homework,
    required this.classSection,
    this.teacherName,
    this.dueDate,
    this.hasAttachment = false,
    this.attachmentUrl,
    this.completed = false,
  });

  final String id;
  final DateTime date;
  final String subject;
  final String classwork;
  final String homework;
  final String classSection;
  final String? teacherName;
  final DateTime? dueDate;
  final bool hasAttachment;
  final String? attachmentUrl;

  /// Student-side: whether homework has been marked complete locally.
  final bool completed;

  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    subject: json['subject'] as String,
    classwork: (json['classwork'] as String?) ?? '',
    homework: (json['homework'] as String?) ?? '',
    classSection: (json['class_section'] as String?) ?? '',
    teacherName: json['teacher_name'] as String?,
    dueDate: json['due_date'] != null
        ? DateTime.parse(json['due_date'] as String)
        : null,
    hasAttachment: (json['has_attachment'] as bool?) ?? false,
    attachmentUrl: json['attachment_url'] as String?,
    completed: (json['completed'] as bool?) ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'subject': subject,
    'classwork': classwork,
    'homework': homework,
    'class_section': classSection,
    'teacher_name': teacherName,
    'due_date': dueDate?.toIso8601String(),
    'has_attachment': hasAttachment,
    'attachment_url': attachmentUrl,
    'completed': completed,
  };
}
