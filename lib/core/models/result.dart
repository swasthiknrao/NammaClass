// Result sealed class — prepared for API integration.
sealed class Result<T> {
  const Result();
}

class ResultSuccess<T> extends Result<T> {
  const ResultSuccess(this.data);
  final T data;
}

class ResultError<T> extends Result<T> {
  const ResultError(this.message, {this.code});
  final String message;
  final int? code;
}
