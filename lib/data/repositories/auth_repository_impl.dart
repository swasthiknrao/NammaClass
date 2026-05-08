import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/config/env_config.dart';
import '../../core/models/result.dart';
import '../../core/network/jwt_tokens.dart';
import '../../core/services/secure_storage.dart';
import '../../domain/constants/demo_tenant.dart';
import '../../domain/entities/auth_credentials.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required Dio dio, required SecureStorage secureStorage})
    : _dio = dio,
      _secure = secureStorage;

  final Dio _dio;
  final SecureStorage _secure;

  @override
  Future<Result<bool>> sendOtp(String phone) async {
    if (EnvConfig.apiBaseUrl.isEmpty) {
      return const ResultError(
        'OTP requires API_BASE_URL (dart-define). Use demo role login meanwhile.',
      );
    }
    try {
      await _dio.post<Map<String, dynamic>>(
        '/auth/otp/send',
        data: {'phone': phone},
      );
      return const ResultSuccess(true);
    } on DioException catch (e) {
      return ResultError(
        e.message ?? 'Network error',
        code: e.response?.statusCode,
        exception: e,
      );
    }
  }

  @override
  Future<Result<AuthCredentials>> verifyOtp({
    required String phone,
    required String code,
  }) async {
    if (EnvConfig.apiBaseUrl.isEmpty) {
      return const ResultError(
        'OTP login requires API_BASE_URL. Use demo role login.',
      );
    }
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/otp/verify',
        data: {'phone': phone, 'code': code},
      );
      final data = res.data;
      if (data == null) {
        return const ResultError('Empty response');
      }
      final access = data['access_token'] as String? ?? '';
      final refresh = data['refresh_token'] as String? ?? '';
      final payload = decodeJwtPayload(access) ?? {};
      final creds = AuthCredentials(
        accessToken: access,
        refreshToken: refresh,
        userId: payload['sub']?.toString() ?? '',
        tenantId: payload['tenant_id']?.toString() ?? kDemoTenantId,
        branchId: payload['branch_id']?.toString(),
        displayName: payload['name']?.toString() ?? phone,
        phone: phone,
        roleName: payload['role']?.toString() ?? 'parent',
        permissions: permissionsFromPayload(payload),
      );
      await persistSession(creds);
      return ResultSuccess(creds);
    } on DioException catch (e) {
      return ResultError(
        e.message ?? 'Verification failed',
        code: e.response?.statusCode,
        exception: e,
      );
    }
  }

  @override
  Future<Result<AuthCredentials>> demoLogin({
    required String userId,
    required String displayName,
    required String phone,
    required String roleName,
    String? tenantId,
    String? branchId,
    List<String>? permissions,
  }) async {
    final tid = tenantId ?? kDemoTenantId;
    final perms = permissions ?? const <String>[];
    final payload = <String, dynamic>{
      'sub': userId,
      'tenant_id': tid,
      'branch_id': branchId,
      'role': roleName,
      'name': displayName,
      'phone': phone,
      'permissions': perms,
    };
    final access = buildUnsignedJwt(payload);
    final refresh = buildUnsignedJwt({...payload, 'typ': 'refresh'});
    final creds = AuthCredentials(
      accessToken: access,
      refreshToken: refresh,
      userId: userId,
      tenantId: tid,
      branchId: branchId,
      displayName: displayName,
      phone: phone,
      roleName: roleName,
      permissions: perms,
    );
    await persistSession(creds);
    return ResultSuccess(creds);
  }

  @override
  Future<void> persistSession(AuthCredentials credentials) async {
    await _secure.writeAuthToken(credentials.accessToken);
    await _secure.writeRefreshToken(credentials.refreshToken);
    await _secure.writeUserId(credentials.userId);
    await _secure.writeTenantId(credentials.tenantId);
    if (credentials.branchId != null && credentials.branchId!.isNotEmpty) {
      await _secure.writeBranchId(credentials.branchId!);
    } else {
      await _secure.removeBranchId();
    }
    await _secure.writePermissionsJson(jsonEncode(credentials.permissions));
  }

  @override
  Future<void> clearLocalSession() async {
    await _secure.clearAuth();
  }
}
