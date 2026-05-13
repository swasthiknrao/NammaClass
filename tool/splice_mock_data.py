from pathlib import Path

helpers_and_apply = r'''
  static Map<String, List<MockPeriod>> _parseTimetable(dynamic raw) {
    if (raw is! Map) return {};
    final out = <String, List<MockPeriod>>{};
    raw.forEach((k, v) {
      if (v is List) {
        out['$k'] = v
            .map(
              (e) =>
                  MockPeriod.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
      }
    });
    return out;
  }

  static List<T> _mapList<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) f,
  ) {
    if (raw is! List) return [];
    return raw
        .map((e) => f(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Map<String, List<String>> _parseDriverStopStudents(dynamic raw) {
    if (raw is! Map) return {};
    final out = <String, List<String>>{};
    raw.forEach((k, v) {
      if (v is List) {
        out['$k'] = v.map((e) => '$e').toList();
      }
    });
    return out;
  }

  static List<MockAttendanceSession> _buildAttendanceSessionsFromTimetable() {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    const classes = ['8-A', '8-B', '9-A'];
    const concepts = {
      'Mathematics': 'Polynomials — factorization',
      'Science': 'Photosynthesis — light reactions',
      'English': 'Comprehension — The Last Leaf',
      'Social Studies': 'Indian Parliament structure',
      'Kannada': 'ವ್ಯಾಕರಣ — ಕ್ರಿಯಾಪದಗಳು',
      'Computer Science': 'Python loops and conditionals',
      'Physical Ed': 'Basketball — dribbling drills',
      'Art & Craft': 'Watercolor techniques',
    };
    final sessions = <MockAttendanceSession>[];
    var id = 0;
    for (var d = 0; d < 21; d++) {
      final date = DateTime.now().subtract(Duration(days: 20 - d));
      if (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) {
        continue;
      }
      final dayName = days[date.weekday - 1];
      final periods = timetable[dayName] ?? [];
      for (final p in periods) {
        for (final cls in classes) {
          sessions.add(
            MockAttendanceSession(
              id: 'sess_${id++}',
              date: date,
              classSection: cls,
              period: p.period,
              subject: p.subject,
              concept: concepts[p.subject] ?? p.subject,
              startTime: p.startTime,
              endTime: p.endTime,
              status: (id % 3 == 0) ? 'marked' : 'pending',
            ),
          );
        }
      }
    }
    return sessions;
  }

  /// Loads demo content from `assets/data/mock_bundle.json` (mock / offline mode).
  static void applyJsonBundle(Map<String, dynamic> json) {
    timetable
      ..clear()
      ..addAll(_parseTimetable(json['timetable']));

    _bundle = MockDataBundle.fromJson(json);

    final rawAtt = json['attendance'];
    if (rawAtt is List && rawAtt.isNotEmpty) {
      attendance = rawAtt
          .map(
            (e) =>
                MockAttendanceDay.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } else {
      attendance = _buildDefaultAttendance();
    }

    final rawDiary = json['diary'];
    if (rawDiary is List && rawDiary.isNotEmpty) {
      diary = rawDiary
          .map(
            (e) => MockDiaryEntry.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } else {
      diary = _buildDefaultDiary();
    }

    final rawSess = json['attendance_sessions'];
    if (rawSess is List && rawSess.isNotEmpty) {
      attendanceSessions = rawSess
          .map(
            (e) => MockAttendanceSession.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } else {
      attendanceSessions = _buildAttendanceSessionsFromTimetable();
    }

    books = _mapList(json['books'], MockBook.fromJson);
    staff = _mapList(json['staff'], MockStaffMember.fromJson);
    canteenMenu = _mapList(json['canteen_menu'], MockCanteenItem.fromJson);
    canteenCombos = _mapList(json['canteen_combos'], MockCanteenCombo.fromJson);
    canteenSubscriptionPlans = _mapList(
      json['canteen_subscription_plans'],
      MockCanteenSubscriptionPlan.fromJson,
    );
    campusWallets =
        _mapList(json['campus_wallets'], MockCampusWallet.fromJson);
    canteenSubscriptions = _mapList(
      json['canteen_subscriptions'],
      MockCanteenSubscription.fromJson,
    );
    canteenOrders =
        _mapList(json['canteen_orders'], MockCanteenOrder.fromJson);
    canteenTransactions = _mapList(
      json['canteen_transactions'],
      MockCanteenTransaction.fromJson,
    );
    leaveApplications = _mapList(
      json['leave_applications'],
      MockLeaveApplication.fromJson,
    );
    complaints = _mapList(json['complaints'], MockComplaint.fromJson);
    supportTickets =
        _mapList(json['support_tickets'], MockSupportTicket.fromJson);
    kbArticles = _mapList(json['kb_articles'], MockKbArticle.fromJson);
    events = _mapList(json['events'], MockEvent.fromJson);
    staffAttendance = _mapList(
      json['staff_attendance'],
      MockStaffAttendanceDay.fromJson,
    );
    payslips = _mapList(json['payslips'], MockPayslip.fromJson);
    trainings = _mapList(json['trainings'], MockTraining.fromJson);

    driverStopStudents
      ..clear()
      ..addAll(_parseDriverStopStudents(json['driver_stop_students']));

    busStops = _mapList(json['bus_stops'], MockBusStop.fromJson);
    bookIssues = _mapList(json['book_issues'], MockBookIssue.fromJson);
    reservations =
        _mapList(json['reservations'], MockReservation.fromJson);
    hostelStudents =
        _mapList(json['hostel_students'], MockHostelStudent.fromJson);
    hostelOutpasses =
        _mapList(json['hostel_outpasses'], MockHostelOutpass.fromJson);
    visitors = _mapList(json['visitors'], MockVisitor.fromJson);
    admissionEnquiries = _mapList(
      json['admission_enquiries'],
      MockAdmissionEnquiry.fromJson,
    );
    assets = _mapList(json['assets'], MockAsset.fromJson);
    staffLeaveRequests = _mapList(
      json['staff_leave_requests'],
      MockStaffLeaveRequest.fromJson,
    );
  }

  // Mutable demo lists — filled by [applyJsonBundle].
  static List<MockBook> books = [];
  static List<MockStaffMember> staff = [];
  static List<MockCanteenItem> canteenMenu = [];
  static List<MockCanteenCombo> canteenCombos = [];
  static List<MockCanteenSubscriptionPlan> canteenSubscriptionPlans = [];
  static List<MockCampusWallet> campusWallets = [];
  static List<MockCanteenSubscription> canteenSubscriptions = [];
  static List<MockCanteenOrder> canteenOrders = [];
  static List<MockCanteenTransaction> canteenTransactions = [];
  static List<MockLeaveApplication> leaveApplications = [];
  static List<MockComplaint> complaints = [];
  static List<MockSupportTicket> supportTickets = [];
  static List<MockKbArticle> kbArticles = [];
  static List<MockEvent> events = [];
  static List<MockStaffAttendanceDay> staffAttendance = [];
  static List<MockPayslip> payslips = [];
  static List<MockTraining> trainings = [];
  static Map<String, List<String>> driverStopStudents = {};
  static List<MockBusStop> busStops = [];
  static List<MockBookIssue> bookIssues = [];
  static List<MockReservation> reservations = [];
  static List<MockHostelStudent> hostelStudents = [];
  static List<MockHostelOutpass> hostelOutpasses = [];
  static List<MockVisitor> visitors = [];
  static List<MockAdmissionEnquiry> admissionEnquiries = [];
  static List<MockAsset> assets = [];
  static List<MockStaffLeaveRequest> staffLeaveRequests = [];

'''

def main() -> None:
    p = Path('lib/core/mock/mock_data.dart')
    text = p.read_text(encoding='utf-8')
    start_marker = (
        '  /// Loads demo content from '
        '`assets/data/mock_bundle.json` (mock / offline mode).\n'
        '  static void applyJsonBundle(Map<String, dynamic> json) {'
    )
    end_marker = '  /// Used by `dart run tool/export_full_mock_bundle.dart`'
    i0 = text.index(start_marker)
    i1 = text.index(end_marker)
    text = text[:i0] + helpers_and_apply + text[i1:]
    p.write_text(text, encoding='utf-8')
    print('ok', i0, i1)


if __name__ == '__main__':
    main()
