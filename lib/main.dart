import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/debug/raw_keyboard_debug_log.dart';
import 'core/mock/mock_bundle_bootstrap.dart';
import 'core/mock/mock_data.dart';
import 'core/providers/app_root_container.dart';
import 'core/services/app_logger.dart';
import 'core/widgets/error_fallback.dart';

Future<void> main() async {
  ErrorWidget.builder = (details) =>
      ErrorFallback(message: 'Something went wrong', details: details);

  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      if (!kReleaseMode) {
        RawKeyboardDebugInstrumentation.install();
      }

      final container = ProviderContainer();
      appRootContainer = container;

      try {
        await loadPersistedBundleIntoMockData();
      } catch (e, st) {
        AppLogger.instance.error('Persisted bundle load failed', e, st);
        MockData.applyJsonBundle(<String, dynamic>{});
      }

      runApp(
        UncontrolledProviderScope(container: container, child: const App()),
      );
    },
    (error, stack) {
      AppLogger.instance.error('Uncaught error', error, stack);
    },
  );
}
