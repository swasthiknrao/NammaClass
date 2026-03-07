import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/librarian/screens/librarian_counter_screen.dart';
import '../features/librarian/screens/librarian_reservations_screen.dart';
import '../features/main_shell.dart';
import '../features/shared/profile/profile_screen.dart';
import 'app_routes.dart';

List<RouteBase> librarianShellRoutes(GlobalKey<NavigatorState> navigatorKey) =>
    [
      ShellRoute(
        navigatorKey: navigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.librarianCounter,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: LibrarianCounterScreen()),
          ),
          GoRoute(
            path: AppRoutes.librarianReservations,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: LibrarianReservationsScreen()),
          ),
          GoRoute(
            path: AppRoutes.librarianProfile,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
    ];
