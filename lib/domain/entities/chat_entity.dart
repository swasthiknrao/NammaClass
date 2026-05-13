/// A single message within a chat thread.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    this.attachmentUrl,
  });

  final String id;
  final String threadId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isRead;
  final String? attachmentUrl;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] as String,
    threadId: json['thread_id'] as String,
    senderId: json['sender_id'] as String,
    senderName: (json['sender_name'] as String?) ?? '',
    text: json['text'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    isRead: (json['is_read'] as bool?) ?? false,
    attachmentUrl: json['attachment_url'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'thread_id': threadId,
    'sender_id': senderId,
    'sender_name': senderName,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'is_read': isRead,
    'attachment_url': attachmentUrl,
  };
}

/// A conversation thread between a parent/student and a teacher.
class ChatThread {
  const ChatThread({
    required this.id,
    required this.participantName,
    required this.participantRole,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.avatarUrl,
    this.subject,
  });

  final String id;
  final String participantName;

  /// e.g. "teacher" | "parent" | "admin"
  final String participantRole;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String? avatarUrl;

  /// Subject the teacher teaches (shown in parent–teacher threads).
  final String? subject;

  factory ChatThread.fromJson(Map<String, dynamic> json) => ChatThread(
    id: json['id'] as String,
    participantName: json['participant_name'] as String,
    participantRole: (json['participant_role'] as String?) ?? 'teacher',
    lastMessage: (json['last_message'] as String?) ?? '',
    lastMessageTime: DateTime.parse(json['last_message_time'] as String),
    unreadCount: (json['unread_count'] as int?) ?? 0,
    avatarUrl: json['avatar_url'] as String?,
    subject: json['subject'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'participant_name': participantName,
    'participant_role': participantRole,
    'last_message': lastMessage,
    'last_message_time': lastMessageTime.toIso8601String(),
    'unread_count': unreadCount,
    'avatar_url': avatarUrl,
    'subject': subject,
  };
}
