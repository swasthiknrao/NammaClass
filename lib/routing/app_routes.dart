/// NammaClass route path constants — BRD Section 1.5.
class AppRoutes {
  AppRoutes._();

  // Auth
  static const String splash = '/splash';
  static const String login = '/login';
  static const String otp = '/otp';

  // Parent
  static const String parentHome = '/parent/home';
  static const String parentAttendance = '/parent/attendance';
  static const String parentFees = '/parent/fees';
  static const String parentDiary = '/parent/diary';
  static const String parentChatList = '/parent/chat';
  static const String parentChatThread = '/parent/chat/:tid';
  static const String parentBus = '/parent/bus';
  static const String parentNotices = '/parent/notices';
  static const String parentCanteen = '/parent/canteen';
  static const String parentProfile = '/parent/profile';

  // Teacher
  static const String teacherHome = '/teacher/home';
  static const String teacherAttendance = '/teacher/attendance';
  static const String teacherDiary = '/teacher/diary';
  static const String teacherStudents = '/teacher/students';
  static const String teacherProfile = '/teacher/profile';

  // Student
  static const String studentHome = '/student/home';
  static const String studentAcademics = '/student/academics';
  static const String studentLibrary = '/student/library';
  static const String studentProfile = '/student/profile';

  // Admin
  static const String adminHome = '/admin/home';
  static const String adminApprovals = '/admin/approvals';
  static const String adminBroadcast = '/admin/broadcast';
  static const String adminPeople = '/admin/people';
  static const String adminProfile = '/admin/profile';

  // Shared
  static const String notifications = '/notifications';
  static const String hostel = '/hostel';
  static const String profile = '/profile';

  // Web portal
  static const String webDashboard = '/web/dashboard';
  static const String webAnalytics = '/web/analytics';
  static const String webStudents = '/web/students';
  static const String webStudentProfile = '/web/students/:id';
  static const String webTimetable = '/web/timetable';
  static const String webMarksEntry = '/web/marks';
  static const String webFeeStructure = '/web/fees/structure';
  static const String webFeeCollection = '/web/fees/collection';
  static const String webStaff = '/web/staff';
  static const String webPayroll = '/web/payroll';
  static const String webNotices = '/web/notices';
  static const String webLibrary = '/web/library';
  static const String webTransport = '/web/transport';
  static const String webHostel = '/web/hostel';
  static const String webSettings = '/web/settings';
  static const String webAiTools = '/web/ai';
  static const String webWebsite = '/web/website';
}
