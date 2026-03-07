import 'package:go_router/go_router.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/otp_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import 'app_routes.dart';
import 'page_transitions.dart';

List<RouteBase> get authRoutes => [
  GoRoute(
    path: AppRoutes.splash,
    pageBuilder: (c, s) => fadeSlideTransition(c, s, const SplashScreen()),
  ),
  GoRoute(
    path: AppRoutes.login,
    pageBuilder: (c, s) => fadeSlideTransition(c, s, const LoginScreen()),
  ),
  GoRoute(
    path: AppRoutes.otp,
    pageBuilder: (c, s) => fadeSlideTransition(c, s, const OtpScreen()),
  ),
];
