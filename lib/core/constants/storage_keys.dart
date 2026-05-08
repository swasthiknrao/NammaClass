/// Storage key constants for future auth/session (e.g. secure storage).
/// Do not store secrets in plain text; use flutter_secure_storage when integrating.
class StorageKeys {
  StorageKeys._();

  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String tenantId = 'tenant_id';
  static const String branchId = 'branch_id';
  static const String permissionsJson = 'permissions_json';
}
