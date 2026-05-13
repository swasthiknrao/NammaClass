import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/sanitization.dart';
import '../../../core/config/env_config.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_input.dart';
import '../providers/auth_provider.dart';
import '../../../routing/app_routes.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _loading = false;
  final UserRole _demoRole = UserRole.parent;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final rawPhone = _phoneController.text;
    final phone = Sanitization.sanitize(rawPhone, maxLength: 10);
    if (phone != rawPhone) _phoneController.text = phone;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _loading = false);
    context.push(AppRoutes.otp, extra: {'phone': phone, 'role': _demoRole});
  }

  void _loginDemo(UserRole role) {
    final users = {
      UserRole.parent: UserModel.parent,
      UserRole.teacher: UserModel.teacher,
      UserRole.student: UserModel.student,
      UserRole.admin: UserModel.admin,
      UserRole.principal: UserModel.principal,
      UserRole.support: UserModel.support,
      UserRole.staff: UserModel.staff,
      UserRole.driver: UserModel.driver,
      UserRole.librarian: UserModel.librarian,
      UserRole.warden: UserModel.warden,
      UserRole.canteenStaff: UserModel.canteenStaff,
      UserRole.accountant: UserModel.accountant,
      UserRole.hod: UserModel.hod,
      UserRole.superAdmin: UserModel.superAdmin,
    };
    ref.read(authProvider.notifier).loginAs(users[role]!);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width > 700;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: isWide
          ? _WideLayout(child: _form())
          : _NarrowLayout(child: _form()),
    );
  }

  Widget _form() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.hasBoundedHeight
                  ? constraints.maxHeight
                  : 0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                        AppConstants.appName,
                        style: AppTypography.displayMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.1, end: 0, curve: Curves.easeOut),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                        'Login to your account',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms)
                      .slideY(begin: -0.05, end: 0, curve: Curves.easeOut),
                  const SizedBox(height: AppSpacing.xl),

                  // Phone field
                  NcTextField(
                    controller: _phoneController,
                    label: 'Mobile Number',
                    hint: 'Enter 10-digit mobile number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    maxLength: 10,
                    validator: AppValidators.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  NcPrimaryButton(
                        label: 'Send OTP',
                        fullWidth: true,
                        icon: Icons.send_outlined,
                        loading: _loading,
                        onPressed: _sendOtp,
                      )
                      .animate()
                      .fadeIn(duration: 350.ms, delay: 200.ms)
                      .slideY(begin: 0.03, end: 0, curve: Curves.easeOut),

                  if (kDebugMode || EnvConfig.env == 'dev') ...[
                    const SizedBox(height: AppSpacing.xl),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          child: Text('OR'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Demo role selector (dev/debug only)
                    Text(
                      'Demo Mode — Select Role',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      alignment: WrapAlignment.center,
                      children: [
                        _DemoButton(
                          label: 'Parent',
                          icon: Icons.family_restroom,
                          color: AppColors.primary,
                          onTap: () => _loginDemo(UserRole.parent),
                        ),
                        _DemoButton(
                          label: 'Teacher',
                          icon: Icons.school,
                          color: AppColors.teal,
                          onTap: () => _loginDemo(UserRole.teacher),
                        ),
                        _DemoButton(
                          label: 'Student',
                          icon: Icons.person,
                          color: AppColors.accent,
                          onTap: () => _loginDemo(UserRole.student),
                        ),
                        _DemoButton(
                          label: 'Super Admin',
                          icon: Icons.verified_user,
                          color: Colors.deepPurple,
                          onTap: () => _loginDemo(UserRole.superAdmin),
                        ),
                        _DemoButton(
                          label: 'Principal',
                          icon: Icons.school_outlined,
                          color: AppColors.primary,
                          onTap: () => _loginDemo(UserRole.principal),
                        ),
                        _DemoButton(
                          label: 'Staff',
                          icon: Icons.badge_outlined,
                          color: AppColors.teal,
                          onTap: () => _loginDemo(UserRole.staff),
                        ),
                        _DemoButton(
                          label: 'Driver',
                          icon: Icons.directions_bus,
                          color: Colors.orange,
                          onTap: () => _loginDemo(UserRole.driver),
                        ),
                        _DemoButton(
                          label: 'Librarian',
                          icon: Icons.menu_book,
                          color: Colors.indigo,
                          onTap: () => _loginDemo(UserRole.librarian),
                        ),
                        _DemoButton(
                          label: 'Warden',
                          icon: Icons.night_shelter,
                          color: Colors.brown,
                          onTap: () => _loginDemo(UserRole.warden),
                        ),
                        _DemoButton(
                          label: 'Canteen',
                          icon: Icons.restaurant,
                          color: Colors.deepOrange,
                          onTap: () => _loginDemo(UserRole.canteenStaff),
                        ),
                        _DemoButton(
                          label: 'Accountant',
                          icon: Icons.calculate,
                          color: Colors.green,
                          onTap: () => _loginDemo(UserRole.accountant),
                        ),
                        _DemoButton(
                          label: 'Support',
                          icon: Icons.support_agent,
                          color: Colors.purple,
                          onTap: () => _loginDemo(UserRole.support),
                        ),
                        _DemoButton(
                          label: 'HOD',
                          icon: Icons.work_outline,
                          color: Colors.teal,
                          onTap: () => _loginDemo(UserRole.hod),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DemoButton extends StatelessWidget {
  const _DemoButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Top illustration 40%
          Container(
            height: MediaQuery.sizeOf(context).height * 0.35,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.primaryGradient,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school, color: Colors.white, size: 64),
                  SizedBox(height: 8),
                  Text(
                    AppConstants.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: child),
        ],
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left panel
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.primaryGradient,
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school, color: Colors.white, size: 80),
                  SizedBox(height: 16),
                  Text(
                    AppConstants.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    AppConstants.appTagline,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Right panel (form)
        SizedBox(
          width: 420,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
