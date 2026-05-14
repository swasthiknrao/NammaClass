import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/demo_permissions.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/secure_storage_provider.dart';
import '../../../core/services/audit_log.dart';
import '../../../core/services/secure_storage.dart';

// ── Auth state ─────────────────────────────────────────────────────────────────
class AuthState {
  const AuthState({
    this.isAuthenticated = false,
    this.currentUser,
    this.isLoading = false,
  });

  final bool isAuthenticated;
  final UserModel? currentUser;
  final bool isLoading;

  UserRole? get role => currentUser?.role;

  AuthState copyWith({
    bool? isAuthenticated,
    UserModel? currentUser,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({SecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? SecureStorage(),
      super(const AuthState());

  final SecureStorage _secureStorage;

  void loginAs(UserModel user) {
    state = AuthState(isAuthenticated: true, currentUser: user);
    AuditLog.instance.log(
      'login_success',
      role: user.role.name,
      userId: user.id,
      details: 'demo_or_otp',
    );
  }

  Future<void> logout() async {
    final role = state.role?.name;
    final userId = state.currentUser?.id;
    state = const AuthState();
    await _secureStorage.clearAuth();
    AuditLog.instance.log('logout', role: role, userId: userId);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(secureStorage: ref.read(secureStorageProvider)),
);

// Convenience providers
final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(authProvider).isAuthenticated,
);

final currentUserProvider = Provider<UserModel?>(
  (ref) => ref.watch(authProvider).currentUser,
);

final userRoleProvider = Provider<UserRole?>(
  (ref) => ref.watch(authProvider).role,
);

/// Demo JWT-style claims for the signed-in role — drives fine-grained UI gates
/// until a real ACL API exists.
final demoPermissionsProvider = Provider<List<String>>((ref) {
  final role = ref.watch(userRoleProvider);
  if (role == null) return const [];
  return demoPermissionsForRole(role);
});
