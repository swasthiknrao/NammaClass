import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'page_transitions.dart';
import '../features/web/academics/web_marks_entry_screen.dart';
import '../features/web/academics/web_report_card_builder_screen.dart';
import '../features/web/academics/web_timetable_screen.dart';
import '../features/web/admissions/web_admission_dashboard_screen.dart';
import '../features/web/admissions/web_application_detail_screen.dart';
import '../features/web/admissions/web_enquiries_screen.dart';
import '../features/web/ai_tools/web_ai_tools_screen.dart';
import '../features/web/analytics/web_analytics_screen.dart';
import '../features/web/analytics/web_report_builder_screen.dart';
import '../features/web/communication/web_communication_analytics_screen.dart';
import '../features/web/communication/web_notices_screen.dart';
import '../features/web/dashboard/web_dashboard_screen.dart';
import '../features/web/fees/web_fee_collection_screen.dart';
import '../features/web/fees/web_fee_collect_screen.dart';
import '../features/web/fees/web_fee_structure_screen.dart';
import '../features/web/finance/web_finance_ledger_screen.dart';
import '../features/web/inventory/web_inventory_assets_screen.dart';
import '../features/web/inventory/web_inventory_stock_screen.dart';
import '../features/web/library/web_library_reports_screen.dart';
import '../features/web/library/web_library_screen.dart';
import '../features/web/platform/platform_add_college_screen.dart';
import '../features/web/platform/platform_college_detail_screen.dart';
import '../features/web/platform/platform_colleges_list_screen.dart';
import '../features/web/platform/super_admin_dashboard_screen.dart';
import '../features/web/settings/web_integrations_screen.dart';
import '../features/web/settings/web_security_log_screen.dart';
import '../features/web/settings/web_settings_screen.dart';
import '../features/web/settings/web_user_management_screen.dart';
import '../features/web/staff/web_payroll_screen.dart';
import '../features/web/staff/add_staff_screen.dart';
import '../features/web/staff/web_staff_screen.dart';
import '../features/web/students/web_bulk_promotion_screen.dart';
import '../features/web/students/web_student_profile.dart';
import '../features/web/students/web_students_screen.dart';
import '../features/web/transport/web_transport_live_screen.dart';
import '../features/web/transport/web_transport_routes_screen.dart';
import '../features/web/website/web_website_manager_screen.dart';
import '../features/web/accountant/web_accountant_dashboard_screen.dart';
import '../features/web/support/web_support_complaints_screen.dart';
import '../features/web/support/web_support_dashboard_screen.dart';
import '../features/web/support/web_support_knowledge_base_screen.dart';
import '../features/web/support/web_support_tickets_screen.dart';
import '../features/hod/screens/hod_home_screen.dart';
import '../features/web_shell.dart';
import 'app_routes.dart';

