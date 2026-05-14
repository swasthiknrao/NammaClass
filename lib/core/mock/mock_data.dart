/// NammaClass local-first dataset (JSON file + disk persistence).
/// Starts empty unless data exists at runtime.
library;

part 'mock_data_store.part.dart';

// ── Student model ──────────────────────────────────────────────────────────────
class MockStudent {
  const MockStudent({
    required this.id,
    required this.name,
    required this.rollNo,
    required this.classSection,
    required this.attendancePercent,
    this.avatarUrl,
    this.parentName,
    this.parentPhone,
    this.feeStatus = 'paid',
  });

  final String id;
  final String name;
  final String rollNo;
  final String classSection;
  final double attendancePercent;
  final String? avatarUrl;
  final String? parentName;
  final String? parentPhone;
  final String feeStatus;

  MockStudent copyWith({
    String? id,
    String? name,
    String? rollNo,
    String? classSection,
    double? attendancePercent,
    String? avatarUrl,
    String? parentName,
    String? parentPhone,
    String? feeStatus,
  }) {
    return MockStudent(
      id: id ?? this.id,
      name: name ?? this.name,
      rollNo: rollNo ?? this.rollNo,
      classSection: classSection ?? this.classSection,
      attendancePercent: attendancePercent ?? this.attendancePercent,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      feeStatus: feeStatus ?? this.feeStatus,
    );
  }
}

// ── Attendance model ───────────────────────────────────────────────────────────
class MockAttendanceDay {
  const MockAttendanceDay({
    required this.date,
    required this.status,
    this.periods = const [],
  });

  final DateTime date;
  final String status; // 'present' | 'absent' | 'leave' | 'holiday'
  final List<String> periods;
}

/// Teacher attendance session — class, period, concept, time for calendar view.
class MockAttendanceSession {
  const MockAttendanceSession({
    required this.id,
    required this.date,
    required this.classSection,
    required this.period,
    required this.subject,
    required this.concept,
    required this.startTime,
    required this.endTime,
    this.status = 'pending', // 'pending' | 'marked'
  });

  final String id;
  final DateTime date;
  final String classSection;
  final int period;
  final String subject;
  final String concept;
  final String startTime;
  final String endTime;
  final String status;
}

// ── Fee model ──────────────────────────────────────────────────────────────────
class MockFeeInstallment {
  const MockFeeInstallment({
    required this.id,
    required this.label,
    required this.amountPaise,
    required this.dueDate,
    required this.status,
    this.paidDate,
    this.transactionId,
  });

  final String id;
  final String label;
  final int amountPaise;
  final DateTime dueDate;
  final String status; // 'paid' | 'pending' | 'overdue'
  final DateTime? paidDate;
  final String? transactionId;
}

// ── Diary model ────────────────────────────────────────────────────────────────
class MockDiaryEntry {
  const MockDiaryEntry({
    required this.date,
    required this.subject,
    required this.classwork,
    required this.homework,
    this.dueDate,
    this.hasAttachment = false,
    this.completed = false,
  });

  final DateTime date;
  final String subject;
  final String classwork;
  final String homework;
  final DateTime? dueDate;
  final bool hasAttachment;
  final bool completed;
}

// ── Message model ──────────────────────────────────────────────────────────────
class MockMessage {
  const MockMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = true,
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;
}

class MockChatThread {
  const MockChatThread({
    required this.id,
    required this.teacherName,
    required this.teacherSubject,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  final String id;
  final String teacherName;
  final String teacherSubject;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
}

// ── Notice model ───────────────────────────────────────────────────────────────
class MockNotice {
  const MockNotice({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.category,
    this.isRead = false,
    this.hasAttachment = false,
    this.targetUserId,
    this.senderUserId,
    this.senderName,
    this.audienceRoleKeys = const [],
    this.audienceClassSection,
  });

  final String id;
  final String title;
  final String body;
  final DateTime date;
  final String category;
  final bool isRead;
  final bool hasAttachment;

  /// If set, this notice is shown only to the user with this ID.
  /// Also used for library overdue: matches borrowerId or student/staff name.
  final String? targetUserId;

  /// Portal user id of sender (e.g. admin broadcast, teacher message).
  final String? senderUserId;

  /// Display name for inbox ("From …").
  final String? senderName;

  /// When [targetUserId] is null: only users whose [UserRole.name] is in this list
  /// see the notice. Empty means no role filter (school-wide).
  final List<String> audienceRoleKeys;

  /// Optional class/section filter (e.g. `8-A`) combined with [audienceRoleKeys].
  final String? audienceClassSection;

  MockNotice copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? date,
    String? category,
    bool? isRead,
    bool? hasAttachment,
    String? targetUserId,
    bool clearTargetUserId = false,
    String? senderUserId,
    bool clearSenderUserId = false,
    String? senderName,
    bool clearSenderName = false,
    List<String>? audienceRoleKeys,
    String? audienceClassSection,
    bool clearAudienceClassSection = false,
  }) {
    return MockNotice(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      date: date ?? this.date,
      category: category ?? this.category,
      isRead: isRead ?? this.isRead,
      hasAttachment: hasAttachment ?? this.hasAttachment,
      targetUserId: clearTargetUserId
          ? null
          : (targetUserId ?? this.targetUserId),
      senderUserId: clearSenderUserId
          ? null
          : (senderUserId ?? this.senderUserId),
      senderName: clearSenderName ? null : (senderName ?? this.senderName),
      audienceRoleKeys: audienceRoleKeys ?? this.audienceRoleKeys,
      audienceClassSection: clearAudienceClassSection
          ? null
          : (audienceClassSection ?? this.audienceClassSection),
    );
  }
}

