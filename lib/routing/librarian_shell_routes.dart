import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'page_transitions.dart';
import '../features/librarian/screens/librarian_catalog_screen.dart';
import '../features/librarian/screens/librarian_counter_screen.dart';
import '../features/librarian/screens/librarian_reservations_screen.dart';
import '../features/main_shell.dart';
import '../features/namma_ai/screens/namma_ai_screen.dart';
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
                fadeSlideTransition(c, s, const LibrarianCounterScreen()),
          ),
          GoRoute(
            path: AppRoutes.librarianCatalog,
            pageBuilder: (c, s) =>
                fadeSlideTransition(c, s, const LibrarianCatalogScreen()),
          ),
          GoRoute(
            path: AppRoutes.librarianReservations,
            pageBuilder: (c, s) =>
                fadeSlideTransition(c, s, const LibrarianReservationsScreen()),
          ),
          GoRoute(
            path: AppRoutes.librarianProfile,
            pageBuilder: (c, s) =>
                fadeSlideTransition(c, s, const ProfileScreen()),
          ),
          GoRoute(
            path: AppRoutes.nammaAi,
            pageBuilder: (c, s) =>
                fadeSlideTransition(c, s, const NammaAiScreen()),
          ),
        ],
      ),
    ];
