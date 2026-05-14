import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'page_transitions.dart';
import '../features/driver/screens/driver_home_screen.dart';
import '../features/driver/screens/driver_incident_report_screen.dart';
import '../features/driver/screens/driver_route_screen.dart';
import '../features/driver/screens/driver_students_screen.dart';
import '../features/driver/screens/driver_trip_history_screen.dart';
import '../features/driver/screens/driver_vehicle_checklist_screen.dart';
import '../features/main_shell.dart';
import '../features/namma_ai/screens/namma_ai_screen.dart';
import '../features/shared/profile/profile_screen.dart';
import 'app_routes.dart';

List<RouteBase> driverShellRoutes(GlobalKey<NavigatorState> navigatorKey) => [
  ShellRoute(
    navigatorKey: navigatorKey,
    builder: (context, state, child) => MainShell(child: child),
    routes: [
      GoRoute(
        path: AppRoutes.driverHome,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const DriverHomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.driverRoute,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const DriverRouteScreen()),
      ),
      GoRoute(
        path: AppRoutes.driverStudents,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const DriverStudentsScreen()),
      ),
      GoRoute(
        path: AppRoutes.driverProfile,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, const ProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.driverTripHistory,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const DriverTripHistoryScreen()),
      ),
      GoRoute(
        path: AppRoutes.driverVehicleChecklist,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const DriverVehicleChecklistScreen()),
      ),
      GoRoute(
        path: AppRoutes.driverIncidentReport,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const DriverIncidentReportScreen()),
      ),
      GoRoute(
        path: AppRoutes.nammaAi,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, const NammaAiScreen()),
      ),
    ],
  ),
];
