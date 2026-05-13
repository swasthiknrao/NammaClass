/// A school/college notice or circular visible to one or more user roles.
class NoticeEntity {
  const NoticeEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.category,
    this.isRead = false,
    this.hasAttachment = false,
    this.targetUserId,
    this.attachmentUrl,
  });

  final String id;
  final String title;
  final String body;
  final DateTime date;

  /// e.g. "general" | "academic" | "event" | "fee" | "exam"
  final String category;
  final bool isRead;
  final bool hasAttachment;

  /// When non-null this notice is shown only to the user with this ID.
  final String? targetUserId;
  final String? attachmentUrl;

  factory NoticeEntity.fromJson(Map<String, dynamic> json) => NoticeEntity(
    id: json['id'] as String,
    title: json['title'] as String,
    body: json['body'] as String,
    date: DateTime.parse(json['date'] as String),
    category: (json['category'] as String?) ?? 'general',
    isRead: (json['is_read'] as bool?) ?? false,
    hasAttachment: (json['has_attachment'] as bool?) ?? false,
    targetUserId: json['target_user_id'] as String?,
    attachmentUrl: json['attachment_url'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'date': date.toIso8601String(),
    'category': category,
    'is_read': isRead,
    'has_attachment': hasAttachment,
    'target_user_id': targetUserId,
    'attachment_url': attachmentUrl,
  };
}
