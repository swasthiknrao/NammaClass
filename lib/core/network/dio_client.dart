import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env_config.dart';
import '../providers/secure_storage_provider.dart';
import '../services/secure_storage.dart';
import 'auth_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final secure = ref.watch(secureStorageProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: EnvConfig.apiBaseUrl.isEmpty
          ? 'https://api.placeholder.invalid'
          : EnvConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
  dio.interceptors.add(AuthInterceptor(secure));
  return dio;
});

/// Raw Dio without Riverpod — for background isolates if needed.
Dio createDio(SecureStorage secure) {
  final dio = Dio(
    BaseOptions(
      baseUrl: EnvConfig.apiBaseUrl.isEmpty
          ? 'https://api.placeholder.invalid'
          : EnvConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
  dio.interceptors.add(AuthInterceptor(secure));
  return dio;
}
