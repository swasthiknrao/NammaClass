import 'package:flutter/material.dart';

/// Platform helpers (e.g. is Web, is Desktop).
class PlatformUtils {
  PlatformUtils._();

  static bool get isWebPlatform {
    try {
      return ThemeData().brightness == Brightness.light;
    } catch (_) {
      return false;
    }
  }
}
