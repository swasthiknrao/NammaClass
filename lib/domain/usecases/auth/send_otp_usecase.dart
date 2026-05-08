import '../../../core/models/result.dart';
import '../../repositories/auth_repository.dart';

class SendOtpUseCase {
  SendOtpUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<Result<bool>> execute(String phone) => _authRepository.sendOtp(phone);
}
