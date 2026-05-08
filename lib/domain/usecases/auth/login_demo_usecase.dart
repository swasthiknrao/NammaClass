import '../../../core/models/result.dart';
import '../../entities/auth_credentials.dart';
import '../../repositories/auth_repository.dart';

class LoginDemoUseCase {
  LoginDemoUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<Result<AuthCredentials>> execute({
    required String userId,
    required String displayName,
    required String phone,
    required String roleName,
    String? tenantId,
    String? branchId,
    List<String>? permissions,
  }) {
    return _authRepository.demoLogin(
      userId: userId,
      displayName: displayName,
      phone: phone,
      roleName: roleName,
      tenantId: tenantId,
      branchId: branchId,
      permissions: permissions,
    );
  }
}
