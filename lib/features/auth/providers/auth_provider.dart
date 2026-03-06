import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_model.dart';

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
  AuthNotifier() : super(const AuthState());

  void loginAs(UserModel user) {
    state = AuthState(isAuthenticated: true, currentUser: user);
  }

  void logout() {
    state = const AuthState();
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
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
