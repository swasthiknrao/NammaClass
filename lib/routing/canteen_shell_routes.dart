import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'page_transitions.dart';
import '../features/canteen/screens/canteen_counter_screen.dart';
import '../features/canteen/screens/canteen_manager_screen.dart';
import '../features/main_shell.dart';
import '../features/shared/profile/profile_screen.dart';
import 'app_routes.dart';

List<RouteBase> canteenShellRoutes(GlobalKey<NavigatorState> navigatorKey) => [
  ShellRoute(
    navigatorKey: navigatorKey,
    builder: (context, state, child) => MainShell(child: child),
    routes: [
      GoRoute(
        path: AppRoutes.canteenCounter,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const CanteenCounterScreen()),
      ),
      GoRoute(
        path: AppRoutes.canteenManage,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const CanteenManagerScreen()),
      ),
      GoRoute(
        path: AppRoutes.canteenProfile,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, const ProfileScreen()),
      ),
    ],
  ),
];
