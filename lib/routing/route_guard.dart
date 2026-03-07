import '../core/models/user_model.dart';
import '../features/auth/providers/auth_provider.dart';
import 'app_routes.dart';

/// Role-scoped path map — each path prefix is only accessible to specific roles.
/// This prevents horizontal privilege escalation even with a valid auth token.
const _rolePrefixMap = {
  '/parent/': {UserRole.parent},
  '/teacher/': {UserRole.teacher},
  '/student/': {UserRole.student},
  '/admin/': {UserRole.admin, UserRole.principal},
  '/staff/': {UserRole.staff, UserRole.teacher},
  '/driver/': {UserRole.driver},
  '/librarian/': {UserRole.librarian},
  '/warden/': {UserRole.warden},
  '/canteen/': {UserRole.canteenStaff},
  '/web/': {
    UserRole.admin,
    UserRole.principal,
    UserRole.teacher,
    UserRole.librarian,
    UserRole.support,
  },
};

/// Shared paths accessible to all authenticated users.
const _sharedAuthPaths = {
  AppRoutes.notifications,
  AppRoutes.hostel,
  AppRoutes.events,
  AppRoutes.search,
  '/profile',
};

/// Role-based route guard. Returns redirect path or null to allow navigation.
String? routeGuard(String path, AuthState authState) {
  final isAuth = authState.isAuthenticated;
  final role = authState.role;

  final publicPaths = {AppRoutes.splash, AppRoutes.login, AppRoutes.otp};

  // Unauthenticated users can only access public paths
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

  // Allow shared paths for all authenticated users
  if (_sharedAuthPaths.any((p) => path.startsWith(p))) return null;

  // Enforce role-scoped access for prefixed paths
  for (final entry in _rolePrefixMap.entries) {
    if (path.startsWith(entry.key)) {
      if (role == null || !entry.value.contains(role)) {
        // Role not authorised for this path section — bounce to their home
        return _roleHome(role);
      }
      return null;
    }
  }

  return null;
}

String _roleHome(UserRole? role) {
  switch (role) {
    case UserRole.parent:
      return AppRoutes.parentHome;
    case UserRole.teacher:
      return AppRoutes.teacherHome;
    case UserRole.student:
      return AppRoutes.studentHome;
    case UserRole.admin:
    case UserRole.principal:
      return AppRoutes.adminHome;
    case UserRole.staff:
      return AppRoutes.staffHome;
    case UserRole.driver:
      return AppRoutes.driverRoute;
    case UserRole.librarian:
      return AppRoutes.librarianCounter;
    case UserRole.warden:
      return AppRoutes.wardenRollcall;
    case UserRole.canteenStaff:
      return AppRoutes.canteenCounter;
    case UserRole.support:
    case null:
      return AppRoutes.login;
  }
}
