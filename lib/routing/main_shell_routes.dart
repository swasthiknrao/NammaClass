import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/screens/admin_dash_screen.dart';
import '../features/admin/screens/approvals_screen.dart';
import '../features/admin/screens/broadcast_screen.dart';
import '../features/admin/screens/people_screen.dart';
import '../features/parent/screens/bus_tracking_screen.dart';
import '../features/parent/screens/canteen_screen.dart';
import '../features/parent/screens/chat_thread_screen.dart';
import '../features/parent/screens/parent_attendance_screen.dart';
import '../features/parent/screens/parent_chat_list_screen.dart';
import '../features/parent/screens/parent_complaint_new_screen.dart';
import '../features/parent/screens/parent_complaints_screen.dart';
import '../features/parent/screens/parent_diary_screen.dart';
import '../features/parent/screens/parent_fees_screen.dart';
import '../features/parent/screens/parent_home_screen.dart';
import '../features/parent/screens/parent_leave_apply_screen.dart';
import '../features/parent/screens/parent_leave_status_screen.dart';
import '../features/parent/screens/parent_notices_screen.dart';
import '../features/shared/events/school_events_screen.dart';
import '../features/shared/hostel/hostel_screen.dart';
import '../features/shared/notifications/notifications_screen.dart';
import '../features/shared/profile/profile_screen.dart';
import '../features/shared/search/global_search_screen.dart';
import '../features/student/screens/academics_screen.dart';
import '../features/student/screens/library_screen.dart';
import '../features/student/screens/student_home_screen.dart';
import '../features/teacher/screens/attendance_mark_screen.dart';
import '../features/teacher/screens/diary_entry_screen.dart';
import '../features/teacher/screens/my_students_screen.dart';
import '../features/teacher/screens/teacher_home_screen.dart';
import '../features/teacher/screens/teacher_leave_apply_screen.dart';
import '../features/teacher/screens/teacher_leave_approvals_screen.dart';
import '../features/main_shell.dart';
import 'app_routes.dart';

List<RouteBase> mainShellRoutes(GlobalKey<NavigatorState> navigatorKey) => [
  ShellRoute(
    navigatorKey: navigatorKey,
    builder: (context, state, child) => MainShell(child: child),
    routes: [
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
        pageBuilder: (c, s) => const NoTransitionPage(child: CanteenScreen()),
      ),
      GoRoute(
        path: AppRoutes.parentProfile,
        pageBuilder: (c, s) => const NoTransitionPage(child: ProfileScreen()),
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
        pageBuilder: (c, s) => const NoTransitionPage(child: ProfileScreen()),
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
      GoRoute(
        path: AppRoutes.studentHome,
        pageBuilder: (c, s) =>
            const NoTransitionPage(child: StudentHomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.studentAcademics,
        pageBuilder: (c, s) => const NoTransitionPage(child: AcademicsScreen()),
      ),
      GoRoute(
        path: AppRoutes.studentLibrary,
        pageBuilder: (c, s) => const NoTransitionPage(child: LibraryScreen()),
      ),
      GoRoute(
        path: AppRoutes.studentProfile,
        pageBuilder: (c, s) => const NoTransitionPage(child: ProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminHome,
        pageBuilder: (c, s) => const NoTransitionPage(child: AdminDashScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminApprovals,
        pageBuilder: (c, s) => const NoTransitionPage(child: ApprovalsScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminBroadcast,
        pageBuilder: (c, s) => const NoTransitionPage(child: BroadcastScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminPeople,
        pageBuilder: (c, s) => const NoTransitionPage(child: PeopleScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminProfile,
        pageBuilder: (c, s) => const NoTransitionPage(child: ProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        pageBuilder: (c, s) => NoTransitionPage(child: NotificationsScreen()),
      ),
      GoRoute(
        path: AppRoutes.hostel,
        pageBuilder: (c, s) => const NoTransitionPage(child: HostelScreen()),
      ),
      GoRoute(
        path: AppRoutes.profile,
        pageBuilder: (c, s) => const NoTransitionPage(child: ProfileScreen()),
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
];
