import '../../core/config/env_config.dart';
import '../../core/models/result.dart';

/// Contract for HTTP API client. Implement with dio or http and inject via Riverpod.
/// Add interceptors for: auth token, refresh token, CSRF header, rate limiting.
abstract class ApiClient {
  String get baseUrl => EnvConfig.apiBaseUrl;

  Future<Result<Map<String, dynamic>>> get(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  });

  Future<Result<Map<String, dynamic>>> post(
    String path, {
    dynamic body,
    Map<String, String>? headers,
  });

  Future<Result<Map<String, dynamic>>> put(
    String path, {
    dynamic body,
    Map<String, String>? headers,
  });

  Future<Result<void>> delete(String path, {Map<String, String>? headers});
}
