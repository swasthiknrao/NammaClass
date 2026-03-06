/// NammaClass application constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'NammaClass';
  static const String appTagline = 'Smart School. Happy Campus.';
  static const String schoolName = 'Vidyashree Public School';
}

/// API endpoint strings — no real calls yet, prepared for backend integration.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.nammaclass.in/v1';

  // Auth
  static const String sendOtp = '/auth/otp/send';
  static const String verifyOtp = '/auth/otp/verify';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String validateToken = '/auth/validate-token';

  // Dashboard
  static const String dashboard = '/dashboard/summary';

  // Students
  static const String students = '/students';
  static const String studentAttendance = '/students/{id}/attendance';
  static const String studentFees = '/students/{id}/fees';

  // Attendance
  static const String attendance = '/attendance';

  // Fees
  static const String feeStructure = '/fees/structure';
  static const String collectFee = '/fees/collect';
  static const String feeTransactions = '/fees/transactions';

  // Notices
  static const String notices = '/notices';

  // Timetable
  static const String timetable = '/timetable';

  // Homework
  static const String homework = '/homework';

  // Chat
  static const String chatThreads = '/chat/threads';

  // Transport
  static const String busLocation = '/transport/bus/{id}/location';

  // Library
  static const String libraryBooks = '/library/books';
  static const String libraryIssue = '/library/issue';

  // Staff
  static const String staff = '/staff';

  // Payroll
  static const String payroll = '/payroll';

  // Canteen
  static const String canteenMenu = '/canteen/menu';
  static const String canteenOrder = '/canteen/order';

  // Wallet
  static const String walletBalance = '/wallet/balance';

  // Hostel
  static const String hostelRoom = '/hostel/my-room';
  static const String hostelMess = '/hostel/mess-menu';

  // AI
  static const String aiDraftNotice = '/ai/draft-notice';
  static const String aiDefaulterPrediction = '/ai/fee-defaulter-prediction';
  static const String aiHealthScore = '/ai/health-score';
}
