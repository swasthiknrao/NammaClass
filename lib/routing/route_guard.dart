import '../core/models/user_model.dart';
import '../domain/entities/tenant_profile.dart';
import '../features/auth/providers/auth_provider.dart';
import 'app_routes.dart';
import 'feature_route_manifest.dart';

/// Role-scoped path map — each path prefix is only accessible to specific roles.
/// This prevents horizontal privilege escalation even with a valid auth token.
const _rolePrefixMap = {
  '/parent/': {UserRole.parent},
  '/teacher/': {UserRole.teacher},
  '/student/': {UserRole.student},
  '/admin/': {UserRole.admin, UserRole.principal, UserRole.hod},
  '/staff/': {UserRole.staff, UserRole.teacher},
  '/driver/': {UserRole.driver},
  '/librarian/': {UserRole.librarian},
  '/warden/': {UserRole.warden},
  '/canteen/': {UserRole.canteenStaff},
  '/hod/': {UserRole.hod},
  '/web/': {
    UserRole.admin,
    UserRole.principal,
    UserRole.accountant,
    UserRole.teacher,
    UserRole.librarian,
    UserRole.support,
    UserRole.hod,
    UserRole.superAdmin,
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
///
/// [tenant] is optional — when null, feature gating is skipped (e.g. during
/// splash before the tenant profile has loaded).
String? routeGuard(String path, AuthState authState, [TenantProfile? tenant]) {
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

  if (path == '/web/platform' || path.startsWith('/web/platform/')) {
    const platformRoles = {
      UserRole.superAdmin,
      UserRole.admin,
      UserRole.principal,
    };
    if (role == null || !platformRoles.contains(role)) {
      return _roleHome(role);
    }
    return _checkFeatureGate(path, role, tenant);
  }

  // Allow shared paths for all authenticated users
  if (_sharedAuthPaths.any((p) => path.startsWith(p))) {
    // Still check feature gating for shared feature paths
    return _checkFeatureGate(path, role, tenant);
  }

  // Enforce role-scoped access for prefixed paths
  for (final entry in _rolePrefixMap.entries) {
    if (path.startsWith(entry.key)) {
      if (role == null || !entry.value.contains(role)) {
        // Role not authorised for this path section — bounce to their home
        return _roleHome(role);
      }
      // Role passes — still check feature subscription
      return _checkFeatureGate(path, role, tenant);
    }
  }

  return null;
}

/// Returns a redirect if [path] requires a feature the tenant hasn't subscribed
/// to. Uses [TenantProfile.hasFeature], which prefers `entitlement_snapshot.modules`
/// when present (see repo `docs/schemas/entitlement_snapshot.schema.json`).
///
/// Returns null when [tenant] is null (loading) so routing is not blocked mid-flight.
String? _checkFeatureGate(String path, UserRole? role, TenantProfile? tenant) {
  if (tenant == null) return null;

  for (final gate in featureRouteGates) {
    if (path.startsWith(gate.prefix) && !tenant.hasFeature(gate.feature)) {
      return _roleHome(role);
    }
  }
  return null;
}

/// Mobile home for hod; null for other roles.
String? mobileHomeForExecRole(UserRole? role) {
  switch (role) {
    case UserRole.hod:
      return AppRoutes.hodHome;
    default:
      return null;
  }
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
    case UserRole.accountant:
      return AppRoutes.webAccountantDashboard;
    case UserRole.support:
      return AppRoutes.webSupportDashboard;
    case UserRole.staff:
      return AppRoutes.staffHome;
    case UserRole.driver:
      return AppRoutes.driverRoute;
    case UserRole.librarian:
      return AppRoutes.librarianCounter;
    case UserRole.warden:
      return AppRoutes.wardenHome;
    case UserRole.canteenStaff:
      return AppRoutes.canteenCounter;
    case UserRole.hod:
      return AppRoutes.webHodHome;
    case UserRole.superAdmin:
      return AppRoutes.webPlatformDashboard;
    case null:
      return AppRoutes.login;
  }
}
