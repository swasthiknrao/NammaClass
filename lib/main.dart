import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/debug/raw_keyboard_debug_log.dart';
import 'core/services/app_logger.dart';
import 'core/widgets/error_fallback.dart';

void main() {
  ErrorWidget.builder = (details) =>
      ErrorFallback(message: 'Something went wrong', details: details);

  runZonedGuarded<void>(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      if (!kReleaseMode) {
        RawKeyboardDebugInstrumentation.install();
      }
      runApp(const ProviderScope(child: App()));
    },
    (error, stack) {
      AppLogger.instance.error('Uncaught error', error, stack);
    },
  );
}
