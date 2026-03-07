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

  /// Clear all auth-related keys. Call on logout.
  Future<void> clearAuth() async {
    await _storage.delete(key: StorageKeys.authToken);
    await _storage.delete(key: StorageKeys.refreshToken);
    await _storage.delete(key: StorageKeys.userId);
  }
}
