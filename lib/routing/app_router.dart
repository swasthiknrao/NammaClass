import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/otp_screen.dart';
import '../features/auth/screens/splash_screen.dart';

// Parent
import '../features/parent/screens/parent_home_screen.dart';
import '../features/parent/screens/parent_attendance_screen.dart';
import '../features/parent/screens/parent_fees_screen.dart';
import '../features/parent/screens/parent_diary_screen.dart';
import '../features/parent/screens/parent_chat_list_screen.dart';
import '../features/parent/screens/chat_thread_screen.dart';
import '../features/parent/screens/bus_tracking_screen.dart';
import '../features/parent/screens/parent_notices_screen.dart';
import '../features/parent/screens/canteen_screen.dart';
import '../features/parent/screens/parent_leave_apply_screen.dart';
import '../features/parent/screens/parent_leave_status_screen.dart';
import '../features/parent/screens/parent_complaint_new_screen.dart';
import '../features/parent/screens/parent_complaints_screen.dart';

// Teacher
import '../features/teacher/screens/teacher_home_screen.dart';
import '../features/teacher/screens/attendance_mark_screen.dart';
import '../features/teacher/screens/diary_entry_screen.dart';
import '../features/teacher/screens/my_students_screen.dart';
import '../features/teacher/screens/teacher_leave_apply_screen.dart';
import '../features/teacher/screens/teacher_leave_approvals_screen.dart';

// Student
import '../features/student/screens/student_home_screen.dart';
import '../features/student/screens/academics_screen.dart';
import '../features/student/screens/library_screen.dart';

// Admin
import '../features/admin/screens/admin_dash_screen.dart';
import '../features/admin/screens/approvals_screen.dart';
import '../features/admin/screens/broadcast_screen.dart';
import '../features/admin/screens/people_screen.dart';

// Staff
import '../features/staff/screens/staff_home_screen.dart';
import '../features/staff/screens/staff_attendance_screen.dart';
import '../features/staff/screens/staff_payslips_screen.dart';
import '../features/staff/screens/staff_training_screen.dart';

// Driver
import '../features/driver/screens/driver_route_screen.dart';
import '../features/driver/screens/driver_students_screen.dart';

// Librarian
import '../features/librarian/screens/librarian_counter_screen.dart';
import '../features/librarian/screens/librarian_reservations_screen.dart';

// Warden
import '../features/warden/screens/warden_rollcall_screen.dart';
import '../features/warden/screens/warden_visitors_screen.dart';

// Canteen
import '../features/canteen/screens/canteen_counter_screen.dart';

// Shared
import '../features/shared/notifications/notifications_screen.dart';
import '../features/shared/profile/profile_screen.dart';
import '../features/shared/hostel/hostel_screen.dart';
import '../features/shared/events/school_events_screen.dart';
import '../features/shared/search/global_search_screen.dart';

// Web — Part 1
import '../features/web/dashboard/web_dashboard_screen.dart';
import '../features/web/analytics/web_analytics_screen.dart';
import '../features/web/students/web_students_screen.dart';
import '../features/web/students/web_student_profile.dart';
import '../features/web/academics/web_timetable_screen.dart';
import '../features/web/academics/web_marks_entry_screen.dart';
import '../features/web/fees/web_fee_structure_screen.dart';
import '../features/web/fees/web_fee_collection_screen.dart';
import '../features/web/staff/web_staff_screen.dart';
import '../features/web/staff/web_payroll_screen.dart';
import '../features/web/communication/web_notices_screen.dart';
import '../features/web/library/web_library_screen.dart';
import '../features/web/settings/web_settings_screen.dart';
import '../features/web/ai_tools/web_ai_tools_screen.dart';
import '../features/web/website/web_website_manager_screen.dart';

