import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';

/// Session debug log for Windows RawKeyboard assertion investigation.
/// Writes NDJSON lines to [logFileName] in the process current working directory.
// #region agent log
const String _logFileName = 'debug-9fba24.log';
const String _sessionId = '9fba24';

void _ndjson({
  required String hypothesisId,
  required String location,
  required String message,
  Map<String, Object?>? data,
  String runId = 'pre-fix',
}) {
  try {
    final payload = <String, Object?>{
      'sessionId': _sessionId,
      'runId': runId,
      'hypothesisId': hypothesisId,
      'location': location,
      'message': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'data': data,
    };
    File(_logFileName).writeAsStringSync(
      '${jsonEncode(payload)}\n',
      mode: FileMode.append,
      flush: true,
    );
  } catch (_) {}
}

/// H1: App lifecycle / focus changes clear or desync keyboard state before Alt down.
/// H2: HardwareKeyboard KeyEvent sequence shows Alt without matching prior state.
/// H3: RawKeyboard listener shows keysPressed empty right before/after problematic transitions.
/// H4: FlutterError captures the RawKeyboard assertion for timestamp correlation.
/// H5: First key activity after resume/hot reload correlates with the crash.
class RawKeyboardDebugInstrumentation {
  RawKeyboardDebugInstrumentation._();

  static bool _installed = false;

  static void install() {
    if (_installed) {
      return;
    }
    _installed = true;

    WidgetsBinding.instance.addObserver(_LifecycleObserver());

    final previousOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final msg = details.exceptionAsString();
      if (msg.contains('keysPressed') ||
          msg.contains('RawKey') ||
          msg.contains('RawKeyboard')) {
        _ndjson(
          hypothesisId: 'H4',
          location: 'FlutterError.onError',
          message: 'keyboard_related_flutter_error',
          data: {
            'summary': details.summary.toString(),
            'exceptionHead': msg.length > 240 ? msg.substring(0, 240) : msg,
          },
        );
      }
      previousOnError?.call(details);
    };
  }
}

class _LifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _ndjson(
      hypothesisId: 'H1',
      location: 'WidgetsBindingObserver.didChangeAppLifecycleState',
      message: 'lifecycle',
      data: {'state': state.name},
    );
  }
}

// #endregion
