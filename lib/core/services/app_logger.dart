import 'package:flutter/foundation.dart';

/// Central logging. In debug: prints to console. Later can send to backend.
/// Do not log tokens, full phone numbers, or passwords.
class AppLogger {
  AppLogger._();
  static final AppLogger _instance = AppLogger._();
  static AppLogger get instance => _instance;

  void debug(String message, [Object? error, StackTrace? stack]) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[NammaClass] $message');
      if (error != null) {
        // ignore: avoid_print
        print(error);
        if (stack != null) {
          // ignore: avoid_print
          print(stack);
        }
      }
    }
  }

  void info(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[NammaClass] $message');
    }
  }

  void warn(String message, [Object? error]) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[NammaClass WARN] $message');
      if (error != null) {
        // ignore: avoid_print
        print(error);
      }
    }
  }

  void error(String message, [Object? error, StackTrace? stack]) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[NammaClass ERROR] $message');
      if (error != null) {
        // ignore: avoid_print
        print(error);
        if (stack != null) {
          // ignore: avoid_print
          print(stack);
        }
      }
    }
  }
}
