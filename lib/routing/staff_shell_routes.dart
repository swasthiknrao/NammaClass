import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/main_shell.dart';
import '../features/shared/notifications/notifications_screen.dart';
import '../features/shared/profile/profile_screen.dart';
import '../features/staff/screens/staff_attendance_screen.dart';
import '../features/staff/screens/staff_home_screen.dart';
import '../features/staff/screens/staff_payslips_screen.dart';
import '../features/staff/screens/staff_training_screen.dart';
import '../features/parent/screens/parent_leave_status_screen.dart';
import 'app_routes.dart';

List<RouteBase> staffShellRoutes(GlobalKey<NavigatorState> navigatorKey) => [
  ShellRoute(
    navigatorKey: navigatorKey,
    builder: (context, state, child) => MainShell(child: child),
    routes: [
      GoRoute(
        path: AppRoutes.staffHome,
        pageBuilder: (c, s) => const NoTransitionPage(child: StaffHomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.staffAttendance,
        pageBuilder: (c, s) =>
            const NoTransitionPage(child: StaffAttendanceScreen()),
      ),
      GoRoute(
        path: AppRoutes.staffLeaves,
        pageBuilder: (c, s) =>
            const NoTransitionPage(child: ParentLeaveStatusScreen()),
      ),
      GoRoute(
        path: AppRoutes.staffPayslips,
        pageBuilder: (c, s) =>
            const NoTransitionPage(child: StaffPayslipsScreen()),
      ),
      GoRoute(
        path: AppRoutes.staffTraining,
        pageBuilder: (c, s) =>
            const NoTransitionPage(child: StaffTrainingScreen()),
      ),
      GoRoute(
        path: AppRoutes.staffProfile,
        pageBuilder: (c, s) => const NoTransitionPage(child: ProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        pageBuilder: (c, s) => NoTransitionPage(child: NotificationsScreen()),
      ),
    ],
  ),
];
