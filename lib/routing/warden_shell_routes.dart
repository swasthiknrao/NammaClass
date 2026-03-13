import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'page_transitions.dart';
import '../features/main_shell.dart';
import '../features/shared/profile/profile_screen.dart';
import '../features/warden/screens/warden_home_screen.dart';
import '../features/warden/screens/warden_outpass_screen.dart';
import '../features/warden/screens/warden_rollcall_screen.dart';
import '../features/warden/screens/warden_visitors_screen.dart';
import 'app_routes.dart';

List<RouteBase> wardenShellRoutes(GlobalKey<NavigatorState> navigatorKey) => [
  ShellRoute(
    navigatorKey: navigatorKey,
    builder: (context, state, child) => MainShell(child: child),
    routes: [
      GoRoute(
        path: AppRoutes.wardenHome,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const WardenHomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.wardenRollcall,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const WardenRollcallScreen()),
      ),
      GoRoute(
        path: AppRoutes.wardenVisitors,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const WardenVisitorsScreen()),
      ),
      GoRoute(
        path: AppRoutes.wardenOutpass,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const WardenOutpassScreen()),
      ),
      GoRoute(
        path: AppRoutes.wardenProfile,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, const ProfileScreen()),
      ),
    ],
  ),
];
