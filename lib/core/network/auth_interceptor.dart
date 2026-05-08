import 'package:dio/dio.dart';

import '../services/secure_storage.dart';

/// Injects Bearer token; attempts refresh on 401 when backend is configured.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  final SecureStorage _storage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.readAuthToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _storage.readRefreshToken();
      if (refreshed != null && refreshed.isNotEmpty) {
        // Placeholder: real refresh would POST /auth/refresh and write new tokens.
        // When API_BASE_URL is empty, skip retry loop.
      }
    }
    handler.next(err);
  }
}
