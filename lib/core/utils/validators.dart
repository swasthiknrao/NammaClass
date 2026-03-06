/// Centralized input validators. Return null if valid, error message if invalid.
/// Use in TextFormField.validator and before submitting forms.
class Validators {
  Validators._();

  static const int passwordMinLength = 8;
  static const int passwordMaxLength = 128;
  static const int emailMaxLength = 254;
  static const int generalMaxLength = 500;

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final trimmed = value.trim();
    if (trimmed.length > emailMaxLength) return 'Email is too long';
    final pattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!pattern.hasMatch(trimmed)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (value.length < passwordMinLength) {
      return 'Password must be at least $passwordMinLength characters';
    }
    if (value.length > passwordMaxLength) {
      return 'Password must be at most $passwordMaxLength characters';
    }
    return null;
  }

  static String? maxLength(String? value, int max) {
    if (value == null) return null;
    if (value.length > max) return 'Must be at most $max characters';
    return null;
  }

  static String? minLength(String? value, int min) {
    if (value == null || value.isEmpty) return null;
    if (value.length < min) return 'Must be at least $min characters';
    return null;
  }

  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final v in validators) {
      final error = v(value);
      if (error != null) return error;
    }
    return null;
  }
}
