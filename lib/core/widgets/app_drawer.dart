import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// A drawer destination for navigation.
class AppDrawerDestination {
  const AppDrawerDestination({
    required this.route,
    required this.label,
    required this.icon,
    this.selectedIcon,
  });

  final String route;
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
}

/// Responsive navigation drawer with role-filtered destinations.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.destinations,
    this.currentPath,
    this.header,
    this.footer,
  });

  final List<AppDrawerDestination> destinations;
  final String? currentPath;
  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.cardDark
          : AppColors.card,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null) header!,
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                  horizontal: AppSpacing.xs,
                ),
                children: destinations.map((d) {
                  final isActive =
                      currentPath != null &&
                      (currentPath == d.route ||
                          currentPath!.startsWith('${d.route}/'));
                  return ListTile(
                    leading: Icon(
                      isActive ? (d.selectedIcon ?? d.icon) : d.icon,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 22,
                    ),
                    title: Text(
                      d.label,
                      style: AppTypography.labelLarge.copyWith(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    selected: isActive,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(d.route);
                    },
                  );
                }).toList(),
              ),
            ),
            if (footer != null) footer!,
          ],
        ),
      ),
    );
  }
}
