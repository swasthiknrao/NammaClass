part of 'mock_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Bundle holder + typed dataset ([MockData]) backed only by JSON (disk persistence).
// ─────────────────────────────────────────────────────────────────────────────

class MockDataBundle {
  MockDataBundle({
    required this.students,
    required this.fees,
    required this.notices,
    required this.chatThreads,
    required this.messages,
    required this.dashboardKpis,
    required this.busInfo,
    required this.leaveBalance,
    required this.hodDepartment,
  });

  final List<MockStudent> students;
  final List<MockFeeInstallment> fees;
  final List<MockNotice> notices;
  final List<MockChatThread> chatThreads;
  final List<MockMessage> messages;
  final Map<String, dynamic> dashboardKpis;
  final Map<String, dynamic> busInfo;
  final Map<String, int> leaveBalance;
  final String hodDepartment;

  factory MockDataBundle.empty() => MockDataBundle(
    students: const [],
    fees: const [],
    notices: const [],
    chatThreads: const [],
    messages: const [],
    dashboardKpis: const {},
    busInfo: const {},
    leaveBalance: const {},
    hodDepartment: '',
  );

  factory MockDataBundle.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> listOfMaps(dynamic raw) {
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    Map<String, int> parseLeave(dynamic raw) {
      if (raw is! Map) return const {};
      return raw.map(
        (k, v) =>
            MapEntry('$k', v is num ? v.toInt() : int.tryParse('$v') ?? 0),
      );
    }

    return MockDataBundle(
      students: listOfMaps(json['students']).map(_studentFromJson).toList(),
      fees: listOfMaps(json['fees']).map(_feeFromJson).toList(),
      notices: listOfMaps(json['notices']).map(_noticeFromJson).toList(),
      chatThreads: listOfMaps(
        json['chat_threads'],
      ).map(_chatThreadFromJson).toList(),
      messages: listOfMaps(json['messages']).map(_messageFromJson).toList(),
      dashboardKpis: Map<String, dynamic>.from(
        json['dashboard_kpis'] as Map? ?? {},
      ),
      busInfo: Map<String, dynamic>.from(json['bus_info'] as Map? ?? {}),
      leaveBalance: parseLeave(json['leave_balance'] ?? {}),
      hodDepartment:
          json['hod_department'] as String? ??
          json['hodDepartment'] as String? ??
          '',
    );
  }
}

DateTime _dt(dynamic v) => DateTime.parse(v as String);

int _i(dynamic v) => (v as num).toInt();

double _d(dynamic v) => (v as num).toDouble();

bool _b(dynamic v) => v as bool;

String _s(dynamic v) => v as String;

String? _sn(dynamic v) => v as String?;

List<T> _mapList<T>(dynamic raw, T Function(Map<String, dynamic>) f) {
  if (raw is! List) return [];
  return raw.map((e) => f(Map<String, dynamic>.from(e as Map))).toList();
}

