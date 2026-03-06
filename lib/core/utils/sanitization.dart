/// Input sanitization for security-aware forms. Use before validation and submission.
class Sanitization {
  Sanitization._();

  static const int defaultMaxLength = 1000;

  /// Trim and optionally enforce max length.
  static String sanitize(
    String? value, {
    int maxLength = defaultMaxLength,
  }) {
    if (value == null) return '';
    var s = value.trim();
    if (s.length > maxLength) s = s.substring(0, maxLength);
    return s;
  }

  /// For email: trim and lower case, then apply max length.
  static String sanitizeEmail(String? value) {
    if (value == null) return '';
    final s = value.trim().toLowerCase();
    if (s.length > 254) return s.substring(0, 254);
    return s;
  }
}