List<RouteBase> webShellRoutes(GlobalKey<NavigatorState> navigatorKey) => [
  ShellRoute(
    navigatorKey: navigatorKey,
    builder: (context, state, child) => WebShell(child: child),
    routes: [
      GoRoute(
        path: AppRoutes.webPlatformDashboard,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const SuperAdminDashboardScreen()),
      ),
      GoRoute(
        path: AppRoutes.webPlatformColleges,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const PlatformCollegesListScreen()),
      ),
      GoRoute(
        path: AppRoutes.webPlatformAddCollege,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const PlatformAddCollegeScreen()),
      ),
      GoRoute(
        path: AppRoutes.webPlatformCollegeDetail,
        pageBuilder: (c, s) => fadeSlideTransition(
          c,
          s,
          PlatformCollegeDetailScreen(
            tenantId: Uri.decodeComponent(s.pathParameters['id'] ?? ''),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.webHodHome,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, const HodHomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.webDashboard,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, WebDashboardScreen()),
      ),
      GoRoute(
        path: AppRoutes.webAnalytics,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, WebAnalyticsScreen()),
      ),
      GoRoute(
        path: AppRoutes.webStudents,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, WebStudentsScreen()),
      ),
      GoRoute(
        path: AppRoutes.webStudentProfile,
        pageBuilder: (c, s) => NoTransitionPage(
          child: WebStudentProfile(studentId: s.pathParameters['id'] ?? ''),
        ),
      ),
      GoRoute(
        path: AppRoutes.webTimetable,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, WebTimetableScreen()),
      ),
      GoRoute(
        path: AppRoutes.webMarksEntry,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, WebMarksEntryScreen()),
      ),
      GoRoute(
        path: AppRoutes.webFeeStructure,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, WebFeeStructureScreen()),
      ),
      GoRoute(
        path: AppRoutes.webFeeCollection,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, WebFeeCollectionScreen()),
      ),
      GoRoute(
        path: AppRoutes.webStaff,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, WebStaffScreen()),
      ),
      GoRoute(
        path: AppRoutes.webAddStaff,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const AddStaffScreen()),
      ),
      GoRoute(
        path: AppRoutes.webPayroll,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, WebPayrollScreen()),
      ),
      GoRoute(
        path: AppRoutes.webNotices,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, WebNoticesScreen()),
      ),
      GoRoute(
        path: AppRoutes.webLibrary,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, WebLibraryScreen()),
      ),
      GoRoute(
        path: AppRoutes.webSettings,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, WebSettingsScreen()),
      ),
      GoRoute(
        path: AppRoutes.webAiTools,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, WebAiToolsScreen()),
      ),
      GoRoute(
        path: AppRoutes.webWebsite,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, WebWebsiteManagerScreen()),
      ),
      GoRoute(
        path: AppRoutes.webAdmissions,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, WebAdmissionDashboardScreen()),
      ),
      GoRoute(
        path: AppRoutes.webEnquiries,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, WebEnquiriesScreen()),
      ),
      GoRoute(
        path: AppRoutes.webApplicationDetail,
        pageBuilder: (c, s) => NoTransitionPage(
          child: WebApplicationDetailScreen(
            applicationId: s.pathParameters['id'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.webBulkPromotion,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, WebBulkPromotionScreen()),
      ),
      GoRoute(
        path: AppRoutes.webFeeCollect,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, WebFeeCollectScreen()),
      ),
      GoRoute(
        path: AppRoutes.webFinanceLedger,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, WebFinanceLedgerScreen()),
      ),
      GoRoute(
        path: AppRoutes.webReportCards,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, WebReportCardBuilderScreen()),
      ),
      GoRoute(
        path: AppRoutes.webCommunicationAnalytics,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, WebCommunicationAnalyticsScreen()),
      ),
      GoRoute(
        path: AppRoutes.webLibraryReports,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, WebLibraryReportsScreen()),
      ),
      GoRoute(
        path: AppRoutes.webTransportRoutes,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, WebTransportRoutesScreen()),
      ),
      GoRoute(
        path: AppRoutes.webTransportLive,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, WebTransportLiveScreen()),
      ),
      GoRoute(
        path: AppRoutes.webInventoryAssets,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, WebInventoryAssetsScreen()),
      ),
      GoRoute(
        path: AppRoutes.webInventoryStock,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, WebInventoryStockScreen()),
      ),
      GoRoute(
        path: AppRoutes.webReportBuilder,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, WebReportBuilderScreen()),
      ),
      GoRoute(
        path: AppRoutes.webUserManagement,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, WebUserManagementScreen()),
      ),
      GoRoute(
        path: AppRoutes.webIntegrations,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, WebIntegrationsScreen()),
      ),
      GoRoute(
        path: AppRoutes.webSecurityLog,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, WebSecurityLogScreen()),
      ),
      // Support portal
      GoRoute(
        path: AppRoutes.webSupportDashboard,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, WebSupportDashboardScreen()),
      ),
      GoRoute(
        path: AppRoutes.webSupportTickets,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, WebSupportTicketsScreen()),
      ),
      GoRoute(
        path: AppRoutes.webSupportComplaints,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, WebSupportComplaintsScreen()),
      ),
      GoRoute(
        path: AppRoutes.webSupportKnowledgeBase,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, WebSupportKnowledgeBaseScreen()),
      ),
      // Accountant portal
      GoRoute(
        path: AppRoutes.webAccountantDashboard,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, WebAccountantDashboardScreen()),
      ),
    ],
  ),
];
