import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('kn'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'NammaClass'**
  String get appName;

  /// App tagline shown on splash screen
  ///
  /// In en, this message translates to:
  /// **'Smart School. Happy Campus.'**
  String get appTagline;

  /// Generic loading state text
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save action
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Submit form action
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Confirm action
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Close dialog / sheet
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Search field hint
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Offline banner message
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// Offline banner description
  ///
  /// In en, this message translates to:
  /// **'Showing cached data. Some actions may not be available.'**
  String get offlineBannerBody;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// Empty state when no records exist
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get noDataFound;

  /// Pull-to-refresh hint
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pullToRefresh;

  /// Link to full list
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// Link to detail screen
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// Shown when tenant hasn't subscribed to a feature
  ///
  /// In en, this message translates to:
  /// **'This feature is not available in your plan.'**
  String get featureNotSubscribed;

  /// Login screen headline
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in with your registered mobile number'**
  String get loginSubtitle;

  /// Mobile number input label
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumberLabel;

  /// Send OTP button
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// OTP screen headline
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get otpTitle;

  /// OTP screen subtitle with phone number
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {phone}'**
  String otpSubtitle(String phone);

  /// Verify OTP button
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyOtp;

  /// Resend OTP link
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// Countdown before OTP can be resent
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(int seconds);

  /// Bottom nav: Home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom nav: Attendance tab
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get navAttendance;

  /// Bottom nav: Fees tab
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get navFees;

  /// Bottom nav: Diary tab
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get navDiary;

  /// Bottom nav: Bus tab
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get navBus;

  /// Bottom nav: Profile tab
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Bottom nav: Library tab
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// Bottom nav: Food / Canteen tab
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get navFood;

  /// Bottom nav: Academics tab
  ///
  /// In en, this message translates to:
  /// **'Academics'**
  String get navAcademics;

  /// Bottom nav: Students tab
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get navStudents;

  /// Bottom nav: Leaves tab
  ///
  /// In en, this message translates to:
  /// **'Leaves'**
  String get navLeaves;

  /// Bottom nav: Payslips tab
  ///
  /// In en, this message translates to:
  /// **'Payslips'**
  String get navPayslips;

  /// Personalised greeting
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}!'**
  String goodMorning(String name);

  /// Attendance screen title
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendanceTitle;

  /// Attendance status: present
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// Attendance status: absent
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// Attendance status: late
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get late;

  /// Attendance status: on leave
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// Attendance status: holiday
  ///
  /// In en, this message translates to:
  /// **'Holiday'**
  String get holiday;

  /// Attendance percentage label
  ///
  /// In en, this message translates to:
  /// **'{percent}% attendance'**
  String attendancePercent(String percent);

  /// Fees screen title
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get feesTitle;

  /// Fee status: pending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get feePending;

  /// Fee status: paid
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get feePaid;

  /// Fee status: overdue
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get feeOverdue;

  /// Pay fee button
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// Total fee due label
  ///
  /// In en, this message translates to:
  /// **'Total due'**
  String get totalDue;

  /// Fee due date label
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String dueDate(String date);

  /// Diary screen title
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get diaryTitle;

  /// Diary classwork label
  ///
  /// In en, this message translates to:
  /// **'Classwork'**
  String get classwork;

  /// Diary homework label
  ///
  /// In en, this message translates to:
  /// **'Homework'**
  String get homework;

  /// Homework due date
  ///
  /// In en, this message translates to:
  /// **'Due by {date}'**
  String dueBy(String date);

  /// Mark homework as complete
  ///
  /// In en, this message translates to:
  /// **'Mark complete'**
  String get markComplete;

  /// Notices screen title
  ///
  /// In en, this message translates to:
  /// **'Notices'**
  String get noticesTitle;

  /// Empty state for notices
  ///
  /// In en, this message translates to:
  /// **'No notices yet'**
  String get noNotices;

  /// Mark all notices read action
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// Chat list screen title
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get chatTitle;

  /// Chat input placeholder
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get typeMessage;

  /// Send message button
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// Bus tracking screen title
  ///
  /// In en, this message translates to:
  /// **'Bus Tracking'**
  String get busTitle;

  /// Live bus indicator
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get busLive;

  /// Estimated time of arrival
  ///
  /// In en, this message translates to:
  /// **'ETA {minutes} min'**
  String eta(int minutes);

  /// Library screen title
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// Library search placeholder
  ///
  /// In en, this message translates to:
  /// **'Search books…'**
  String get searchBooks;

  /// Book available status
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// Book checked out status
  ///
  /// In en, this message translates to:
  /// **'Checked out'**
  String get checkedOut;

  /// Book or fee overdue status
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// Days until due
  ///
  /// In en, this message translates to:
  /// **'Due in {days}d'**
  String dueIn(int days);

  /// Canteen screen title
  ///
  /// In en, this message translates to:
  /// **'Canteen'**
  String get canteenTitle;

  /// Place order button
  ///
  /// In en, this message translates to:
  /// **'Order Now'**
  String get orderNow;

  /// Add item to cart
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCart;

  /// Wallet balance display
  ///
  /// In en, this message translates to:
  /// **'Wallet: ₹{amount}'**
  String walletBalance(String amount);

  /// Order confirmation message
  ///
  /// In en, this message translates to:
  /// **'Order placed!'**
  String get orderPlaced;

  /// Order status: preparing
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get orderPreparing;

  /// Order status: ready
  ///
  /// In en, this message translates to:
  /// **'Ready to collect'**
  String get orderReady;

  /// Order status: collected
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get orderCollected;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Logout action
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// Logout confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutConfirmTitle;

  /// Logout confirmation dialog body
  ///
  /// In en, this message translates to:
  /// **'You will be signed out of NammaClass.'**
  String get logoutConfirmBody;

  /// Leave application screen title
  ///
  /// In en, this message translates to:
  /// **'Apply for Leave'**
  String get leaveApplyTitle;

  /// Leave reason label
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get leaveReason;

  /// Leave start date label
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get leaveFrom;

  /// Leave end date label
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get leaveTo;

  /// Leave status screen title
  ///
  /// In en, this message translates to:
  /// **'Leave Status'**
  String get leaveStatusTitle;

  /// Leave status: approved
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get leaveApproved;

  /// Leave status: pending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get leavePending;

  /// Leave status: rejected
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get leaveRejected;

  /// Complaints screen title
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get complaintTitle;

  /// New complaint button
  ///
  /// In en, this message translates to:
  /// **'New Complaint'**
  String get newComplaint;

  /// Complaint subject label
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get complaintSubject;

  /// Complaint description label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get complaintDescription;

  /// Admin dashboard screen title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get adminDashboard;

  /// KPI: total students
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get totalStudents;

  /// KPI: total staff
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get totalStaff;

  /// KPI: pending approvals
  ///
  /// In en, this message translates to:
  /// **'Pending approvals'**
  String get pendingApprovals;

  /// Broadcast / notices compose screen title
  ///
  /// In en, this message translates to:
  /// **'Broadcast'**
  String get broadcastTitle;

  /// People management screen title
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get peopleTitle;

  /// Approvals screen title
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get approvalsTitle;

  /// Approve action
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// Reject action
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// Payslips screen title
  ///
  /// In en, this message translates to:
  /// **'Payslips'**
  String get payslipsTitle;

  /// Download payslip PDF
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadPayslip;

  /// Payslip gross salary label
  ///
  /// In en, this message translates to:
  /// **'Gross'**
  String get grossSalary;

  /// Payslip deductions label
  ///
  /// In en, this message translates to:
  /// **'Deductions'**
  String get deductions;

  /// Payslip net salary label
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get netSalary;

  /// Hostel screen title
  ///
  /// In en, this message translates to:
  /// **'Hostel'**
  String get hostelTitle;

  /// Warden roll call screen title
  ///
  /// In en, this message translates to:
  /// **'Roll Call'**
  String get rollCallTitle;

  /// Warden visitors screen title
  ///
  /// In en, this message translates to:
  /// **'Visitors'**
  String get visitorsTitle;

  /// Warden outpass screen title
  ///
  /// In en, this message translates to:
  /// **'Outpass'**
  String get outpassTitle;

  /// Driver route screen title
  ///
  /// In en, this message translates to:
  /// **'My Route'**
  String get driverRouteTitle;

  /// No description provided for @driverHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s trip'**
  String get driverHomeTitle;

  /// No description provided for @driverTodaySummary.
  ///
  /// In en, this message translates to:
  /// **'Today\'s summary'**
  String get driverTodaySummary;

  /// No description provided for @driverBusNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get driverBusNumberLabel;

  /// No description provided for @driverMorningStart.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get driverMorningStart;

  /// No description provided for @driverEveningStart.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get driverEveningStart;

  /// No description provided for @driverNextStopLabel.
  ///
  /// In en, this message translates to:
  /// **'Next stop'**
  String get driverNextStopLabel;

  /// No description provided for @driverEtaLabel.
  ///
  /// In en, this message translates to:
  /// **'ETA'**
  String get driverEtaLabel;

  /// No description provided for @driverNoUpcomingStop.
  ///
  /// In en, this message translates to:
  /// **'All stops completed'**
  String get driverNoUpcomingStop;

  /// No description provided for @driverSafetyTip.
  ///
  /// In en, this message translates to:
  /// **'Safety tip'**
  String get driverSafetyTip;

  /// No description provided for @driverSafetyTipFallback.
  ///
  /// In en, this message translates to:
  /// **'Drive rested, buckle up, watch for two-wheelers.'**
  String get driverSafetyTipFallback;

  /// No description provided for @driverReportDelay.
  ///
  /// In en, this message translates to:
  /// **'Report delay'**
  String get driverReportDelay;

  /// Slider label for delay minutes
  ///
  /// In en, this message translates to:
  /// **'{count} min late'**
  String driverDelayMinutesLabel(int count);

  /// No description provided for @driverApplyDelay.
  ///
  /// In en, this message translates to:
  /// **'Apply delay'**
  String get driverApplyDelay;

  /// No description provided for @driverDelayDefaultReason.
  ///
  /// In en, this message translates to:
  /// **'Traffic / route conditions'**
  String get driverDelayDefaultReason;

  /// No description provided for @driverDelayUpdatedSnack.
  ///
  /// In en, this message translates to:
  /// **'Parents notified: bus running about {count} min late.'**
  String driverDelayUpdatedSnack(int count);

  /// No description provided for @driverShareLiveTrip.
  ///
  /// In en, this message translates to:
  /// **'Share live trip'**
  String get driverShareLiveTrip;

  /// No description provided for @driverShareLiveTripSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Parents with bus tracking see movement (demo toggle).'**
  String get driverShareLiveTripSubtitle;

  /// No description provided for @driverQuickLinks.
  ///
  /// In en, this message translates to:
  /// **'Quick links'**
  String get driverQuickLinks;

  /// No description provided for @driverOpenFullRoute.
  ///
  /// In en, this message translates to:
  /// **'Open route & stops'**
  String get driverOpenFullRoute;

  /// No description provided for @driverStudentRoster.
  ///
  /// In en, this message translates to:
  /// **'Student roster'**
  String get driverStudentRoster;

  /// No description provided for @driverTripHistory.
  ///
  /// In en, this message translates to:
  /// **'Trip history'**
  String get driverTripHistory;

  /// No description provided for @driverVehicleChecklist.
  ///
  /// In en, this message translates to:
  /// **'Vehicle checklist'**
  String get driverVehicleChecklist;

  /// No description provided for @driverIncidentReport.
  ///
  /// In en, this message translates to:
  /// **'Incident report'**
  String get driverIncidentReport;

  /// No description provided for @driverCallOffice.
  ///
  /// In en, this message translates to:
  /// **'Call transport office'**
  String get driverCallOffice;

  /// No description provided for @driverOpenInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get driverOpenInMaps;

  /// No description provided for @driverTripHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip history'**
  String get driverTripHistoryTitle;

  /// No description provided for @driverTripLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No completed trips yet. Submit a boarding report to build history.'**
  String get driverTripLogEmpty;

  /// No description provided for @driverTripHistoryCounts.
  ///
  /// In en, this message translates to:
  /// **'{boarded} boarded / {total} on roster'**
  String driverTripHistoryCounts(int boarded, int total);

  /// No description provided for @driverVehicleChecklistTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle checklist'**
  String get driverVehicleChecklistTitle;

  /// No description provided for @driverVehicleChecklistIntro.
  ///
  /// In en, this message translates to:
  /// **'Complete before every trip. Tap to tick each item.'**
  String get driverVehicleChecklistIntro;

  /// No description provided for @driverChecklistTyres.
  ///
  /// In en, this message translates to:
  /// **'Tyres & pressure'**
  String get driverChecklistTyres;

  /// No description provided for @driverChecklistLights.
  ///
  /// In en, this message translates to:
  /// **'Lights & indicators'**
  String get driverChecklistLights;

  /// No description provided for @driverChecklistBrakes.
  ///
  /// In en, this message translates to:
  /// **'Brakes'**
  String get driverChecklistBrakes;

  /// No description provided for @driverChecklistMirrors.
  ///
  /// In en, this message translates to:
  /// **'Mirrors & horn'**
  String get driverChecklistMirrors;

  /// No description provided for @driverChecklistFireExtinguisher.
  ///
  /// In en, this message translates to:
  /// **'Fire extinguisher'**
  String get driverChecklistFireExtinguisher;

  /// No description provided for @driverChecklistFirstAid.
  ///
  /// In en, this message translates to:
  /// **'First aid kit'**
  String get driverChecklistFirstAid;

  /// No description provided for @driverIncidentReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Incident report'**
  String get driverIncidentReportTitle;

  /// No description provided for @driverIncidentIntro.
  ///
  /// In en, this message translates to:
  /// **'Describe any incident, near-miss, or student concern. Transport office receives a copy in this demo.'**
  String get driverIncidentIntro;

  /// No description provided for @driverIncidentHint.
  ///
  /// In en, this message translates to:
  /// **'What happened? Where? Who was involved?'**
  String get driverIncidentHint;

  /// No description provided for @driverIncidentEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a short description.'**
  String get driverIncidentEmpty;

  /// No description provided for @driverIncidentSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Incident report logged.'**
  String get driverIncidentSubmitted;

  /// No description provided for @driverSosDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Send SOS alert'**
  String get driverSosDialogTitle;

  /// No description provided for @driverSosCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get driverSosCategoryLabel;

  /// No description provided for @driverSosCategoryMedical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get driverSosCategoryMedical;

  /// No description provided for @driverSosCategoryBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Breakdown'**
  String get driverSosCategoryBreakdown;

  /// No description provided for @driverSosCategorySecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get driverSosCategorySecurity;

  /// No description provided for @driverSosCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get driverSosCategoryOther;

  /// No description provided for @driverSosNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Short note (optional)'**
  String get driverSosNoteLabel;

  /// No description provided for @driverSosSend.
  ///
  /// In en, this message translates to:
  /// **'Send SOS'**
  String get driverSosSend;

  /// No description provided for @driverSosSentSnack.
  ///
  /// In en, this message translates to:
  /// **'SOS logged — transport manager notified (demo).'**
  String get driverSosSentSnack;

  /// No description provided for @driverSosShort.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get driverSosShort;

  /// No description provided for @driverLiveRouteMap.
  ///
  /// In en, this message translates to:
  /// **'Live route map'**
  String get driverLiveRouteMap;

  /// No description provided for @driverGpsTrackingActive.
  ///
  /// In en, this message translates to:
  /// **'GPS tracking active'**
  String get driverGpsTrackingActive;

  /// No description provided for @driverNoStopsOnRoute.
  ///
  /// In en, this message translates to:
  /// **'No stops on this route'**
  String get driverNoStopsOnRoute;

  /// No description provided for @driverProgressStops.
  ///
  /// In en, this message translates to:
  /// **'Progress: {visited}/{total} stops'**
  String driverProgressStops(int visited, int total);

  /// No description provided for @driverProgressPercent.
  ///
  /// In en, this message translates to:
  /// **'{p}% complete'**
  String driverProgressPercent(int p);

  /// No description provided for @driverTripStartedSnack.
  ///
  /// In en, this message translates to:
  /// **'Trip started — GPS broadcasting (demo).'**
  String get driverTripStartedSnack;

  /// No description provided for @driverTripEndedSnack.
  ///
  /// In en, this message translates to:
  /// **'Trip ended — summary saved (demo).'**
  String get driverTripEndedSnack;

  /// No description provided for @driverStartTrip.
  ///
  /// In en, this message translates to:
  /// **'Start trip'**
  String get driverStartTrip;

  /// No description provided for @driverEndTrip.
  ///
  /// In en, this message translates to:
  /// **'End trip'**
  String get driverEndTrip;

  /// No description provided for @driverNoRouteStopsYet.
  ///
  /// In en, this message translates to:
  /// **'No route stops yet'**
  String get driverNoRouteStopsYet;

  /// No description provided for @driverNoRouteStopsBody.
  ///
  /// In en, this message translates to:
  /// **'When your school assigns bus stops to this route, they will appear here with ETAs and student counts.'**
  String get driverNoRouteStopsBody;

  /// No description provided for @driverStopEtaStudents.
  ///
  /// In en, this message translates to:
  /// **'ETA: {eta}  ·  {count} students'**
  String driverStopEtaStudents(String eta, int count);

  /// No description provided for @driverMarkArrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get driverMarkArrived;

  /// No description provided for @driverStudentsBoardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Student boarding'**
  String get driverStudentsBoardingTitle;

  /// No description provided for @driverMorningTrip.
  ///
  /// In en, this message translates to:
  /// **'Morning trip'**
  String get driverMorningTrip;

  /// No description provided for @driverEveningTrip.
  ///
  /// In en, this message translates to:
  /// **'Evening trip'**
  String get driverEveningTrip;

  /// No description provided for @driverPickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get driverPickup;

  /// No description provided for @driverDropoff.
  ///
  /// In en, this message translates to:
  /// **'Drop-off'**
  String get driverDropoff;

  /// No description provided for @driverAbsentSection.
  ///
  /// In en, this message translates to:
  /// **'Absent today (not expected on bus)'**
  String get driverAbsentSection;

  /// No description provided for @driverScanStudentQr.
  ///
  /// In en, this message translates to:
  /// **'Scan student QR card'**
  String get driverScanStudentQr;

  /// No description provided for @driverQrCameraStubTitle.
  ///
  /// In en, this message translates to:
  /// **'QR scanner'**
  String get driverQrCameraStubTitle;

  /// No description provided for @driverQrCameraStubNote.
  ///
  /// In en, this message translates to:
  /// **'Production builds can use the device camera (mobile_scanner). For this demo, simulate a successful scan below.'**
  String get driverQrCameraStubNote;

  /// No description provided for @driverQrSimulateScan.
  ///
  /// In en, this message translates to:
  /// **'Simulate scan'**
  String get driverQrSimulateScan;

  /// No description provided for @driverSubmitBoardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit boarding report'**
  String get driverSubmitBoardingTitle;

  /// No description provided for @driverSubmitBoardingBody.
  ///
  /// In en, this message translates to:
  /// **'{boarded} of {total} students marked. Submit?'**
  String driverSubmitBoardingBody(int boarded, int total);

  /// No description provided for @driverBoardingReportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Boarding report submitted!'**
  String get driverBoardingReportSubmitted;

  /// No description provided for @driverTripHistorySubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get driverTripHistorySubmitted;

  /// No description provided for @driverBoardedOk.
  ///
  /// In en, this message translates to:
  /// **'Boarded ✓'**
  String get driverBoardedOk;

  /// No description provided for @driverDroppedOk.
  ///
  /// In en, this message translates to:
  /// **'Dropped ✓'**
  String get driverDroppedOk;

  /// No description provided for @driverBoardedLabel.
  ///
  /// In en, this message translates to:
  /// **'Boarded'**
  String get driverBoardedLabel;

  /// No description provided for @driverDroppedLabel.
  ///
  /// In en, this message translates to:
  /// **'Dropped'**
  String get driverDroppedLabel;

  /// No description provided for @driverStopStudentCount.
  ///
  /// In en, this message translates to:
  /// **'{n} students'**
  String driverStopStudentCount(int n);

  /// No description provided for @driverBoardingFooter.
  ///
  /// In en, this message translates to:
  /// **'Marked: {done} / {total} students'**
  String driverBoardingFooter(int done, int total);

  /// No description provided for @wardenLodgeDeskTitle.
  ///
  /// In en, this message translates to:
  /// **'Lodge desk'**
  String get wardenLodgeDeskTitle;

  /// No description provided for @wardenLodgeHospitalityLine.
  ///
  /// In en, this message translates to:
  /// **'Hospitality & safety — one calm campus night at a time.'**
  String get wardenLodgeHospitalityLine;

  /// No description provided for @wardenLodgeSeasonalCard.
  ///
  /// In en, this message translates to:
  /// **'Tonight at the house'**
  String get wardenLodgeSeasonalCard;

  /// No description provided for @wardenLodgeChefSpecialLabel.
  ///
  /// In en, this message translates to:
  /// **'Chef\'s counter'**
  String get wardenLodgeChefSpecialLabel;

  /// No description provided for @wardenLodgeQuietHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get wardenLodgeQuietHoursLabel;

  /// No description provided for @wardenLodgeOccupancyLabel.
  ///
  /// In en, this message translates to:
  /// **'House occupancy'**
  String get wardenLodgeOccupancyLabel;

  /// No description provided for @wardenLodgeMessHall.
  ///
  /// In en, this message translates to:
  /// **'Mess & dining floor'**
  String get wardenLodgeMessHall;

  /// No description provided for @wardenLodgeMessHallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Covers, seconds, and allergy call-outs like a busy restaurant pass.'**
  String get wardenLodgeMessHallSubtitle;

  /// No description provided for @wardenLodgeRoomBoard.
  ///
  /// In en, this message translates to:
  /// **'Rooms & housekeeping'**
  String get wardenLodgeRoomBoard;

  /// No description provided for @wardenLodgeRoomBoardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turnover, linen, and VIP parent rooms — lodge operations board.'**
  String get wardenLodgeRoomBoardSubtitle;

  /// No description provided for @wardenLodgeNightPatrol.
  ///
  /// In en, this message translates to:
  /// **'Night patrol'**
  String get wardenLodgeNightPatrol;

  /// No description provided for @wardenLodgeNightPatrolSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Gates, mess lock-up, fire panel — curfew checklist.'**
  String get wardenLodgeNightPatrolSubtitle;

  /// No description provided for @wardenLodgeConcierge.
  ///
  /// In en, this message translates to:
  /// **'Concierge log'**
  String get wardenLodgeConcierge;

  /// No description provided for @wardenLodgeConciergeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shift notes parents and admin will thank you for.'**
  String get wardenLodgeConciergeSubtitle;

  /// No description provided for @wardenLodgeOverview.
  ///
  /// In en, this message translates to:
  /// **'Tonight\'s snapshot'**
  String get wardenLodgeOverview;

  /// No description provided for @wardenLodgeHouseOps.
  ///
  /// In en, this message translates to:
  /// **'House operations'**
  String get wardenLodgeHouseOps;

  /// No description provided for @wardenLodgeAbsentHint.
  ///
  /// In en, this message translates to:
  /// **'Open roll call to call guardians and log reasons.'**
  String get wardenLodgeAbsentHint;

  /// No description provided for @wardenLodgeGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get wardenLodgeGoodMorning;

  /// No description provided for @wardenLodgeGoodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get wardenLodgeGoodAfternoon;

  /// No description provided for @wardenLodgeGoodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get wardenLodgeGoodEvening;

  /// No description provided for @wardenLodgeRollCallHint.
  ///
  /// In en, this message translates to:
  /// **'Roll call · 8:00 PM'**
  String get wardenLodgeRollCallHint;

  /// No description provided for @wardenDiningTitle.
  ///
  /// In en, this message translates to:
  /// **'Mess & dining'**
  String get wardenDiningTitle;

  /// No description provided for @wardenDiningWindow.
  ///
  /// In en, this message translates to:
  /// **'Window'**
  String get wardenDiningWindow;

  /// No description provided for @wardenDiningExpected.
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get wardenDiningExpected;

  /// No description provided for @wardenDiningServed.
  ///
  /// In en, this message translates to:
  /// **'Served'**
  String get wardenDiningServed;

  /// No description provided for @wardenDiningPortionServed.
  ///
  /// In en, this message translates to:
  /// **'Portion served'**
  String get wardenDiningPortionServed;

  /// No description provided for @wardenDiningRoundComplete.
  ///
  /// In en, this message translates to:
  /// **'Service complete for this meal'**
  String get wardenDiningRoundComplete;

  /// No description provided for @wardenDiningChefNote.
  ///
  /// In en, this message translates to:
  /// **'Pass note'**
  String get wardenDiningChefNote;

  /// No description provided for @wardenRoomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rooms & linen'**
  String get wardenRoomsTitle;

  /// No description provided for @wardenRoomFloor.
  ///
  /// In en, this message translates to:
  /// **'Floor {floor}'**
  String wardenRoomFloor(String floor);

  /// No description provided for @wardenRoomLinen.
  ///
  /// In en, this message translates to:
  /// **'Linen'**
  String get wardenRoomLinen;

  /// No description provided for @wardenRoomTapCycle.
  ///
  /// In en, this message translates to:
  /// **'Tap status to cycle'**
  String get wardenRoomTapCycle;

  /// No description provided for @wardenRoomStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get wardenRoomStatusReady;

  /// No description provided for @wardenRoomStatusOccupied.
  ///
  /// In en, this message translates to:
  /// **'Occupied'**
  String get wardenRoomStatusOccupied;

  /// No description provided for @wardenRoomStatusTurnover.
  ///
  /// In en, this message translates to:
  /// **'Turnover'**
  String get wardenRoomStatusTurnover;

  /// No description provided for @wardenPatrolTitle.
  ///
  /// In en, this message translates to:
  /// **'Night patrol'**
  String get wardenPatrolTitle;

  /// No description provided for @wardenPatrolSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tick before signing off the shift.'**
  String get wardenPatrolSubtitle;

  /// No description provided for @wardenPatrolGates.
  ///
  /// In en, this message translates to:
  /// **'Main gates & perimeter locked'**
  String get wardenPatrolGates;

  /// No description provided for @wardenPatrolMess.
  ///
  /// In en, this message translates to:
  /// **'Mess / kitchen closed & gas off'**
  String get wardenPatrolMess;

  /// No description provided for @wardenPatrolFire.
  ///
  /// In en, this message translates to:
  /// **'Fire panel — no alerts'**
  String get wardenPatrolFire;

  /// No description provided for @wardenPatrolLights.
  ///
  /// In en, this message translates to:
  /// **'Common-area lights to night mode'**
  String get wardenPatrolLights;

  /// No description provided for @wardenPatrolQuiet.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours announced on PA'**
  String get wardenPatrolQuiet;

  /// No description provided for @wardenPatrolFirstAid.
  ///
  /// In en, this message translates to:
  /// **'First-aid room accessible'**
  String get wardenPatrolFirstAid;

  /// No description provided for @wardenConciergeTitle.
  ///
  /// In en, this message translates to:
  /// **'Concierge log'**
  String get wardenConciergeTitle;

  /// No description provided for @wardenConciergeEmpty.
  ///
  /// In en, this message translates to:
  /// **'No entries yet — log handovers, calls, and medicine drops.'**
  String get wardenConciergeEmpty;

  /// No description provided for @wardenConciergeDetailHint.
  ///
  /// In en, this message translates to:
  /// **'What should the next shift know?'**
  String get wardenConciergeDetailHint;

  /// No description provided for @wardenConciergeAdd.
  ///
  /// In en, this message translates to:
  /// **'Log entry'**
  String get wardenConciergeAdd;

  /// No description provided for @wardenConciergeQuickParentCall.
  ///
  /// In en, this message translates to:
  /// **'Parent called — returned'**
  String get wardenConciergeQuickParentCall;

  /// No description provided for @wardenConciergeQuickMedicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine handed to student'**
  String get wardenConciergeQuickMedicine;

  /// No description provided for @wardenConciergeQuickMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance ticket raised'**
  String get wardenConciergeQuickMaintenance;

  /// No description provided for @accountantFinanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Finance dashboard'**
  String get accountantFinanceTitle;

  /// No description provided for @accountantFinanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Collections, payroll obligation, and operating spend for the selected month.'**
  String get accountantFinanceSubtitle;

  /// No description provided for @accountantPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Finance period'**
  String get accountantPeriodLabel;

  /// No description provided for @accountantTodaysCollection.
  ///
  /// In en, this message translates to:
  /// **'Today\'s collection'**
  String get accountantTodaysCollection;

  /// No description provided for @accountantTotalPending.
  ///
  /// In en, this message translates to:
  /// **'Pending fees'**
  String get accountantTotalPending;

  /// No description provided for @accountantOverdueAmount.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get accountantOverdueAmount;

  /// No description provided for @accountantStudentsCleared.
  ///
  /// In en, this message translates to:
  /// **'Students cleared'**
  String get accountantStudentsCleared;

  /// No description provided for @accountantPayrollLiability.
  ///
  /// In en, this message translates to:
  /// **'Payroll liability (pending)'**
  String get accountantPayrollLiability;

  /// No description provided for @accountantExpenseBurnMtd.
  ///
  /// In en, this message translates to:
  /// **'MTD operating spend'**
  String get accountantExpenseBurnMtd;

  /// No description provided for @accountantCollectionTrend.
  ///
  /// In en, this message translates to:
  /// **'Collection trend (7 days)'**
  String get accountantCollectionTrend;

  /// No description provided for @accountantQuickLinks.
  ///
  /// In en, this message translates to:
  /// **'Quick links'**
  String get accountantQuickLinks;

  /// No description provided for @accountantPayrollSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Payroll snapshot'**
  String get accountantPayrollSnapshot;

  /// No description provided for @accountantPfEmployerChip.
  ///
  /// In en, this message translates to:
  /// **'PF (employer est.)'**
  String get accountantPfEmployerChip;

  /// No description provided for @accountantEsiEmployerChip.
  ///
  /// In en, this message translates to:
  /// **'ESI (employer est.)'**
  String get accountantEsiEmployerChip;

  /// No description provided for @accountantExpenseBurnTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget vs actual'**
  String get accountantExpenseBurnTitle;

  /// No description provided for @accountantExceptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Exceptions & holds'**
  String get accountantExceptionsTitle;

  /// No description provided for @accountantPendingByClass.
  ///
  /// In en, this message translates to:
  /// **'Pending by class'**
  String get accountantPendingByClass;

  /// No description provided for @accountantRecentCollections.
  ///
  /// In en, this message translates to:
  /// **'Recent collections'**
  String get accountantRecentCollections;

  /// No description provided for @accountantViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get accountantViewAll;

  /// No description provided for @accountantCollectFeesCta.
  ///
  /// In en, this message translates to:
  /// **'Collect fees'**
  String get accountantCollectFeesCta;

  /// No description provided for @accountantLinkLedger.
  ///
  /// In en, this message translates to:
  /// **'Finance ledger'**
  String get accountantLinkLedger;

  /// No description provided for @accountantLinkPayroll.
  ///
  /// In en, this message translates to:
  /// **'Payroll overview'**
  String get accountantLinkPayroll;

  /// No description provided for @accountantLinkExpenses.
  ///
  /// In en, this message translates to:
  /// **'Payables & spend'**
  String get accountantLinkExpenses;

  /// No description provided for @accountantLinkMonthClose.
  ///
  /// In en, this message translates to:
  /// **'Month close'**
  String get accountantLinkMonthClose;

  /// No description provided for @accountantPrintSummary.
  ///
  /// In en, this message translates to:
  /// **'Print summary'**
  String get accountantPrintSummary;

  /// No description provided for @accountantPrintSummarySnack.
  ///
  /// In en, this message translates to:
  /// **'Today\'s summary queued for printer (demo).'**
  String get accountantPrintSummarySnack;

  /// No description provided for @accountantPayrollScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Payroll & compliance'**
  String get accountantPayrollScreenTitle;

  /// No description provided for @accountantPayrollScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read-only roster with payslip status for the finance period.'**
  String get accountantPayrollScreenSubtitle;

  /// No description provided for @accountantExportBankFile.
  ///
  /// In en, this message translates to:
  /// **'Export bank file'**
  String get accountantExportBankFile;

  /// No description provided for @accountantBankFileSnack.
  ///
  /// In en, this message translates to:
  /// **'Bank file CSV copied to clipboard (demo).'**
  String get accountantBankFileSnack;

  /// No description provided for @accountantProcessPayrollSnack.
  ///
  /// In en, this message translates to:
  /// **'Payroll processing is admin-only in production — demo acknowledgement logged.'**
  String get accountantProcessPayrollSnack;

  /// No description provided for @accountantExpensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Payables & spend'**
  String get accountantExpensesTitle;

  /// No description provided for @accountantExpensesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vendor pipeline and budget bars (mock).'**
  String get accountantExpensesSubtitle;

  /// No description provided for @accountantPipelineVendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get accountantPipelineVendor;

  /// No description provided for @accountantPipelineAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get accountantPipelineAmount;

  /// No description provided for @accountantPipelineStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get accountantPipelineStatus;

  /// No description provided for @accountantPipelineDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get accountantPipelineDue;

  /// No description provided for @accountantMonthCloseTitle.
  ///
  /// In en, this message translates to:
  /// **'Month close'**
  String get accountantMonthCloseTitle;

  /// No description provided for @accountantMonthCloseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Checklist, exports, and India-friendly presets (demo).'**
  String get accountantMonthCloseSubtitle;

  /// No description provided for @accountantMonthCloseChecklist.
  ///
  /// In en, this message translates to:
  /// **'Close checklist'**
  String get accountantMonthCloseChecklist;

  /// No description provided for @accountantExportPdfPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Export PDF summary'**
  String get accountantExportPdfPlaceholder;

  /// No description provided for @accountantExportPdfSnack.
  ///
  /// In en, this message translates to:
  /// **'PDF placeholder — file name: finance_close_{period}.pdf'**
  String accountantExportPdfSnack(String period);

  /// No description provided for @accountantExportTallyPreset.
  ///
  /// In en, this message translates to:
  /// **'Tally / CSV preset'**
  String get accountantExportTallyPreset;

  /// No description provided for @accountantExportTallySnack.
  ///
  /// In en, this message translates to:
  /// **'Preset label copied — map to your COA in Tally (demo).'**
  String get accountantExportTallySnack;

  /// No description provided for @ledgerColDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get ledgerColDescription;

  /// No description provided for @ledgerColAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get ledgerColAmount;

  /// No description provided for @ledgerColDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get ledgerColDate;

  /// No description provided for @accountantLedgerTitle.
  ///
  /// In en, this message translates to:
  /// **'Finance ledger'**
  String get accountantLedgerTitle;

  /// No description provided for @accountantLedgerExport.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get accountantLedgerExport;

  /// No description provided for @accountantLedgerExportSnack.
  ///
  /// In en, this message translates to:
  /// **'Ledger CSV copied to clipboard.'**
  String get accountantLedgerExportSnack;

  /// No description provided for @accountantLedgerIncomeVsExpense.
  ///
  /// In en, this message translates to:
  /// **'Income vs expenses'**
  String get accountantLedgerIncomeVsExpense;

  /// No description provided for @accountantTabIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get accountantTabIncome;

  /// No description provided for @accountantTabExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get accountantTabExpenses;

  /// No description provided for @accountantTabPl.
  ///
  /// In en, this message translates to:
  /// **'P&L statement'**
  String get accountantTabPl;

  /// No description provided for @accountantPlPettyCash.
  ///
  /// In en, this message translates to:
  /// **'Petty cash'**
  String get accountantPlPettyCash;

  /// No description provided for @accountantPlMargin.
  ///
  /// In en, this message translates to:
  /// **'Net margin (on income)'**
  String get accountantPlMargin;

  /// No description provided for @accountantSeverityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get accountantSeverityHigh;

  /// No description provided for @accountantSeverityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get accountantSeverityMedium;

  /// No description provided for @accountantPayablesPipelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Payables pipeline'**
  String get accountantPayablesPipelineTitle;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Dark mode toggle label
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// App version display
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'kn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
