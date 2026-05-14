import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../../routing/app_routes.dart';

/// ## Institution portal capability matrix (demo ERP)
///
/// Single source of truth for **principal** vs **school admin** vs **HOD** on
/// institution routes (`/admin/`, mobile shells, web leadership rail).
///
/// | Area | Admin / Support | Principal | HOD |
/// |------|-----------------|-----------|-----|
/// | Federation / multi-college (`/web/platform/*`) | Yes | No | No |
/// | HR onboarding (faculty add, staff add, user add) | Yes | No | Yes |
/// | Timetable structure edit / settings | Yes | No | Yes |
/// | Timetable week **view** | Yes | Yes (read-only UX) | Yes |
/// | Policy / leave / mock **approvals** | Yes | Yes | Yes |
/// | Cover / unavailability **approvals** | Yes | Yes | Yes |
/// | School-wide comms / broadcast | Yes | Yes | Yes |
/// | Staff directory **read** | Yes | Yes | Yes |
/// | Staff directory **HR edit** | Yes | No | Yes |
/// | Guardian contact correction (`/admin/principal/contacts`) | Via SIS | Yes | No |
///
/// **Principal `/admin/` redirect:** any path matching [principalForbiddenAdminPrefixes]
/// (exact or child) sends the user to [AppRoutes.adminHome] — see
/// [PrincipalPortalPolicy.shouldRedirectPrincipalFromAdmin].
enum PortalCapability {
  /// `/web/platform/*` (super-admin tooling; institution admin only).
  platformFederation,

  /// Faculty add, staff add, user provisioning.
  hrOnboardingWrite,

  /// Day builder, period grid edits, timetable settings.
  timetableStructureEdit,

  /// Week grid read-only view under `/admin/timetable`.
  timetableWeekGridRead,

  /// High-level approval queues (leave, policy, etc.).
  operationalApprovals,

  /// Pulse / broadcast / school comms surfaces.
  schoolWideCommsWrite,

  /// Open team roster and detail (read path).
  staffDirectoryRead,

  /// Edit mode, bulk actions, onboard on roster screens.
  staffDirectoryHrWrite,

  /// Principal guardian corrections screen.
  guardianContactWrite,
}

/// Principal-only policy and shared capability checks for institution operators.
abstract final class PrincipalPortalPolicy {
  static bool isPrincipal(UserRole? role) => role == UserRole.principal;

  /// Path prefixes (under `/admin/`) a principal must not open.
  static const List<String> principalForbiddenAdminPrefixes = <String>[
    AppRoutes.adminFacultyAdd,
    AppRoutes.adminAddStaff,
    AppRoutes.adminAddUser,
    AppRoutes.adminTimetableEdit,
    AppRoutes.adminTimetableSettings,
  ];

  /// When `true`, the router should send the principal to [AppRoutes.adminHome].
  static bool shouldRedirectPrincipalFromAdmin(String path) {
    if (!path.startsWith('/admin/')) return false;
    for (final p in principalForbiddenAdminPrefixes) {
      if (path == p || path.startsWith('$p/')) return true;
    }
    return false;
  }
}

/// Capability checks for admin, principal, HOD, and support (support ≈ admin UI).
abstract final class PortalCapabilityRegistry {
  static bool hasCapability(UserRole? role, PortalCapability c) {
    if (role == null) return false;
    final isSchoolAdmin = role == UserRole.admin || role == UserRole.support;
    if (isSchoolAdmin) return _adminSupportHas(c);
    if (role == UserRole.principal) return _principalHas(c);
    if (role == UserRole.hod) return _hodHas(c);
    return false;
  }

  static bool _adminSupportHas(PortalCapability c) => switch (c) {
    PortalCapability.platformFederation => true,
    PortalCapability.hrOnboardingWrite => true,
    PortalCapability.timetableStructureEdit => true,
    PortalCapability.timetableWeekGridRead => true,
    PortalCapability.operationalApprovals => true,
    PortalCapability.schoolWideCommsWrite => true,
    PortalCapability.staffDirectoryRead => true,
    PortalCapability.staffDirectoryHrWrite => true,
    PortalCapability.guardianContactWrite => true,
  };

