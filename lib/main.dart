import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/app_logger.dart';
import 'core/widgets/error_fallback.dart';

void main() {
  ErrorWidget.builder = (details) =>
      ErrorFallback(message: 'Something went wrong', details: details);

  runZonedGuarded<void>(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      runApp(const ProviderScope(child: App()));
    },
    (error, stack) {
      AppLogger.instance.error('Uncaught error', error, stack);
    },
  );
}
