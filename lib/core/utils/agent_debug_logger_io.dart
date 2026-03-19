import 'dart:convert';
import 'dart:io';

class AgentDebugLogger {
  static const String _logPath = 'debug-c2209d.log';
  static const String _sessionId = 'c2209d';

  static void log({
    required String hypothesisId,
    required String location,
    required String message,
    required Map<String, Object?> data,
    String runId = 'pre-fix',
  }) {
    try {
      final payload = <String, Object?>{
        'sessionId': _sessionId,
        'runId': runId,
        'hypothesisId': hypothesisId,
        'location': location,
        'message': message,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      final line = jsonEncode(payload);
      File(_logPath).writeAsStringSync('$line\n', mode: FileMode.append);
    } catch (_) {
      // Never crash the app due to logging.
    }
  }
}
