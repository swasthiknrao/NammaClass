import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/app_logger.dart';

void main() {
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
