import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'page_transitions.dart';
import '../features/admin/screens/admin_dash_screen.dart';
import '../features/admin/screens/admin_unavailability_approvals_screen.dart';
import '../features/admin/screens/approvals_screen.dart';
import '../features/admin/screens/broadcast_screen.dart';
import '../features/admin/screens/principal_student_contacts_screen.dart';
import '../features/admin/faculty/screens/admin_faculty_add_screen.dart';
import '../features/admin/faculty/screens/admin_faculty_detail_screen.dart';
import '../features/admin/faculty/screens/admin_faculty_list_screen.dart';
import '../features/admin/timetable/screens/admin_timetable_management_screen.dart';
import '../features/admin/timetable/screens/admin_timetable_settings_screen.dart';
import '../features/admin/timetable/screens/admin_timetable_view_screen.dart';
import '../features/web/staff/add_staff_screen.dart';
import '../features/namma_ai/screens/namma_ai_screen.dart';
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
import '../features/teacher/screens/attendance_calendar_screen.dart';
import '../features/teacher/screens/attendance_mark_screen.dart';
import '../features/teacher/screens/diary_entry_screen.dart';
import '../features/teacher/screens/my_students_screen.dart';
import '../features/teacher/screens/teacher_comms_screen.dart';
import '../features/teacher/screens/teacher_home_screen.dart';
import '../features/teacher/screens/teacher_leave_apply_screen.dart';
import '../features/teacher/screens/teacher_leave_approvals_screen.dart';
import '../features/teacher/timetable/screens/teacher_my_timetable_screen.dart';
import '../features/teacher/unavailability/screens/teacher_unavailability_screen.dart';
import '../features/hod/screens/hod_comms_screen.dart';
import '../features/hod/screens/hod_home_screen.dart';
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
            fadeSlideTransition(c, s, const ParentHomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.parentAttendance,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const ParentAttendanceScreen()),
      ),
      GoRoute(
        path: AppRoutes.parentFees,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const ParentFeesScreen()),
      ),
      GoRoute(
        path: AppRoutes.parentDiary,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const ParentDiaryScreen()),
      ),
      GoRoute(
        path: AppRoutes.parentChatList,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const ParentChatListScreen()),
      ),
      GoRoute(
        path: AppRoutes.parentChatThread,
        pageBuilder: (c, s) => fadeSlideTransition(
          c,
          s,
          ChatThreadScreen(threadId: s.pathParameters['tid'] ?? ''),
        ),
      ),
      GoRoute(
        path: AppRoutes.parentBus,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const BusTrackingScreen()),
      ),
      GoRoute(
        path: AppRoutes.parentNotices,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const ParentNoticesScreen()),
      ),
      GoRoute(
        path: AppRoutes.parentCanteen,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, CanteenScreen()),
      ),
      GoRoute(
        path: AppRoutes.parentProfile,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, ProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.parentLeaveApply,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const ParentLeaveApplyScreen()),
      ),
      GoRoute(
        path: AppRoutes.parentLeaveStatus,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, ParentLeaveStatusScreen()),
      ),
      GoRoute(
        path: AppRoutes.parentComplaintNew,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, ParentComplaintNewScreen()),
      ),
      GoRoute(
        path: AppRoutes.parentComplaints,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, ParentComplaintsScreen()),
      ),
      GoRoute(
        path: AppRoutes.teacherHome,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, TeacherHomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.teacherAttendance,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const AttendanceCalendarScreen()),
      ),
      GoRoute(
        path: AppRoutes.teacherAttendanceMark,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const AttendanceMarkScreen()),
      ),
      GoRoute(
        path: AppRoutes.teacherDiary,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, DiaryEntryScreen()),
      ),
      GoRoute(
        path: AppRoutes.teacherStudents,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, MyStudentsScreen()),
      ),
      GoRoute(
        path: AppRoutes.teacherMessages,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const TeacherCommsScreen()),
      ),
      GoRoute(
        path: AppRoutes.teacherProfile,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, ProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.teacherLeaveApply,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, TeacherLeaveApplyScreen()),
      ),
      GoRoute(
        path: AppRoutes.teacherLeaveApprovals,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, TeacherLeaveApprovalsScreen()),
      ),
      GoRoute(
        path: AppRoutes.teacherTimetable,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const TeacherMyTimetableScreen()),
      ),
      GoRoute(
        path: AppRoutes.teacherUnavailability,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const TeacherUnavailabilityScreen()),
      ),
      GoRoute(
        path: AppRoutes.studentHome,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, StudentHomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.studentAcademics,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, AcademicsScreen()),
      ),
      GoRoute(
        path: AppRoutes.studentLibrary,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, LibraryScreen()),
      ),
      GoRoute(
        path: AppRoutes.studentCanteen,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, const CanteenScreen()),
      ),
      GoRoute(
        path: AppRoutes.studentProfile,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, ProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminHome,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, AdminDashScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminApprovals,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, ApprovalsScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminBroadcast,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, BroadcastScreen()),
      ),
      GoRoute(
        path: AppRoutes.principalStudentContacts,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const PrincipalStudentContactsScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminPeople,
        redirect: (context, state) => AppRoutes.adminFaculty,
      ),
      GoRoute(
        path: AppRoutes.adminAddStaff,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const AddStaffScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminAddUser,
        redirect: (context, state) => AppRoutes.adminFacultyAdd,
      ),
      GoRoute(
        path: AppRoutes.adminProfile,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, ProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminTimetableView,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const AdminTimetableViewScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminTimetableEdit,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const AdminTimetableManagementScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminTimetableSettings,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const AdminTimetableSettingsScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminFaculty,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const AdminFacultyListScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminFacultyAdd,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const AdminFacultyAddScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminFacultyDetail,
        pageBuilder: (c, s) => fadeSlideTransition(
          c,
          s,
          AdminFacultyDetailScreen(facultyId: s.pathParameters['id'] ?? ''),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminUnavailabilityApprovals,
        pageBuilder: (c, s) => fadeSlideTransition(
          c,
          s,
          const AdminUnavailabilityApprovalsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.hodHome,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, const HodHomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.hodComms,
        pageBuilder: (c, s) =>
            fadeSlideTransition(c, s, const HodCommsScreen()),
      ),
      GoRoute(
        path: AppRoutes.hodProfile,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, ProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, NotificationsScreen()),
      ),
      GoRoute(
        path: AppRoutes.hostel,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, HostelScreen()),
      ),
      GoRoute(
        path: AppRoutes.profile,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, ProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.events,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, SchoolEventsScreen()),
      ),
      GoRoute(
        path: AppRoutes.search,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, GlobalSearchScreen()),
      ),
      GoRoute(
        path: AppRoutes.nammaAi,
        pageBuilder: (c, s) => fadeSlideTransition(c, s, const NammaAiScreen()),
      ),
    ],
  ),
];
