/// Minimal audit event for security-sensitive actions.
/// Logged in memory; can be sent to backend when integrated.
class AuditEvent {
  const AuditEvent({
    required this.action,
    required this.timestamp,
    this.role,
    this.userId,
    this.details,
  });

  final String action;
  final DateTime timestamp;
  final String? role;
  final String? userId;
  final String? details;

  Map<String, dynamic> toMap() => {
    'action': action,
    'timestamp': timestamp.toIso8601String(),
    if (role != null) 'role': role,
    if (userId != null) 'userId': userId,
    if (details != null) 'details': details,
  };
}

/// In-memory audit log for auth and sensitive actions.
/// Do not log tokens, full phone numbers, or passwords.
class AuditLog {
  AuditLog._();
  static final AuditLog _instance = AuditLog._();
  static AuditLog get instance => _instance;

  static const int _maxEvents = 200;
  final List<AuditEvent> _events = [];

  List<AuditEvent> get events => List.unmodifiable(_events);

  void log(String action, {String? role, String? userId, String? details}) {
    _events.add(
      AuditEvent(
        action: action,
        timestamp: DateTime.now(),
        role: role,
        userId: userId,
        details: details,
      ),
    );
    while (_events.length > _maxEvents) {
      _events.removeAt(0);
    }
  }

  void clear() => _events.clear();
}
