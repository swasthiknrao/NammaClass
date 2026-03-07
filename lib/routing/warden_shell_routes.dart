import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/main_shell.dart';
import '../features/shared/profile/profile_screen.dart';
import '../features/warden/screens/warden_rollcall_screen.dart';
import '../features/warden/screens/warden_visitors_screen.dart';
import 'app_routes.dart';

List<RouteBase> wardenShellRoutes(GlobalKey<NavigatorState> navigatorKey) => [
  ShellRoute(
    navigatorKey: navigatorKey,
    builder: (context, state, child) => MainShell(child: child),
    routes: [
      GoRoute(
        path: AppRoutes.wardenRollcall,
        pageBuilder: (c, s) =>
            const NoTransitionPage(child: WardenRollcallScreen()),
      ),
      GoRoute(
        path: AppRoutes.wardenVisitors,
        pageBuilder: (c, s) =>
            const NoTransitionPage(child: WardenVisitorsScreen()),
      ),
      GoRoute(
        path: AppRoutes.wardenProfile,
        pageBuilder: (c, s) => const NoTransitionPage(child: ProfileScreen()),
      ),
    ],
  ),
];
