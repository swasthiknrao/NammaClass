import '../features/auth/providers/auth_provider.dart';
import 'app_routes.dart';

/// Role-based route guard — reads auth + role state and redirects.
String? routeGuard(String path, AuthState authState) {
  final isAuth = authState.isAuthenticated;
  final role = authState.role;

  final publicPaths = {AppRoutes.splash, AppRoutes.login, AppRoutes.otp};

  if (!isAuth) {
    if (!publicPaths.contains(path)) {
      return AppRoutes.login;
    }
    return null;
  }

  // Authenticated — redirect from splash/login to role home
  if (path == AppRoutes.splash || path == AppRoutes.login || path == '/') {
    return _roleHome(role);
  }

  return null;
}

String _roleHome(dynamic role) {
  if (role == null) return AppRoutes.login;
  switch (role.toString().split('.').last) {
    case 'parent':
      return AppRoutes.parentHome;
    case 'teacher':
      return AppRoutes.teacherHome;
    case 'student':
      return AppRoutes.studentHome;
    case 'admin':
    case 'principal':
      return AppRoutes.adminHome;
    default:
      return AppRoutes.login;
  }
}
