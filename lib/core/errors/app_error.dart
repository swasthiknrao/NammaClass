/// Application error type for consistent handling.
/// Use with Result or catch blocks to map to user-facing messages.
class AppError implements Exception {
  AppError(this.message, {this.code, this.original});

  final String message;
  final int? code;
  final Object? original;

  @override
  String toString() =>
      'AppError: $message${code != null ? ' (code: $code)' : ''}';
}
