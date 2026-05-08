import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

/// Secure storage wrapper for auth tokens and sensitive data.
/// Use this instead of SharedPreferences for tokens.
class SecureStorage {
  SecureStorage({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  final FlutterSecureStorage _storage;

  Future<void> writeAuthToken(String value) async {
    await _storage.write(key: StorageKeys.authToken, value: value);
  }

  Future<String?> readAuthToken() async {
    return _storage.read(key: StorageKeys.authToken);
  }

  Future<void> writeRefreshToken(String value) async {
    await _storage.write(key: StorageKeys.refreshToken, value: value);
  }

  Future<String?> readRefreshToken() async {
    return _storage.read(key: StorageKeys.refreshToken);
  }

  Future<void> writeUserId(String value) async {
    await _storage.write(key: StorageKeys.userId, value: value);
  }

  Future<String?> readUserId() async {
    return _storage.read(key: StorageKeys.userId);
  }

  Future<void> writeTenantId(String value) async {
    await _storage.write(key: StorageKeys.tenantId, value: value);
  }

  Future<String?> readTenantId() async {
    return _storage.read(key: StorageKeys.tenantId);
  }

  Future<void> writeBranchId(String value) async {
    await _storage.write(key: StorageKeys.branchId, value: value);
  }

  Future<String?> readBranchId() async {
    return _storage.read(key: StorageKeys.branchId);
  }

  Future<void> removeBranchId() async {
    await _storage.delete(key: StorageKeys.branchId);
  }

  Future<void> writePermissionsJson(String value) async {
    await _storage.write(key: StorageKeys.permissionsJson, value: value);
  }

  Future<String?> readPermissionsJson() async {
    return _storage.read(key: StorageKeys.permissionsJson);
  }

  /// Clear all auth-related keys. Call on logout.
  Future<void> clearAuth() async {
    await _storage.delete(key: StorageKeys.authToken);
    await _storage.delete(key: StorageKeys.refreshToken);
    await _storage.delete(key: StorageKeys.userId);
    await _storage.delete(key: StorageKeys.tenantId);
    await _storage.delete(key: StorageKeys.branchId);
    await _storage.delete(key: StorageKeys.permissionsJson);
  }
}
