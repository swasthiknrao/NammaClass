/// NammaClass route path constants — BRD Section 1.5 + Part 2.
class AppRoutes {
  AppRoutes._();

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String splash = '/splash';
  static const String login = '/login';
  static const String otp = '/otp';

  // ── Parent ────────────────────────────────────────────────────────────────
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
  // Part 2 — Leave & Complaints
  static const String parentLeaveApply = '/parent/leave-apply';
  static const String parentLeaveStatus = '/parent/leave-status';
  static const String parentComplaintNew = '/parent/complaint-new';
  static const String parentComplaints = '/parent/complaints';

  // ── Teacher ───────────────────────────────────────────────────────────────
  static const String teacherHome = '/teacher/home';
  static const String teacherAttendance = '/teacher/attendance';
  static const String teacherAttendanceMark = '/teacher/attendance/mark';
  static const String teacherDiary = '/teacher/diary';
  static const String teacherStudents = '/teacher/students';
  static const String teacherProfile = '/teacher/profile';
  // Part 2 — Leave
  static const String teacherLeaveApply = '/teacher/leave-apply';
  static const String teacherLeaveApprovals = '/teacher/leave-approvals';

  // ── Student ───────────────────────────────────────────────────────────────
  static const String studentHome = '/student/home';
  static const String studentAcademics = '/student/academics';
  static const String studentLibrary = '/student/library';
  static const String studentCanteen = '/student/canteen';
  static const String studentProfile = '/student/profile';

  // ── Admin ─────────────────────────────────────────────────────────────────
  static const String adminHome = '/admin/home';
  static const String adminApprovals = '/admin/approvals';
  static const String adminBroadcast = '/admin/broadcast';
  static const String adminPeople = '/admin/people';
  static const String adminAddStaff = '/admin/staff/add';
  static const String adminProfile = '/admin/profile';

  // ── Shared ────────────────────────────────────────────────────────────────
  static const String notifications = '/notifications';
  static const String hostel = '/hostel';
  static const String profile = '/profile';
  // Part 2
  static const String events = '/events';
  static const String search = '/search';

  // ── Staff HR Portal (Part 2) ──────────────────────────────────────────────
  static const String staffHome = '/staff/home';
  static const String staffAttendance = '/staff/attendance';
  static const String staffLeaves = '/staff/leaves';
  static const String staffPayslips = '/staff/payslips';
  static const String staffTraining = '/staff/training';
  static const String staffCanteen = '/staff/canteen';
  static const String staffProfile = '/staff/profile';

  // ── Driver App (Part 2) ───────────────────────────────────────────────────
  static const String driverRoute = '/driver/route';
  static const String driverStudents = '/driver/students';
  static const String driverProfile = '/driver/profile';

  // ── Librarian App (Part 2) ────────────────────────────────────────────────
  static const String librarianCounter = '/librarian/counter';
  static const String librarianCatalog = '/librarian/catalog';
  static const String librarianReservations = '/librarian/reservations';
  static const String librarianProfile = '/librarian/profile';

  // ── Hostel Warden App (Part 2) ────────────────────────────────────────────
  static const String wardenHome = '/warden/home';
  static const String wardenRollcall = '/warden/rollcall';
  static const String wardenVisitors = '/warden/visitors';
  static const String wardenOutpass = '/warden/outpass';
  static const String wardenProfile = '/warden/profile';

  // ── Canteen Staff App (Part 2) ────────────────────────────────────────────
  static const String canteenCounter = '/canteen/counter';
  static const String canteenManage = '/canteen/manage';
  static const String canteenProfile = '/canteen/profile';

  // ── HOD (mobile-first) ───────────────────────────────────────────────────────
  static const String hodHome = '/hod/home';
  static const String hodProfile = '/hod/profile';

  // ── Shared Food/Canteen (for student, staff, parent) ──────────────────────
  static const String foodMenu = '/food';

  // ── Web Portal (Part 1) ───────────────────────────────────────────────────
  static const String webHodHome = '/web/hod-home';
  static const String webDashboard = '/web/dashboard';
  static const String webAnalytics = '/web/analytics';
  static const String webStudents = '/web/students';
  static const String webStudentProfile = '/web/students/:id';
  static const String webTimetable = '/web/timetable';
  static const String webMarksEntry = '/web/marks';
  static const String webFeeStructure = '/web/fees/structure';
  static const String webFeeCollection = '/web/fees/collection';
  static const String webStaff = '/web/staff';
  static const String webAddStaff = '/web/staff/add';
  static const String webPayroll = '/web/payroll';
  static const String webNotices = '/web/notices';
  static const String webLibrary = '/web/library';
  static const String webTransport = '/web/transport';
  static const String webHostel = '/web/hostel';
  static const String webSettings = '/web/settings';
  static const String webAiTools = '/web/ai';
  static const String webWebsite = '/web/website';

  // ── Web Portal (Part 2) ───────────────────────────────────────────────────
  // Admissions
  static const String webAdmissions = '/web/admissions';
  static const String webEnquiries = '/web/admissions/enquiries';
  static const String webApplicationDetail = '/web/admissions/applications/:id';
  // Students
  static const String webBulkPromotion = '/web/students/promote';
  // Finance
  static const String webFeeCollect = '/web/fees/collect';
  static const String webFinanceLedger = '/web/finance/ledger';
  // Academics
  static const String webReportCards = '/web/report-cards';
  // Communication
  static const String webCommunicationAnalytics =
      '/web/communication/analytics';
  // Library
  static const String webLibraryReports = '/web/library/reports';
  // Transport
  static const String webTransportRoutes = '/web/transport/routes';
  static const String webTransportLive = '/web/transport/live';
  // Inventory
  static const String webInventoryAssets = '/web/inventory/assets';
  static const String webInventoryStock = '/web/inventory/stock';
  // Reports & Analytics
  static const String webReportBuilder = '/web/reports/builder';
  // Settings
  static const String webUserManagement = '/web/settings/users';
  static const String webIntegrations = '/web/settings/integrations';
  static const String webSecurityLog = '/web/settings/security-log';

  // ── Support Portal ─────────────────────────────────────────────────────────
  static const String webSupportDashboard = '/web/support/dashboard';
  static const String webSupportTickets = '/web/support/tickets';
  static const String webSupportComplaints = '/web/support/complaints';
  static const String webSupportKnowledgeBase = '/web/support/kb';

  // ── Accountant Portal ──────────────────────────────────────────────────────
  static const String webAccountantDashboard = '/web/accountant/dashboard';
}
