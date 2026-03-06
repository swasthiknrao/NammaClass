import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/route_config.dart';

/// Placeholder auth state. When backend is integrated, replace with real auth.
final isAuthenticatedProvider = StateProvider<bool>((ref) => true);

/// Route guard: returns redirect path if user must be sent elsewhere (e.g. login).
String? routeGuard(String location, bool isAuthenticated) {
  final isLoginRoute = location == RouteConfig.login || location.startsWith('${RouteConfig.login}/');
  if (!isAuthenticated && !isLoginRoute) {
    return RouteConfig.login;
  }
  if (isAuthenticated && isLoginRoute) {
    return RouteConfig.home;
  }
  return null;
}
