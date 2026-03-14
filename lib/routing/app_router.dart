import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_provider.dart';
import 'app_routes.dart';
import 'auth_routes.dart';
import 'canteen_shell_routes.dart';
import 'driver_shell_routes.dart';
import 'librarian_shell_routes.dart';
import 'main_shell_routes.dart';
import 'route_guard.dart';
import 'staff_shell_routes.dart';
import 'warden_shell_routes.dart';
import 'web_shell_routes.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellKey = GlobalKey<NavigatorState>(debugLabel: 'shell');
final _webShellKey = GlobalKey<NavigatorState>(debugLabel: 'webShell');
final _staffShellKey = GlobalKey<NavigatorState>(debugLabel: 'staffShell');
final _driverShellKey = GlobalKey<NavigatorState>(debugLabel: 'driverShell');
final _librarianShellKey = GlobalKey<NavigatorState>(
  debugLabel: 'librarianShell',
);
final _wardenShellKey = GlobalKey<NavigatorState>(debugLabel: 'wardenShell');
final _canteenShellKey = GlobalKey<NavigatorState>(debugLabel: 'canteenShell');

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final path = state.uri.path;
      var result = routeGuard(path, authState);
      if (result != null &&
          (result == AppRoutes.webDashboard ||
              result == AppRoutes.webMarksEntry ||
              result == AppRoutes.webHodHome)) {
        final mobileHome = mobileHomeForExecRole(authState.role);
        if (mobileHome != null && MediaQuery.sizeOf(context).width < 600) {
          result = mobileHome;
        }
      }
      return result;
    },
    routes: [
      ...authRoutes,
      ...mainShellRoutes(_shellKey),
      ...staffShellRoutes(_staffShellKey),
      ...driverShellRoutes(_driverShellKey),
      ...librarianShellRoutes(_librarianShellKey),
      ...wardenShellRoutes(_wardenShellKey),
      ...canteenShellRoutes(_canteenShellKey),
      ...webShellRoutes(_webShellKey),
    ],
  );
});
