import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../features/auth/providers/auth_provider.dart';
import '../core/models/user_model.dart';
import '../core/widgets/nc_avatar.dart';
import '../routing/app_routes.dart';

class WebShell extends ConsumerStatefulWidget {
  const WebShell({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<WebShell> createState() => _WebShellState();
}

class _WebShellState extends ConsumerState<WebShell> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(userRoleProvider);
    final user = ref.watch(currentUserProvider);
    final menuItems = _menuItemsFor(role);
    final currentPath = GoRouterState.of(context).uri.path;

    final sidebarWidth = _collapsed ? 64.0 : 240.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // ── Sidebar ────────────────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            width: sidebarWidth,
            color: AppColors.sidebarBg,
            child: Column(
              children: [
                // Logo area
                SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      const SizedBox(width: AppSpacing.md),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(AppSpacing.xs),
                        ),
                        child: const Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      if (!_collapsed) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            AppConstants.appName,
                            style: AppTypography.headlineSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: AppSpacing.xs),

                // Menu items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xs,
                    ),
                    children: menuItems.map((item) {
                      final isActive = currentPath.startsWith(item.route);
                      return _SidebarItem(
                        item: item,
                        isActive: isActive,
                        collapsed: _collapsed,
                        onTap: () => context.go(item.route),
                      );
                    }).toList(),
                  ),
                ),

                // Collapse toggle
                const Divider(color: Colors.white12, height: 1),
                InkWell(
                  onTap: () => setState(() => _collapsed = !_collapsed),
                  child: SizedBox(
                    height: 48,
                    child: Row(
                      mainAxisAlignment: _collapsed
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.end,
                      children: [
                        if (!_collapsed) const SizedBox(width: AppSpacing.md),
                        Icon(
                          _collapsed ? Icons.chevron_right : Icons.chevron_left,
                          color: Colors.white54,
                          size: 22,
                        ),
                        if (!_collapsed) const SizedBox(width: AppSpacing.md),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Main area ──────────────────────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 56,
                  color: AppColors.card,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _titleFor(currentPath),
                          style: AppTypography.headlineMedium,
                        ),
                      ),
                      // Search
                      SizedBox(
                        width: 220,
                        height: 36,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search…',
                            prefixIcon: const Icon(Icons.search, size: 18),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.xl,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.divider,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Notifications
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      // Avatar + name
                      if (user != null)
                        Row(
                          children: [
                            NcAvatar(name: user.name, radius: 16),
                            const SizedBox(width: AppSpacing.xs),
                            if (MediaQuery.sizeOf(context).width > 900)
                              Text(
                                user.name.split(' ').first,
                                style: AppTypography.labelMedium,
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Content
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    alignment: Alignment.topCenter,
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _titleFor(String path) {
    const titles = {
      '/web/dashboard': 'Dashboard',
      '/web/analytics': 'Analytics',
      '/web/students': 'Students',
      '/web/timetable': 'Timetable',
      '/web/marks': 'Marks Entry',
      '/web/fees/structure': 'Fee Structure',
      '/web/fees/collection': 'Fee Collection',
      '/web/staff': 'Staff',
      '/web/payroll': 'Payroll',
      '/web/notices': 'Notices',
      '/web/library': 'Library',
      '/web/settings': 'Settings',
      '/web/ai': 'AI Tools',
      '/web/website': 'Website Manager',
    };
    for (final entry in titles.entries) {
      if (path.startsWith(entry.key)) return entry.value;
    }
    return AppConstants.appName;
  }

  List<_MenuItem> _menuItemsFor(UserRole? role) {
    return [
      _MenuItem(AppRoutes.webDashboard, 'Dashboard', Icons.dashboard_outlined),
      _MenuItem(AppRoutes.webAnalytics, 'Analytics', Icons.bar_chart_outlined),
      _MenuItem(AppRoutes.webStudents, 'Students', Icons.people_outline),
      _MenuItem(
        AppRoutes.webTimetable,
        'Timetable',
        Icons.table_chart_outlined,
      ),
      _MenuItem(AppRoutes.webMarksEntry, 'Marks Entry', Icons.grade_outlined),
      _MenuItem(
        AppRoutes.webFeeStructure,
        'Fee Structure',
        Icons.list_alt_outlined,
      ),
      _MenuItem(
        AppRoutes.webFeeCollection,
        'Fee Collection',
        Icons.payments_outlined,
      ),
      _MenuItem(AppRoutes.webStaff, 'Staff', Icons.badge_outlined),
      _MenuItem(
        AppRoutes.webPayroll,
        'Payroll',
        Icons.account_balance_outlined,
      ),
      _MenuItem(AppRoutes.webNotices, 'Notices', Icons.campaign_outlined),
      _MenuItem(AppRoutes.webLibrary, 'Library', Icons.local_library_outlined),
      _MenuItem(AppRoutes.webSettings, 'Settings', Icons.settings_outlined),
      _MenuItem(AppRoutes.webAiTools, 'AI Tools', Icons.auto_awesome_outlined),
      _MenuItem(AppRoutes.webWebsite, 'Website', Icons.web_outlined),
    ];
  }
}

class _MenuItem {
  const _MenuItem(this.route, this.label, this.icon);
  final String route;
  final String label;
  final IconData icon;
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.item,
    required this.isActive,
    required this.collapsed,
    required this.onTap,
  });
  final _MenuItem item;
  final bool isActive;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 2),
          padding: EdgeInsets.symmetric(
            horizontal: widget.collapsed ? 0 : AppSpacing.sm,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: widget.isActive
                ? Colors.white.withValues(alpha: 0.12)
                : _hover
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.xs),
            border: widget.isActive
                ? const Border(
                    left: BorderSide(color: AppColors.accent, width: 3),
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: widget.collapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                widget.item.icon,
                color: widget.isActive ? Colors.white : Colors.white60,
                size: 20,
              ),
              if (!widget.collapsed) ...[
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: AppTypography.labelMedium.copyWith(
                      color: widget.isActive ? Colors.white : Colors.white70,
                      fontWeight: widget.isActive
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