Map<String, List<MockPeriod>> _parseTimetable(dynamic raw) {
  if (raw is! Map) return {};
  final out = <String, List<MockPeriod>>{};
  raw.forEach((k, v) {
    if (v is List) {
      out['$k'] = v
          .map((e) => _periodFromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
  });
  return out;
}

Map<String, List<String>> _parseDriverStopStudents(dynamic raw) {
  if (raw is! Map) return {};
  final out = <String, List<String>>{};
  raw.forEach((k, v) {
    if (v is List) out['$k'] = v.map((e) => '$e').toList();
  });
  return out;
}

// ── fromJson ────────────────────────────────────────────────────────────────

MockStudent _studentFromJson(Map<String, dynamic> j) => MockStudent(
  id: _s(j['id']),
  name: _s(j['name']),
  rollNo: _s(j['roll_no'] ?? j['rollNo']),
  classSection: _s(j['class_section'] ?? j['classSection']),
  attendancePercent: _d(j['attendance_percent'] ?? j['attendancePercent']),
  avatarUrl: _sn(j['avatar_url'] ?? j['avatarUrl']),
  parentName: _sn(j['parent_name'] ?? j['parentName']),
  parentPhone: _sn(j['parent_phone'] ?? j['parentPhone']),
  feeStatus: _sn(j['fee_status'] ?? j['feeStatus']) ?? 'paid',
);

MockAttendanceDay _attendanceDayFromJson(Map<String, dynamic> j) =>
    MockAttendanceDay(
      date: _dt(j['date']),
      status: _s(j['status']),
      periods: (j['periods'] as List?)?.map((e) => '$e').toList() ?? const [],
    );

MockAttendanceSession _attendanceSessionFromJson(Map<String, dynamic> j) =>
    MockAttendanceSession(
      id: _s(j['id']),
      date: _dt(j['date']),
      classSection: _s(j['class_section'] ?? j['classSection']),
      period: _i(j['period']),
      subject: _s(j['subject']),
      concept: _s(j['concept']),
      startTime: _s(j['start_time'] ?? j['startTime']),
      endTime: _s(j['end_time'] ?? j['endTime']),
      status: _sn(j['status']) ?? 'pending',
    );

MockFeeInstallment _feeFromJson(Map<String, dynamic> j) => MockFeeInstallment(
  id: _s(j['id']),
  label: _s(j['label']),
  amountPaise: _i(j['amount_paise'] ?? j['amountPaise']),
  dueDate: _dt(j['due_date'] ?? j['dueDate']),
  status: _s(j['status']),
  paidDate: j['paid_date'] != null || j['paidDate'] != null
      ? DateTime.tryParse('${j['paid_date'] ?? j['paidDate']}')
      : null,
  transactionId: _sn(j['transaction_id'] ?? j['transactionId']),
);

MockDiaryEntry _diaryFromJson(Map<String, dynamic> j) => MockDiaryEntry(
  date: _dt(j['date']),
  subject: _s(j['subject']),
  classwork: _s(j['classwork']),
  homework: _s(j['homework']),
  dueDate: j['due_date'] != null || j['dueDate'] != null
      ? DateTime.tryParse('${j['due_date'] ?? j['dueDate']}')
      : null,
  hasAttachment: _b(j['has_attachment'] ?? j['hasAttachment'] ?? false),
  completed: _b(j['completed'] ?? false),
);

MockMessage _messageFromJson(Map<String, dynamic> j) => MockMessage(
  id: _s(j['id']),
  senderId: _s(j['sender_id'] ?? j['senderId']),
  text: _s(j['text']),
  timestamp: _dt(j['timestamp']),
  isRead: _b(j['is_read'] ?? j['isRead'] ?? true),
);

MockChatThread _chatThreadFromJson(Map<String, dynamic> j) => MockChatThread(
  id: _s(j['id']),
  teacherName: _s(j['teacher_name'] ?? j['teacherName']),
  teacherSubject: _s(j['teacher_subject'] ?? j['teacherSubject']),
  lastMessage: _s(j['last_message'] ?? j['lastMessage']),
  lastMessageTime: _dt(j['last_message_time'] ?? j['lastMessageTime']),
  unreadCount: _i(j['unread_count'] ?? j['unreadCount'] ?? 0),
);

MockNotice _noticeFromJson(Map<String, dynamic> j) => MockNotice(
  id: _s(j['id']),
  title: _s(j['title']),
  body: _s(j['body']),
  date: _dt(j['date']),
  category: _s(j['category']),
  isRead: _b(j['is_read'] ?? j['isRead'] ?? false),
  hasAttachment: _b(j['has_attachment'] ?? j['hasAttachment'] ?? false),
  targetUserId: _sn(j['target_user_id'] ?? j['targetUserId']),
);

MockPeriod _periodFromJson(Map<String, dynamic> j) => MockPeriod(
  period: _i(j['period']),
  subject: _s(j['subject']),
  teacher: _s(j['teacher']),
  startTime: _s(j['start_time'] ?? j['startTime']),
  endTime: _s(j['end_time'] ?? j['endTime']),
  room: _sn(j['room']),
);

BookFormat _bookFormat(dynamic v) => '$v'.toLowerCase() == 'softcopy'
    ? BookFormat.softcopy
    : BookFormat.hardcopy;

MockBook _bookFromJson(Map<String, dynamic> j) => MockBook(
  id: _s(j['id']),
  title: _s(j['title']),
  author: _s(j['author']),
  category: _s(j['category']),
  available: _b(j['available']),
  issuedTo: _sn(j['issued_to'] ?? j['issuedTo']),
  coverUrl: _sn(j['cover_url'] ?? j['coverUrl']),
  isbn: _sn(j['isbn']),
  format: _bookFormat(j['format'] ?? 'hardcopy'),
  totalCopies: _i(j['total_copies'] ?? j['totalCopies'] ?? 1),
  availableCopies: j['available_copies'] != null || j['availableCopies'] != null
      ? _i(j['available_copies'] ?? j['availableCopies'])
      : null,
  accessionCode: _sn(j['accession_code'] ?? j['accessionCode']),
);

MockStaffMember _staffFromJson(Map<String, dynamic> j) => MockStaffMember(
  id: _s(j['id']),
  name: _s(j['name']),
  role: _s(j['role']),
  department: _s(j['department']),
  phone: _s(j['phone']),
  email: _s(j['email']),
  salaryCTC: _i(j['salary_ctc'] ?? j['salaryCTC']),
);

MockCanteenItem _canteenItemFromJson(Map<String, dynamic> j) => MockCanteenItem(
  id: _s(j['id']),
  name: _s(j['name']),
  category: _s(j['category']),
  pricePaise: _i(j['price_paise'] ?? j['pricePaise']),
  isVeg: _b(j['is_veg'] ?? j['isVeg']),
  allergens: (j['allergens'] as List?)?.map((e) => '$e').toList() ?? const [],
  available: _b(j['available']),
);

MockCanteenCombo _canteenComboFromJson(Map<String, dynamic> j) =>
    MockCanteenCombo(
      id: _s(j['id']),
      name: _s(j['name']),
      itemIds:
          ((j['item_ids'] ?? j['itemIds']) as List?)
              ?.map((e) => '$e')
              .toList() ??
          const [],
      pricePaise: _i(j['price_paise'] ?? j['pricePaise']),
      description: _s(j['description']),
      isVeg: _b(j['is_veg'] ?? j['isVeg']),
      available: _b(j['available']),
    );

MockCanteenSubscriptionPlan _canteenPlanFromJson(Map<String, dynamic> j) =>
    MockCanteenSubscriptionPlan(
      id: _s(j['id']),
      name: _s(j['name']),
      type: _s(j['type']),
      pricePaise: _i(j['price_paise'] ?? j['pricePaise']),
      durationDays: _i(j['duration_days'] ?? j['durationDays']),
      forStudent: _b(j['for_student'] ?? j['forStudent']),
      forStaff: _b(j['for_staff'] ?? j['forStaff']),
      description: _sn(j['description']),
    );

MockCanteenSubscription _canteenSubFromJson(Map<String, dynamic> j) =>
    MockCanteenSubscription(
      id: _s(j['id']),
      personId: _s(j['person_id'] ?? j['personId']),
      personName: _s(j['person_name'] ?? j['personName']),
      planId: _s(j['plan_id'] ?? j['planId']),
      planName: _s(j['plan_name'] ?? j['planName']),
      type: _s(j['type']),
      startDate: _dt(j['start_date'] ?? j['startDate']),
      endDate: _dt(j['end_date'] ?? j['endDate']),
      status: _s(j['status']),
    );

MockCanteenOrderItem _orderItemFromJson(Map<String, dynamic> j) =>
    MockCanteenOrderItem(
      itemId: _s(j['item_id'] ?? j['itemId']),
      name: _s(j['name']),
      qty: _i(j['qty']),
      pricePaise: _i(j['price_paise'] ?? j['pricePaise']),
    );

MockCanteenOrder _canteenOrderFromJson(Map<String, dynamic> j) =>
    MockCanteenOrder(
      id: _s(j['id']),
      personId: _s(j['person_id'] ?? j['personId']),
      personName: _s(j['person_name'] ?? j['personName']),
      items: _mapList(j['items'], _orderItemFromJson),
      totalPaise: _i(j['total_paise'] ?? j['totalPaise']),
      paymentStatus: _s(j['payment_status'] ?? j['paymentStatus']),
      createdAt: _dt(j['created_at'] ?? j['createdAt']),
      barcode: _sn(j['barcode']),
    );

MockCampusWallet _walletFromJson(Map<String, dynamic> j) => MockCampusWallet(
  personId: _s(j['person_id'] ?? j['personId']),
  personName: _s(j['person_name'] ?? j['personName']),
  balancePaise: _i(j['balance_paise'] ?? j['balancePaise'] ?? 0),
);

MockCanteenTransaction _canteenTxFromJson(Map<String, dynamic> j) =>
    MockCanteenTransaction(
      id: _s(j['id']),
      personId: _s(j['person_id'] ?? j['personId']),
      amountPaise: _i(j['amount_paise'] ?? j['amountPaise']),
      type: _s(j['type']),
      description: _s(j['description']),
      createdAt: _dt(j['created_at'] ?? j['createdAt']),
    );

MockLeaveApplication _leaveAppFromJson(Map<String, dynamic> j) =>
    MockLeaveApplication(
      id: _s(j['id']),
      childName: _s(j['child_name'] ?? j['childName']),
      type: _s(j['type']),
      fromDate: _dt(j['from_date'] ?? j['fromDate']),
      toDate: _dt(j['to_date'] ?? j['toDate']),
      workingDays: _i(j['working_days'] ?? j['workingDays']),
      reason: _s(j['reason']),
      status: _s(j['status']),
      approvedBy: _sn(j['approved_by'] ?? j['approvedBy']),
      rejectionReason: _sn(j['rejection_reason'] ?? j['rejectionReason']),
      attachmentName: _sn(j['attachment_name'] ?? j['attachmentName']),
    );

MockComplaintResponse _complaintRespFromJson(Map<String, dynamic> j) =>
    MockComplaintResponse(
      sender: _s(j['sender']),
      message: _s(j['message']),
      timestamp: _dt(j['timestamp']),
      isAdmin: _b(j['is_admin'] ?? j['isAdmin']),
    );

MockComplaint _complaintFromJson(Map<String, dynamic> j) => MockComplaint(
  ticketId: _s(j['ticket_id'] ?? j['ticketId']),
  category: _s(j['category']),
  subject: _s(j['subject']),
  description: _s(j['description']),
  priority: _s(j['priority']),
  status: _s(j['status']),
  createdAt: _dt(j['created_at'] ?? j['createdAt']),
  responses: _mapList(j['responses'], _complaintRespFromJson),
  isAnonymous: _b(j['is_anonymous'] ?? j['isAnonymous'] ?? false),
);

MockSupportTicket _ticketFromJson(Map<String, dynamic> j) => MockSupportTicket(
  id: _s(j['id']),
  subject: _s(j['subject']),
  status: _s(j['status']),
  priority: _s(j['priority']),
  category: _s(j['category']),
  createdAt: _dt(j['created_at'] ?? j['createdAt']),
  assignee: _sn(j['assignee']),
  description: _sn(j['description']),
);

MockKbArticle _kbFromJson(Map<String, dynamic> j) => MockKbArticle(
  id: _s(j['id']),
  title: _s(j['title']),
  category: _s(j['category']),
  excerpt: _s(j['excerpt']),
  body: _s(j['body']),
);

MockEvent _eventFromJson(Map<String, dynamic> j) => MockEvent(
  id: _s(j['id']),
  title: _s(j['title']),
  date: _dt(j['date']),
  type: _s(j['type']),
  description: _s(j['description']),
  venue: _s(j['venue']),
  requiresRsvp: _b(j['requires_rsvp'] ?? j['requiresRsvp']),
  rsvpCount: _i(j['rsvp_count'] ?? j['rsvpCount'] ?? 0),
  hasRsvped: _b(j['has_rsvped'] ?? j['hasRsvped'] ?? false),
);

MockStaffAttendanceDay _staffAttFromJson(Map<String, dynamic> j) =>
    MockStaffAttendanceDay(
      date: _dt(j['date']),
      status: _s(j['status']),
      checkInTime: _sn(j['check_in_time'] ?? j['checkInTime']),
      checkOutTime: _sn(j['check_out_time'] ?? j['checkOutTime']),
      isWithinGeofence: _b(
        j['is_within_geofence'] ?? j['isWithinGeofence'] ?? true,
      ),
      employeeId: _sn(j['employee_id'] ?? j['employeeId']),
    );

MockPayslip _payslipFromJson(Map<String, dynamic> j) => MockPayslip(
  id: _s(j['id']),
  month: _s(j['month']),
  basicPaise: _i(j['basic_paise'] ?? j['basicPaise']),
  employeeId: _sn(j['employee_id'] ?? j['employeeId']),
  hraPaise: _i(j['hra_paise'] ?? j['hraPaise']),
  daPaise: _i(j['da_paise'] ?? j['daPaise']),
  allowancesPaise: _i(j['allowances_paise'] ?? j['allowancesPaise']),
  pfDeductionPaise: _i(j['pf_deduction_paise'] ?? j['pfDeductionPaise']),
  esiDeductionPaise: _i(j['esi_deduction_paise'] ?? j['esiDeductionPaise']),
  tdsDeductionPaise: _i(j['tds_deduction_paise'] ?? j['tdsDeductionPaise']),
  status: _s(j['status']),
);

MockTraining _trainingFromJson(Map<String, dynamic> j) => MockTraining(
  id: _s(j['id']),
  title: _s(j['title']),
  provider: _s(j['provider']),
  date: _dt(j['date']),
  employeeId: _sn(j['employee_id'] ?? j['employeeId']),
  hours: _i(j['hours']),
  venue: _s(j['venue']),
  isCompleted: _b(j['is_completed'] ?? j['isCompleted']),
  certificateUrl: _sn(j['certificate_url'] ?? j['certificateUrl']),
);

MockBusStop _busStopFromJson(Map<String, dynamic> j) => MockBusStop(
  id: _s(j['id']),
  name: _s(j['name']),
  eta: _s(j['eta']),
  studentCount: _i(j['student_count'] ?? j['studentCount']),
  isVisited: _b(j['is_visited'] ?? j['isVisited'] ?? false),
);

LibraryBorrowerType _borrowerType(dynamic v) => '$v'.toLowerCase() == 'staff'
    ? LibraryBorrowerType.staff
    : LibraryBorrowerType.student;

MockBookIssue _bookIssueFromJson(Map<String, dynamic> j) => MockBookIssue(
  id: _s(j['id']),
  studentName: _s(j['student_name'] ?? j['studentName']),
  studentClass: _s(j['student_class'] ?? j['studentClass']),
  bookTitle: _s(j['book_title'] ?? j['bookTitle']),
  bookAccession: _s(j['book_accession'] ?? j['bookAccession']),
  issueDate: _dt(j['issue_date'] ?? j['issueDate']),
  dueDate: _dt(j['due_date'] ?? j['dueDate']),
  isOverdue: _b(j['is_overdue'] ?? j['isOverdue']),
  finePaise: _i(j['fine_paise'] ?? j['finePaise'] ?? 0),
  borrowerType: _borrowerType(j['borrower_type'] ?? j['borrowerType']),
  borrowerId: _sn(j['borrower_id'] ?? j['borrowerId']),
);

MockReservation _reservationFromJson(Map<String, dynamic> j) => MockReservation(
  id: _s(j['id']),
  studentName: _s(j['student_name'] ?? j['studentName']),
  studentClass: _s(j['student_class'] ?? j['studentClass']),
  bookTitle: _s(j['book_title'] ?? j['bookTitle']),
  bookAccession: _s(j['book_accession'] ?? j['bookAccession']),
  reservedAt: _dt(j['reserved_at'] ?? j['reservedAt']),
  expiresAt: _dt(j['expires_at'] ?? j['expiresAt']),
  status: _s(j['status']),
);

MockHostelStudent _hostelStudentFromJson(Map<String, dynamic> j) =>
    MockHostelStudent(
      id: _s(j['id']),
      name: _s(j['name']),
      roomNo: _s(j['room_no'] ?? j['roomNo']),
      bedNo: _s(j['bed_no'] ?? j['bedNo']),
      classSection: _s(j['class_section'] ?? j['classSection']),
      isPresent: _b(j['is_present'] ?? j['isPresent']),
      absentReason: _sn(j['absent_reason'] ?? j['absentReason']),
      parentName: _sn(j['parent_name'] ?? j['parentName']),
      parentPhone: _sn(j['parent_phone'] ?? j['parentPhone']),
      bloodGroup: _sn(j['blood_group'] ?? j['bloodGroup']),
      medicalNotes: _sn(j['medical_notes'] ?? j['medicalNotes']),
      emergencyContact: _sn(j['emergency_contact'] ?? j['emergencyContact']),
      emergencyPhone: _sn(j['emergency_phone'] ?? j['emergencyPhone']),
      feeStatus: _sn(j['fee_status'] ?? j['feeStatus']) ?? 'paid',
    );

MockHostelOutpass _hostelOutpassFromJson(Map<String, dynamic> j) =>
    MockHostelOutpass(
      id: _s(j['id']),
      studentName: _s(j['student_name'] ?? j['studentName']),
      studentId: _s(j['student_id'] ?? j['studentId']),
      reason: _s(j['reason']),
      fromDate: _dt(j['from_date'] ?? j['fromDate']),
      toDate: _dt(j['to_date'] ?? j['toDate']),
      status: _s(j['status']),
      approvedBy: _sn(j['approved_by'] ?? j['approvedBy']),
      parentConsentPhone: _sn(
        j['parent_consent_phone'] ?? j['parentConsentPhone'],
      ),
      checkOutTime: j['check_out_time'] != null || j['checkOutTime'] != null
          ? DateTime.tryParse('${j['check_out_time'] ?? j['checkOutTime']}')
          : null,
      expectedReturnTime:
          j['expected_return_time'] != null || j['expectedReturnTime'] != null
          ? DateTime.tryParse(
              '${j['expected_return_time'] ?? j['expectedReturnTime']}',
            )
          : null,
    );

MockVisitor _visitorFromJson(Map<String, dynamic> j) => MockVisitor(
  id: _s(j['id']),
  visitorName: _s(j['visitor_name'] ?? j['visitorName']),
  relationship: _s(j['relationship']),
  phone: _s(j['phone']),
  studentName: _s(j['student_name'] ?? j['studentName']),
  idType: _s(j['id_type'] ?? j['idType']),
  checkInTime: _dt(j['check_in_time'] ?? j['checkInTime']),
  checkOutTime: j['check_out_time'] != null || j['checkOutTime'] != null
      ? DateTime.tryParse('${j['check_out_time'] ?? j['checkOutTime']}')
      : null,
);

MockAdmissionEnquiry _admissionFromJson(Map<String, dynamic> j) =>
    MockAdmissionEnquiry(
      id: _s(j['id']),
      studentName: _s(j['student_name'] ?? j['studentName']),
      parentName: _s(j['parent_name'] ?? j['parentName']),
      phone: _s(j['phone']),
      classApplying: _s(j['class_applying'] ?? j['classApplying']),
      source: _s(j['source']),
      status: _s(j['status']),
      aiLeadScore: _i(j['ai_lead_score'] ?? j['aiLeadScore']),
      enquiryDate: _dt(j['enquiry_date'] ?? j['enquiryDate']),
      email: _sn(j['email']),
      notes: _sn(j['notes']),
    );

MockAsset _assetFromJson(Map<String, dynamic> j) => MockAsset(
  id: _s(j['id']),
  name: _s(j['name']),
  category: _s(j['category']),
  brand: _s(j['brand']),
  location: _s(j['location']),
  condition: _s(j['condition']),
  assignedTo: _s(j['assigned_to'] ?? j['assignedTo']),
  serialNo: _sn(j['serial_no'] ?? j['serialNo']),
  purchaseDate: j['purchase_date'] != null || j['purchaseDate'] != null
      ? DateTime.tryParse('${j['purchase_date'] ?? j['purchaseDate']}')
      : null,
  costPaise: j['cost_paise'] != null || j['costPaise'] != null
      ? _i(j['cost_paise'] ?? j['costPaise'])
      : null,
  warrantyTill: j['warranty_till'] != null || j['warrantyTill'] != null
      ? DateTime.tryParse('${j['warranty_till'] ?? j['warrantyTill']}')
      : null,
);

MockStaffLeaveRequest _staffLeaveReqFromJson(Map<String, dynamic> j) =>
    MockStaffLeaveRequest(
      id: _s(j['id']),
      staffName: _s(j['staff_name'] ?? j['staffName']),
      staffId: _s(j['staff_id'] ?? j['staffId']),
      department: _s(j['department']),
      type: _s(j['type']),
      fromDate: _dt(j['from_date'] ?? j['fromDate']),
      toDate: _dt(j['to_date'] ?? j['toDate']),
      workingDays: _i(j['working_days'] ?? j['workingDays']),
      reason: _s(j['reason']),
      status: _s(j['status']),
    );

// ── toJson ───────────────────────────────────────────────────────────────────

Map<String, dynamic> _studentToJson(MockStudent s) => {
  'id': s.id,
  'name': s.name,
  'roll_no': s.rollNo,
  'class_section': s.classSection,
  'attendance_percent': s.attendancePercent,
  'avatar_url': s.avatarUrl,
  'parent_name': s.parentName,
  'parent_phone': s.parentPhone,
  'fee_status': s.feeStatus,
};

Map<String, dynamic> _attendanceDayToJson(MockAttendanceDay d) => {
  'date': d.date.toIso8601String(),
  'status': d.status,
  'periods': d.periods,
};

Map<String, dynamic> _attendanceSessionToJson(MockAttendanceSession s) => {
  'id': s.id,
  'date': s.date.toIso8601String(),
  'class_section': s.classSection,
  'period': s.period,
  'subject': s.subject,
  'concept': s.concept,
  'start_time': s.startTime,
  'end_time': s.endTime,
  'status': s.status,
};

Map<String, dynamic> _feeToJson(MockFeeInstallment f) => {
  'id': f.id,
  'label': f.label,
  'amount_paise': f.amountPaise,
  'due_date': f.dueDate.toIso8601String(),
  'status': f.status,
  'paid_date': f.paidDate?.toIso8601String(),
  'transaction_id': f.transactionId,
};

Map<String, dynamic> _diaryToJson(MockDiaryEntry d) => {
  'date': d.date.toIso8601String(),
  'subject': d.subject,
  'classwork': d.classwork,
  'homework': d.homework,
  'due_date': d.dueDate?.toIso8601String(),
  'has_attachment': d.hasAttachment,
  'completed': d.completed,
};

Map<String, dynamic> _messageToJson(MockMessage m) => {
  'id': m.id,
  'sender_id': m.senderId,
  'text': m.text,
  'timestamp': m.timestamp.toIso8601String(),
  'is_read': m.isRead,
};

Map<String, dynamic> _chatThreadToJson(MockChatThread t) => {
  'id': t.id,
  'teacher_name': t.teacherName,
  'teacher_subject': t.teacherSubject,
  'last_message': t.lastMessage,
  'last_message_time': t.lastMessageTime.toIso8601String(),
  'unread_count': t.unreadCount,
};

Map<String, dynamic> _noticeToJson(MockNotice n) => {
  'id': n.id,
  'title': n.title,
  'body': n.body,
  'date': n.date.toIso8601String(),
  'category': n.category,
  'is_read': n.isRead,
  'has_attachment': n.hasAttachment,
  'target_user_id': n.targetUserId,
};

Map<String, dynamic> _periodToJson(MockPeriod p) => {
  'period': p.period,
  'subject': p.subject,
  'teacher': p.teacher,
  'start_time': p.startTime,
  'end_time': p.endTime,
  'room': p.room,
};

Map<String, dynamic> _bookToJson(MockBook b) => {
  'id': b.id,
  'title': b.title,
  'author': b.author,
  'category': b.category,
  'available': b.available,
  'issued_to': b.issuedTo,
  'cover_url': b.coverUrl,
  'isbn': b.isbn,
  'format': b.format.name,
  'total_copies': b.totalCopies,
  'available_copies': b.availableCopies,
  'accession_code': b.accessionCode,
};

Map<String, dynamic> _staffToJson(MockStaffMember s) => {
  'id': s.id,
  'name': s.name,
  'role': s.role,
  'department': s.department,
  'phone': s.phone,
  'email': s.email,
  'salary_ctc': s.salaryCTC,
};

Map<String, dynamic> _canteenItemToJson(MockCanteenItem i) => {
  'id': i.id,
  'name': i.name,
  'category': i.category,
  'price_paise': i.pricePaise,
  'is_veg': i.isVeg,
  'allergens': i.allergens,
  'available': i.available,
};

Map<String, dynamic> _canteenComboToJson(MockCanteenCombo c) => {
  'id': c.id,
  'name': c.name,
  'item_ids': c.itemIds,
  'price_paise': c.pricePaise,
  'description': c.description,
  'is_veg': c.isVeg,
  'available': c.available,
};

Map<String, dynamic> _canteenPlanToJson(MockCanteenSubscriptionPlan p) => {
  'id': p.id,
  'name': p.name,
  'type': p.type,
  'price_paise': p.pricePaise,
  'duration_days': p.durationDays,
  'for_student': p.forStudent,
  'for_staff': p.forStaff,
  'description': p.description,
};

Map<String, dynamic> _canteenSubToJson(MockCanteenSubscription s) => {
  'id': s.id,
  'person_id': s.personId,
  'person_name': s.personName,
  'plan_id': s.planId,
  'plan_name': s.planName,
  'type': s.type,
  'start_date': s.startDate.toIso8601String(),
  'end_date': s.endDate.toIso8601String(),
  'status': s.status,
};

Map<String, dynamic> _orderItemToJson(MockCanteenOrderItem i) => {
  'item_id': i.itemId,
  'name': i.name,
  'qty': i.qty,
  'price_paise': i.pricePaise,
};

Map<String, dynamic> _canteenOrderToJson(MockCanteenOrder o) => {
  'id': o.id,
  'person_id': o.personId,
  'person_name': o.personName,
  'items': o.items.map(_orderItemToJson).toList(),
  'total_paise': o.totalPaise,
  'payment_status': o.paymentStatus,
  'created_at': o.createdAt.toIso8601String(),
  'barcode': o.barcode,
};

Map<String, dynamic> _walletToJson(MockCampusWallet w) => {
  'person_id': w.personId,
  'person_name': w.personName,
  'balance_paise': w.balancePaise,
};

Map<String, dynamic> _canteenTxToJson(MockCanteenTransaction t) => {
  'id': t.id,
  'person_id': t.personId,
  'amount_paise': t.amountPaise,
  'type': t.type,
  'description': t.description,
  'created_at': t.createdAt.toIso8601String(),
};

Map<String, dynamic> _leaveAppToJson(MockLeaveApplication l) => {
  'id': l.id,
  'child_name': l.childName,
  'type': l.type,
  'from_date': l.fromDate.toIso8601String(),
  'to_date': l.toDate.toIso8601String(),
  'working_days': l.workingDays,
  'reason': l.reason,
  'status': l.status,
  'approved_by': l.approvedBy,
  'rejection_reason': l.rejectionReason,
  'attachment_name': l.attachmentName,
};

Map<String, dynamic> _complaintRespToJson(MockComplaintResponse r) => {
  'sender': r.sender,
  'message': r.message,
  'timestamp': r.timestamp.toIso8601String(),
  'is_admin': r.isAdmin,
};

Map<String, dynamic> _complaintToJson(MockComplaint c) => {
  'ticket_id': c.ticketId,
  'category': c.category,
  'subject': c.subject,
  'description': c.description,
  'priority': c.priority,
  'status': c.status,
  'created_at': c.createdAt.toIso8601String(),
  'responses': c.responses.map(_complaintRespToJson).toList(),
  'is_anonymous': c.isAnonymous,
};

Map<String, dynamic> _ticketToJson(MockSupportTicket t) => {
  'id': t.id,
  'subject': t.subject,
  'status': t.status,
  'priority': t.priority,
  'category': t.category,
  'created_at': t.createdAt.toIso8601String(),
  'assignee': t.assignee,
  'description': t.description,
};

Map<String, dynamic> _kbToJson(MockKbArticle a) => {
  'id': a.id,
  'title': a.title,
  'category': a.category,
  'excerpt': a.excerpt,
  'body': a.body,
};

Map<String, dynamic> _eventToJson(MockEvent e) => {
  'id': e.id,
  'title': e.title,
  'date': e.date.toIso8601String(),
  'type': e.type,
  'description': e.description,
  'venue': e.venue,
  'requires_rsvp': e.requiresRsvp,
  'rsvp_count': e.rsvpCount,
  'has_rsvped': e.hasRsvped,
};

Map<String, dynamic> _staffAttToJson(MockStaffAttendanceDay d) => {
  'date': d.date.toIso8601String(),
  'status': d.status,
  'check_in_time': d.checkInTime,
  'check_out_time': d.checkOutTime,
  'is_within_geofence': d.isWithinGeofence,
  'employee_id': d.employeeId,
};

Map<String, dynamic> _payslipToJson(MockPayslip p) => {
  'id': p.id,
  'month': p.month,
  'basic_paise': p.basicPaise,
  'employee_id': p.employeeId,
  'hra_paise': p.hraPaise,
  'da_paise': p.daPaise,
  'allowances_paise': p.allowancesPaise,
  'pf_deduction_paise': p.pfDeductionPaise,
  'esi_deduction_paise': p.esiDeductionPaise,
  'tds_deduction_paise': p.tdsDeductionPaise,
  'status': p.status,
};

Map<String, dynamic> _trainingToJson(MockTraining t) => {
  'id': t.id,
  'title': t.title,
  'provider': t.provider,
  'date': t.date.toIso8601String(),
  'employee_id': t.employeeId,
  'hours': t.hours,
  'venue': t.venue,
  'is_completed': t.isCompleted,
  'certificate_url': t.certificateUrl,
};

Map<String, dynamic> _busStopToJson(MockBusStop b) => {
  'id': b.id,
  'name': b.name,
  'eta': b.eta,
  'student_count': b.studentCount,
  'is_visited': b.isVisited,
};

Map<String, dynamic> _bookIssueToJson(MockBookIssue i) => {
  'id': i.id,
  'student_name': i.studentName,
  'student_class': i.studentClass,
  'book_title': i.bookTitle,
  'book_accession': i.bookAccession,
  'issue_date': i.issueDate.toIso8601String(),
  'due_date': i.dueDate.toIso8601String(),
  'is_overdue': i.isOverdue,
  'fine_paise': i.finePaise,
  'borrower_type': i.borrowerType == LibraryBorrowerType.staff
      ? 'staff'
      : 'student',
  'borrower_id': i.borrowerId,
};

Map<String, dynamic> _reservationToJson(MockReservation r) => {
  'id': r.id,
  'student_name': r.studentName,
  'student_class': r.studentClass,
  'book_title': r.bookTitle,
  'book_accession': r.bookAccession,
  'reserved_at': r.reservedAt.toIso8601String(),
  'expires_at': r.expiresAt.toIso8601String(),
  'status': r.status,
};

Map<String, dynamic> _hostelStudentToJson(MockHostelStudent s) => {
  'id': s.id,
  'name': s.name,
  'room_no': s.roomNo,
  'bed_no': s.bedNo,
  'class_section': s.classSection,
  'is_present': s.isPresent,
  'absent_reason': s.absentReason,
  'parent_name': s.parentName,
  'parent_phone': s.parentPhone,
  'blood_group': s.bloodGroup,
  'medical_notes': s.medicalNotes,
  'emergency_contact': s.emergencyContact,
  'emergency_phone': s.emergencyPhone,
  'fee_status': s.feeStatus,
};

Map<String, dynamic> _hostelOutpassToJson(MockHostelOutpass o) => {
  'id': o.id,
  'student_name': o.studentName,
  'student_id': o.studentId,
  'reason': o.reason,
  'from_date': o.fromDate.toIso8601String(),
  'to_date': o.toDate.toIso8601String(),
  'status': o.status,
  'approved_by': o.approvedBy,
  'parent_consent_phone': o.parentConsentPhone,
  'check_out_time': o.checkOutTime?.toIso8601String(),
  'expected_return_time': o.expectedReturnTime?.toIso8601String(),
};

Map<String, dynamic> _visitorToJson(MockVisitor v) => {
  'id': v.id,
  'visitor_name': v.visitorName,
  'relationship': v.relationship,
  'phone': v.phone,
  'student_name': v.studentName,
  'id_type': v.idType,
  'check_in_time': v.checkInTime.toIso8601String(),
  'check_out_time': v.checkOutTime?.toIso8601String(),
};

Map<String, dynamic> _admissionToJson(MockAdmissionEnquiry e) => {
  'id': e.id,
  'student_name': e.studentName,
  'parent_name': e.parentName,
  'phone': e.phone,
  'class_applying': e.classApplying,
  'source': e.source,
  'status': e.status,
  'ai_lead_score': e.aiLeadScore,
  'enquiry_date': e.enquiryDate.toIso8601String(),
  'email': e.email,
  'notes': e.notes,
};

Map<String, dynamic> _assetToJson(MockAsset a) => {
  'id': a.id,
  'name': a.name,
  'category': a.category,
  'brand': a.brand,
  'location': a.location,
  'condition': a.condition,
  'assigned_to': a.assignedTo,
  'serial_no': a.serialNo,
  'purchase_date': a.purchaseDate?.toIso8601String(),
  'cost_paise': a.costPaise,
  'warranty_till': a.warrantyTill?.toIso8601String(),
};

Map<String, dynamic> _staffLeaveReqToJson(MockStaffLeaveRequest r) => {
  'id': r.id,
  'staff_name': r.staffName,
  'staff_id': r.staffId,
  'department': r.department,
  'type': r.type,
  'from_date': r.fromDate.toIso8601String(),
  'to_date': r.toDate.toIso8601String(),
  'working_days': r.workingDays,
  'reason': r.reason,
  'status': r.status,
};

class MockData {
  MockData._();

  static MockDataBundle _bundle = MockDataBundle.empty();

  static List<MockStudent> get students => _bundle.students;
  static List<MockFeeInstallment> get fees => _bundle.fees;
  static List<MockNotice> get notices => _bundle.notices;
  static List<MockChatThread> get chatThreads => _bundle.chatThreads;
  static List<MockMessage> get messages => _bundle.messages;
  static Map<String, dynamic> get dashboardKpis => _bundle.dashboardKpis;
  static Map<String, dynamic> get busInfo => _bundle.busInfo;
  static Map<String, int> get leaveBalance => _bundle.leaveBalance;
  static String get hodDepartment => _bundle.hodDepartment;

  static Map<String, List<MockPeriod>> timetable = {};
  static List<MockAttendanceSession> attendanceSessions = [];
  static List<MockAttendanceDay> attendance = [];
  static List<MockDiaryEntry> diary = [];

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

  /// Replace all in-memory datasets from [json]. Missing keys → empty lists/maps.
  static void applyJsonBundle(Map<String, dynamic> json) {
    timetable
      ..clear()
      ..addAll(_parseTimetable(json['timetable']));
    _bundle = MockDataBundle.fromJson(json);

    attendance = _mapList(json['attendance'], _attendanceDayFromJson);
    diary = _mapList(json['diary'], _diaryFromJson);
    attendanceSessions = _mapList(
      json['attendance_sessions'],
      _attendanceSessionFromJson,
    );

    books = _mapList(json['books'], _bookFromJson);
    staff = _mapList(json['staff'], _staffFromJson);
    canteenMenu = _mapList(json['canteen_menu'], _canteenItemFromJson);
    canteenCombos = _mapList(json['canteen_combos'], _canteenComboFromJson);
    canteenSubscriptionPlans = _mapList(
      json['canteen_subscription_plans'],
      _canteenPlanFromJson,
    );
    campusWallets = _mapList(json['campus_wallets'], _walletFromJson);
    canteenSubscriptions = _mapList(
      json['canteen_subscriptions'],
      _canteenSubFromJson,
    );
    canteenOrders = _mapList(json['canteen_orders'], _canteenOrderFromJson);
    canteenTransactions = _mapList(
      json['canteen_transactions'],
      _canteenTxFromJson,
    );
    leaveApplications = _mapList(json['leave_applications'], _leaveAppFromJson);
    complaints = _mapList(json['complaints'], _complaintFromJson);
    supportTickets = _mapList(json['support_tickets'], _ticketFromJson);
    kbArticles = _mapList(json['kb_articles'], _kbFromJson);
    events = _mapList(json['events'], _eventFromJson);
    staffAttendance = _mapList(json['staff_attendance'], _staffAttFromJson);
    payslips = _mapList(json['payslips'], _payslipFromJson);
    trainings = _mapList(json['trainings'], _trainingFromJson);

    driverStopStudents
      ..clear()
      ..addAll(_parseDriverStopStudents(json['driver_stop_students']));

    busStops = _mapList(json['bus_stops'], _busStopFromJson);
    bookIssues = _mapList(json['book_issues'], _bookIssueFromJson);
    reservations = _mapList(json['reservations'], _reservationFromJson);
    hostelStudents = _mapList(json['hostel_students'], _hostelStudentFromJson);
    hostelOutpasses = _mapList(
      json['hostel_outpasses'],
      _hostelOutpassFromJson,
    );
    visitors = _mapList(json['visitors'], _visitorFromJson);
    admissionEnquiries = _mapList(
      json['admission_enquiries'],
      _admissionFromJson,
    );
    assets = _mapList(json['assets'], _assetFromJson);
    staffLeaveRequests = _mapList(
      json['staff_leave_requests'],
      _staffLeaveReqFromJson,
    );
  }

  /// Snapshot for disk persistence ([MockBundlePersistence]) / export tooling.
  static Map<String, dynamic> exportFullBundleForJson() {
    return <String, dynamic>{
      'dashboard_kpis': Map<String, dynamic>.from(dashboardKpis),
      'bus_info': Map<String, dynamic>.from(busInfo),
      'leave_balance': Map<String, int>.from(leaveBalance),
      'hod_department': hodDepartment,
      'students': students.map(_studentToJson).toList(),
      'fees': fees.map(_feeToJson).toList(),
      'notices': notices.map(_noticeToJson).toList(),
      'chat_threads': chatThreads.map(_chatThreadToJson).toList(),
      'messages': messages.map(_messageToJson).toList(),
      'attendance': attendance.map(_attendanceDayToJson).toList(),
      'diary': diary.map(_diaryToJson).toList(),
      'timetable': timetable.map(
        (k, v) => MapEntry(k, v.map(_periodToJson).toList()),
      ),
      'attendance_sessions': attendanceSessions
          .map(_attendanceSessionToJson)
          .toList(),
      'books': books.map(_bookToJson).toList(),
      'staff': staff.map(_staffToJson).toList(),
      'canteen_menu': canteenMenu.map(_canteenItemToJson).toList(),
      'canteen_combos': canteenCombos.map(_canteenComboToJson).toList(),
      'canteen_subscription_plans': canteenSubscriptionPlans
          .map(_canteenPlanToJson)
          .toList(),
      'campus_wallets': campusWallets.map(_walletToJson).toList(),
      'canteen_subscriptions': canteenSubscriptions
          .map(_canteenSubToJson)
          .toList(),
      'canteen_orders': canteenOrders.map(_canteenOrderToJson).toList(),
      'canteen_transactions': canteenTransactions
          .map(_canteenTxToJson)
          .toList(),
      'leave_applications': leaveApplications.map(_leaveAppToJson).toList(),
      'complaints': complaints.map(_complaintToJson).toList(),
      'support_tickets': supportTickets.map(_ticketToJson).toList(),
      'kb_articles': kbArticles.map(_kbToJson).toList(),
      'events': events.map(_eventToJson).toList(),
      'staff_attendance': staffAttendance.map(_staffAttToJson).toList(),
      'payslips': payslips.map(_payslipToJson).toList(),
      'trainings': trainings.map(_trainingToJson).toList(),
      'driver_stop_students': Map<String, dynamic>.from(
        driverStopStudents.map((k, v) => MapEntry(k, v)),
      ),
      'bus_stops': busStops.map(_busStopToJson).toList(),
      'book_issues': bookIssues.map(_bookIssueToJson).toList(),
      'reservations': reservations.map(_reservationToJson).toList(),
      'hostel_students': hostelStudents.map(_hostelStudentToJson).toList(),
      'hostel_outpasses': hostelOutpasses.map(_hostelOutpassToJson).toList(),
      'visitors': visitors.map(_visitorToJson).toList(),
      'admission_enquiries': admissionEnquiries.map(_admissionToJson).toList(),
      'assets': assets.map(_assetToJson).toList(),
      'staff_leave_requests': staffLeaveRequests
          .map(_staffLeaveReqToJson)
          .toList(),
    };
  }
}
