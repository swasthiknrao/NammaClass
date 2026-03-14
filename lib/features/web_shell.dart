import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/screen_size.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../features/auth/providers/auth_provider.dart';
import '../core/models/user_model.dart';
import '../core/widgets/nc_avatar.dart';
import '../core/widgets/notification_icon_button.dart';
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
    final isMobile = ScreenSize.isMobile(context);

    // Mobile: bottom nav instead of sidebar (like MainShell for other roles)
    if (isMobile) {
      return _buildMobileLayout(context, role, user, menuItems, currentPath);
    }

    final sidebarWidth = _collapsed ? 64.0 : 240.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          // ── Sidebar ────────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            width: sidebarWidth,
            decoration: BoxDecoration(
              color: AppColors.sidebarBg,
              border: Border(
                right: BorderSide(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
            ),
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

          // ── Main area ──────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 56,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.cardDark
                      : AppColors.card,
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
                      const NotificationIconButton(
                        iconColor: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
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

  Widget _buildMobileLayout(
    BuildContext context,
    UserRole? role,
    UserModel? user,
    List<_MenuItem> menuItems,
    String currentPath,
  ) {
    // Limit to 5 items for bottom nav; take the most relevant
    final navItems = menuItems.length > 5
        ? menuItems.take(5).toList()
        : menuItems;
    var selectedIndex = 0;
    for (var i = 0; i < navItems.length; i++) {
      if (currentPath.startsWith(navItems[i].route)) {
        selectedIndex = i;
        break;
      }
    }

    final accentColor = _accentForRole(role);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Compact top bar
          Container(
            height: 56,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.cardDark
                : AppColors.card,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _titleFor(currentPath),
                    style: AppTypography.headlineSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () => context.go(AppRoutes.search),
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.search, size: 22),
                  ),
                ),
                const NotificationIconButton(
                  iconColor: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                if (user != null)
                  InkWell(
                    onTap: () => _goToProfileForRole(context, role),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: NcAvatar(name: user.name, radius: 18),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.cardDark
                  : AppColors.card,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: NavigationBar(
              height: 64,
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                context.go(navItems[index].route);
              },
              destinations: navItems
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.icon),
                      label: item.label,
                    ),
                  )
                  .toList(),
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: accentColor.withValues(alpha: 0.2),
            ),
          ),
        ),
      ),
    );
  }

  void _goToProfileForRole(BuildContext context, UserRole? role) {
    switch (role) {
      case UserRole.hod:
        context.go(AppRoutes.hodProfile);
        break;
      default:
        context.go(AppRoutes.profile);
        break;
    }
  }

  Color _accentForRole(UserRole? role) {
    switch (role) {
      case UserRole.hod:
        return AppColors.teal;
      default:
        return AppColors.primary;
    }
  }

  String _titleFor(String path) {
    const titles = {
      '/web/hod-home': 'Home',
      '/web/dashboard': 'Dashboard',
      '/web/analytics': 'Analytics',
      '/web/admissions': 'Admissions',
      '/web/students/promote': 'Bulk Promotion',
      '/web/students': 'Students',
      '/web/timetable': 'Timetable',
      '/web/report-cards': 'Report Cards',
      '/web/marks': 'Marks Entry',
      '/web/fees/structure': 'Fee Structure',
      '/web/fees/collection': 'Fee Collection',
      '/web/fees/collect': 'Collect Fees',
      '/web/finance/ledger': 'Finance Ledger',
      '/web/staff': 'Staff',
      '/web/payroll': 'Payroll',
      '/web/notices': 'Notices',
      '/web/communication/analytics': 'Communication Analytics',
      '/web/library/reports': 'Library Reports',
      '/web/library': 'Library',
      '/web/transport/routes': 'Transport Routes',
      '/web/transport/live': 'Live Transport',
      '/web/transport': 'Transport',
      '/web/inventory/assets': 'Asset Registry',
      '/web/inventory/stock': 'Stock & Purchase',
      '/web/reports/builder': 'Report Builder',
      '/web/settings/users': 'User Management',
      '/web/settings/integrations': 'Integrations',
      '/web/settings': 'Settings',
      '/web/ai': 'AI Tools',
      '/web/website': 'Website Manager',
      '/web/support/dashboard': 'Support Dashboard',
      '/web/support/tickets': 'Support Tickets',
      '/web/support/complaints': 'Complaints',
      '/web/support/kb': 'Knowledge Base',
      '/web/accountant/dashboard': 'Finance Dashboard',
    };
    for (final entry in titles.entries) {
      if (path.startsWith(entry.key)) return entry.value;
    }
    return AppConstants.appName;
  }

  List<_MenuItem> _menuItemsFor(UserRole? role) {
    if (role == UserRole.librarian) {
      return [
        _MenuItem(
          AppRoutes.webLibrary,
          'Library',
          Icons.local_library_outlined,
        ),
        _MenuItem(
          AppRoutes.webLibraryReports,
          'Reports',
          Icons.analytics_outlined,
        ),
      ];
    }
    if (role == UserRole.support) {
      return [
        _MenuItem(
          AppRoutes.webSupportDashboard,
          'Dashboard',
          Icons.dashboard_outlined,
        ),
        _MenuItem(
          AppRoutes.webSupportTickets,
          'Tickets',
          Icons.confirmation_number_outlined,
        ),
        _MenuItem(
          AppRoutes.webSupportComplaints,
          'Complaints',
          Icons.report_outlined,
        ),
        _MenuItem(
          AppRoutes.webSupportKnowledgeBase,
          'Knowledge Base',
          Icons.menu_book_outlined,
        ),
      ];
    }
    if (role == UserRole.accountant) {
      return [
        _MenuItem(
          AppRoutes.webAccountantDashboard,
          'Dashboard',
          Icons.dashboard_outlined,
        ),
        _MenuItem(
          AppRoutes.webFeeCollect,
          'Collect Fees',
          Icons.point_of_sale_outlined,
        ),
        _MenuItem(
          AppRoutes.webFinanceLedger,
          'Finance Ledger',
          Icons.account_balance_outlined,
        ),
      ];
    }
    if (role == UserRole.hod) {
      return [
        _MenuItem(AppRoutes.webHodHome, 'My Home', Icons.home_outlined),
        _MenuItem(
          AppRoutes.webDashboard,
          'Dashboard',
          Icons.dashboard_outlined,
        ),
        _MenuItem(AppRoutes.webStudents, 'Students', Icons.people_outline),
        _MenuItem(
          AppRoutes.webTimetable,
          'Timetable',
          Icons.table_chart_outlined,
        ),
        _MenuItem(
          AppRoutes.webReportCards,
          'Report Cards',
          Icons.grading_outlined,
        ),
        _MenuItem(AppRoutes.webMarksEntry, 'Marks Entry', Icons.grade_outlined),
        _MenuItem(AppRoutes.webNotices, 'Notices', Icons.campaign_outlined),
        _MenuItem(
          AppRoutes.webAnalytics,
          'Analytics',
          Icons.bar_chart_outlined,
        ),
      ];
    }
    // Admin / Principal / Teacher / Super Admin — full menu
    return [
      _MenuItem(AppRoutes.webDashboard, 'Dashboard', Icons.dashboard_outlined),
      _MenuItem(
        AppRoutes.webAdmissions,
        'Admissions',
        Icons.how_to_reg_outlined,
      ),
      _MenuItem(AppRoutes.webStudents, 'Students', Icons.people_outline),
      _MenuItem(AppRoutes.webAnalytics, 'Analytics', Icons.bar_chart_outlined),
      _MenuItem(
        AppRoutes.webTimetable,
        'Timetable',
        Icons.table_chart_outlined,
      ),
      _MenuItem(
        AppRoutes.webReportCards,
        'Report Cards',
        Icons.grading_outlined,
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
      _MenuItem(
        AppRoutes.webFeeCollect,
        'Collect Fees',
        Icons.point_of_sale_outlined,
      ),
      _MenuItem(
        AppRoutes.webFinanceLedger,
        'Finance Ledger',
        Icons.account_balance_outlined,
      ),
      _MenuItem(AppRoutes.webStaff, 'HR & Staff', Icons.badge_outlined),
      _MenuItem(AppRoutes.webPayroll, 'Payroll', Icons.receipt_long_outlined),
      _MenuItem(AppRoutes.webNotices, 'Notices', Icons.campaign_outlined),
      _MenuItem(
        AppRoutes.webCommunicationAnalytics,
        'Comms Analytics',
        Icons.insights_outlined,
      ),
      _MenuItem(AppRoutes.webLibrary, 'Library', Icons.local_library_outlined),
      _MenuItem(
        AppRoutes.webLibraryReports,
        'Library Reports',
        Icons.analytics_outlined,
      ),
      _MenuItem(
        AppRoutes.webTransportRoutes,
        'Transport',
        Icons.directions_bus_outlined,
      ),
      _MenuItem(
        AppRoutes.webTransportLive,
        'Live Tracking',
        Icons.gps_fixed_outlined,
      ),
      _MenuItem(
        AppRoutes.webInventoryAssets,
        'Assets',
        Icons.inventory_2_outlined,
      ),
      _MenuItem(
        AppRoutes.webInventoryStock,
        'Stock & PO',
        Icons.warehouse_outlined,
      ),
      _MenuItem(
        AppRoutes.webReportBuilder,
        'Report Builder',
        Icons.summarize_outlined,
      ),
      _MenuItem(AppRoutes.webAiTools, 'AI Tools', Icons.auto_awesome_outlined),
      _MenuItem(AppRoutes.webWebsite, 'Website', Icons.web_outlined),
      _MenuItem(
        AppRoutes.webUserManagement,
        'User Mgmt',
        Icons.manage_accounts_outlined,
      ),
      _MenuItem(
        AppRoutes.webIntegrations,
        'Integrations',
        Icons.cable_outlined,
      ),
      _MenuItem(AppRoutes.webSettings, 'Settings', Icons.settings_outlined),
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
