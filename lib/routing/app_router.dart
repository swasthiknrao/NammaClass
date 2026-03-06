import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/route_config.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/presentation/shell_screen.dart';
import 'page_transitions.dart';
import 'route_guard.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// App router provider. Uses route guard for auth redirect.
final goRouterProvider = Provider<GoRouter>((ref) {
  ref.watch(isAuthenticatedProvider);
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteConfig.home,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuth = ref.read(isAuthenticatedProvider);
      return routeGuard(state.uri.path, isAuth);
    },
    routes: [
      GoRoute(
        path: RouteConfig.login,
        pageBuilder: (context, state) => fadeSlideTransition(context, state, const LoginScreen()),
      ),
      ShellRoute(
        builder: (context, state, child) => ShellScreen(child: child),
        routes: [
          GoRoute(
            path: RouteConfig.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: RouteConfig.dashboard,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: RouteConfig.settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
