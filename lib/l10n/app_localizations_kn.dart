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
  String get driverHomeTitle => 'ಇಂದಿನ ಪ್ರವಾಸ';

  @override
  String get driverTodaySummary => 'ಇಂದಿನ ಸಾರಾಂಶ';

  @override
  String get driverBusNumberLabel => 'Bus';

  @override
  String get driverMorningStart => 'Morning';

  @override
  String get driverEveningStart => 'Evening';

  @override
  String get driverNextStopLabel => 'ಮುಂದಿನ ನಿಲುಗಡೆ';

  @override
  String get driverEtaLabel => 'ETA';

  @override
  String get driverNoUpcomingStop => 'ಎಲ್ಲ ನಿಲುಗಡೆಗಳು ಪೂರ್ಣ';

  @override
  String get driverSafetyTip => 'ಸುರಕ್ಷತೆ ಸಲಹೆ';

  @override
  String get driverSafetyTipFallback =>
      'Drive rested, buckle up, watch for two-wheelers.';

  @override
  String get driverReportDelay => 'ವಿಳಂಬ ವರದಿ';

  @override
  String driverDelayMinutesLabel(int count) {
    return '$count min late';
  }

  @override
  String get driverApplyDelay => 'Apply delay';

  @override
  String get driverDelayDefaultReason => 'Traffic / route conditions';

  @override
  String driverDelayUpdatedSnack(int count) {
    return 'Parents notified: bus running about $count min late.';
  }

  @override
  String get driverShareLiveTrip => 'ಲೈವ್ ಪ್ರವಾಸ ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get driverShareLiveTripSubtitle =>
      'Parents with bus tracking see movement (demo toggle).';

  @override
  String get driverQuickLinks => 'ತ್ವರಿತ ಲಿಂಕ್‌ಗಳು';

  @override
  String get driverOpenFullRoute => 'ಮಾರ್ಗ ಮತ್ತು ನಿಲುಗಡೆಗಳು';

  @override
  String get driverStudentRoster => 'ವಿದ್ಯಾರ್ಥಿ ಪಟ್ಟಿ';

  @override
  String get driverTripHistory => 'ಪ್ರವಾಸ ಇತಿಹಾಸ';

  @override
  String get driverVehicleChecklist => 'ವಾಹನ ಪರಿಶೀಲನೆ';

  @override
  String get driverIncidentReport => 'ಘಟನೆ ವರದಿ';

  @override
  String get driverCallOffice => 'ಸಾರಿಗೆ ಕಚೇರಿಗೆ ಕರೆ';

  @override
  String get driverOpenInMaps => 'ನಕ್ಷೆಯಲ್ಲಿ ತೆರೆಯಿರಿ';

  @override
  String get driverTripHistoryTitle => 'ಪ್ರವಾಸ ಇತಿಹಾಸ';

  @override
  String get driverTripLogEmpty =>
      'No completed trips yet. Submit a boarding report to build history.';

  @override
  String driverTripHistoryCounts(int boarded, int total) {
    return '$boarded boarded / $total on roster';
  }

  @override
  String get driverVehicleChecklistTitle => 'ವಾಹನ ಪರಿಶೀಲನೆ';

  @override
  String get driverVehicleChecklistIntro =>
      'Complete before every trip. Tap to tick each item.';

  @override
  String get driverChecklistTyres => 'Tyres & pressure';

  @override
  String get driverChecklistLights => 'Lights & indicators';

  @override
  String get driverChecklistBrakes => 'Brakes';

  @override
  String get driverChecklistMirrors => 'Mirrors & horn';

  @override
  String get driverChecklistFireExtinguisher => 'Fire extinguisher';

  @override
  String get driverChecklistFirstAid => 'First aid kit';

  @override
  String get driverIncidentReportTitle => 'ಘಟನೆ ವರದಿ';

  @override
  String get driverIncidentIntro =>
      'Describe any incident, near-miss, or student concern. Transport office receives a copy in this demo.';

  @override
  String get driverIncidentHint => 'What happened? Where? Who was involved?';

  @override
  String get driverIncidentEmpty => 'Please enter a short description.';

  @override
  String get driverIncidentSubmitted => 'Incident report logged.';

  @override
  String get driverSosDialogTitle => 'Send SOS alert';

  @override
  String get driverSosCategoryLabel => 'Category';

  @override
  String get driverSosCategoryMedical => 'Medical';

  @override
  String get driverSosCategoryBreakdown => 'Breakdown';

  @override
  String get driverSosCategorySecurity => 'Security';

  @override
  String get driverSosCategoryOther => 'Other';

  @override
  String get driverSosNoteLabel => 'Short note (optional)';

  @override
  String get driverSosSend => 'Send SOS';

  @override
  String get driverSosSentSnack =>
      'SOS logged — transport manager notified (demo).';

  @override
  String get driverSosShort => 'SOS';

  @override
  String get driverLiveRouteMap => 'Live route map';

  @override
  String get driverGpsTrackingActive => 'GPS tracking active';

  @override
  String get driverNoStopsOnRoute => 'No stops on this route';

  @override
  String driverProgressStops(int visited, int total) {
    return 'Progress: $visited/$total stops';
  }

  @override
  String driverProgressPercent(int p) {
    return '$p% complete';
  }

  @override
  String get driverTripStartedSnack =>
      'Trip started — GPS broadcasting (demo).';

  @override
  String get driverTripEndedSnack => 'Trip ended — summary saved (demo).';

  @override
  String get driverStartTrip => 'Start trip';

  @override
  String get driverEndTrip => 'End trip';

  @override
  String get driverNoRouteStopsYet => 'No route stops yet';

  @override
  String get driverNoRouteStopsBody =>
      'When your school assigns bus stops to this route, they will appear here with ETAs and student counts.';

  @override
  String driverStopEtaStudents(String eta, int count) {
    return 'ETA: $eta  ·  $count students';
  }

  @override
  String get driverMarkArrived => 'Arrived';

  @override
  String get driverStudentsBoardingTitle => 'ವಿದ್ಯಾರ್ಥಿ ಏರುವಿಕೆ';

  @override
  String get driverMorningTrip => 'ಬೆಳಿಗ್ಗೆ ಪ್ರವಾಸ';

  @override
  String get driverEveningTrip => 'ಸಂಜೆ ಪ್ರವಾಸ';

  @override
  String get driverPickup => 'ಪಿಕಪ್';

  @override
  String get driverDropoff => 'ಡ್ರಾಪ್';

  @override
  String get driverAbsentSection => 'ಇಂದು ಗೈರು (ಬಸ್‌ನಲ್ಲಿ ನಿರೀಕ್ಷಿಸಲಾಗಿಲ್ಲ)';

  @override
  String get driverScanStudentQr => 'ವಿದ್ಯಾರ್ಥಿ QR ಕಾರ್ಡ್ ಸ್ಕ್ಯಾನ್';

  @override
  String get driverQrCameraStubTitle => 'QR scanner';

  @override
  String get driverQrCameraStubNote =>
      'Production builds can use the device camera (mobile_scanner). For this demo, simulate a successful scan below.';

  @override
  String get driverQrSimulateScan => 'Simulate scan';

  @override
  String get driverSubmitBoardingTitle => 'ಏರುವಿಕೆ ವರದಿ ಸಲ್ಲಿಸಿ';

  @override
  String driverSubmitBoardingBody(int boarded, int total) {
    return '$boarded of $total students marked. Submit?';
  }

  @override
  String get driverBoardingReportSubmitted => 'ಏರುವಿಕೆ ವರದಿ ಸಲ್ಲಿಸಲಾಗಿದೆ!';

  @override
  String get driverTripHistorySubmitted => 'Submitted';

  @override
  String get driverBoardedOk => 'Boarded ✓';

  @override
  String get driverDroppedOk => 'Dropped ✓';

  @override
  String get driverBoardedLabel => 'Boarded';

  @override
  String get driverDroppedLabel => 'Dropped';

  @override
  String driverStopStudentCount(int n) {
    return '$n students';
  }

  @override
  String driverBoardingFooter(int done, int total) {
    return 'Marked: $done / $total students';
  }

  @override
  String get wardenLodgeDeskTitle => 'Lodge desk';

  @override
  String get wardenLodgeHospitalityLine =>
      'Hospitality & safety — one calm campus night at a time.';

  @override
  String get wardenLodgeSeasonalCard => 'Tonight at the house';

  @override
  String get wardenLodgeChefSpecialLabel => 'Chef\'s counter';

  @override
  String get wardenLodgeQuietHoursLabel => 'Quiet hours';

  @override
  String get wardenLodgeOccupancyLabel => 'House occupancy';

  @override
  String get wardenLodgeMessHall => 'Mess & dining floor';

  @override
  String get wardenLodgeMessHallSubtitle =>
      'Covers, seconds, and allergy call-outs like a busy restaurant pass.';

  @override
  String get wardenLodgeRoomBoard => 'Rooms & housekeeping';

  @override
  String get wardenLodgeRoomBoardSubtitle =>
      'Turnover, linen, and VIP parent rooms — lodge operations board.';

  @override
  String get wardenLodgeNightPatrol => 'Night patrol';

  @override
  String get wardenLodgeNightPatrolSubtitle =>
      'Gates, mess lock-up, fire panel — curfew checklist.';

  @override
  String get wardenLodgeConcierge => 'Concierge log';

  @override
  String get wardenLodgeConciergeSubtitle =>
      'Shift notes parents and admin will thank you for.';

  @override
  String get wardenLodgeOverview => 'Tonight\'s snapshot';

  @override
  String get wardenLodgeHouseOps => 'House operations';

  @override
  String get wardenLodgeAbsentHint =>
      'Open roll call to call guardians and log reasons.';

  @override
  String get wardenLodgeGoodMorning => 'Good morning';

  @override
  String get wardenLodgeGoodAfternoon => 'Good afternoon';

  @override
  String get wardenLodgeGoodEvening => 'Good evening';

  @override
  String get wardenLodgeRollCallHint => 'Roll call · 8:00 PM';

  @override
  String get wardenDiningTitle => 'Mess & dining';

  @override
  String get wardenDiningWindow => 'Window';

  @override
  String get wardenDiningExpected => 'Expected';

  @override
  String get wardenDiningServed => 'Served';

  @override
  String get wardenDiningPortionServed => 'Portion served';

  @override
  String get wardenDiningRoundComplete => 'Service complete for this meal';

  @override
  String get wardenDiningChefNote => 'Pass note';

  @override
  String get wardenRoomsTitle => 'Rooms & linen';

  @override
  String wardenRoomFloor(String floor) {
    return 'Floor $floor';
  }

  @override
  String get wardenRoomLinen => 'Linen';

  @override
  String get wardenRoomTapCycle => 'Tap status to cycle';

  @override
  String get wardenRoomStatusReady => 'Ready';

  @override
  String get wardenRoomStatusOccupied => 'Occupied';

  @override
  String get wardenRoomStatusTurnover => 'Turnover';

  @override
  String get wardenPatrolTitle => 'Night patrol';

  @override
  String get wardenPatrolSubtitle => 'Tick before signing off the shift.';

  @override
  String get wardenPatrolGates => 'Main gates & perimeter locked';

  @override
  String get wardenPatrolMess => 'Mess / kitchen closed & gas off';

  @override
  String get wardenPatrolFire => 'Fire panel — no alerts';

  @override
  String get wardenPatrolLights => 'Common-area lights to night mode';

  @override
  String get wardenPatrolQuiet => 'Quiet hours announced on PA';

  @override
  String get wardenPatrolFirstAid => 'First-aid room accessible';

  @override
  String get wardenConciergeTitle => 'Concierge log';

  @override
  String get wardenConciergeEmpty =>
      'No entries yet — log handovers, calls, and medicine drops.';

  @override
  String get wardenConciergeDetailHint => 'What should the next shift know?';

  @override
  String get wardenConciergeAdd => 'Log entry';

  @override
  String get wardenConciergeQuickParentCall => 'Parent called — returned';

  @override
  String get wardenConciergeQuickMedicine => 'Medicine handed to student';

  @override
  String get wardenConciergeQuickMaintenance => 'Maintenance ticket raised';

  @override
  String get accountantFinanceTitle => 'Finance dashboard';

  @override
  String get accountantFinanceSubtitle =>
      'Collections, payroll obligation, and operating spend for the selected month.';

  @override
  String get accountantPeriodLabel => 'Finance period';

  @override
  String get accountantTodaysCollection => 'Today\'s collection';

  @override
  String get accountantTotalPending => 'Pending fees';

  @override
  String get accountantOverdueAmount => 'Overdue';

  @override
  String get accountantStudentsCleared => 'Students cleared';

  @override
  String get accountantPayrollLiability => 'Payroll liability (pending)';

  @override
  String get accountantExpenseBurnMtd => 'MTD operating spend';

  @override
  String get accountantCollectionTrend => 'Collection trend (7 days)';

  @override
  String get accountantQuickLinks => 'Quick links';

  @override
  String get accountantPayrollSnapshot => 'Payroll snapshot';

  @override
  String get accountantPfEmployerChip => 'PF (employer est.)';

  @override
  String get accountantEsiEmployerChip => 'ESI (employer est.)';

  @override
  String get accountantExpenseBurnTitle => 'Budget vs actual';

  @override
  String get accountantExceptionsTitle => 'Exceptions & holds';

  @override
  String get accountantPendingByClass => 'Pending by class';

  @override
  String get accountantRecentCollections => 'Recent collections';

  @override
  String get accountantViewAll => 'View all';

  @override
  String get accountantCollectFeesCta => 'Collect fees';

  @override
  String get accountantLinkLedger => 'Finance ledger';

  @override
  String get accountantLinkPayroll => 'Payroll overview';

  @override
  String get accountantLinkExpenses => 'Payables & spend';

  @override
  String get accountantLinkMonthClose => 'Month close';

  @override
  String get accountantPrintSummary => 'Print summary';

  @override
  String get accountantPrintSummarySnack =>
      'Today\'s summary queued for printer (demo).';

  @override
  String get accountantPayrollScreenTitle => 'Payroll & compliance';

  @override
  String get accountantPayrollScreenSubtitle =>
      'Read-only roster with payslip status for the finance period.';

  @override
  String get accountantExportBankFile => 'Export bank file';

  @override
  String get accountantBankFileSnack =>
      'Bank file CSV copied to clipboard (demo).';

  @override
  String get accountantProcessPayrollSnack =>
      'Payroll processing is admin-only in production — demo acknowledgement logged.';

  @override
  String get accountantExpensesTitle => 'Payables & spend';

  @override
  String get accountantExpensesSubtitle =>
      'Vendor pipeline and budget bars (mock).';

  @override
  String get accountantPipelineVendor => 'Vendor';

  @override
  String get accountantPipelineAmount => 'Amount';

  @override
  String get accountantPipelineStatus => 'Status';

  @override
  String get accountantPipelineDue => 'Due';

  @override
  String get accountantMonthCloseTitle => 'Month close';

  @override
  String get accountantMonthCloseSubtitle =>
      'Checklist, exports, and India-friendly presets (demo).';

  @override
  String get accountantMonthCloseChecklist => 'Close checklist';

  @override
  String get accountantExportPdfPlaceholder => 'Export PDF summary';

  @override
  String accountantExportPdfSnack(String period) {
    return 'PDF placeholder — file name: finance_close_$period.pdf';
  }

  @override
  String get accountantExportTallyPreset => 'Tally / CSV preset';

  @override
  String get accountantExportTallySnack =>
      'Preset label copied — map to your COA in Tally (demo).';

  @override
  String get ledgerColDescription => 'Description';

  @override
  String get ledgerColAmount => 'Amount';

  @override
  String get ledgerColDate => 'Date';

  @override
  String get accountantLedgerTitle => 'Finance ledger';

  @override
  String get accountantLedgerExport => 'Export CSV';

  @override
  String get accountantLedgerExportSnack => 'Ledger CSV copied to clipboard.';

  @override
  String get accountantLedgerIncomeVsExpense => 'Income vs expenses';

  @override
  String get accountantTabIncome => 'Income';

  @override
  String get accountantTabExpenses => 'Expenses';

  @override
  String get accountantTabPl => 'P&L statement';

  @override
  String get accountantPlPettyCash => 'Petty cash';

  @override
  String get accountantPlMargin => 'Net margin (on income)';

  @override
  String get accountantSeverityHigh => 'High';

  @override
  String get accountantSeverityMedium => 'Medium';

  @override
  String get accountantPayablesPipelineTitle => 'Payables pipeline';

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
