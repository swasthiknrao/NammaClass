import '../models/result.dart';

/// Placeholder for auth service. Implement when backend is integrated.
abstract class AuthService {
  Future<Result<void>> signIn(String email, String password);
  Future<void> signOut();
  bool get isAuthenticated;
}