// ── Timetable model ────────────────────────────────────────────────────────────
class MockPeriod {
  const MockPeriod({
    required this.period,
    required this.subject,
    required this.teacher,
    required this.startTime,
    required this.endTime,
    this.room,
  });

  final int period;
  final String subject;
  final String teacher;
  final String startTime;
  final String endTime;
  final String? room;
}

// ── Book model ─────────────────────────────────────────────────────────────────
/// Format: hardcopy (physical) or softcopy (digital)
enum BookFormat { hardcopy, softcopy }

class MockBook {
  const MockBook({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.available,
    this.issuedTo,
    this.coverUrl,
    this.isbn,
    this.format = BookFormat.hardcopy,
    this.totalCopies = 1,
    int? availableCopies,
    this.accessionCode,
  }) : availableCopies = availableCopies ?? (available ? 1 : 0);

  final String id;
  final String title;
  final String author;
  final String category;
  final bool available;
  final String? issuedTo;
  final String? coverUrl;
  final String? isbn;
  final BookFormat format;
  final int totalCopies;
  final int availableCopies;
  final String? accessionCode;

  String get accessionOrId =>
      accessionCode ?? 'ACC-${id.replaceAll('b', '').padLeft(4, '0')}';
}

// ── Staff model ────────────────────────────────────────────────────────────────
class MockStaffMember {
  const MockStaffMember({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.phone,
    this.email,
    this.joinDate,
    this.status = 'active',
    this.salaryCTC = 0,
    this.employeeCode,
    this.campusBlock,
  });

  final String id;
  final String name;
  final String role;
  final String department;
  final String phone;
  final String? email;
  final DateTime? joinDate;
  final String status;
  final int salaryCTC;
  final String? employeeCode;
  final String? campusBlock;

  MockStaffMember copyWith({
    String? id,
    String? name,
    String? role,
    String? department,
    String? phone,
    String? email,
    DateTime? joinDate,
    String? status,
    int? salaryCTC,
    String? employeeCode,
    String? campusBlock,
    bool clearEmail = false,
    bool clearEmployeeCode = false,
    bool clearCampusBlock = false,
  }) {
    return MockStaffMember(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      email: clearEmail ? null : (email ?? this.email),
      joinDate: joinDate ?? this.joinDate,
      status: status ?? this.status,
      salaryCTC: salaryCTC ?? this.salaryCTC,
      employeeCode: clearEmployeeCode
          ? null
          : (employeeCode ?? this.employeeCode),
      campusBlock: clearCampusBlock ? null : (campusBlock ?? this.campusBlock),
    );
  }
}

// ── Canteen model ──────────────────────────────────────────────────────────────
class MockCanteenItem {
  const MockCanteenItem({
    required this.id,
    required this.name,
    required this.category,
    required this.pricePaise,
    this.isVeg = true,
    this.allergens = const [],
    this.available = true,
  });

  final String id;
  final String name;
  final String category;
  final int pricePaise;
  final bool isVeg;
  final List<String> allergens;
  final bool available;

  MockCanteenItem copyWith({
    String? id,
    String? name,
    String? category,
    int? pricePaise,
    bool? isVeg,
    List<String>? allergens,
    bool? available,
  }) {
    return MockCanteenItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      pricePaise: pricePaise ?? this.pricePaise,
      isVeg: isVeg ?? this.isVeg,
      allergens: allergens ?? this.allergens,
      available: available ?? this.available,
    );
  }
}

