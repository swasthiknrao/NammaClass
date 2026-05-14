import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/portal_capabilities.dart';
import '../core/constants/app_constants.dart';
import '../core/models/user_model.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/layout_theme.dart';
import '../core/utils/screen_size.dart';
import '../core/widgets/nc_avatar.dart';
import '../core/widgets/notification_icon_button.dart';
import '../core/widgets/shell_layout_scope.dart';
import '../domain/entities/nc_feature.dart';
import '../domain/entities/tenant_profile.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/tenant/providers/tenant_provider.dart';
import 'namma_ai/widgets/namma_ai_draggable_fab.dart';
import 'namma_ai/widgets/namma_ai_panel_overlay.dart';
import '../routing/app_routes.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  bool _sidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(userRoleProvider);
    final user = ref.watch(currentUserProvider);
    final tenant = ref.watch(tenantProfileProvider);
    final destinations = _destinationsFor(role, tenant);
    final currentPath = GoRouterState.of(context).uri.path;
    final selectedIndex = _selectedIndex(currentPath, destinations);
    final isDesktop = ScreenSize.isDesktop(context);
    final isTablet = ScreenSize.isTablet(context);
    final isWide = isDesktop || isTablet;

    // Desktop/Tablet: collapsible sidebar + top bar + content
    if (isWide) {
      return ShellLayoutScope(
        hasPersistentTopBar: true,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Row(
                children: [
                  _DesktopSidebar(
                    destinations: destinations,
                    selectedIndex: selectedIndex,
                    collapsed: _sidebarCollapsed,
                    onTap: (i) => context.go(destinations[i].route),
                    onToggleCollapse: () =>
                        setState(() => _sidebarCollapsed = !_sidebarCollapsed),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        _DesktopTopBar(
                          title: _titleFor(currentPath, role),
                          onSearchTap: () => context.go(AppRoutes.search),
                          profileRoute: _profileRouteFor(role),
                          user: user,
                        ),
                        const Divider(height: 1),
                        Expanded(child: widget.child),
                      ],
                    ),
                  ),
                ],
              ),
              const NammaAiDraggableFab(dockAboveBottomNav: false),
              const NammaAiPanelOverlay(),
            ],
          ),
        ),
      );
    }

    // Mobile: layout-aware bottom navigation
    final layout =
        Theme.of(context).extension<LayoutTheme>() ?? LayoutTheme.floatingPill;
    final accentColor = _accentForRole(role);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    final navDestinations = destinations
        .map(
          (d) => NavigationDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon ?? d.icon),
            label: d.label,
          ),
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          const NammaAiDraggableFab(dockAboveBottomNav: true),
          const NammaAiPanelOverlay(),
        ],
      ),
      bottomNavigationBar: _LayoutAwareBottomNav(
        destinations: destinations,
        navDestinations: navDestinations,
        selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
        layout: layout,
        accentColor: accentColor,
        primary: primary,
        isDark: isDark,
        onTap: (i) => context.go(destinations[i].route),
      ),
    );
  }

  // ── Feature-gated navigation destinations ─────────────────────────────────
  //
  // Each role has a fixed set of core tabs.  Optional tabs are only included
  // when the tenant has subscribed to the matching [NcFeature].
  // NavigationBar supports 3–5 destinations; tabs are trimmed to 5 maximum.

  List<_NavDest> _destinationsFor(UserRole? role, TenantProfile tenant) {
    switch (role) {
      case UserRole.parent:
        return [
          _NavDest(
            AppRoutes.parentHome,
            'Home',
            Icons.home_outlined,
            Icons.home,
          ),
          _NavDest(
            AppRoutes.parentAttendance,
            'Attendance',
            Icons.calendar_month_outlined,
            Icons.calendar_month,
          ),
          _NavDest(
            AppRoutes.parentFees,
            'Fees',
            Icons.account_balance_wallet_outlined,
            Icons.account_balance_wallet,
          ),
          _NavDest(
            AppRoutes.parentDiary,
            'Diary',
            Icons.book_outlined,
            Icons.book,
          ),
          // Bus tab: only when transport feature is subscribed
          if (tenant.hasFeature(NcFeature.transport))
            _NavDest(
              AppRoutes.parentBus,
              'Bus',
              Icons.directions_bus_outlined,
              Icons.directions_bus,
            )
          else
            _NavDest(
              AppRoutes.parentProfile,
              'Profile',
              Icons.person_outline,
              Icons.person,
            ),
        ].take(5).toList();
      case UserRole.teacher:
        return [
          _NavDest(
            AppRoutes.teacherHome,
            'Home',
            Icons.home_outlined,
            Icons.home,
          ),
          _NavDest(
            AppRoutes.teacherAttendance,
            'Attendance',
            Icons.how_to_reg_outlined,
            Icons.how_to_reg,
          ),
          _NavDest(
            AppRoutes.teacherDiary,
            'Diary',
            Icons.edit_note_outlined,
            Icons.edit_note,
          ),
          _NavDest(
            AppRoutes.teacherStudents,
            'Students',
            Icons.groups_outlined,
            Icons.groups,
          ),
          _NavDest(
            AppRoutes.teacherMessages,
            'Comms',
            Icons.campaign_outlined,
            Icons.campaign,
          ),
          _NavDest(
            AppRoutes.teacherProfile,
            'Profile',
            Icons.person_outline,
            Icons.person,
          ),
        ];
      case UserRole.student:
        return [
          _NavDest(
            AppRoutes.studentHome,
            'Home',
            Icons.home_outlined,
            Icons.home,
          ),
          _NavDest(
            AppRoutes.studentAcademics,
            'Academics',
            Icons.school_outlined,
            Icons.school,
          ),
          // Library tab: only when library feature is subscribed
          if (tenant.hasFeature(NcFeature.library))
            _NavDest(
              AppRoutes.studentLibrary,
              'Library',
              Icons.local_library_outlined,
              Icons.local_library,
            ),
          // Food tab: only when canteen feature is subscribed
          if (tenant.hasFeature(NcFeature.canteen))
            _NavDest(
              AppRoutes.studentCanteen,
              'Food',
              Icons.restaurant_outlined,
              Icons.restaurant,
            ),
          _NavDest(
            AppRoutes.studentProfile,
            'Profile',
            Icons.person_outline,
            Icons.person,
          ),
        ].take(5).toList();
      case UserRole.staff:
        return [
          _NavDest(
            AppRoutes.staffHome,
            'Home',
            Icons.home_outlined,
            Icons.home,
          ),
          _NavDest(
            AppRoutes.staffAttendance,
            'Attendance',
            Icons.location_on_outlined,
            Icons.location_on,
          ),
          _NavDest(
            AppRoutes.staffLeaves,
            'Leaves',
            Icons.event_note_outlined,
            Icons.event_note,
          ),
          // Payslips: only when hr_payroll feature is subscribed
          if (tenant.hasFeature(NcFeature.hrPayroll))
            _NavDest(
              AppRoutes.staffPayslips,
              'Payslips',
              Icons.receipt_long_outlined,
              Icons.receipt_long,
            ),
          // Food: only when canteen feature is subscribed
          if (tenant.hasFeature(NcFeature.canteen))
            _NavDest(
              AppRoutes.staffCanteen,
              'Food',
              Icons.restaurant_outlined,
              Icons.restaurant,
            ),
          _NavDest(
            AppRoutes.staffProfile,
            'Profile',
            Icons.person_outline,
            Icons.person,
          ),
        ].take(5).toList();
      case UserRole.driver:
        return [
          _NavDest(
            AppRoutes.driverHome,
            'Today',
            Icons.dashboard_outlined,
            Icons.dashboard,
          ),
          _NavDest(
            AppRoutes.driverRoute,
            'Route',
            Icons.map_outlined,
            Icons.map,
          ),
          _NavDest(
            AppRoutes.driverStudents,
            'Students',
            Icons.groups_outlined,
            Icons.groups,
          ),
          _NavDest(
            AppRoutes.driverProfile,
            'Profile',
            Icons.person_outline,
            Icons.person,
          ),
        ];
      case UserRole.librarian:
        return [
          _NavDest(
            AppRoutes.librarianCounter,
            'Counter',
            Icons.qr_code_scanner_outlined,
            Icons.qr_code_scanner,
          ),
          _NavDest(
            AppRoutes.librarianCatalog,
            'Catalog',
            Icons.menu_book_outlined,
            Icons.menu_book,
          ),
          _NavDest(
            AppRoutes.librarianReservations,
            'Reservations',
            Icons.bookmark_outlined,
            Icons.bookmark,
          ),
          _NavDest(
            AppRoutes.librarianProfile,
            'Profile',
            Icons.person_outline,
            Icons.person,
          ),
        ];
      case UserRole.warden:
        return [
          _NavDest(
            AppRoutes.wardenHome,
            'Home',
            Icons.home_outlined,
            Icons.home,
          ),
          _NavDest(
            AppRoutes.wardenRollcall,
            'Roll Call',
            Icons.how_to_reg_outlined,
            Icons.how_to_reg,
          ),
          _NavDest(
            AppRoutes.wardenVisitors,
            'Visitors',
            Icons.badge_outlined,
            Icons.badge,
          ),
          _NavDest(
            AppRoutes.wardenOutpass,
            'Outpass',
            Icons.event_note_outlined,
            Icons.event_note,
          ),
          _NavDest(
            AppRoutes.wardenProfile,
            'Profile',
            Icons.person_outline,
            Icons.person,
          ),
        ];
      case UserRole.canteenStaff:
        return [
          _NavDest(
            AppRoutes.canteenCounter,
            'Counter',
            Icons.point_of_sale_outlined,
            Icons.point_of_sale,
          ),
          _NavDest(
            AppRoutes.canteenManage,
            'Manage',
            Icons.restaurant_menu_outlined,
            Icons.restaurant_menu,
          ),
          _NavDest(
            AppRoutes.canteenProfile,
            'Profile',
            Icons.person_outline,
            Icons.person,
          ),
        ];
      case UserRole.hod:
        return [
          _NavDest(AppRoutes.hodHome, 'Home', Icons.home_outlined, Icons.home),
          _NavDest(
            AppRoutes.webTimetable,
            'Timetable',
            Icons.table_chart_outlined,
            Icons.table_chart,
          ),
          _NavDest(
            AppRoutes.webMarksEntry,
            'Marks',
            Icons.grade_outlined,
            Icons.grade,
          ),
          _NavDest(
            AppRoutes.adminApprovals,
            'Approvals',
            Icons.approval_outlined,
            Icons.approval,
          ),
          _NavDest(
            AppRoutes.hodComms,
            'Comms',
            Icons.campaign_outlined,
            Icons.campaign,
          ),
          _NavDest(
            AppRoutes.hodProfile,
            'Profile',
            Icons.person_outline,
            Icons.person,
          ),
        ];
      case UserRole.superAdmin:
        return [
          _NavDest(
            AppRoutes.webPlatformDashboard,
            'Platform',
            Icons.dashboard_outlined,
            Icons.dashboard,
          ),
          _NavDest(
            AppRoutes.webPlatformColleges,
            'Colleges',
            Icons.apartment_outlined,
            Icons.apartment,
          ),
          _NavDest(
            AppRoutes.webUserManagement,
            'Users',
            Icons.manage_accounts_outlined,
            Icons.manage_accounts,
          ),
          _NavDest(
            AppRoutes.webSettings,
            'Settings',
            Icons.settings_outlined,
            Icons.settings,
          ),
          _NavDest(
            AppRoutes.webIntegrations,
            'Integrations',
            Icons.integration_instructions_outlined,
            Icons.integration_instructions,
          ),
        ];
      case UserRole.principal:
        return InstitutionMobileNavCatalog.principalDestinations()
            .map((e) => _NavDest(e.route, e.label, e.outline, e.filled))
            .toList();
      case UserRole.admin:
      case UserRole.support:
        return InstitutionMobileNavCatalog.adminSupportDestinations()
            .map((e) => _NavDest(e.route, e.label, e.outline, e.filled))
            .toList();
      case UserRole.accountant:
        return [
          _NavDest(
            AppRoutes.webAccountantDashboard,
            'Finance',
            Icons.account_balance_outlined,
            Icons.account_balance,
          ),
          _NavDest(
            AppRoutes.profile,
            'Profile',
            Icons.person_outline,
            Icons.person,
          ),
        ];
      case null:
        return [
          _NavDest(
            AppRoutes.login,
            'Sign in',
            Icons.login_outlined,
            Icons.login,
          ),
        ];
    }
  }

  int _selectedIndex(String path, List<_NavDest> dests) {
    for (int i = 0; i < dests.length; i++) {
      if (path.startsWith(dests[i].route)) return i;
    }
    return 0;
  }

  static String _titleFor(String path, UserRole? role) {
    if (path.startsWith(AppRoutes.principalStudentContacts)) {
      return 'Guardian contacts';
    }
    if (path == AppRoutes.adminBroadcast && role == UserRole.principal) {
      return 'Principal pulse';
    }
    if (path.startsWith('${AppRoutes.adminFaculty}/')) {
      final suffix = path.substring(AppRoutes.adminFaculty.length + 1);
      if (suffix.isNotEmpty && suffix != 'add') {
        return 'Team member';
      }
    }
    if (path == AppRoutes.adminFaculty && role == UserRole.principal) {
      return 'Team directory';
    }
    const titles = <String, String>{
      AppRoutes.parentHome: 'Home',
      AppRoutes.parentAttendance: 'Attendance',
      AppRoutes.parentFees: 'Fees',
      AppRoutes.parentDiary: 'Diary',
      AppRoutes.parentChatList: 'Messages',
      AppRoutes.parentChatThread: 'Chat',
      AppRoutes.parentBus: 'Bus Tracking',
      AppRoutes.parentNotices: 'Notices',
      AppRoutes.parentCanteen: 'Canteen',
      AppRoutes.parentProfile: 'Profile',
      AppRoutes.parentLeaveApply: 'Apply Leave',
      AppRoutes.parentLeaveStatus: 'Leave Status',
      AppRoutes.parentComplaintNew: 'Raise Complaint',
      AppRoutes.parentComplaints: 'My Complaints',
      AppRoutes.teacherHome: 'Home',
      AppRoutes.teacherAttendance: 'Attendance',
      AppRoutes.teacherDiary: 'Diary & Homework',
      AppRoutes.teacherStudents: 'My Students',
      AppRoutes.teacherMessages: 'School Pulse',
      AppRoutes.teacherProfile: 'Profile',
      AppRoutes.teacherLeaveApply: 'Apply Leave',
      AppRoutes.teacherLeaveApprovals: 'Leave Approvals',
      AppRoutes.studentHome: 'Home',
      AppRoutes.studentAcademics: 'Academics',
      AppRoutes.studentLibrary: 'Library',
      AppRoutes.studentCanteen: 'Food',
      AppRoutes.studentProfile: 'Profile',
      AppRoutes.adminHome: 'Dashboard',
      AppRoutes.adminApprovals: 'Approvals',
      AppRoutes.adminBroadcast: 'Broadcast',
      AppRoutes.principalStudentContacts: 'Guardian contacts',
      AppRoutes.adminAddStaff: 'Add Staff',
      AppRoutes.adminProfile: 'Profile',
      AppRoutes.adminTimetableSettings: 'Timetable settings',
      AppRoutes.adminTimetableEdit: 'Timetable (day)',
      AppRoutes.adminTimetableView: 'Timetable',
      AppRoutes.adminFacultyAdd: 'Onboard team member',
      AppRoutes.adminFaculty: 'Team roster',
      AppRoutes.adminUnavailabilityApprovals: 'Cover requests',
      AppRoutes.teacherTimetable: 'My timetable',
      AppRoutes.teacherUnavailability: 'Unavailability',
      AppRoutes.notifications: 'Notifications',
      AppRoutes.hostel: 'Hostel',
      AppRoutes.profile: 'Profile',
      AppRoutes.events: 'Events',
      AppRoutes.search: 'Search',
      AppRoutes.nammaAi: 'Namma AI',
      AppRoutes.staffHome: 'Home',
      AppRoutes.staffAttendance: 'Attendance',
      AppRoutes.staffLeaves: 'Leaves',
      AppRoutes.staffPayslips: 'Payslips',
      AppRoutes.staffTraining: 'Training',
      AppRoutes.staffCanteen: 'Food',
      AppRoutes.staffProfile: 'Profile',
      AppRoutes.driverHome: 'Today',
      AppRoutes.driverRoute: 'Route',
      AppRoutes.driverStudents: 'Students',
      AppRoutes.driverProfile: 'Profile',
      AppRoutes.driverTripHistory: 'Trip history',
      AppRoutes.driverVehicleChecklist: 'Vehicle checklist',
      AppRoutes.driverIncidentReport: 'Incident report',
      AppRoutes.librarianCounter: 'Counter',
      AppRoutes.librarianCatalog: 'Catalog',
      AppRoutes.librarianReservations: 'Reservations',
      AppRoutes.librarianProfile: 'Profile',
      AppRoutes.wardenHome: 'Home',
      AppRoutes.wardenRollcall: 'Roll Call',
      AppRoutes.wardenVisitors: 'Visitors',
      AppRoutes.wardenOutpass: 'Outpass',
      AppRoutes.wardenDining: 'Mess & dining',
      AppRoutes.wardenRooms: 'Rooms',
      AppRoutes.wardenNightPatrol: 'Night patrol',
      AppRoutes.wardenConcierge: 'Concierge',
      AppRoutes.wardenProfile: 'Profile',
      AppRoutes.canteenCounter: 'Counter',
      AppRoutes.canteenManage: 'Manage',
      AppRoutes.canteenProfile: 'Profile',
      AppRoutes.hodHome: 'Home',
      AppRoutes.hodComms: 'School Pulse',
      AppRoutes.hodProfile: 'Profile',
      AppRoutes.webTimetable: 'Timetable',
      AppRoutes.webMarksEntry: 'Marks',
      AppRoutes.webReportCards: 'Report Cards',
    };
    for (final e in titles.entries) {
      if (path.startsWith(e.key)) return e.value;
    }
    return AppConstants.appName;
  }

  static Color _accentForRole(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.primary;
      case UserRole.principal:
        return AppColors.deepPurple;
      case UserRole.teacher:
        return AppColors.teal;
      case UserRole.parent:
        return AppColors.accent;
      case UserRole.student:
        return AppColors.success;
      case UserRole.staff:
        return AppColors.purple;
      case UserRole.driver:
        return AppColors.warning;
      case UserRole.librarian:
        return AppColors.deepPurple;
      case UserRole.warden:
        return AppColors.teal;
      case UserRole.canteenStaff:
        return AppColors.accent;
      case UserRole.hod:
        return AppColors.teal;
      case UserRole.superAdmin:
        return AppColors.deepPurple;
      default:
        return AppColors.primary;
    }
  }

  static String _profileRouteFor(UserRole? role) {
    switch (role) {
      case UserRole.parent:
        return AppRoutes.parentProfile;
      case UserRole.teacher:
        return AppRoutes.teacherProfile;
      case UserRole.student:
        return AppRoutes.studentProfile;
      case UserRole.staff:
        return AppRoutes.staffProfile;
      case UserRole.driver:
        return AppRoutes.driverProfile;
      case UserRole.librarian:
        return AppRoutes.librarianProfile;
      case UserRole.warden:
        return AppRoutes.wardenProfile;
      case UserRole.canteenStaff:
        return AppRoutes.canteenProfile;
      case UserRole.hod:
        return AppRoutes.hodProfile;
      case UserRole.superAdmin:
        return AppRoutes.profile;
      default:
        return AppRoutes.adminProfile;
    }
  }
}

