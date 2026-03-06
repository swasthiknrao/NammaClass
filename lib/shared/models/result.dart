/// Result type for async operations. Use when integrating API calls.
sealed class Result<T> {
  const Result();
}

final class ResultSuccess<T> extends Result<T> {
  const ResultSuccess(this.data);
  final T data;
}

final class ResultError<T> extends Result<T> {
  const ResultError(this.message, [this.exception]);
  final String message;
  final Object? exception;
}
