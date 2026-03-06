import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/otp_screen.dart';
import '../features/auth/screens/splash_screen.dart';

import '../features/parent/screens/parent_home_screen.dart';
import '../features/parent/screens/parent_attendance_screen.dart';
import '../features/parent/screens/parent_fees_screen.dart';
import '../features/parent/screens/parent_diary_screen.dart';
import '../features/parent/screens/parent_chat_list_screen.dart';
import '../features/parent/screens/chat_thread_screen.dart';
import '../features/parent/screens/bus_tracking_screen.dart';
import '../features/parent/screens/parent_notices_screen.dart';
import '../features/parent/screens/canteen_screen.dart';

import '../features/teacher/screens/teacher_home_screen.dart';
import '../features/teacher/screens/attendance_mark_screen.dart';
import '../features/teacher/screens/diary_entry_screen.dart';
import '../features/teacher/screens/my_students_screen.dart';

import '../features/student/screens/student_home_screen.dart';
import '../features/student/screens/academics_screen.dart';
import '../features/student/screens/library_screen.dart';

import '../features/admin/screens/admin_dash_screen.dart';
import '../features/admin/screens/approvals_screen.dart';
import '../features/admin/screens/broadcast_screen.dart';
import '../features/admin/screens/people_screen.dart';

import '../features/shared/notifications/notifications_screen.dart';
import '../features/shared/profile/profile_screen.dart';
import '../features/shared/hostel/hostel_screen.dart';

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

import '../features/main_shell.dart';
import '../features/web_shell.dart';

import 'app_routes.dart';
import 'route_guard.dart';
import 'page_transitions.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellKey = GlobalKey<NavigatorState>(debugLabel: 'shell');
final _webShellKey = GlobalKey<NavigatorState>(debugLabel: 'webShell');

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) => routeGuard(state.uri.path, authState),
    routes: [
      // ── Auth ──────────────────────────────────────────────────────────────────
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

      // ── Mobile Shell ──────────────────────────────────────────────────────────
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

          // Shared mobile
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
        ],
      ),

      // ── Web Shell ─────────────────────────────────────────────────────────────
      ShellRoute(
        navigatorKey: _webShellKey,
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
        ],
      ),
    ],
  );
});