  static bool _principalHas(PortalCapability c) => switch (c) {
    PortalCapability.platformFederation => false,
    PortalCapability.hrOnboardingWrite => false,
    PortalCapability.timetableStructureEdit => false,
    PortalCapability.timetableWeekGridRead => true,
    PortalCapability.operationalApprovals => true,
    PortalCapability.schoolWideCommsWrite => true,
    PortalCapability.staffDirectoryRead => true,
    PortalCapability.staffDirectoryHrWrite => false,
    PortalCapability.guardianContactWrite => true,
  };

  static bool _hodHas(PortalCapability c) => switch (c) {
    PortalCapability.platformFederation => false,
    PortalCapability.hrOnboardingWrite => true,
    PortalCapability.timetableStructureEdit => true,
    PortalCapability.timetableWeekGridRead => true,
    PortalCapability.operationalApprovals => true,
    PortalCapability.schoolWideCommsWrite => true,
    PortalCapability.staffDirectoryRead => true,
    PortalCapability.staffDirectoryHrWrite => true,
    PortalCapability.guardianContactWrite => false,
  };
}

/// Mobile [MainShell] destinations for `/admin/` institution operators — built
/// from the same routes/labels as the historical `_destinationsFor` switch.
abstract final class InstitutionMobileNavCatalog {
  static List<({String route, String label, IconData outline, IconData filled})>
  adminSupportDestinations() {
    return [
      (
        route: AppRoutes.adminHome,
        label: 'Dashboard',
        outline: Icons.dashboard_outlined,
        filled: Icons.dashboard,
      ),
      (
        route: AppRoutes.adminApprovals,
        label: 'Approvals',
        outline: Icons.approval_outlined,
        filled: Icons.approval,
      ),
      (
        route: AppRoutes.adminBroadcast,
        label: 'Broadcast',
        outline: Icons.campaign_outlined,
        filled: Icons.campaign,
      ),
      (
        route: AppRoutes.adminProfile,
        label: 'Profile',
        outline: Icons.person_outline,
        filled: Icons.person,
      ),
    ];
  }

  static List<({String route, String label, IconData outline, IconData filled})>
  principalDestinations() {
    return [
      (
        route: AppRoutes.adminHome,
        label: 'Overview',
        outline: Icons.insights_outlined,
        filled: Icons.insights,
      ),
      (
        route: AppRoutes.adminApprovals,
        label: 'Approvals',
        outline: Icons.approval_outlined,
        filled: Icons.approval,
      ),
      (
        route: AppRoutes.adminBroadcast,
        label: 'Pulse',
        outline: Icons.campaign_outlined,
        filled: Icons.campaign,
      ),
      (
        route: AppRoutes.adminFaculty,
        label: 'Team',
        outline: Icons.groups_outlined,
        filled: Icons.groups,
      ),
      (
        route: AppRoutes.principalStudentContacts,
        label: 'Contacts',
        outline: Icons.contact_phone_outlined,
        filled: Icons.contact_phone,
      ),
      (
        route: AppRoutes.adminProfile,
        label: 'Profile',
        outline: Icons.person_outline,
        filled: Icons.person,
      ),
    ];
  }
}

/// Web sidebar entries for the principal leadership rail (subset of admin web).
abstract final class InstitutionWebNavCatalog {
  static List<({String route, String label, IconData icon})>
  principalLeadershipMenu() {
    return [
      (
        route: AppRoutes.webDashboard,
        label: 'Leadership dashboard',
        icon: Icons.dashboard_outlined,
      ),
      (
        route: AppRoutes.webStudents,
        label: 'Students',
        icon: Icons.people_outline,
      ),
      (
        route: AppRoutes.webStaff,
        label: 'Staff directory',
        icon: Icons.groups_outlined,
      ),
      (
        route: AppRoutes.webTimetable,
        label: 'Timetable',
        icon: Icons.table_chart_outlined,
      ),
      (
        route: AppRoutes.webNotices,
        label: 'Notices & comms',
        icon: Icons.campaign_outlined,
      ),
      (
        route: AppRoutes.webAnalytics,
        label: 'Outcomes',
        icon: Icons.bar_chart_outlined,
      ),
    ];
  }
}