/// Combo offer — bundle of items at discounted price
class MockCanteenCombo {
  const MockCanteenCombo({
    required this.id,
    required this.name,
    required this.itemIds,
    required this.pricePaise,
    this.description,
    this.isVeg = true,
    this.available = true,
  });

  final String id;
  final String name;
  final List<String> itemIds;
  final int pricePaise;
  final String? description;
  final bool isVeg;
  final bool available;

  MockCanteenCombo copyWith({
    String? id,
    String? name,
    List<String>? itemIds,
    int? pricePaise,
    String? description,
    bool? isVeg,
    bool? available,
    bool clearDescription = false,
  }) {
    return MockCanteenCombo(
      id: id ?? this.id,
      name: name ?? this.name,
      itemIds: itemIds ?? this.itemIds,
      pricePaise: pricePaise ?? this.pricePaise,
      description: clearDescription ? null : (description ?? this.description),
      isVeg: isVeg ?? this.isVeg,
      available: available ?? this.available,
    );
  }
}

/// Subscription plan — veg/non-veg monthly
class MockCanteenSubscriptionPlan {
  const MockCanteenSubscriptionPlan({
    required this.id,
    required this.name,
    required this.type,
    required this.pricePaise,
    required this.durationDays,
    this.forStudent = true,
    this.forStaff = true,
    this.description,
  });

  final String id;
  final String name;
  final String type; // veg | nonveg
  final int pricePaise;
  final int durationDays;
  final bool forStudent;
  final bool forStaff;
  final String? description;
}

/// Active subscription for a person
class MockCanteenSubscription {
  MockCanteenSubscription({
    required this.id,
    required this.personId,
    required this.personName,
    required this.planId,
    required this.planName,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  final String id;
  final String personId;
  final String personName;
  final String planId;
  final String planName;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  String status; // active | expired | cancelled
}

/// Order — paid via wallet, linked by personId
class MockCanteenOrder {
  MockCanteenOrder({
    required this.id,
    required this.personId,
    required this.personName,
    required this.items,
    required this.totalPaise,
    required this.paymentStatus,
    required this.createdAt,
    this.barcode,
  });

  final String id;
  final String personId;
  final String personName;
  final List<MockCanteenOrderItem> items;
  final int totalPaise;
  String paymentStatus; // paid | pending | refunded
  final DateTime createdAt;
  final String? barcode;
}

class MockCanteenOrderItem {
  const MockCanteenOrderItem({
    required this.itemId,
    required this.name,
    required this.qty,
    required this.pricePaise,
  });

  final String itemId;
  final String name;
  final int qty;
  final int pricePaise;
}

/// Campus wallet — balance by personId
class MockCampusWallet {
  MockCampusWallet({
    required this.personId,
    required this.personName,
    this.balancePaise = 0,
  });

  final String personId;
  final String personName;
  int balancePaise;
}

/// Transaction for wallet top-up or deduction
class MockCanteenTransaction {
  MockCanteenTransaction({
    required this.id,
    required this.personId,
    required this.amountPaise,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  final String id;
  final String personId;
  final int amountPaise;
  final String type; // topup | deduction | refund
  final String description;
  final DateTime createdAt;
}

// ── Leave application model ────────────────────────────────────────────────
class MockLeaveApplication {
  MockLeaveApplication({
    required this.id,
    required this.childName,
    required this.type,
    required this.fromDate,
    required this.toDate,
    required this.workingDays,
    required this.reason,
    required this.status,
    this.approvedBy,
    this.rejectionReason,
    this.attachmentName,
  });

  final String id;
  final String childName;
  final String type;
  final DateTime fromDate;
  final DateTime toDate;
  final int workingDays;
  final String reason;
  final String status; // pending | approved | rejected
  final String? approvedBy;
  final String? rejectionReason;
  final String? attachmentName;
}

// ── Complaint model ────────────────────────────────────────────────────────
class MockComplaintResponse {
  const MockComplaintResponse({
    required this.sender,
    required this.message,
    required this.timestamp,
    required this.isAdmin,
  });

  final String sender;
  final String message;
  final DateTime timestamp;
  final bool isAdmin;
}

class MockComplaint {
  MockComplaint({
    required this.ticketId,
    required this.category,
    required this.subject,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.responses = const [],
    this.isAnonymous = false,
  });

  final String ticketId;
  final String category;
  final String subject;
  final String description;
  final String priority; // Low | Medium | High | Urgent
  final String
  status; // Open | In Progress | Awaiting Response | Resolved | Closed
  final DateTime createdAt;
  final List<MockComplaintResponse> responses;
  final bool isAnonymous;
}

// ── Support ticket model ────────────────────────────────────────────────────
class MockSupportTicket {
  const MockSupportTicket({
    required this.id,
    required this.subject,
    required this.status,
    required this.priority,
    required this.category,
    required this.createdAt,
    this.assignee,
    this.description,
  });

  final String id;
  final String subject;
  final String
  status; // open | in_progress | awaiting_response | resolved | closed
  final String priority; // low | medium | high | urgent
  final String category;
  final DateTime createdAt;
  final String? assignee;
  final String? description;
}

// ── Knowledge base article model ────────────────────────────────────────────
class MockKbArticle {
  const MockKbArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.excerpt,
    required this.body,
  });

  final String id;
  final String title;
  final String category;
  final String excerpt;
  final String body;
}

// ── Event model ────────────────────────────────────────────────────────────
class MockEvent {
  MockEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    required this.description,
    required this.venue,
    required this.requiresRsvp,
    required this.rsvpCount,
    this.hasRsvped = false,
  });

