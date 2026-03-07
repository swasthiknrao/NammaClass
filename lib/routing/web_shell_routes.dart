import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
import '../features/web/settings/web_integrations_screen.dart';
import '../features/web/settings/web_security_log_screen.dart';
import '../features/web/settings/web_settings_screen.dart';
import '../features/web/settings/web_user_management_screen.dart';
import '../features/web/staff/web_payroll_screen.dart';
import '../features/web/staff/web_staff_screen.dart';
import '../features/web/students/web_bulk_promotion_screen.dart';
import '../features/web/students/web_student_profile.dart';
import '../features/web/students/web_students_screen.dart';
import '../features/web/transport/web_transport_live_screen.dart';
import '../features/web/transport/web_transport_routes_screen.dart';
import '../features/web/website/web_website_manager_screen.dart';
import '../features/web_shell.dart';
import 'app_routes.dart';

List<RouteBase> webShellRoutes(GlobalKey<NavigatorState> navigatorKey) => [
  ShellRoute(
    navigatorKey: navigatorKey,
    builder: (context, state, child) => WebShell(child: child),
    routes: [
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
        pageBuilder: (c, s) => const NoTransitionPage(child: WebStaffScreen()),
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
      GoRoute(
        path: AppRoutes.webBulkPromotion,
        pageBuilder: (c, s) =>
            const NoTransitionPage(child: WebBulkPromotionScreen()),
      ),
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
      GoRoute(
        path: AppRoutes.webReportCards,
        pageBuilder: (c, s) =>
            const NoTransitionPage(child: WebReportCardBuilderScreen()),
      ),
      GoRoute(
        path: AppRoutes.webCommunicationAnalytics,
        pageBuilder: (c, s) =>
            const NoTransitionPage(child: WebCommunicationAnalyticsScreen()),
      ),
      GoRoute(
        path: AppRoutes.webLibraryReports,
        pageBuilder: (c, s) =>
            const NoTransitionPage(child: WebLibraryReportsScreen()),
      ),
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
      GoRoute(
        path: AppRoutes.webReportBuilder,
        pageBuilder: (c, s) =>
            const NoTransitionPage(child: WebReportBuilderScreen()),
      ),
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
      GoRoute(
        path: AppRoutes.webSecurityLog,
        pageBuilder: (c, s) =>
            const NoTransitionPage(child: WebSecurityLogScreen()),
      ),
    ],
  ),
];
