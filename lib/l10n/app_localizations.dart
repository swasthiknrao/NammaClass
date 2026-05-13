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
