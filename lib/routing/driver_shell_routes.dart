import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/driver/screens/driver_route_screen.dart';
import '../features/driver/screens/driver_students_screen.dart';
import '../features/main_shell.dart';
import '../features/shared/profile/profile_screen.dart';
import 'app_routes.dart';

List<RouteBase> driverShellRoutes(GlobalKey<NavigatorState> navigatorKey) => [
  ShellRoute(
    navigatorKey: navigatorKey,
    builder: (context, state, child) => MainShell(child: child),
    routes: [
      GoRoute(
        path: AppRoutes.driverRoute,
        pageBuilder: (c, s) =>
            const NoTransitionPage(child: DriverRouteScreen()),
      ),
      GoRoute(
        path: AppRoutes.driverStudents,
        pageBuilder: (c, s) =>
            const NoTransitionPage(child: DriverStudentsScreen()),
      ),
      GoRoute(
        path: AppRoutes.driverProfile,
        pageBuilder: (c, s) => const NoTransitionPage(child: ProfileScreen()),
      ),
    ],
  ),
];
