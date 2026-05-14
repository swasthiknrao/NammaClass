import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'page_transitions.dart';
import '../features/main_shell.dart';
import '../features/namma_ai/screens/namma_ai_screen.dart';
import '../features/shared/profile/profile_screen.dart';
import '../features/warden/screens/warden_concierge_screen.dart';
import '../features/warden/screens/warden_dining_screen.dart';
import '../features/warden/screens/warden_home_screen.dart';
import '../features/warden/screens/warden_night_patrol_screen.dart';
import '../features/warden/screens/warden_outpass_screen.dart';
import '../features/warden/screens/warden_rooms_screen.dart';
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
        path: AppRoutes.wardenDining,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const WardenDiningScreen()),
      ),
      GoRoute(
        path: AppRoutes.wardenRooms,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const WardenRoomsScreen()),
      ),
      GoRoute(
        path: AppRoutes.wardenNightPatrol,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const WardenNightPatrolScreen()),
      ),
      GoRoute(
        path: AppRoutes.wardenConcierge,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const WardenConciergeScreen()),
      ),
      GoRoute(
        path: AppRoutes.wardenProfile,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, const ProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.nammaAi,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, const NammaAiScreen()),
      ),
    ],
  ),
];
