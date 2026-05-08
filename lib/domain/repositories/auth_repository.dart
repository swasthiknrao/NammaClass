import '../../core/models/result.dart';
import '../entities/auth_credentials.dart';

abstract class AuthRepository {
  Future<Result<AuthCredentials>> verifyOtp({
    required String phone,
    required String code,
  });

  Future<Result<bool>> sendOtp(String phone);

  /// Demo login used by role-picker — issues synthetic JWT-shaped credentials.
  Future<Result<AuthCredentials>> demoLogin({
    required String userId,
    required String displayName,
    required String phone,
    required String roleName,
    String? tenantId,
    String? branchId,
    List<String>? permissions,
  });

  Future<void> persistSession(AuthCredentials credentials);

  Future<void> clearLocalSession();
}