class _DesktopTopBar extends StatelessWidget {
  const _DesktopTopBar({
    required this.title,
    required this.onSearchTap,
    required this.profileRoute,
    required this.user,
  });

  final String title;
  final VoidCallback onSearchTap;
  final String profileRoute;
  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 56,
      color: isDark ? AppColors.cardDark : AppColors.card,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.headlineMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: onSearchTap,
            borderRadius: BorderRadius.circular(AppSpacing.xl),
            child: SizedBox(
              width: 220,
              height: 36,
              child: TextField(
                readOnly: true,
                onTap: onSearchTap,
                decoration: InputDecoration(
                  hintText: 'Search…',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.xl),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const NotificationIconButton(iconColor: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          if (user != null)
            InkWell(
              onTap: () => context.go(profileRoute),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xxs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NcAvatar(name: user!.name, radius: 16),
                    if (MediaQuery.sizeOf(context).width > 900) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        user!.name.split(' ').first,
                        style: AppTypography.labelMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Layout-aware bottom navigation ──────────────────────────────────────────

class _LayoutAwareBottomNav extends StatelessWidget {
  const _LayoutAwareBottomNav({
    required this.destinations,
    required this.navDestinations,
    required this.selectedIndex,
    required this.layout,
    required this.accentColor,
    required this.primary,
    required this.isDark,
    required this.onTap,
  });

  final List<_NavDest> destinations;
  final List<NavigationDestination> navDestinations;
  final int selectedIndex;
  final LayoutTheme layout;
  final Color accentColor;
  final Color primary;
  final bool isDark;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.cardDark : AppColors.card;

    switch (layout.navStyle) {
      // ── Floating pill (Ocean Blue default) ──────────────────────────
      case NavStyle.floatingPill:
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(layout.navCornerRadius),
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(layout.navCornerRadius),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: NavigationBar(
                height: 64,
                selectedIndex: selectedIndex,
                onDestinationSelected: onTap,
                destinations: navDestinations,
                backgroundColor: Colors.transparent,
                elevation: 0,
                indicatorColor: primary.withValues(alpha: 0.18),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              ),
            ),
          ),
        );

      // ── Floating icon-only rail (Royal Purple) ───────────────────────
      case NavStyle.floatingRail:
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(layout.navCornerRadius),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.45),
                  blurRadius: 28,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(destinations.length, (i) {
                final isSelected = i == selectedIndex;
                return GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.22)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      isSelected
                          ? (destinations[i].selectedIcon ??
                                destinations[i].icon)
                          : destinations[i].icon,
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.55),
                      size: isSelected ? 26 : 22,
                    ),
                  ),
                );
              }),
            ),
          ),
        );

      // ── Straight flush bar (Crimson Red compact) ─────────────────────
      case NavStyle.straightBar:
        return Container(
          decoration: BoxDecoration(
            color: bg,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.dividerDark : AppColors.divider,
              ),
            ),
          ),
          child: NavigationBar(
            height: 56,
            selectedIndex: selectedIndex,
            onDestinationSelected: onTap,
            destinations: navDestinations,
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: primary.withValues(alpha: 0.14),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          ),
        );

      // ── Transparent ghost nav (Solar Orange minimal) ─────────────────
      case NavStyle.transparent:
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(destinations.length, (i) {
                final isSelected = i == selectedIndex;
                return GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: primary.withValues(alpha: 0.3))
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected
                              ? (destinations[i].selectedIcon ??
                                    destinations[i].icon)
                              : destinations[i].icon,
                          color: isSelected ? primary : AppColors.textSecondary,
                          size: 22,
                        ),
                        if (layout.showNavLabels) ...[
                          const SizedBox(height: 2),
                          Text(
                            destinations[i].label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        );

      // ── M2 tab-indicator bar (Midnight Steel corporate) ──────────────
      case NavStyle.tabBar:
        return Container(
          decoration: BoxDecoration(
            color: bg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // active tab indicator strip
              Row(
                children: List.generate(destinations.length, (i) {
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 3,
                      color: i == selectedIndex ? primary : Colors.transparent,
                    ),
                  );
                }),
              ),
              NavigationBar(
                height: 60,
                selectedIndex: selectedIndex,
                onDestinationSelected: onTap,
                destinations: navDestinations,
                backgroundColor: Colors.transparent,
                elevation: 0,
                indicatorColor: Colors.transparent,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              ),
            ],
          ),
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.destinations,
    required this.selectedIndex,
    required this.onTap,
    this.collapsed = false,
    required this.onToggleCollapse,
  });

  final List<_NavDest> destinations;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool collapsed;
  final VoidCallback onToggleCollapse;

  static const double _widthExpanded = 240;
  static const double _widthCollapsed = 64;

  @override
  Widget build(BuildContext context) {
    final width = collapsed ? _widthCollapsed : _widthExpanded;
    final layout =
        Theme.of(context).extension<LayoutTheme>() ?? LayoutTheme.floatingPill;
    final itemRadius = (layout.cardCornerRadius * 0.7).clamp(4.0, 16.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: width,
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
                    borderRadius: BorderRadius.circular(itemRadius),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                if (!collapsed) ...[
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.sm,
              ),
              children: List.generate(destinations.length, (i) {
                final d = destinations[i];
                final isActive = selectedIndex == i;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: EdgeInsets.symmetric(
                        horizontal: collapsed ? AppSpacing.sm : AppSpacing.md,
                        vertical: layout.listTilePaddingV * 0.6,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(itemRadius),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isActive ? (d.selectedIcon ?? d.icon) : d.icon,
                            color: isActive ? Colors.white : Colors.white70,
                            size: 22,
                          ),
                          if (!collapsed) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                d.label,
                                style: AppTypography.labelMedium.copyWith(
                                  color: isActive
                                      ? Colors.white
                                      : Colors.white70,
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.w500,
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
              }),
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          InkWell(
            onTap: onToggleCollapse,
            child: SizedBox(
              height: 48,
              child: Row(
                mainAxisAlignment: collapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.end,
                children: [
                  if (!collapsed) const SizedBox(width: AppSpacing.md),
                  Icon(
                    collapsed ? Icons.chevron_right : Icons.chevron_left,
                    color: Colors.white54,
                    size: 22,
                  ),
                  if (!collapsed) const SizedBox(width: AppSpacing.md),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavDest {
  const _NavDest(this.route, this.label, this.icon, [this.selectedIcon]);
  final String route;
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
}
