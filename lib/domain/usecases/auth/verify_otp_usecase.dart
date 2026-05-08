import '../../../core/models/result.dart';
import '../../entities/auth_credentials.dart';
import '../../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  VerifyOtpUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<Result<AuthCredentials>> execute({
    required String phone,
    required String code,
  }) {
    return _authRepository.verifyOtp(phone: phone, code: code);
  }
}
