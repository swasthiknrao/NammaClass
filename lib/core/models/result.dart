// Result sealed class — prepared for API integration.
// Single source of truth; supports both HTTP code and exception for errors.
sealed class Result<T> {
  const Result();
}

final class ResultSuccess<T> extends Result<T> {
  const ResultSuccess(this.data);
  final T data;
}

final class ResultError<T> extends Result<T> {
  const ResultError(this.message, {this.code, this.exception});
  final String message;
  final int? code;
  final Object? exception;
}
