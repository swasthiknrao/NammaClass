import 'package:flutter/foundation.dart' show kIsWeb;

/// Platform helpers (e.g. is Web, is Desktop).
class PlatformUtils {
  PlatformUtils._();

  static bool get isWebPlatform => kIsWeb;
}
