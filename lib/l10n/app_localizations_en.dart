// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'NammaClass';

  @override
  String get appTagline => 'Smart School. Happy Campus.';

  @override
  String get loading => 'Loading…';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get submit => 'Submit';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get search => 'Search';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get offlineBannerBody =>
      'Showing cached data. Some actions may not be available.';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get noDataFound => 'No data found';

  @override
  String get pullToRefresh => 'Pull to refresh';

  @override
  String get seeAll => 'See all';

  @override
  String get viewDetails => 'View details';

  @override
  String get featureNotSubscribed =>
      'This feature is not available in your plan.';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginSubtitle => 'Sign in with your registered mobile number';

  @override
  String get mobileNumberLabel => 'Mobile Number';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get otpTitle => 'Verify OTP';

  @override
  String otpSubtitle(String phone) {
    return 'Enter the 6-digit code sent to $phone';
  }

  @override
  String get verifyOtp => 'Verify';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navAttendance => 'Attendance';

  @override
  String get navFees => 'Fees';

  @override
  String get navDiary => 'Diary';

  @override
  String get navBus => 'Bus';

  @override
  String get navProfile => 'Profile';

  @override
  String get navLibrary => 'Library';

  @override
  String get navFood => 'Food';

  @override
  String get navAcademics => 'Academics';

  @override
  String get navStudents => 'Students';

  @override
  String get navLeaves => 'Leaves';

  @override
  String get navPayslips => 'Payslips';

  @override
  String goodMorning(String name) {
    return 'Good morning, $name!';
  }

  @override
  String get attendanceTitle => 'Attendance';

  @override
  String get present => 'Present';

  @override
  String get absent => 'Absent';

  @override
  String get late => 'Late';

  @override
  String get leave => 'Leave';

  @override
  String get holiday => 'Holiday';

  @override
  String attendancePercent(String percent) {
    return '$percent% attendance';
  }

  @override
  String get feesTitle => 'Fees';

  @override
  String get feePending => 'Pending';

  @override
  String get feePaid => 'Paid';

  @override
  String get feeOverdue => 'Overdue';

  @override
  String get payNow => 'Pay Now';

  @override
  String get totalDue => 'Total due';

  @override
  String dueDate(String date) {
    return 'Due $date';
  }

  @override
  String get diaryTitle => 'Diary';

  @override
  String get classwork => 'Classwork';

  @override
  String get homework => 'Homework';

  @override
  String dueBy(String date) {
    return 'Due by $date';
  }

  @override
  String get markComplete => 'Mark complete';

  @override
  String get noticesTitle => 'Notices';

  @override
  String get noNotices => 'No notices yet';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get chatTitle => 'Messages';

  @override
  String get typeMessage => 'Type a message…';

  @override
  String get send => 'Send';

  @override
  String get busTitle => 'Bus Tracking';

  @override
  String get busLive => 'Live';

  @override
  String eta(int minutes) {
    return 'ETA $minutes min';
  }

  @override
  String get libraryTitle => 'Library';

  @override
  String get searchBooks => 'Search books…';

  @override
  String get available => 'Available';

  @override
  String get checkedOut => 'Checked out';

  @override
  String get overdue => 'Overdue';

  @override
  String dueIn(int days) {
    return 'Due in ${days}d';
  }

  @override
  String get canteenTitle => 'Canteen';

  @override
  String get orderNow => 'Order Now';

  @override
  String get addToCart => 'Add to cart';

  @override
  String walletBalance(String amount) {
    return 'Wallet: ₹$amount';
  }

  @override
  String get orderPlaced => 'Order placed!';

  @override
  String get orderPreparing => 'Preparing';

  @override
  String get orderReady => 'Ready to collect';

  @override
  String get orderCollected => 'Collected';

  @override
  String get profileTitle => 'Profile';

  @override
  String get logout => 'Log out';

  @override
  String get logoutConfirmTitle => 'Log out?';

  @override
  String get logoutConfirmBody => 'You will be signed out of NammaClass.';

  @override
  String get leaveApplyTitle => 'Apply for Leave';

  @override
  String get leaveReason => 'Reason';

  @override
  String get leaveFrom => 'From';

  @override
  String get leaveTo => 'To';

  @override
  String get leaveStatusTitle => 'Leave Status';

  @override
  String get leaveApproved => 'Approved';

  @override
  String get leavePending => 'Pending';

  @override
  String get leaveRejected => 'Rejected';

  @override
  String get complaintTitle => 'Complaints';

  @override
  String get newComplaint => 'New Complaint';

  @override
  String get complaintSubject => 'Subject';

  @override
  String get complaintDescription => 'Description';

  @override
  String get adminDashboard => 'Dashboard';

  @override
  String get totalStudents => 'Students';

  @override
  String get totalStaff => 'Staff';

  @override
  String get pendingApprovals => 'Pending approvals';

  @override
  String get broadcastTitle => 'Broadcast';

  @override
  String get peopleTitle => 'People';

  @override
  String get approvalsTitle => 'Approvals';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get payslipsTitle => 'Payslips';

  @override
  String get downloadPayslip => 'Download';

  @override
  String get grossSalary => 'Gross';

  @override
  String get deductions => 'Deductions';

  @override
  String get netSalary => 'Net';

  @override
  String get hostelTitle => 'Hostel';

  @override
  String get rollCallTitle => 'Roll Call';

  @override
  String get visitorsTitle => 'Visitors';

  @override
  String get outpassTitle => 'Outpass';

  @override
  String get driverRouteTitle => 'My Route';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get language => 'Language';

  @override
  String version(String version) {
    return 'Version $version';
  }
}