  final String id;
  final String title;
  final DateTime date;
  final String type; // sports | pta | holiday | academic | cultural
  final String description;
  final String venue;
  final bool requiresRsvp;
  final int rsvpCount;
  bool hasRsvped;
}

// ── Staff attendance model ─────────────────────────────────────────────────
class MockStaffAttendanceDay {
  MockStaffAttendanceDay({
    required this.date,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    this.isWithinGeofence = true,
    this.employeeId,
  });

  final DateTime date;
  final String
  status; // present | absent | leave | half_day | holiday | on_duty
  final String? checkInTime;
  final String? checkOutTime;
  final bool isWithinGeofence;
  final String? employeeId;
}

// ── Payslip model ──────────────────────────────────────────────────────────
class MockPayslip {
  const MockPayslip({
    required this.id,
    required this.month,
    required this.basicPaise,
    this.employeeId,
    required this.hraPaise,
    required this.daPaise,
    required this.allowancesPaise,
    required this.pfDeductionPaise,
    required this.esiDeductionPaise,
    required this.tdsDeductionPaise,
    required this.status,
  });

  final String id;
  final String month;
  final int basicPaise;
  final int hraPaise;
  final int daPaise;
  final int allowancesPaise;
  final int pfDeductionPaise;
  final int esiDeductionPaise;
  final int tdsDeductionPaise;
  final String status; // Generated | Pending
  final String? employeeId;

  int get grossPaise => basicPaise + hraPaise + daPaise + allowancesPaise;
  int get totalDeductionsPaise =>
      pfDeductionPaise + esiDeductionPaise + tdsDeductionPaise;
  int get netPaise => grossPaise - totalDeductionsPaise;
}

// ── Training model ─────────────────────────────────────────────────────────
class MockTraining {
  MockTraining({
    required this.id,
    required this.title,
    required this.provider,
    required this.date,
    this.employeeId,
    required this.hours,
    required this.venue,
    required this.isCompleted,
    this.certificateUrl,
  });

  final String id;
  final String title;
  final String provider;
  final DateTime date;
  final int hours;
  final String venue;
  final bool isCompleted;
  final String? certificateUrl;
  final String? employeeId;
}

// ── Bus stop model ─────────────────────────────────────────────────────────
class MockBusStop {
  MockBusStop({
    required this.id,
    required this.name,
    required this.eta,
    required this.studentCount,
    required this.isVisited,
    this.lat,
    this.lng,
  });

  final String id;
  final String name;
  final String eta;
  final int studentCount;
  bool isVisited;

  /// WGS84 — used for external maps deep links when non-null.
  final double? lat;
  final double? lng;
}

/// Borrower type for library issues
enum LibraryBorrowerType { student, staff }

// ── Book issue model ───────────────────────────────────────────────────────
class MockBookIssue {
  MockBookIssue({
    required this.id,
    required this.studentName,
    required this.studentClass,
    required this.bookTitle,
    required this.bookAccession,
    required this.issueDate,
    required this.dueDate,
    required this.isOverdue,
    this.finePaise = 0,
    this.borrowerType = LibraryBorrowerType.student,
    this.borrowerId,
  });

  final String id;
  final String studentName;
  final String studentClass;
  final String bookTitle;
  final String bookAccession;
  final DateTime issueDate;
  final DateTime dueDate;
  final bool isOverdue;
  final int finePaise;
  final LibraryBorrowerType borrowerType;
  final String? borrowerId;

  /// Display name (student or staff)
  String get borrowerName => studentName;

  /// Display info (class or department)
  String get borrowerInfo => studentClass;
}

