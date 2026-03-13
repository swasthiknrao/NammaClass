import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/launch_utils.dart';
import '../../../routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/theme_mode_provider.dart';
import '../../../core/widgets/nc_avatar.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../features/auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final auth = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      NcAvatar(name: user?.name ?? 'U', radius: 40),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    user?.name ?? 'User',
                    style: AppTypography.headlineMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    user?.roleLabel ?? '',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    AppConstants.schoolName,
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),

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