// Web — Part 2
import '../features/web/admissions/web_admission_dashboard_screen.dart';
import '../features/web/admissions/web_enquiries_screen.dart';
import '../features/web/admissions/web_application_detail_screen.dart';
import '../features/web/students/web_bulk_promotion_screen.dart';
import '../features/web/fees/web_fee_collect_screen.dart';
import '../features/web/finance/web_finance_ledger_screen.dart';
import '../features/web/academics/web_report_card_builder_screen.dart';
import '../features/web/communication/web_communication_analytics_screen.dart';
import '../features/web/library/web_library_reports_screen.dart';
import '../features/web/transport/web_transport_routes_screen.dart';
import '../features/web/transport/web_transport_live_screen.dart';
import '../features/web/inventory/web_inventory_assets_screen.dart';
import '../features/web/inventory/web_inventory_stock_screen.dart';
import '../features/web/analytics/web_report_builder_screen.dart';
import '../features/web/settings/web_user_management_screen.dart';
import '../features/web/settings/web_integrations_screen.dart';

import '../features/main_shell.dart';
import '../features/web_shell.dart';

import 'app_routes.dart';
import 'route_guard.dart';
import 'page_transitions.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellKey = GlobalKey<NavigatorState>(debugLabel: 'shell');
final _webShellKey = GlobalKey<NavigatorState>(debugLabel: 'webShell');
final _staffShellKey = GlobalKey<NavigatorState>(debugLabel: 'staffShell');
final _driverShellKey = GlobalKey<NavigatorState>(debugLabel: 'driverShell');
final _librarianShellKey = GlobalKey<NavigatorState>(
  debugLabel: 'librarianShell',
);
final _wardenShellKey = GlobalKey<NavigatorState>(debugLabel: 'wardenShell');
final _canteenShellKey = GlobalKey<NavigatorState>(debugLabel: 'canteenShell');

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) => routeGuard(state.uri.path, authState),
    routes: [
      // ── Auth ────────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, const SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.otp,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, const OtpScreen()),
      ),

      // ── Mobile Shell (Parent + Teacher + Student + Admin) ────────────────────
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // Parent
          GoRoute(
            path: AppRoutes.parentHome,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: ParentHomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.parentAttendance,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: ParentAttendanceScreen()),
          ),
          GoRoute(
            path: AppRoutes.parentFees,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: ParentFeesScreen()),
          ),
          GoRoute(
            path: AppRoutes.parentDiary,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: ParentDiaryScreen()),
          ),
          GoRoute(
            path: AppRoutes.parentChatList,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: ParentChatListScreen()),
          ),
          GoRoute(
            path: AppRoutes.parentChatThread,
            pageBuilder: (c, s) => NoTransitionPage(
              child: ChatThreadScreen(threadId: s.pathParameters['tid'] ?? ''),
            ),
          ),
          GoRoute(
            path: AppRoutes.parentBus,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: BusTrackingScreen()),
          ),
          GoRoute(
            path: AppRoutes.parentNotices,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: ParentNoticesScreen()),
          ),
          GoRoute(
            path: AppRoutes.parentCanteen,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: CanteenScreen()),
          ),
          GoRoute(
            path: AppRoutes.parentProfile,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
          GoRoute(
            path: AppRoutes.parentLeaveApply,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: ParentLeaveApplyScreen()),
          ),
          GoRoute(
            path: AppRoutes.parentLeaveStatus,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: ParentLeaveStatusScreen()),
          ),
          GoRoute(
            path: AppRoutes.parentComplaintNew,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: ParentComplaintNewScreen()),
          ),
          GoRoute(
            path: AppRoutes.parentComplaints,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: ParentComplaintsScreen()),
          ),

          // Teacher
          GoRoute(
            path: AppRoutes.teacherHome,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: TeacherHomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.teacherAttendance,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: AttendanceMarkScreen()),
          ),
          GoRoute(
            path: AppRoutes.teacherDiary,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: DiaryEntryScreen()),
          ),
          GoRoute(
            path: AppRoutes.teacherStudents,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: MyStudentsScreen()),
          ),
          GoRoute(
            path: AppRoutes.teacherProfile,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
          GoRoute(
            path: AppRoutes.teacherLeaveApply,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: TeacherLeaveApplyScreen()),
          ),
          GoRoute(
            path: AppRoutes.teacherLeaveApprovals,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: TeacherLeaveApprovalsScreen()),
          ),

          // Student
          GoRoute(
            path: AppRoutes.studentHome,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: StudentHomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.studentAcademics,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: AcademicsScreen()),
          ),
          GoRoute(
            path: AppRoutes.studentLibrary,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: LibraryScreen()),
          ),
          GoRoute(
            path: AppRoutes.studentProfile,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),

          // Admin
          GoRoute(
            path: AppRoutes.adminHome,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: AdminDashScreen()),
          ),
          GoRoute(
            path: AppRoutes.adminApprovals,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: ApprovalsScreen()),
          ),
          GoRoute(
            path: AppRoutes.adminBroadcast,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: BroadcastScreen()),
          ),
          GoRoute(
            path: AppRoutes.adminPeople,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: PeopleScreen()),
          ),
          GoRoute(
            path: AppRoutes.adminProfile,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),

          // Shared mobile (accessible from multiple roles)
          GoRoute(
            path: AppRoutes.notifications,
            pageBuilder: (c, s) =>
                NoTransitionPage(child: NotificationsScreen()),
          ),
          GoRoute(
            path: AppRoutes.hostel,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: HostelScreen()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
          GoRoute(
            path: AppRoutes.events,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: SchoolEventsScreen()),
          ),
          GoRoute(
            path: AppRoutes.search,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: GlobalSearchScreen()),
          ),
        ],
      ),

      // ── Staff Shell ──────────────────────────────────────────────────────────
      ShellRoute(
        navigatorKey: _staffShellKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.staffHome,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: StaffHomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.staffAttendance,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: StaffAttendanceScreen()),
          ),
          GoRoute(
            path: AppRoutes.staffLeaves,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: ParentLeaveStatusScreen()),
          ),
          GoRoute(
            path: AppRoutes.staffPayslips,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: StaffPayslipsScreen()),
          ),
          GoRoute(
            path: AppRoutes.staffTraining,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: StaffTrainingScreen()),
          ),
          GoRoute(
            path: AppRoutes.staffProfile,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            pageBuilder: (c, s) =>
                NoTransitionPage(child: NotificationsScreen()),
          ),
        ],
      ),

      // ── Driver Shell ─────────────────────────────────────────────────────────
      ShellRoute(
        navigatorKey: _driverShellKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.driverRoute,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: DriverRouteScreen()),
          ),
          GoRoute(
            path: AppRoutes.driverStudents,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: DriverStudentsScreen()),
          ),
          GoRoute(
            path: AppRoutes.driverProfile,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),

      // ── Librarian Shell ──────────────────────────────────────────────────────
      ShellRoute(
        navigatorKey: _librarianShellKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.librarianCounter,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: LibrarianCounterScreen()),
          ),
          GoRoute(
            path: AppRoutes.librarianReservations,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: LibrarianReservationsScreen()),
          ),
          GoRoute(
            path: AppRoutes.librarianProfile,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),

      // ── Warden Shell ─────────────────────────────────────────────────────────
      ShellRoute(
        navigatorKey: _wardenShellKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.wardenRollcall,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WardenRollcallScreen()),
          ),
          GoRoute(
            path: AppRoutes.wardenVisitors,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WardenVisitorsScreen()),
          ),
          GoRoute(
            path: AppRoutes.wardenProfile,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),

      // ── Canteen Shell ────────────────────────────────────────────────────────
      ShellRoute(
        navigatorKey: _canteenShellKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.canteenCounter,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: CanteenCounterScreen()),
          ),
          GoRoute(
            path: AppRoutes.canteenProfile,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),

      // ── Web Shell ────────────────────────────────────────────────────────────
      ShellRoute(
        navigatorKey: _webShellKey,
        builder: (context, state, child) => WebShell(child: child),
        routes: [
          // Part 1
          GoRoute(
            path: AppRoutes.webDashboard,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebDashboardScreen()),
          ),
          GoRoute(
            path: AppRoutes.webAnalytics,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebAnalyticsScreen()),
          ),
          GoRoute(
            path: AppRoutes.webStudents,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebStudentsScreen()),
          ),
          GoRoute(
            path: AppRoutes.webStudentProfile,
            pageBuilder: (c, s) => NoTransitionPage(
              child: WebStudentProfile(studentId: s.pathParameters['id'] ?? ''),
            ),
          ),
          GoRoute(
            path: AppRoutes.webTimetable,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebTimetableScreen()),
          ),
          GoRoute(
            path: AppRoutes.webMarksEntry,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebMarksEntryScreen()),
          ),
          GoRoute(
            path: AppRoutes.webFeeStructure,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebFeeStructureScreen()),
          ),
          GoRoute(
            path: AppRoutes.webFeeCollection,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebFeeCollectionScreen()),
          ),
          GoRoute(
            path: AppRoutes.webStaff,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebStaffScreen()),
          ),
          GoRoute(
            path: AppRoutes.webPayroll,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebPayrollScreen()),
          ),
          GoRoute(
            path: AppRoutes.webNotices,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebNoticesScreen()),
          ),
          GoRoute(
            path: AppRoutes.webLibrary,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebLibraryScreen()),
          ),
          GoRoute(
            path: AppRoutes.webSettings,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebSettingsScreen()),
          ),
          GoRoute(
            path: AppRoutes.webAiTools,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebAiToolsScreen()),
          ),
          GoRoute(
            path: AppRoutes.webWebsite,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebWebsiteManagerScreen()),
          ),

          // Part 2 — Admissions
          GoRoute(
            path: AppRoutes.webAdmissions,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebAdmissionDashboardScreen()),
          ),
          GoRoute(
            path: AppRoutes.webEnquiries,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebEnquiriesScreen()),
          ),
          GoRoute(
            path: AppRoutes.webApplicationDetail,
            pageBuilder: (c, s) => NoTransitionPage(
              child: WebApplicationDetailScreen(
                applicationId: s.pathParameters['id'] ?? '',
              ),
            ),
          ),
          // Part 2 — Student Management
          GoRoute(
            path: AppRoutes.webBulkPromotion,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebBulkPromotionScreen()),
          ),
          // Part 2 — Finance
          GoRoute(
            path: AppRoutes.webFeeCollect,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebFeeCollectScreen()),
          ),
          GoRoute(
            path: AppRoutes.webFinanceLedger,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebFinanceLedgerScreen()),
          ),
          // Part 2 — Academics
          GoRoute(
            path: AppRoutes.webReportCards,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebReportCardBuilderScreen()),
          ),
          // Part 2 — Communication
          GoRoute(
            path: AppRoutes.webCommunicationAnalytics,
            pageBuilder: (c, s) => const NoTransitionPage(
              child: WebCommunicationAnalyticsScreen(),
            ),
          ),
          // Part 2 — Library
          GoRoute(
            path: AppRoutes.webLibraryReports,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebLibraryReportsScreen()),
          ),
          // Part 2 — Transport
          GoRoute(
            path: AppRoutes.webTransportRoutes,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebTransportRoutesScreen()),
          ),
          GoRoute(
            path: AppRoutes.webTransportLive,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebTransportLiveScreen()),
          ),
          // Part 2 — Inventory
          GoRoute(
            path: AppRoutes.webInventoryAssets,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebInventoryAssetsScreen()),
          ),
          GoRoute(
            path: AppRoutes.webInventoryStock,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebInventoryStockScreen()),
          ),
          // Part 2 — Reports
          GoRoute(
            path: AppRoutes.webReportBuilder,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebReportBuilderScreen()),
          ),
          // Part 2 — Settings
          GoRoute(
            path: AppRoutes.webUserManagement,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebUserManagementScreen()),
          ),
          GoRoute(
            path: AppRoutes.webIntegrations,
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WebIntegrationsScreen()),
          ),
        ],
      ),
    ],
  );
});