// ── Reservation model ──────────────────────────────────────────────────────
class MockReservation {
  MockReservation({
    required this.id,
    required this.studentName,
    required this.studentClass,
    required this.bookTitle,
    required this.bookAccession,
    required this.reservedAt,
    required this.expiresAt,
    required this.status,
  });

  final String id;
  final String studentName;
  final String studentClass;
  final String bookTitle;
  final String bookAccession;
  final DateTime reservedAt;
  final DateTime expiresAt;
  String status; // pending | ready | expired | cancelled
}

// ── Hostel student model ───────────────────────────────────────────────────
class MockHostelStudent {
  MockHostelStudent({
    required this.id,
    required this.name,
    required this.roomNo,
    required this.bedNo,
    required this.classSection,
    required this.isPresent,
    this.absentReason,
    this.parentName,
    this.parentPhone,
    this.bloodGroup,
    this.medicalNotes,
    this.emergencyContact,
    this.emergencyPhone,
    this.feeStatus = 'paid',
  });

  final String id;
  final String name;
  final String roomNo;
  final String bedNo;
  final String classSection;
  bool isPresent;
  String? absentReason;

  /// Parent/guardian name for quick contact
  final String? parentName;

  /// Parent phone for call/SMS
  final String? parentPhone;
  final String? bloodGroup;
  final String? medicalNotes;
  final String? emergencyContact;
  final String? emergencyPhone;
  final String feeStatus;
}

// ── Hostel outpass / leave request ─────────────────────────────────────────
class MockHostelOutpass {
  MockHostelOutpass({
    required this.id,
    required this.studentName,
    required this.studentId,
    required this.reason,
    required this.fromDate,
    required this.toDate,
    required this.status,
    this.approvedBy,
    this.parentConsentPhone,
    this.checkOutTime,
    this.expectedReturnTime,
  });

  final String id;
  final String studentName;
  final String studentId;
  final String reason; // Home visit | Medical | Family event | Other
  final DateTime fromDate;
  final DateTime toDate;
  String status; // pending | approved | rejected | completed
  String? approvedBy;
  final String? parentConsentPhone;
  DateTime? checkOutTime;
  DateTime? expectedReturnTime;
}

// ── Visitor model ──────────────────────────────────────────────────────────
class MockVisitor {
  MockVisitor({
    required this.id,
    required this.visitorName,
    required this.relationship,
    required this.phone,
    required this.studentName,
    required this.idType,
    required this.checkInTime,
    this.checkOutTime,
  });

  final String id;
  final String visitorName;
  final String relationship;
  final String phone;
  final String studentName;
  final String idType;
  final DateTime checkInTime;
  DateTime? checkOutTime;
}

// ── Admission enquiry model ────────────────────────────────────────────────
class MockAdmissionEnquiry {
  MockAdmissionEnquiry({
    required this.id,
    required this.studentName,
    required this.parentName,
    required this.phone,
    required this.classApplying,
    required this.source,
    required this.status,
    required this.aiLeadScore,
    required this.enquiryDate,
    this.email,
    this.notes,
  });

  final String id;
  final String studentName;
  final String parentName;
  final String phone;
  final String classApplying;
  final String source; // Walk-in | Online | Referral | Camp
  final String
  status; // New | Contacted | Visit Scheduled | Application Given | Converted | Lost
  final int aiLeadScore; // 0-100
  final DateTime enquiryDate;
  final String? email;
  final String? notes;
}

// ── Asset model ────────────────────────────────────────────────────────────
class MockAsset {
  MockAsset({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.location,
    required this.condition,
    required this.assignedTo,
    this.serialNo,
    this.purchaseDate,
    this.costPaise,
    this.warrantyTill,
  });

  final String id;
  final String name;
  final String
  category; // IT | Furniture | AV Equipment | Lab | Sports | Electrical
  final String brand;
  final String location;
  final String condition; // Good | Fair | Needs Repair | Condemned
  final String assignedTo;
  final String? serialNo;
  final DateTime? purchaseDate;
  final int? costPaise;
  final DateTime? warrantyTill;
}

class MockStaffLeaveRequest {
  const MockStaffLeaveRequest({
    required this.id,
    required this.staffName,
    required this.staffId,
    required this.department,
    required this.type,
    required this.fromDate,
    required this.toDate,
    required this.workingDays,
    required this.reason,
    required this.status,
  });

  final String id;
  final String staffName;
  final String staffId;
  final String department;
  final String type;
  final DateTime fromDate;
  final DateTime toDate;
  final int workingDays;
  final String reason;
  final String status; // pending | approved | rejected
}
