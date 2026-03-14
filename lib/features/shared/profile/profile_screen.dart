import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/launch_utils.dart';
import '../../../routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/theme_mode_provider.dart';
import '../../../core/widgets/nc_avatar.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../features/auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final auth = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(title: const Text('Profile & Settings')),
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Creative header — wave shape + pattern
            _ProfileHeader(user: user),
            const SizedBox(height: AppSpacing.sm),
            // Profile section card
            _ProfileSection(user: user),
            const SizedBox(height: AppSpacing.lg),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _SectionHeader('Appearance'),
                  NcCard(padding: EdgeInsets.zero, child: const _ThemeTile()),
                  const SizedBox(height: AppSpacing.lg),
                  // Account section
                  _SectionHeader('Account'),
                  NcCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _SettingsTile(Icons.person_outline, 'Edit Profile', () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Edit profile coming soon'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }),
                        const Divider(height: 1),
                        _SettingsTile(
                          Icons.phone_outlined,
                          user?.phone ?? '+91 XXXXX XXXXX',
                          () {
                            final phone = user?.phone;
                            if (phone != null &&
                                phone.contains(RegExp(r'\d')) &&
                                !phone.contains('X')) {
                              launchTel(context, phone: phone);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Phone number not available'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                        const Divider(height: 1),
                        _SettingsTile(
                          Icons.email_outlined,
                          user?.email ?? 'email@example.com',
                          () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Preferences
                  _SectionHeader('Preferences'),
                  NcCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.language_outlined),
                          title: Text(
                            'Language',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          trailing: DropdownButton<String>(
                            value: 'English',
                            underline: const SizedBox.shrink(),
                            items: ['English', 'Kannada', 'Hindi']
                                .map(
                                  (l) => DropdownMenuItem(
                                    value: l,
                                    child: Text(l),
                                  ),
                                )
                                .toList(),
                            onChanged: (_) {},
                          ),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          secondary: const Icon(Icons.notifications_outlined),
                          title: Text(
                            'Push Notifications',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          value: true,
                          onChanged: (_) {},
                        ),
                        const Divider(height: 1),
                        Consumer(
                          builder: (context, ref, _) {
                            final themeMode = ref.watch(themeModeProvider);
                            return SwitchListTile(
                              secondary: const Icon(Icons.dark_mode_outlined),
                              title: Text(
                                'Dark Mode',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              value: themeMode == ThemeMode.dark,
                              onChanged: (v) {
                                ref.read(themeModeProvider.notifier).state = v
                                    ? ThemeMode.dark
                                    : ThemeMode.light;
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Support
                  _SectionHeader('Support'),
                  NcCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _SettingsTile(Icons.help_outline, 'Help & FAQ', () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Help & FAQ coming soon'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }),
                        const Divider(height: 1),
                        _SettingsTile(
                          Icons.privacy_tip_outlined,
                          'Privacy Policy',
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Privacy Policy coming soon'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _SettingsTile(
                          Icons.info_outline,
                          'About NammaClass',
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('About NammaClass coming soon'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Logout
                  FilledButton.icon(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (dialogContext) => AlertDialog(
                          icon: Icon(
                            Icons.logout_rounded,
                            color: AppColors.error,
                            size: 32,
                          ),
                          title: const Text('Log out?'),
                          content: const Text(
                            'You’ll need to sign in again to use NammaClass.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () async {
                                Navigator.pop(dialogContext);
                                await auth.logout();
                                if (!context.mounted) return;
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (!context.mounted) return;
                                  context.go(AppRoutes.login);
                                });
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.error,
                              ),
                              child: const Text('Log out'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Log out'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.error,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _roleBadgeText(dynamic user) {
  if (user == null) return 'User';
  if (user.role == UserRole.hod) {
    return 'HOD • ${MockData.hodDepartment}';
  }
  return user.roleLabel ?? 'User';
}

String? _roleContextText(dynamic user) {
  if (user == null) return null;
  if (user.role == UserRole.hod) {
    return 'Department: ${MockData.hodDepartment}';
  }
  return null;
}

IconData _roleContextIcon(dynamic user) {
  if (user == null) return Icons.info_outline;
  if (user.role == UserRole.hod) return Icons.business;
  return Icons.info_outline;
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({this.user});
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _CreativeHeaderClipper(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xl + 8,
          AppSpacing.lg,
          AppSpacing.xl + 36,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-1.2, -0.8),
            end: Alignment(1.2, 1.2),
            colors: [
              AppColors.primary,
              const Color(0xFF234A66),
              AppColors.teal.withValues(alpha: 0.9),
              AppColors.accent.withValues(alpha: 0.25),
            ],
            stops: const [0.0, 0.35, 0.75, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Diagonal accent stripe
            Positioned(
              top: -40,
              right: -60,
              child: Transform.rotate(
                angle: 0.4,
                child: Container(
                  width: 160,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Floating orbs
            Positioned(
              top: 20,
              right: 30,
              child: _FloatingOrb(size: 60, alpha: 0.08),
            ),
            Positioned(
              top: 80,
              left: -15,
              child: _FloatingOrb(size: 45, alpha: 0.12),
            ),
            Positioned(
              bottom: 50,
              right: 40,
              child: _FloatingOrb(size: 35, alpha: 0.1),
            ),
            Positioned(
              bottom: 90,
              left: 60,
              child: _FloatingOrb(size: 25, alpha: 0.15),
            ),
            // Dot grid pattern
            Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),
            // Content
            Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Concentric rings behind avatar
                    ...List.generate(3, (i) {
                      final r = 52.0 + (i * 12.0);
                      return Container(
                        width: r * 2,
                        height: r * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: 0.12 - (i * 0.03),
                            ),
                            width: 1.5,
                          ),
                          color: Colors.transparent,
                        ),
                      );
                    }),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: NcAvatar(name: user?.name ?? 'U', radius: 46),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Change photo coming soon'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: AppColors.accentGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  user?.name ?? 'User',
                  style: AppTypography.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _roleBadgeText(user),
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.school_rounded,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        AppConstants.schoolName,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingOrb extends StatelessWidget {
  const _FloatingOrb({required this.size, required this.alpha});
  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;
    const spacing = 24.0;
    for (var x = 0.0; x < size.width + spacing; x += spacing) {
      for (var y = 0.0; y < size.height + spacing; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CreativeHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width * 0.15,
      size.height + 5,
      size.width * 0.35,
      size.height - 25,
    );
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height - 55,
      size.width * 0.65,
      size.height - 20,
    );
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height + 10,
      size.width,
      size.height - 35,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({this.user});
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: NcCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            Text(
              'Profile',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_roleContextText(user) != null) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  border: Border.all(
                    color: AppColors.teal.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _roleContextIcon(user),
                      size: 18,
                      color: AppColors.teal,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _roleContextText(user)!,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _QuickActionChip(
                  icon: Icons.phone_outlined,
                  label: 'Call',
                  onTap: () {
                    final phone = user?.phone;
                    if (phone != null &&
                        phone.contains(RegExp(r'\d')) &&
                        !phone.contains('X')) {
                      launchTel(context, phone: phone);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Phone not available'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(width: AppSpacing.md),
                _QuickActionChip(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(user?.email ?? 'Email not set'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    user?.phone ?? '••• ••• ••••',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeTile extends ConsumerWidget {
  const _ThemeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    String label;
    switch (themeMode) {
      case ThemeMode.light:
        label = 'Light';
        break;
      case ThemeMode.dark:
        label = 'Dark';
        break;
      case ThemeMode.system:
        label = 'System';
        break;
    }
    return ListTile(
      leading: const Icon(
        Icons.brightness_6_outlined,
        color: AppColors.textSecondary,
      ),
      title: Text('Theme', style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
        size: 18,
      ),
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Light'),
                  leading: Icon(
                    Icons.light_mode,
                    color: themeMode == ThemeMode.light
                        ? AppColors.primary
                        : null,
                  ),
                  onTap: () {
                    ref.read(themeModeProvider.notifier).state =
                        ThemeMode.light;
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  title: const Text('Dark'),
                  leading: Icon(
                    Icons.dark_mode,
                    color: themeMode == ThemeMode.dark
                        ? AppColors.primary
                        : null,
                  ),
                  onTap: () {
                    ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  title: const Text('System'),
                  leading: Icon(
                    Icons.settings_brightness,
                    color: themeMode == ThemeMode.system
                        ? AppColors.primary
                        : null,
                  ),
                  onTap: () {
                    ref.read(themeModeProvider.notifier).state =
                        ThemeMode.system;
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: AppTypography.headlineSmall),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile(this.icon, this.label, this.onTap);
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
        size: 18,
      ),
      onTap: onTap,
    );
  }
}
