import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
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
      backgroundColor: AppColors.background,
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
                  // Account section
                  _SectionHeader('Account'),
                  NcCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _SettingsTile(
                          Icons.person_outline,
                          'Edit Profile',
                          () {},
                        ),
                        const Divider(height: 1),
                        _SettingsTile(
                          Icons.phone_outlined,
                          user?.phone ?? '+91 XXXXX XXXXX',
                          () {},
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
                            style: AppTypography.bodyMedium,
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
                            style: AppTypography.bodyMedium,
                          ),
                          value: true,
                          onChanged: (_) {},
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          secondary: const Icon(Icons.dark_mode_outlined),
                          title: Text(
                            'Dark Mode',
                            style: AppTypography.bodyMedium,
                          ),
                          value: false,
                          onChanged: (_) {},
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
                        _SettingsTile(Icons.help_outline, 'Help & FAQ', () {}),
                        const Divider(height: 1),
                        _SettingsTile(
                          Icons.privacy_tip_outlined,
                          'Privacy Policy',
                          () {},
                        ),
                        const Divider(height: 1),
                        _SettingsTile(
                          Icons.info_outline,
                          'About NammaClass',
                          () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Logout
                  FilledButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text(
                            'Are you sure you want to logout?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                auth.logout();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                              ),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
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
      title: Text(label, style: AppTypography.bodyMedium),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
        size: 18,
      ),
      onTap: onTap,
    );
  }
}
