import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import '../../../routing/app_routes.dart';
import '../../../routing/route_guard.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _progressController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  String _version = '';

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0, 0.5)),
    );
    _init();
  }

  Future<void> _init() async {
    _logoController.forward();
    _progressController.forward();
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = 'v${info.version}');
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    final isAuth = ref.read(isAuthenticatedProvider);
    if (isAuth) {
      final role = ref.read(userRoleProvider);
      context.go(_roleHome(context, role));
    } else {
      context.go(AppRoutes.login);
    }
  }

  String _roleHome(BuildContext context, UserRole? role) {
    if (role == null) return AppRoutes.login;
    // Mobile override for hod
    if (MediaQuery.sizeOf(context).width < 600) {
      final mobileHome = mobileHomeForExecRole(role);
      if (mobileHome != null) return mobileHome;
    }
    switch (role) {
      case UserRole.parent:
        return AppRoutes.parentHome;
      case UserRole.teacher:
        return AppRoutes.teacherHome;
      case UserRole.student:
        return AppRoutes.studentHome;
      case UserRole.staff:
        return AppRoutes.staffHome;
      case UserRole.driver:
        return AppRoutes.driverRoute;
      case UserRole.librarian:
        return AppRoutes.librarianCounter;
      case UserRole.warden:
        return AppRoutes.wardenHome;
      case UserRole.canteenStaff:
        return AppRoutes.canteenCounter;
      case UserRole.admin:
      case UserRole.principal:
        return AppRoutes.adminHome;
      case UserRole.support:
        return AppRoutes.webSupportDashboard;
      case UserRole.accountant:
        return AppRoutes.webAccountantDashboard;
      case UserRole.hod:
        return AppRoutes.webDashboard;
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Animated logo
              FadeTransition(
                opacity: _logoFade,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Column(
                    children: [
                      CustomPaint(
                        size: const Size(100, 100),
                        painter: _LogoPainter(),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppConstants.appName,
                        style: AppTypography.displayLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppConstants.appTagline,
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 2),
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progressController.value,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        minHeight: 3,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _version.isEmpty ? 'Loading…' : _version,
                style: AppTypography.bodySmall.copyWith(color: Colors.white60),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = Colors.white.withValues(alpha: 0.15);
    final accentPaint = Paint()..color = AppColors.accent;
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Background circle
    canvas.drawCircle(center, r, bgPaint);

    // School building
    final buildingRect = Rect.fromLTWH(
      center.dx - r * 0.5,
      center.dy - r * 0.2,
      r,
      r * 0.7,
    );
    canvas.drawRect(buildingRect, whitePaint);

    // Roof (triangle)
    final roofPath = Path()
      ..moveTo(center.dx - r * 0.6, center.dy - r * 0.2)
      ..lineTo(center.dx, center.dy - r * 0.7)
      ..lineTo(center.dx + r * 0.6, center.dy - r * 0.2)
      ..close();
    canvas.drawPath(roofPath, accentPaint);

    // Door
    final doorRect = Rect.fromLTWH(
      center.dx - r * 0.12,
      center.dy + r * 0.2,
      r * 0.24,
      r * 0.3,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        doorRect,
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      ),
      Paint()..color = AppColors.primary,
    );

    // Windows
    for (int i = 0; i < 2; i++) {
      final wRect = Rect.fromLTWH(
        center.dx - r * 0.42 + i * r * 0.5,
        center.dy - r * 0.1,
        r * 0.2,
        r * 0.2,
      );
      canvas.drawRect(wRect, Paint()..color = AppColors.primary);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
