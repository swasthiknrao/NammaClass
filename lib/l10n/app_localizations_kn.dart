// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get appName => 'ನಮ್ಮ ಕ್ಲಾಸ್';

  @override
  String get appTagline => 'ಸ್ಮಾರ್ಟ್ ಶಾಲೆ. ಸಂತೋಷದ ಕ್ಯಾಂಪಸ್.';

  @override
  String get loading => 'ಲೋಡ್ ಆಗುತ್ತಿದೆ…';

  @override
  String get retry => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get cancel => 'ರದ್ದುಮಾಡಿ';

  @override
  String get save => 'ಉಳಿಸಿ';

  @override
  String get submit => 'ಸಲ್ಲಿಸಿ';

  @override
  String get delete => 'ಅಳಿಸಿ';

  @override
  String get confirm => 'ದೃಢಪಡಿಸಿ';

  @override
  String get close => 'ಮುಚ್ಚಿ';

  @override
  String get search => 'ಹುಡುಕಿ';

  @override
  String get noInternetConnection => 'ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕವಿಲ್ಲ';

  @override
  String get offlineBannerBody => 'ಸಂಗ್ರಹಿಸಿದ ಡೇಟಾ ತೋರಿಸಲಾಗುತ್ತಿದೆ.';

  @override
  String get somethingWentWrong => 'ಏನೋ ತಪ್ಪಾಗಿದೆ';

  @override
  String get noDataFound => 'ಯಾವುದೇ ಡೇಟಾ ಕಂಡುಬಂದಿಲ್ಲ';

  @override
  String get pullToRefresh => 'Pull to refresh';

  @override
  String get seeAll => 'ಎಲ್ಲ ನೋಡಿ';

  @override
  String get viewDetails => 'View details';

  @override
  String get featureNotSubscribed =>
      'This feature is not available in your plan.';

  @override
  String get loginTitle => 'ಮತ್ತೆ ಸ್ವಾಗತ';

  @override
  String get loginSubtitle => 'ನಿಮ್ಮ ಮೊಬೈಲ್ ಸಂಖ್ಯೆಯಿಂದ ಸೈನ್ ಇನ್ ಮಾಡಿ';

  @override
  String get mobileNumberLabel => 'ಮೊಬೈಲ್ ಸಂಖ್ಯೆ';

  @override
  String get sendOtp => 'OTP ಕಳುಹಿಸಿ';

  @override
  String get otpTitle => 'OTP ಪರಿಶೀಲಿಸಿ';

  @override
  String otpSubtitle(String phone) {
    return '$phone ಗೆ ಕಳುಹಿಸಿದ 6-ಅಂಕಿಯ ಕೋಡ್ ನಮೂದಿಸಿ';
  }

  @override
  String get verifyOtp => 'ಪರಿಶೀಲಿಸಿ';

  @override
  String get resendOtp => 'OTP ಮತ್ತೆ ಕಳುಹಿಸಿ';

  @override
  String resendIn(int seconds) {
    return '$seconds ಸೆಕೆಂಡ್‌ನಲ್ಲಿ ಮತ್ತೆ ಕಳುಹಿಸಿ';
  }

  @override
  String get navHome => 'ಮುಖಪುಟ';

  @override
  String get navAttendance => 'ಹಾಜರಾತಿ';

  @override
  String get navFees => 'ಶುಲ್ಕ';

  @override
  String get navDiary => 'ಡೈರಿ';

  @override
  String get navBus => 'ಬಸ್';

  @override
  String get navProfile => 'ಪ್ರೊಫೈಲ್';

  @override
  String get navLibrary => 'ಗ್ರಂಥಾಲಯ';

  @override
  String get navFood => 'ಆಹಾರ';

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
  String get present => 'ಹಾಜರು';

  @override
  String get absent => 'ಗೈರು';

  @override
  String get late => 'Late';

  @override
  String get leave => 'ರಜೆ';

  @override
  String get holiday => 'ರಜಾದಿನ';

  @override
  String attendancePercent(String percent) {
    return '$percent% attendance';
  }

  @override
  String get feesTitle => 'Fees';

  @override
  String get feePending => 'ಬಾಕಿ';

  @override
  String get feePaid => 'ಪಾವತಿಸಲಾಗಿದೆ';

  @override
  String get feeOverdue => 'ಮೀರಿದ ದಿನಾಂಕ';

  @override
  String get payNow => 'ಈಗ ಪಾವತಿಸಿ';

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
  String get send => 'ಕಳುಹಿಸಿ';

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
  String get logout => 'ಲಾಗ್ ಔಟ್';

  @override
  String get logoutConfirmTitle => 'ಲಾಗ್ ಔಟ್ ಮಾಡಬೇಕೇ?';

  @override
  String get logoutConfirmBody => 'NammaClass ನಿಂದ ಸೈನ್ ಔಟ್ ಆಗುತ್ತೀರಿ.';

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
  String get approve => 'ಅನುಮೋದಿಸಿ';

  @override
  String get reject => 'ತಿರಸ್ಕರಿಸಿ';

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
