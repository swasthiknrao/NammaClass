import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/result.dart';
import 'api_client.dart';

/// Stub implementation until backend is integrated.
/// Replace with real implementation (e.g. DioApiClient) and register here.
class StubApiClient extends ApiClient {
  @override
  Future<Result<Map<String, dynamic>>> get(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async => ResultError<Map<String, dynamic>>('API not configured');

  @override
  Future<Result<Map<String, dynamic>>> post(
    String path, {
    dynamic body,
    Map<String, String>? headers,
  }) async => ResultError<Map<String, dynamic>>('API not configured');

  @override
  Future<Result<Map<String, dynamic>>> put(
    String path, {
    dynamic body,
    Map<String, String>? headers,
  }) async => ResultError<Map<String, dynamic>>('API not configured');

  @override
  Future<Result<void>> delete(
    String path, {
    Map<String, String>? headers,
  }) async => ResultError<void>('API not configured');
}

final apiClientProvider = Provider<ApiClient>((ref) => StubApiClient());
