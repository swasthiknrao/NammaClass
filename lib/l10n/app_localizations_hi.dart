// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'नम्मा क्लास';

  @override
  String get appTagline => 'स्मार्ट स्कूल। खुशहाल कैंपस।';

  @override
  String get loading => 'लोड हो रहा है…';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get save => 'सहेजें';

  @override
  String get submit => 'जमा करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get close => 'बंद करें';

  @override
  String get search => 'खोजें';

  @override
  String get noInternetConnection => 'इंटरनेट कनेक्शन नहीं है';

  @override
  String get offlineBannerBody => 'संग्रहित डेटा दिखाया जा रहा है।';

  @override
  String get somethingWentWrong => 'कुछ गलत हो गया';

  @override
  String get noDataFound => 'कोई डेटा नहीं मिला';

  @override
  String get pullToRefresh => 'Pull to refresh';

  @override
  String get seeAll => 'सभी देखें';

  @override
  String get viewDetails => 'View details';

  @override
  String get featureNotSubscribed =>
      'This feature is not available in your plan.';

  @override
  String get loginTitle => 'वापस स्वागत है';

  @override
  String get loginSubtitle => 'अपने पंजीकृत मोबाइल नंबर से साइन इन करें';

  @override
  String get mobileNumberLabel => 'मोबाइल नंबर';

  @override
  String get sendOtp => 'OTP भेजें';

  @override
  String get otpTitle => 'OTP सत्यापित करें';

  @override
  String otpSubtitle(String phone) {
    return '$phone पर भेजा गया 6-अंकीय कोड दर्ज करें';
  }

  @override
  String get verifyOtp => 'सत्यापित करें';

  @override
  String get resendOtp => 'OTP फिर से भेजें';

  @override
  String resendIn(int seconds) {
    return '$seconds सेकंड में फिर से भेजें';
  }

  @override
  String get navHome => 'होम';

  @override
  String get navAttendance => 'उपस्थिति';

  @override
  String get navFees => 'शुल्क';

  @override
  String get navDiary => 'डायरी';

  @override
  String get navBus => 'बस';

  @override
  String get navProfile => 'प्रोफाइल';

  @override
  String get navLibrary => 'पुस्तकालय';

  @override
  String get navFood => 'खाना';

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
  String get present => 'उपस्थित';

  @override
  String get absent => 'अनुपस्थित';

  @override
  String get late => 'Late';

  @override
  String get leave => 'छुट्टी';

  @override
  String get holiday => 'अवकाश';

  @override
  String attendancePercent(String percent) {
    return '$percent% attendance';
  }

  @override
  String get feesTitle => 'Fees';

  @override
  String get feePending => 'बकाया';

  @override
  String get feePaid => 'भुगतान किया';

  @override
  String get feeOverdue => 'अतिदेय';

  @override
  String get payNow => 'अभी भुगतान करें';

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
  String get send => 'भेजें';

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
  String get logout => 'लॉग आउट';

  @override
  String get logoutConfirmTitle => 'लॉग आउट करें?';

  @override
  String get logoutConfirmBody => 'आप NammaClass से साइन आउट हो जाएंगे।';

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
  String get approve => 'स्वीकृत करें';

  @override
  String get reject => 'अस्वीकार करें';

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
