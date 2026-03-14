/// NammaClass complete mock dataset.
/// All data is purely static — ready to swap for real API calls.
library;

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
  });

  final String id;
  final String name;
  final String eta;
  final int studentCount;
  bool isVisited;
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

// ══════════════════════════════════════════════════════════════════════════════
// MOCK DATA SETS
// ══════════════════════════════════════════════════════════════════════════════

class MockData {
  MockData._();

  // ── 35 Students ─────────────────────────────────────────────────────────────
  static final List<MockStudent> students = [
    const MockStudent(
      id: 's01',
      name: 'Arjun Kumar',
      rollNo: '01',
      classSection: '8-A',
      attendancePercent: 0.92,
      parentName: 'Suresh Kumar',
      parentPhone: '9876543210',
      feeStatus: 'paid',
    ),
    const MockStudent(
      id: 's02',
      name: 'Bhavya Shetty',
      rollNo: '02',
      classSection: '8-A',
      attendancePercent: 0.88,
      parentName: 'Ravi Shetty',
      parentPhone: '9845001122',
      feeStatus: 'pending',
    ),
    const MockStudent(
      id: 's03',
      name: 'Chandan Rao',
      rollNo: '03',
      classSection: '8-A',
      attendancePercent: 0.95,
      parentName: 'Mohan Rao',
      parentPhone: '9900112233',
      feeStatus: 'paid',
    ),
    const MockStudent(
      id: 's04',
      name: 'Deepika Nair',
      rollNo: '04',
      classSection: '8-A',
      attendancePercent: 0.78,
      parentName: 'Anil Nair',
      parentPhone: '9812345678',
      feeStatus: 'overdue',
    ),
    const MockStudent(
      id: 's05',
      name: 'Eshan Patel',
      rollNo: '05',
      classSection: '8-A',
      attendancePercent: 0.91,
      parentName: 'Sanjay Patel',
      parentPhone: '9987654321',
      feeStatus: 'paid',
    ),
    const MockStudent(
      id: 's06',
      name: 'Fatima Sheikh',
      rollNo: '06',
      classSection: '8-A',
      attendancePercent: 0.85,
      parentName: 'Ibrahim Sheikh',
      parentPhone: '9711223344',
      feeStatus: 'paid',
    ),
    const MockStudent(
      id: 's07',
      name: 'Ganesh Hegde',
      rollNo: '07',
      classSection: '8-A',
      attendancePercent: 0.73,
      parentName: 'Vishnu Hegde',
      parentPhone: '9600112233',
      feeStatus: 'pending',
    ),
    const MockStudent(
      id: 's08',
      name: 'Harini Reddy',
      rollNo: '08',
      classSection: '8-A',
      attendancePercent: 0.97,
      parentName: 'Srikanth Reddy',
      parentPhone: '9988776655',
      feeStatus: 'paid',
    ),
    const MockStudent(
      id: 's09',
      name: 'Ishaan Joshi',
      rollNo: '09',
      classSection: '8-B',
      attendancePercent: 0.86,
      parentName: 'Prakash Joshi',
      parentPhone: '9876001122',
      feeStatus: 'paid',
    ),
    const MockStudent(
      id: 's10',
      name: 'Jaya Krishnan',
      rollNo: '10',
      classSection: '8-B',
      attendancePercent: 0.90,
      parentName: 'Krishnan Iyer',
      parentPhone: '9845123456',
      feeStatus: 'paid',
    ),
    const MockStudent(
      id: 's11',
      name: 'Karthik Gowda',
      rollNo: '11',
      classSection: '8-B',
      attendancePercent: 0.83,
      parentName: 'Nagesh Gowda',
      parentPhone: '9900223344',
      feeStatus: 'pending',
    ),
    const MockStudent(
      id: 's12',
      name: 'Lakshmi Bai',
      rollNo: '12',
      classSection: '8-B',
      attendancePercent: 0.94,
      parentName: 'Ramaiah Bai',
      parentPhone: '9800112233',
      feeStatus: 'paid',
    ),
    const MockStudent(
      id: 's13',
      name: 'Manoj Singh',
      rollNo: '13',
      classSection: '8-B',
      attendancePercent: 0.68,
      parentName: 'Ranjit Singh',
      parentPhone: '9712345678',
      feeStatus: 'overdue',
    ),
    const MockStudent(
      id: 's14',
      name: 'Nandini Rao',
      rollNo: '14',
      classSection: '8-B',
      attendancePercent: 0.89,
      parentName: 'Venkat Rao',
      parentPhone: '9611223344',
      feeStatus: 'paid',
    ),
    const MockStudent(
      id: 's15',
      name: 'Om Prakash',
      rollNo: '15',
      classSection: '9-A',
      attendancePercent: 0.92,
      parentName: 'Suresh Prakash',
      parentPhone: '9500112233',
      feeStatus: 'paid',
    ),
    const MockStudent(
      id: 's16',
      name: 'Pooja Sharma',
      rollNo: '16',
      classSection: '9-A',
      attendancePercent: 0.96,
      parentName: 'Deepak Sharma',
      parentPhone: '9988001122',
      feeStatus: 'paid',
    ),
    const MockStudent(
      id: 's17',
      name: 'Qasim Ali',
      rollNo: '17',
      classSection: '9-A',
      attendancePercent: 0.80,
      parentName: 'Saleem Ali',
      parentPhone: '9877001122',
      feeStatus: 'paid',
    ),
    const MockStudent(
      id: 's18',
      name: 'Rashmi Kulkarni',
      rollNo: '18',
      classSection: '9-A',
      attendancePercent: 0.87,
      parentName: 'Anand Kulkarni',
      parentPhone: '9766001122',
      feeStatus: 'pending',
    ),
    const MockStudent(
      id: 's19',
      name: 'Siddharth Kamath',
      rollNo: '19',
      classSection: '9-A',
      attendancePercent: 0.93,
      parentName: 'Madhu Kamath',
      parentPhone: '9655001122',
      feeStatus: 'paid',
    ),
    const MockStudent(
      id: 's20',
      name: 'Tejas Patil',
      rollNo: '20',
      classSection: '9-B',
      attendancePercent: 0.75,
      parentName: 'Vinod Patil',
      parentPhone: '9544001122',
      feeStatus: 'overdue',
    ),
    const MockStudent(
      id: 's21',
      name: 'Usha Bhat',
      rollNo: '21',
      classSection: '9-B',
      attendancePercent: 0.91,
      parentName: 'Gopal Bhat',
      parentPhone: '9433001122',
      feeStatus: 'paid',
    ),
    const MockStudent(
      id: 's22',
      name: 'Varun Menon',
      rollNo: '22',
      classSection: '9-B',
      attendancePercent: 0.88,
      parentName: 'Sunil Menon',
      parentPhone: '9322001122',
      feeStatus: 'paid',
    ),
    const MockStudent(
      id: 's23',
      name: 'Wafa Khan',
      rollNo: '23',
      classSection: '9-B',
      attendancePercent: 0.82,
      parentName: 'Rashid Khan',
      parentPhone: '9211001122',
      feeStatus: 'paid',
    ),
    const MockStudent(
      id: 's24',
      name: 'Xavier Thomas',
      rollNo: '24',
      classSection: '10-A',
      attendancePercent: 0.94,
      parentName: 'George Thomas',
      parentPhone: '9100001122',
      feeStatus: 'paid',
    ),
    const MockStudent(
      id: 's25',
      name: 'Yashodha Gowda',
      rollNo: '25',
      classSection: '10-A',
      attendancePercent: 0.76,
      parentName: 'Babu Gowda',
      parentPhone: '8999001122',
      feeStatus: 'pending',
    ),
    const MockStudent(
      id: 's26',
      name: 'Zaheer Hussain',
      rollNo: '26',
      classSection: '10-A',
      attendancePercent: 0.89,
      parentName: 'Ahmed Hussain',
      parentPhone: '8888001122',
      feeStatus: 'paid',
    ),
    const MockStudent(
      id: 's27',
      name: 'Aarav Mehta',
      rollNo: '27',
      classSection: '10-A',
      attendancePercent: 0.97,
      parentName: 'Vivek Mehta',
      parentPhone: '8777001122',
      feeStatus: 'paid',
    ),
    const MockStudent(
      id: 's28',
      name: 'Bhoomi Naik',
      rollNo: '28',
      classSection: '10-B',
      attendancePercent: 0.84,
      parentName: 'Suresh Naik',
      parentPhone: '8666001122',
      feeStatus: 'paid',
    ),
    const MockStudent(
      id: 's29',
      name: 'Chinmay Dixit',
      rollNo: '29',
      classSection: '10-B',
      attendancePercent: 0.71,
      parentName: 'Amit Dixit',
      parentPhone: '8555001122',
      feeStatus: 'overdue',
    ),
    const MockStudent(
      id: 's30',
      name: 'Devika Pillai',
      rollNo: '30',
      classSection: '10-B',
      attendancePercent: 0.93,
      parentName: 'Rajan Pillai',
      parentPhone: '8444001122',
      feeStatus: 'paid',
    ),
    const MockStudent(
      id: 's31',
      name: 'Ekalavya Mishra',
      rollNo: '31',
      classSection: '10-B',
      attendancePercent: 0.86,
      parentName: 'Rajesh Mishra',
      parentPhone: '8333001122',
      feeStatus: 'paid',
    ),
    const MockStudent(
      id: 's32',
      name: 'Falguni Desai',
      rollNo: '32',
      classSection: '7-A',
      attendancePercent: 0.90,
      parentName: 'Hitesh Desai',
      parentPhone: '8222001122',
      feeStatus: 'paid',
    ),
    const MockStudent(
      id: 's33',
      name: 'Gaurav Tiwari',
      rollNo: '33',
      classSection: '7-A',
      attendancePercent: 0.78,
      parentName: 'Rakesh Tiwari',
      parentPhone: '8111001122',
      feeStatus: 'pending',
    ),
    const MockStudent(
      id: 's34',
      name: 'Hema Laxmi',
      rollNo: '34',
      classSection: '7-A',
      attendancePercent: 0.95,
      parentName: 'Padma Laxmi',
      parentPhone: '8000001122',
      feeStatus: 'paid',
    ),
    const MockStudent(
      id: 's35',
      name: 'Ishan Wagh',
      rollNo: '35',
      classSection: '7-A',
      attendancePercent: 0.81,
      parentName: 'Sachin Wagh',
      parentPhone: '7999001122',
      feeStatus: 'paid',
    ),
  ];

  // ── Attendance (30 days) ─────────────────────────────────────────────────────
  static List<MockAttendanceDay> attendance = List.generate(30, (i) {
    final date = DateTime.now().subtract(Duration(days: 29 - i));
    final weekday = date.weekday;
    if (weekday == 7) return MockAttendanceDay(date: date, status: 'holiday');
    if (weekday == 6) return MockAttendanceDay(date: date, status: 'holiday');
    final statuses = [
      'present',
      'present',
      'present',
      'present',
      'absent',
      'leave',
    ];
    final status = statuses[i % statuses.length];
    return MockAttendanceDay(
      date: date,
      status: status,
      periods: status == 'present'
          ? [
              'Mathematics',
              'Science',
              'English',
              'Social Studies',
              'Kannada',
              'Physical Ed',
            ]
          : [],
    );
  });

  // ── Fee Installments ─────────────────────────────────────────────────────────
  static final List<MockFeeInstallment> fees = [
    MockFeeInstallment(
      id: 'fee_001',
      label: 'Term 1 — Apr-Jun',
      amountPaise: 2500000,
      dueDate: DateTime(2025, 4, 10),
      status: 'paid',
      paidDate: DateTime(2025, 4, 8),
      transactionId: 'TXN20250408001',
    ),
    MockFeeInstallment(
      id: 'fee_002',
      label: 'Term 2 — Jul-Sep',
      amountPaise: 2500000,
      dueDate: DateTime(2025, 7, 10),
      status: 'paid',
      paidDate: DateTime(2025, 7, 7),
      transactionId: 'TXN20250707002',
    ),
    MockFeeInstallment(
      id: 'fee_003',
      label: 'Term 3 — Oct-Dec',
      amountPaise: 2500000,
      dueDate: DateTime(2025, 10, 10),
      status: 'overdue',
    ),
    MockFeeInstallment(
      id: 'fee_004',
      label: 'Term 4 — Jan-Mar',
      amountPaise: 2500000,
      dueDate: DateTime(2026, 1, 10),
      status: 'pending',
    ),
  ];

  // ── Diary (7 days × 6 subjects) ──────────────────────────────────────────────
  static final List<MockDiaryEntry> diary = List.generate(42, (i) {
    final dayIndex = i ~/ 6;
    final subjectIndex = i % 6;
    final date = DateTime.now().subtract(Duration(days: 6 - dayIndex));
    final subjects = [
      'Mathematics',
      'Science',
      'English',
      'Social Studies',
      'Kannada',
      'Computer Science',
    ];
    final classworks = [
      'Chapter 5: Polynomials — completed examples 1-10',
      'Chapter 3: Photosynthesis — diagrams and notes',
      'Reading comprehension — The Last Leaf',
      'Civics: Indian Parliament structure',
      'ಅಧ್ಯಾಯ ೪: ವ್ಯಾಕರಣ ಪ್ರಶ್ನೆಗಳು',
      'Python basics: loops and conditionals',
    ];
    final homeworks = [
      'Exercises 5.1 Q1-Q10 in textbook',
      'Draw and label a plant cell',
      'Write summary of the story in 200 words',
      'Create a flow-chart of Indian law-making',
      'ಸ್ವಲ್ಪ ಪದಗಳ ಅರ್ಥ ಬರೆಯಿರಿ',
      'Write a Python program to print Fibonacci series',
    ];
    return MockDiaryEntry(
      date: date,
      subject: subjects[subjectIndex],
      classwork: classworks[subjectIndex],
      homework: homeworks[subjectIndex],
      dueDate: date.add(const Duration(days: 1)),
      hasAttachment: subjectIndex == 1 || subjectIndex == 5,
      completed: dayIndex < 4,
    );
  });

  // ── Chat Threads ─────────────────────────────────────────────────────────────
  static final List<MockChatThread> chatThreads = [
    MockChatThread(
      id: 'thread_001',
      teacherName: 'Priya Sharma',
      teacherSubject: 'Mathematics',
      lastMessage: 'Please ensure Arjun completes his assignment.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 2,
    ),
    MockChatThread(
      id: 'thread_002',
      teacherName: 'Rajesh Kumar',
      teacherSubject: 'Science',
      lastMessage: 'The science fair project submission is tomorrow.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
      unreadCount: 0,
    ),
    MockChatThread(
      id: 'thread_003',
      teacherName: 'Kavitha Menon',
      teacherSubject: 'English',
      lastMessage: 'Great work on the reading comprehension!',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
    ),
    MockChatThread(
      id: 'thread_004',
      teacherName: 'Suresh Naik',
      teacherSubject: 'Social Studies',
      lastMessage: 'Class test scheduled for Friday.',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
      unreadCount: 1,
    ),
  ];

  // ── Messages for thread_001 ───────────────────────────────────────────────────
  static final List<MockMessage> messages = [
    MockMessage(
      id: 'm01',
      senderId: 'teacher',
      text: 'Good morning! Please remind Arjun to bring his textbook tomorrow.',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 9)),
    ),
    MockMessage(
      id: 'm02',
      senderId: 'parent',
      text: 'Good morning ma\'am. Will do, thank you for informing.',
      timestamp: DateTime.now().subtract(
        const Duration(days: 1, hours: 9, minutes: 5),
      ),
    ),
    MockMessage(
      id: 'm03',
      senderId: 'teacher',
      text: 'Also, the class test for Chapter 5 is scheduled for next Monday.',
      timestamp: DateTime.now().subtract(
        const Duration(days: 1, hours: 9, minutes: 10),
      ),
    ),
    MockMessage(
      id: 'm04',
      senderId: 'parent',
      text: 'Understood. We will prepare over the weekend.',
      timestamp: DateTime.now().subtract(
        const Duration(days: 1, hours: 9, minutes: 12),
      ),
    ),
    MockMessage(
      id: 'm05',
      senderId: 'teacher',
      text: 'Please ensure Arjun completes his assignment by Thursday.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    MockMessage(
      id: 'm06',
      senderId: 'teacher',
      text: 'He has not submitted exercises 5.1 yet.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
      isRead: false,
    ),
  ];

  // ── Notices ──────────────────────────────────────────────────────────────────
  static final List<MockNotice> notices = [
    MockNotice(
      id: 'n01',
      title: 'Annual Day Celebration',
      body:
          'Annual Day will be held on March 20th at the school auditorium. All students are requested to attend in formal uniform.',
      date: DateTime.now().subtract(const Duration(hours: 3)),
      category: 'Events',
      isRead: false,
    ),
    MockNotice(
      id: 'n02',
      title: 'Parent-Teacher Meeting',
      body:
          'PTM scheduled for Saturday, March 8th from 10 AM to 1 PM. All parents are requested to attend.',
      date: DateTime.now().subtract(const Duration(hours: 8)),
      category: 'Academic',
      isRead: false,
      hasAttachment: true,
    ),
    MockNotice(
      id: 'n03',
      title: 'Holiday Notification — Holi',
      body:
          'School will remain closed on March 14th on account of Holi. Classes will resume on March 17th.',
      date: DateTime.now().subtract(const Duration(days: 1)),
      category: 'Holiday',
      isRead: true,
    ),
    MockNotice(
      id: 'n04',
      title: 'Sports Day Registration',
      body:
          'Students interested in participating in sports events must register by March 10th. Contact the sports teacher for details.',
      date: DateTime.now().subtract(const Duration(days: 2)),
      category: 'Events',
      isRead: true,
    ),
    MockNotice(
      id: 'n05',
      title: 'Term 3 Fee Reminder',
      body:
          'Term 3 fees are overdue. Please clear the dues by March 15th to avoid late charges.',
      date: DateTime.now().subtract(const Duration(days: 3)),
      category: 'Finance',
      isRead: false,
      hasAttachment: false,
    ),
    MockNotice(
      id: 'n06',
      title: 'Science Exhibition',
      body:
          'Inter-school science exhibition on March 25th. Top projects from each class will be selected.',
      date: DateTime.now().subtract(const Duration(days: 4)),
      category: 'Academic',
      isRead: true,
      hasAttachment: true,
    ),
    MockNotice(
      id: 'n07',
      title: 'New Library Books',
      body:
          '50 new books have been added to the library across various genres. Students can borrow from Monday.',
      date: DateTime.now().subtract(const Duration(days: 5)),
      category: 'Library',
      isRead: true,
    ),
    MockNotice(
      id: 'n08',
      title: 'Exam Schedule Released',
      body:
          'Final term examination schedule has been released. Please check the academic portal for details.',
      date: DateTime.now().subtract(const Duration(days: 7)),
      category: 'Academic',
      isRead: true,
      hasAttachment: true,
    ),
  ];

  // ── Timetable (5 days × 8 periods) ───────────────────────────────────────────
  static final Map<String, List<MockPeriod>> timetable = {
    'Monday': [
      const MockPeriod(
        period: 1,
        subject: 'Mathematics',
        teacher: 'Priya Sharma',
        startTime: '08:00',
        endTime: '08:45',
      ),
      const MockPeriod(
        period: 2,
        subject: 'English',
        teacher: 'Kavitha Menon',
        startTime: '08:45',
        endTime: '09:30',
      ),
      const MockPeriod(
        period: 3,
        subject: 'Science',
        teacher: 'Rajesh Kumar',
        startTime: '09:45',
        endTime: '10:30',
      ),
      const MockPeriod(
        period: 4,
        subject: 'Social Studies',
        teacher: 'Suresh Naik',
        startTime: '10:30',
        endTime: '11:15',
      ),
      const MockPeriod(
        period: 5,
        subject: 'Kannada',
        teacher: 'Usha Devi',
        startTime: '11:30',
        endTime: '12:15',
      ),
      const MockPeriod(
        period: 6,
        subject: 'Computer Science',
        teacher: 'Anand Rao',
        startTime: '12:15',
        endTime: '13:00',
      ),
      const MockPeriod(
        period: 7,
        subject: 'Physical Ed',
        teacher: 'Mohan Raj',
        startTime: '14:00',
        endTime: '14:45',
      ),
      const MockPeriod(
        period: 8,
        subject: 'Art & Craft',
        teacher: 'Lakshmi Bhat',
        startTime: '14:45',
        endTime: '15:30',
      ),
    ],
    'Tuesday': [
      const MockPeriod(
        period: 1,
        subject: 'Science',
        teacher: 'Rajesh Kumar',
        startTime: '08:00',
        endTime: '08:45',
      ),
      const MockPeriod(
        period: 2,
        subject: 'Mathematics',
        teacher: 'Priya Sharma',
        startTime: '08:45',
        endTime: '09:30',
      ),
      const MockPeriod(
        period: 3,
        subject: 'Kannada',
        teacher: 'Usha Devi',
        startTime: '09:45',
        endTime: '10:30',
      ),
      const MockPeriod(
        period: 4,
        subject: 'English',
        teacher: 'Kavitha Menon',
        startTime: '10:30',
        endTime: '11:15',
      ),
      const MockPeriod(
        period: 5,
        subject: 'Computer Science',
        teacher: 'Anand Rao',
        startTime: '11:30',
        endTime: '12:15',
      ),
      const MockPeriod(
        period: 6,
        subject: 'Social Studies',
        teacher: 'Suresh Naik',
        startTime: '12:15',
        endTime: '13:00',
      ),
      const MockPeriod(
        period: 7,
        subject: 'Music',
        teacher: 'Veena Shetty',
        startTime: '14:00',
        endTime: '14:45',
      ),
      const MockPeriod(
        period: 8,
        subject: 'Library',
        teacher: 'Shylaja M',
        startTime: '14:45',
        endTime: '15:30',
      ),
    ],
    'Wednesday': [
      const MockPeriod(
        period: 1,
        subject: 'English',
        teacher: 'Kavitha Menon',
        startTime: '08:00',
        endTime: '08:45',
      ),
      const MockPeriod(
        period: 2,
        subject: 'Social Studies',
        teacher: 'Suresh Naik',
        startTime: '08:45',
        endTime: '09:30',
      ),
      const MockPeriod(
        period: 3,
        subject: 'Mathematics',
        teacher: 'Priya Sharma',
        startTime: '09:45',
        endTime: '10:30',
      ),
      const MockPeriod(
        period: 4,
        subject: 'Science Lab',
        teacher: 'Rajesh Kumar',
        startTime: '10:30',
        endTime: '12:00',
      ),
      const MockPeriod(
        period: 5,
        subject: 'Kannada',
        teacher: 'Usha Devi',
        startTime: '12:00',
        endTime: '12:45',
      ),
      const MockPeriod(
        period: 6,
        subject: 'Physical Ed',
        teacher: 'Mohan Raj',
        startTime: '14:00',
        endTime: '15:30',
      ),
    ],
    'Thursday': [
      const MockPeriod(
        period: 1,
        subject: 'Kannada',
        teacher: 'Usha Devi',
        startTime: '08:00',
        endTime: '08:45',
      ),
      const MockPeriod(
        period: 2,
        subject: 'Computer Science',
        teacher: 'Anand Rao',
        startTime: '08:45',
        endTime: '09:30',
      ),
      const MockPeriod(
        period: 3,
        subject: 'English',
        teacher: 'Kavitha Menon',
        startTime: '09:45',
        endTime: '10:30',
      ),
      const MockPeriod(
        period: 4,
        subject: 'Mathematics',
        teacher: 'Priya Sharma',
        startTime: '10:30',
        endTime: '11:15',
      ),
      const MockPeriod(
        period: 5,
        subject: 'Science',
        teacher: 'Rajesh Kumar',
        startTime: '11:30',
        endTime: '12:15',
      ),
      const MockPeriod(
        period: 6,
        subject: 'Social Studies',
        teacher: 'Suresh Naik',
        startTime: '12:15',
        endTime: '13:00',
      ),
      const MockPeriod(
        period: 7,
        subject: 'Art & Craft',
        teacher: 'Lakshmi Bhat',
        startTime: '14:00',
        endTime: '14:45',
      ),
      const MockPeriod(
        period: 8,
        subject: 'Music',
        teacher: 'Veena Shetty',
        startTime: '14:45',
        endTime: '15:30',
      ),
    ],
    'Friday': [
      const MockPeriod(
        period: 1,
        subject: 'Social Studies',
        teacher: 'Suresh Naik',
        startTime: '08:00',
        endTime: '08:45',
      ),
      const MockPeriod(
        period: 2,
        subject: 'Science',
        teacher: 'Rajesh Kumar',
        startTime: '08:45',
        endTime: '09:30',
      ),
      const MockPeriod(
        period: 3,
        subject: 'Kannada',
        teacher: 'Usha Devi',
        startTime: '09:45',
        endTime: '10:30',
      ),
      const MockPeriod(
        period: 4,
        subject: 'Computer Science',
        teacher: 'Anand Rao',
        startTime: '10:30',
        endTime: '11:15',
      ),
      const MockPeriod(
        period: 5,
        subject: 'Mathematics',
        teacher: 'Priya Sharma',
        startTime: '11:30',
        endTime: '12:15',
      ),
      const MockPeriod(
        period: 6,
        subject: 'English',
        teacher: 'Kavitha Menon',
        startTime: '12:15',
        endTime: '13:00',
      ),
      const MockPeriod(
        period: 7,
        subject: 'Physical Ed',
        teacher: 'Mohan Raj',
        startTime: '14:00',
        endTime: '15:30',
      ),
    ],
  };

  // ── 30 Library Books ─────────────────────────────────────────────────────────
  static const List<MockBook> books = [
    MockBook(
      id: 'b01',
      title: 'The Alchemist',
      author: 'Paulo Coelho',
      category: 'Fiction',
      available: true,
      accessionCode: 'ACC-0108',
    ),
    MockBook(
      id: 'b02',
      title: 'Wings of Fire',
      author: 'A. P. J. Abdul Kalam',
      category: 'Biography',
      available: false,
      issuedTo: 'Arjun Kumar',
      accessionCode: 'ACC-0042',
    ),
    MockBook(
      id: 'b03',
      title: 'Rich Dad Poor Dad',
      author: 'Robert Kiyosaki',
      category: 'Finance',
      available: true,
    ),
    MockBook(
      id: 'b04',
      title: 'Harry Potter & Sorcerer\'s Stone',
      author: 'J. K. Rowling',
      category: 'Fiction',
      available: false,
      issuedTo: 'Bhavya Shetty',
    ),
    MockBook(
      id: 'b05',
      title: 'Sapiens',
      author: 'Yuval Noah Harari',
      category: 'History',
      available: true,
    ),
    MockBook(
      id: 'b06',
      title: 'Ramayana',
      author: 'Valmiki',
      category: 'Mythology',
      available: true,
    ),
    MockBook(
      id: 'b07',
      title: 'Mahabharata Stories',
      author: 'C. Rajagopalachari',
      category: 'Mythology',
      available: false,
      issuedTo: 'Chandan Rao',
    ),
    MockBook(
      id: 'b08',
      title: 'Think and Grow Rich',
      author: 'Napoleon Hill',
      category: 'Self-Help',
      available: true,
    ),
    MockBook(
      id: 'b09',
      title: 'The Jungle Book',
      author: 'Rudyard Kipling',
      category: 'Fiction',
      available: true,
    ),
    MockBook(
      id: 'b10',
      title: 'India After Gandhi',
      author: 'Ramachandra Guha',
      category: 'History',
      available: true,
    ),
    MockBook(
      id: 'b11',
      title: 'Malgudi Days',
      author: 'R. K. Narayan',
      category: 'Fiction',
      available: false,
      issuedTo: 'Harini Reddy',
    ),
    MockBook(
      id: 'b12',
      title: 'The Discovery of India',
      author: 'Jawaharlal Nehru',
      category: 'History',
      available: true,
    ),
    MockBook(
      id: 'b13',
      title: 'The Monk Who Sold His Ferrari',
      author: 'Robin Sharma',
      category: 'Self-Help',
      available: true,
    ),
    MockBook(
      id: 'b14',
      title: 'Panchatantra',
      author: 'Vishnu Sharma',
      category: 'Mythology',
      available: true,
    ),
    MockBook(
      id: 'b15',
      title: 'Adventures of Tom Sawyer',
      author: 'Mark Twain',
      category: 'Fiction',
      available: false,
      issuedTo: 'Deepika Nair',
    ),
    MockBook(
      id: 'b16',
      title: 'Brief History of Time',
      author: 'Stephen Hawking',
      category: 'Science',
      available: true,
    ),
    MockBook(
      id: 'b17',
      title: 'My Experiments with Truth',
      author: 'M. K. Gandhi',
      category: 'Biography',
      available: true,
    ),
    MockBook(
      id: 'b18',
      title: 'The Power of Now',
      author: 'Eckhart Tolle',
      category: 'Self-Help',
      available: true,
    ),
    MockBook(
      id: 'b19',
      title: 'Charlotte\'s Web',
      author: 'E. B. White',
      category: 'Fiction',
      available: true,
    ),
    MockBook(
      id: 'b20',
      title: 'The Kite Runner',
      author: 'Khaled Hosseini',
      category: 'Fiction',
      available: false,
      issuedTo: 'Pooja Sharma',
    ),
    MockBook(
      id: 'b21',
      title: 'Cosmos',
      author: 'Carl Sagan',
      category: 'Science',
      available: true,
    ),
    MockBook(
      id: 'b22',
      title: 'Swami and Friends',
      author: 'R. K. Narayan',
      category: 'Fiction',
      available: true,
    ),
    MockBook(
      id: 'b23',
      title: 'The Secret',
      author: 'Rhonda Byrne',
      category: 'Self-Help',
      available: false,
      issuedTo: 'Ishaan Joshi',
    ),
    MockBook(
      id: 'b24',
      title: 'Chanakya Neeti',
      author: 'Chanakya',
      category: 'Philosophy',
      available: true,
    ),
    MockBook(
      id: 'b25',
      title: 'The Gita As It Is',
      author: 'A. C. Bhaktivedanta',
      category: 'Philosophy',
      available: true,
    ),
    MockBook(
      id: 'b26',
      title: 'Origin of Species',
      author: 'Charles Darwin',
      category: 'Science',
      available: true,
    ),
    MockBook(
      id: 'b27',
      title: 'Robin Hood',
      author: 'Howard Pyle',
      category: 'Fiction',
      available: false,
      issuedTo: 'Karthik Gowda',
    ),
    MockBook(
      id: 'b28',
      title: 'Mathematics NCERT Class 10',
      author: 'NCERT',
      category: 'Textbook',
      available: true,
    ),
    MockBook(
      id: 'b29',
      title: 'Science NCERT Class 9',
      author: 'NCERT',
      category: 'Textbook',
      available: true,
    ),
    MockBook(
      id: 'b30',
      title: 'Encyclopedia of India',
      author: 'Stanley Wolpert',
      category: 'Reference',
      available: true,
    ),
  ];

  // ── 20 Staff Members ─────────────────────────────────────────────────────────
  static final List<MockStaffMember> staff = [
    MockStaffMember(
      id: 'st01',
      name: 'Priya Sharma',
      role: 'Teacher',
      department: 'Mathematics',
      phone: '9845012345',
      email: 'priya@vidyashree.edu.in',
      salaryCTC: 600000,
    ),
    MockStaffMember(
      id: 'st02',
      name: 'Rajesh Kumar',
      role: 'Teacher',
      department: 'Science',
      phone: '9845023456',
      email: 'rajesh@vidyashree.edu.in',
      salaryCTC: 550000,
    ),
    MockStaffMember(
      id: 'st03',
      name: 'Kavitha Menon',
      role: 'Teacher',
      department: 'English',
      phone: '9845034567',
      email: 'kavitha@vidyashree.edu.in',
      salaryCTC: 580000,
    ),
    MockStaffMember(
      id: 'st04',
      name: 'Suresh Naik',
      role: 'Teacher',
      department: 'Social Studies',
      phone: '9845045678',
      email: 'sureshn@vidyashree.edu.in',
      salaryCTC: 520000,
    ),
    MockStaffMember(
      id: 'st05',
      name: 'Usha Devi',
      role: 'Teacher',
      department: 'Kannada',
      phone: '9845056789',
      email: 'usha@vidyashree.edu.in',
      salaryCTC: 500000,
    ),
    MockStaffMember(
      id: 'st06',
      name: 'Anand Rao',
      role: 'Teacher',
      department: 'Computer Science',
      phone: '9845067890',
      email: 'anand@vidyashree.edu.in',
      salaryCTC: 620000,
    ),
    MockStaffMember(
      id: 'st07',
      name: 'Mohan Raj',
      role: 'Teacher',
      department: 'Physical Ed',
      phone: '9845078901',
      email: 'mohan@vidyashree.edu.in',
      salaryCTC: 480000,
    ),
    MockStaffMember(
      id: 'st08',
      name: 'Lakshmi Bhat',
      role: 'Teacher',
      department: 'Art & Craft',
      phone: '9845089012',
      email: 'lakshmi@vidyashree.edu.in',
      salaryCTC: 460000,
    ),
    MockStaffMember(
      id: 'st09',
      name: 'Veena Shetty',
      role: 'Teacher',
      department: 'Music',
      phone: '9845090123',
      email: 'veena@vidyashree.edu.in',
      salaryCTC: 470000,
    ),
    MockStaffMember(
      id: 'st10',
      name: 'Shylaja M',
      role: 'Librarian',
      department: 'Library',
      phone: '9845101234',
      email: 'shylaja@vidyashree.edu.in',
      salaryCTC: 440000,
    ),
    MockStaffMember(
      id: 'st11',
      name: 'Ramesh Naik',
      role: 'Admin',
      department: 'Administration',
      phone: '9880001111',
      email: 'admin@vidyashree.edu.in',
      salaryCTC: 800000,
    ),
    MockStaffMember(
      id: 'st12',
      name: 'Sunita Kamath',
      role: 'Accountant',
      department: 'Finance',
      phone: '9845112345',
      email: 'sunita@vidyashree.edu.in',
      salaryCTC: 540000,
    ),
    MockStaffMember(
      id: 'st13',
      name: 'Ravi Narayanan',
      role: 'Driver',
      department: 'Transport',
      phone: '9845123456',
      salaryCTC: 360000,
    ),
    MockStaffMember(
      id: 'st14',
      name: 'Murugan P',
      role: 'Driver',
      department: 'Transport',
      phone: '9845134567',
      salaryCTC: 360000,
    ),
    MockStaffMember(
      id: 'st15',
      name: 'Shantha Bai',
      role: 'Support Staff',
      department: 'Housekeeping',
      phone: '9845145678',
      salaryCTC: 300000,
    ),
    MockStaffMember(
      id: 'st16',
      name: 'Prakash D',
      role: 'Security',
      department: 'Security',
      phone: '9845156789',
      salaryCTC: 320000,
    ),
    MockStaffMember(
      id: 'st17',
      name: 'Leela Rani',
      role: 'Canteen Operator',
      department: 'Canteen',
      phone: '9845167890',
      salaryCTC: 350000,
    ),
    MockStaffMember(
      id: 'st18',
      name: 'Devraj Hostel',
      role: 'Hostel Warden',
      department: 'Hostel',
      phone: '9845178901',
      salaryCTC: 420000,
    ),
    MockStaffMember(
      id: 'st19',
      name: 'Asha Nurse',
      role: 'Medical Staff',
      department: 'Health',
      phone: '9845189012',
      salaryCTC: 380000,
    ),
    MockStaffMember(
      id: 'st20',
      name: 'Balu Technician',
      role: 'IT Support',
      department: 'IT',
      phone: '9845190123',
      salaryCTC: 480000,
    ),
  ];

  // ── Canteen Menu ──────────────────────────────────────────────────────────────
  static const List<MockCanteenItem> canteenMenu = [
    MockCanteenItem(
      id: 'c01',
      name: 'Idli Sambar (2 pcs)',
      category: 'Breakfast',
      pricePaise: 3000,
      isVeg: true,
    ),
    MockCanteenItem(
      id: 'c02',
      name: 'Masala Dosa',
      category: 'Breakfast',
      pricePaise: 4000,
      isVeg: true,
    ),
    MockCanteenItem(
      id: 'c03',
      name: 'Bread Omelette',
      category: 'Breakfast',
      pricePaise: 3500,
      isVeg: false,
      allergens: ['eggs'],
    ),
    MockCanteenItem(
      id: 'c04',
      name: 'Poha',
      category: 'Breakfast',
      pricePaise: 2500,
      isVeg: true,
    ),
    MockCanteenItem(
      id: 'c05',
      name: 'Veg Rice Plate',
      category: 'Lunch',
      pricePaise: 6000,
      isVeg: true,
    ),
    MockCanteenItem(
      id: 'c06',
      name: 'Chapati Dal',
      category: 'Lunch',
      pricePaise: 5000,
      isVeg: true,
    ),
    MockCanteenItem(
      id: 'c07',
      name: 'Chicken Biryani',
      category: 'Lunch',
      pricePaise: 8000,
      isVeg: false,
      allergens: ['nuts'],
    ),
    MockCanteenItem(
      id: 'c08',
      name: 'Veg Pulao',
      category: 'Lunch',
      pricePaise: 5500,
      isVeg: true,
    ),
    MockCanteenItem(
      id: 'c09',
      name: 'Vada Pav',
      category: 'Snacks',
      pricePaise: 2000,
      isVeg: true,
    ),
    MockCanteenItem(
      id: 'c10',
      name: 'Samosa (2 pcs)',
      category: 'Snacks',
      pricePaise: 2500,
      isVeg: true,
    ),
    MockCanteenItem(
      id: 'c11',
      name: 'Cold Coffee',
      category: 'Beverages',
      pricePaise: 3000,
      isVeg: true,
      allergens: ['milk'],
    ),
    MockCanteenItem(
      id: 'c12',
      name: 'Fresh Lime Soda',
      category: 'Beverages',
      pricePaise: 2000,
      isVeg: true,
    ),
  ];

  // ── Canteen combos, subscriptions, wallets, orders ─────────────────────────
  static final List<MockCanteenCombo> canteenCombos = [
    const MockCanteenCombo(
      id: 'combo1',
      name: 'Breakfast Combo',
      itemIds: ['c01', 'c11'],
      pricePaise: 5000,
      description: 'Idli Sambar + Cold Coffee',
      isVeg: true,
    ),
    const MockCanteenCombo(
      id: 'combo2',
      name: 'Lunch Special',
      itemIds: ['c05', 'c06', 'c12'],
      pricePaise: 12000,
      description: 'Veg Rice + 2 Chapati Dal + Lime Soda',
      isVeg: true,
    ),
    const MockCanteenCombo(
      id: 'combo3',
      name: 'Snacks Deal',
      itemIds: ['c09', 'c10', 'c11'],
      pricePaise: 6000,
      description: 'Vada Pav + Samosa + Cold Coffee',
      isVeg: true,
    ),
  ];

  static const List<MockCanteenSubscriptionPlan> canteenSubscriptionPlans = [
    MockCanteenSubscriptionPlan(
      id: 'sub_veg',
      name: 'Veg Monthly',
      type: 'veg',
      pricePaise: 450000,
      durationDays: 30,
      forStudent: true,
      forStaff: true,
      description: 'Unlimited veg lunch Mon–Sat',
    ),
    MockCanteenSubscriptionPlan(
      id: 'sub_nonveg',
      name: 'Non-Veg Monthly',
      type: 'nonveg',
      pricePaise: 600000,
      durationDays: 30,
      forStudent: true,
      forStaff: true,
      description: 'Unlimited non-veg lunch Mon–Sat',
    ),
  ];

  static final List<MockCampusWallet> campusWallets = [
    MockCampusWallet(
      personId: 's01',
      personName: 'Arjun Kumar',
      balancePaise: 35000,
    ),
    MockCampusWallet(
      personId: 'usr_student_001',
      personName: 'Arjun Kumar',
      balancePaise: 35000,
    ),
    MockCampusWallet(
      personId: 'usr_staff_001',
      personName: 'Rajesh Gowda',
      balancePaise: 50000,
    ),
    MockCampusWallet(
      personId: 'usr_parent_001',
      personName: 'Suresh Kumar',
      balancePaise: 25000,
    ),
  ];

  static final List<MockCanteenSubscription> canteenSubscriptions = [
    MockCanteenSubscription(
      id: 'act1',
      personId: 's01',
      personName: 'Arjun Kumar',
      planId: 'sub_veg',
      planName: 'Veg Monthly',
      type: 'veg',
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      endDate: DateTime.now().add(const Duration(days: 20)),
      status: 'active',
    ),
  ];

  static final List<MockCanteenOrder> canteenOrders = [
    MockCanteenOrder(
      id: 'ord1',
      personId: 's01',
      personName: 'Arjun Kumar',
      items: const [
        MockCanteenOrderItem(
          itemId: 'c01',
          name: 'Idli Sambar (2 pcs)',
          qty: 2,
          pricePaise: 3000,
        ),
      ],
      totalPaise: 6000,
      paymentStatus: 'paid',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  static final List<MockCanteenTransaction> canteenTransactions = [
    MockCanteenTransaction(
      id: 'tx1',
      personId: 's01',
      amountPaise: 50000,
      type: 'topup',
      description: 'Wallet top-up',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  // ── KPI summary for dashboard ─────────────────────────────────────────────────
  static const Map<String, dynamic> dashboardKpis = {
    'totalStudents': 1248,
    'totalStaff': 87,
    'presentToday': 1156,
    'absentToday': 92,
    'attendancePercent': 92.6,
    'feesCollectedPaise': 48500000,
    'feesPendingPaise': 12500000,
    'feesCollectedPercent': 79.5,
    'pendingApprovals': 7,
    'unreadNotices': 3,
    'activeBuses': 6,
    'newAdmissions': 23,
  };

  // ── Bus tracking ─────────────────────────────────────────────────────────────
  static const Map<String, dynamic> busInfo = {
    'busNumber': 'KA-01-MH-2345',
    'route': 'Route 3 — Jayanagar',
    'driverName': 'Ravi Narayanan',
    'driverPhone': '9845123456',
    'etaMinutes': 8,
    'lastStop': 'Jayanagar 4th Block',
    'nextStop': 'Vidyashree School Gate',
    'studentsOnboard': 34,
  };

  // ── Leave applications ────────────────────────────────────────────────────
  static final List<MockLeaveApplication> leaveApplications = [
    MockLeaveApplication(
      id: 'lv001',
      childName: 'Arjun Kumar',
      type: 'Sick Leave',
      fromDate: DateTime.now().subtract(const Duration(days: 5)),
      toDate: DateTime.now().subtract(const Duration(days: 4)),
      workingDays: 2,
      reason: 'High fever and doctor advised rest for 2 days.',
      status: 'approved',
      approvedBy: 'Ms. Priya Sharma',
    ),
    MockLeaveApplication(
      id: 'lv002',
      childName: 'Arjun Kumar',
      type: 'Casual Leave',
      fromDate: DateTime.now().add(const Duration(days: 3)),
      toDate: DateTime.now().add(const Duration(days: 5)),
      workingDays: 3,
      reason: 'Family function — attending cousin\'s wedding.',
      status: 'pending',
    ),
    MockLeaveApplication(
      id: 'lv003',
      childName: 'Arjun Kumar',
      type: 'Half Day',
      fromDate: DateTime.now().subtract(const Duration(days: 10)),
      toDate: DateTime.now().subtract(const Duration(days: 10)),
      workingDays: 1,
      reason: 'Dental appointment in the afternoon.',
      status: 'rejected',
      rejectionReason:
          'Exam was scheduled that afternoon. Please reschedule appointment.',
    ),
  ];

  static const Map<String, int> leaveBalance = {
    'CL': 8,
    'SL': 5,
    'EL': 12,
    'Total Used': 4,
  };

  // ── Complaints ────────────────────────────────────────────────────────────
  static final List<MockComplaint> complaints = [
    MockComplaint(
      ticketId: 'NC-2026-0042',
      category: 'Transport',
      subject: 'Bus arrives 20 minutes late every day',
      description:
          'The Route 3 bus (KA-01-MH-2345) has been consistently arriving 20–25 minutes late for the past week, causing my daughter to miss the first period.',
      priority: 'High',
      status: 'In Progress',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      responses: [
        MockComplaintResponse(
          sender: 'Admin',
          message:
              'Thank you for reporting this. We have escalated to the transport team and are investigating the route timing.',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          isAdmin: true,
        ),
      ],
    ),
    MockComplaint(
      ticketId: 'NC-2026-0031',
      category: 'Infrastructure',
      subject: 'Water cooler on 2nd floor not working',
      description:
          'The drinking water cooler near Class 8 section has not been working for over a week.',
      priority: 'Medium',
      status: 'Resolved',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      responses: [
        MockComplaintResponse(
          sender: 'Facilities Team',
          message:
              'The cooler has been repaired and is now functional. Apologies for the inconvenience.',
          timestamp: DateTime.now().subtract(const Duration(days: 8)),
          isAdmin: true,
        ),
      ],
    ),
  ];

  // ── Support tickets ──────────────────────────────────────────────────────
  static final List<MockSupportTicket> supportTickets = [
    MockSupportTicket(
      id: 'TKT-001',
      subject: 'Parent portal login issues',
      status: 'open',
      priority: 'high',
      category: 'Technical',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      assignee: 'Kiran Shetty',
      description:
          'Several parents reported unable to login to the parent portal.',
    ),
    MockSupportTicket(
      id: 'TKT-002',
      subject: 'Fee receipt not generated',
      status: 'in_progress',
      priority: 'medium',
      category: 'Finance',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      assignee: 'Kiran Shetty',
      description: 'Payment completed but receipt was not emailed.',
    ),
    MockSupportTicket(
      id: 'TKT-003',
      subject: 'Bus route change request',
      status: 'awaiting_response',
      priority: 'low',
      category: 'Transport',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      description: 'Request to add a stop near Green Park colony.',
    ),
    MockSupportTicket(
      id: 'TKT-004',
      subject: 'Attendance marked incorrectly',
      status: 'resolved',
      priority: 'high',
      category: 'Academic',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      assignee: 'Kiran Shetty',
      description: 'Student was present but marked absent on 12th March.',
    ),
  ];

  // ── Knowledge base articles ──────────────────────────────────────────────
  static final List<MockKbArticle> kbArticles = [
    const MockKbArticle(
      id: 'kb001',
      title: 'How to reset parent portal password',
      category: 'Account & Login',
      excerpt:
          'Step-by-step guide to reset your password if you have forgotten it.',
      body:
          '1. Go to the login page and tap "Forgot Password".\n2. Enter your registered mobile number.\n3. You will receive an OTP. Enter it to verify.\n4. Set a new password (min 8 characters).\n5. Log in with the new password.',
    ),
    const MockKbArticle(
      id: 'kb002',
      title: 'Understanding fee installments',
      category: 'Fees',
      excerpt: 'How fee installments work and when payments are due.',
      body:
          'Fees are divided into 3–4 installments per academic year.\nEach installment has a due date. Late fees may apply after 7 days.\nYou can pay via the app (UPI/Card) or at the school counter.\nReceipts are generated automatically and sent via email.',
    ),
    const MockKbArticle(
      id: 'kb003',
      title: 'Bus tracking and route info',
      category: 'Transport',
      excerpt: 'Track your child\'s bus and view route details.',
      body:
          'Live tracking is available during school hours.\nGo to Bus in the bottom nav and select your child\'s route.\nYou can see estimated arrival time and bus location.\nFor route change requests, raise a complaint from the app.',
    ),
  ];

  // ── Events / School Calendar ──────────────────────────────────────────────
  static final List<MockEvent> events = [
    MockEvent(
      id: 'ev001',
      title: 'Annual Sports Day',
      date: DateTime.now().add(const Duration(days: 7)),
      type: 'sports',
      description:
          'The annual inter-house sports competition. All parents are invited to attend.',
      venue: 'School Ground',
      requiresRsvp: true,
      rsvpCount: 142,
    ),
    MockEvent(
      id: 'ev002',
      title: 'Parent-Teacher Meeting — Term 2',
      date: DateTime.now().add(const Duration(days: 14)),
      type: 'pta',
      description:
          'Term 2 PTA meeting. Discuss academic progress with your child\'s teachers.',
      venue: 'School Auditorium',
      requiresRsvp: true,
      rsvpCount: 89,
    ),
    MockEvent(
      id: 'ev003',
      title: 'Republic Day — School Holiday',
      date: DateTime.now().add(const Duration(days: 21)),
      type: 'holiday',
      description: 'Republic Day national holiday.',
      venue: '',
      requiresRsvp: false,
      rsvpCount: 0,
    ),
    MockEvent(
      id: 'ev004',
      title: 'Science Exhibition',
      date: DateTime.now().add(const Duration(days: 28)),
      type: 'academic',
      description: 'Students showcase science projects. Open to all parents.',
      venue: 'School Hall',
      requiresRsvp: false,
      rsvpCount: 0,
    ),
    MockEvent(
      id: 'ev005',
      title: 'Holi Celebration',
      date: DateTime.now().add(const Duration(days: 35)),
      type: 'cultural',
      description: 'School Holi celebration — dry colours only.',
      venue: 'School Ground',
      requiresRsvp: false,
      rsvpCount: 0,
    ),
  ];

  // ── Staff attendance ──────────────────────────────────────────────────────
  static final List<MockStaffAttendanceDay> staffAttendance = List.generate(
    30,
    (i) {
      final date = DateTime.now().subtract(Duration(days: 29 - i));
      final weekday = date.weekday;
      if (weekday == DateTime.sunday) {
        return MockStaffAttendanceDay(date: date, status: 'holiday');
      }
      final statuses = [
        'present',
        'present',
        'present',
        'present',
        'leave',
        'half_day',
      ];
      return MockStaffAttendanceDay(
        date: date,
        status: statuses[i % statuses.length],
        checkInTime: '08:32 AM',
        checkOutTime: '04:45 PM',
        isWithinGeofence: true,
        employeeId: 'EMP_2031',
      );
    },
  );

  // ── Payslips ──────────────────────────────────────────────────────────────
  static final List<MockPayslip> payslips = [
    MockPayslip(
      id: 'ps_mar_2026',
      month: 'March 2026',
      basicPaise: 4500000,
      employeeId: 'EMP_2031',
      hraPaise: 1800000,
      daPaise: 450000,
      allowancesPaise: 500000,
      pfDeductionPaise: 540000,
      esiDeductionPaise: 157500,
      tdsDeductionPaise: 225000,
      status: 'Generated',
    ),
    MockPayslip(
      id: 'ps_feb_2026',
      month: 'February 2026',
      basicPaise: 4500000,
      employeeId: 'EMP_2031',
      hraPaise: 1800000,
      daPaise: 450000,
      allowancesPaise: 500000,
      pfDeductionPaise: 540000,
      esiDeductionPaise: 157500,
      tdsDeductionPaise: 225000,
      status: 'Generated',
    ),
    MockPayslip(
      id: 'ps_jan_2026',
      month: 'January 2026',
      basicPaise: 4500000,
      employeeId: 'EMP_2031',
      hraPaise: 1800000,
      daPaise: 450000,
      allowancesPaise: 500000,
      pfDeductionPaise: 540000,
      esiDeductionPaise: 157500,
      tdsDeductionPaise: 225000,
      status: 'Generated',
    ),
  ];

  // ── Training records ──────────────────────────────────────────────────────
  static final List<MockTraining> trainings = [
    MockTraining(
      id: 'tr001',
      title: 'NEP 2020 Implementation Workshop',
      provider: 'CBSE Training Centre',
      date: DateTime.now().add(const Duration(days: 5)),
      hours: 6,
      venue: 'Regional Institute, Bengaluru',
      isCompleted: false,
      employeeId: 'EMP_2031',
    ),
    MockTraining(
      id: 'tr002',
      title: 'Digital Classroom Tools',
      provider: 'EdTech India Pvt. Ltd.',
      date: DateTime.now().subtract(const Duration(days: 30)),
      hours: 4,
      venue: 'Online (Zoom)',
      isCompleted: true,
      certificateUrl: 'https://cert.example.com/tr002',
      employeeId: 'EMP_2031',
    ),
    MockTraining(
      id: 'tr003',
      title: 'Child Safety & POCSO Awareness',
      provider: 'School Management',
      date: DateTime.now().subtract(const Duration(days: 60)),
      hours: 3,
      venue: 'School Auditorium',
      isCompleted: true,
      employeeId: 'EMP_2031',
    ),
  ];

  // ── Driver: stop → students (for boarding screen) ─────────────────────────
  static final Map<String, List<String>> driverStopStudents = {
    'Jayanagar 4th Block': [
      'Arjun Kumar',
      'Preethi Nair',
      'Kiran Rao',
      'Anjali Singh',
    ],
    'BTM Layout 2nd Stage': ['Ravi Shankar', 'Mohan Das', 'Sunil Kumar'],
    'Koramangala 5th Block': ['Deepa Raj', 'Vikram Shetty', 'Lakshmi Bai'],
  };

  // ── Bus stops for driver ──────────────────────────────────────────────────
  static final List<MockBusStop> busStops = [
    MockBusStop(
      id: 'bs01',
      name: 'Jayanagar 4th Block',
      eta: '7:45 AM',
      studentCount: 4,
      isVisited: true,
    ),
    MockBusStop(
      id: 'bs02',
      name: 'BTM Layout 2nd Stage',
      eta: '7:55 AM',
      studentCount: 6,
      isVisited: true,
    ),
    MockBusStop(
      id: 'bs03',
      name: 'Koramangala 5th Block',
      eta: '8:05 AM',
      studentCount: 3,
      isVisited: false,
    ),
    MockBusStop(
      id: 'bs04',
      name: 'HSR Layout Sector 2',
      eta: '8:15 AM',
      studentCount: 5,
      isVisited: false,
    ),
    MockBusStop(
      id: 'bs05',
      name: 'Ejipura Signal',
      eta: '8:25 AM',
      studentCount: 4,
      isVisited: false,
    ),
    MockBusStop(
      id: 'bs06',
      name: 'School Gate',
      eta: '8:40 AM',
      studentCount: 0,
      isVisited: false,
    ),
  ];

  // ── Book issues for librarian ─────────────────────────────────────────────
  static final List<MockBookIssue> bookIssues = [
    MockBookIssue(
      id: 'bi001',
      studentName: 'Arjun Kumar',
      studentClass: '8-A',
      bookTitle: 'Wings of Fire',
      bookAccession: 'ACC-0042',
      issueDate: DateTime.now().subtract(const Duration(days: 8)),
      dueDate: DateTime.now().add(const Duration(days: 6)),
      isOverdue: false,
    ),
    MockBookIssue(
      id: 'bi002',
      studentName: 'Preethi Nair',
      studentClass: '9-B',
      bookTitle: 'The Alchemist',
      bookAccession: 'ACC-0108',
      issueDate: DateTime.now().subtract(const Duration(days: 18)),
      dueDate: DateTime.now().subtract(const Duration(days: 4)),
      isOverdue: true,
      finePaise: 2000,
    ),
  ];

  // ── Reservations for librarian ────────────────────────────────────────────
  static final List<MockReservation> reservations = [
    MockReservation(
      id: 'res001',
      studentName: 'Kiran Rao',
      studentClass: '7-A',
      bookTitle: 'Harry Potter and the Sorcerer\'s Stone',
      bookAccession: 'ACC-0201',
      reservedAt: DateTime.now().subtract(const Duration(hours: 2)),
      expiresAt: DateTime.now().add(const Duration(hours: 22)),
      status: 'pending',
    ),
    MockReservation(
      id: 'res002',
      studentName: 'Anjali Singh',
      studentClass: '10-A',
      bookTitle: 'To Kill a Mockingbird',
      bookAccession: 'ACC-0312',
      reservedAt: DateTime.now().subtract(const Duration(hours: 6)),
      expiresAt: DateTime.now().add(const Duration(hours: 18)),
      status: 'ready',
    ),
  ];

  // ── Hostel students for warden ────────────────────────────────────────────
  static final List<MockHostelStudent> hostelStudents = [
    MockHostelStudent(
      id: 'hs001',
      name: 'Ravi Shankar',
      roomNo: '201',
      bedNo: 'A',
      classSection: '9-A',
      isPresent: true,
      parentName: 'Rajan Shankar',
      parentPhone: '9845011122',
      bloodGroup: 'O+',
      medicalNotes: 'No allergies',
      emergencyContact: 'Lakshmi Shankar',
      emergencyPhone: '9845011123',
    ),
    MockHostelStudent(
      id: 'hs002',
      name: 'Ajay Reddy',
      roomNo: '201',
      bedNo: 'B',
      classSection: '10-B',
      isPresent: true,
      parentName: 'Venkat Reddy',
      parentPhone: '9845099887',
      bloodGroup: 'B+',
      medicalNotes: 'Asthma – inhaler in room',
      emergencyContact: 'Kavitha Reddy',
      emergencyPhone: '9845099888',
    ),
    MockHostelStudent(
      id: 'hs003',
      name: 'Mohan Das',
      roomNo: '202',
      bedNo: 'A',
      classSection: '8-C',
      isPresent: false,
      parentName: 'Ramesh Das',
      parentPhone: '9900112234',
      bloodGroup: 'A+',
      medicalNotes: null,
      emergencyContact: 'Sita Das',
      emergencyPhone: '9900112235',
    ),
    MockHostelStudent(
      id: 'hs004',
      name: 'Sunil Kumar',
      roomNo: '202',
      bedNo: 'B',
      classSection: '9-B',
      isPresent: true,
      parentName: 'Vishnu Kumar',
      parentPhone: '9811223345',
      bloodGroup: 'AB+',
      medicalNotes: 'Lactose intolerant',
      emergencyContact: 'Lakshmi Kumar',
      emergencyPhone: '9811223346',
    ),
    MockHostelStudent(
      id: 'hs005',
      name: 'Ramesh N',
      roomNo: '203',
      bedNo: 'A',
      classSection: '10-A',
      isPresent: true,
      parentName: 'Narayan N',
      parentPhone: '9712345678',
      bloodGroup: 'O-',
      medicalNotes: null,
      emergencyContact: 'Geeta N',
      emergencyPhone: '9712345679',
    ),
    MockHostelStudent(
      id: 'hs006',
      name: 'Vikram Shetty',
      roomNo: '203',
      bedNo: 'B',
      classSection: '8-A',
      isPresent: false,
      parentName: 'Raghu Shetty',
      parentPhone: '9600112234',
      bloodGroup: 'A-',
      medicalNotes: 'Penicillin allergy',
      emergencyContact: 'Uma Shetty',
      emergencyPhone: '9600112235',
    ),
    MockHostelStudent(
      id: 'hs007',
      name: 'Arjun Kumar',
      roomNo: '204',
      bedNo: 'A',
      classSection: '8-A',
      isPresent: true,
      parentName: 'Suresh Kumar',
      parentPhone: '9876543210',
      bloodGroup: 'B+',
      medicalNotes: null,
      emergencyContact: 'Suresh Kumar',
      emergencyPhone: '9876543210',
    ),
  ];

  // ── Hostel outpass / leave requests ───────────────────────────────────────
  static final List<MockHostelOutpass> hostelOutpasses = [
    MockHostelOutpass(
      id: 'op001',
      studentName: 'Ravi Shankar',
      studentId: 'hs001',
      reason: 'Home visit',
      fromDate: DateTime.now().subtract(const Duration(days: 1)),
      toDate: DateTime.now().add(const Duration(days: 2)),
      status: 'approved',
      approvedBy: 'Warden',
      parentConsentPhone: '9845011122',
      checkOutTime: DateTime.now().subtract(const Duration(hours: 20)),
      expectedReturnTime: DateTime.now().add(const Duration(days: 2)),
    ),
    MockHostelOutpass(
      id: 'op002',
      studentName: 'Sunil Kumar',
      studentId: 'hs004',
      reason: 'Medical',
      fromDate: DateTime.now(),
      toDate: DateTime.now().add(const Duration(days: 1)),
      status: 'pending',
    ),
  ];

  // ── Visitors for warden ───────────────────────────────────────────────────
  static final List<MockVisitor> visitors = [
    MockVisitor(
      id: 'vis001',
      visitorName: 'Rajan Shankar',
      relationship: 'Parent',
      phone: '9845011122',
      studentName: 'Ravi Shankar',
      idType: 'Aadhaar',
      checkInTime: DateTime.now().subtract(const Duration(hours: 2)),
      checkOutTime: null,
    ),
    MockVisitor(
      id: 'vis002',
      visitorName: 'Kavitha Reddy',
      relationship: 'Parent',
      phone: '9845099887',
      studentName: 'Ajay Reddy',
      idType: 'Driving Licence',
      checkInTime: DateTime.now().subtract(const Duration(hours: 1)),
      checkOutTime: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
  ];

  // ── Admission enquiries ───────────────────────────────────────────────────
  static final List<MockAdmissionEnquiry> admissionEnquiries = [
    MockAdmissionEnquiry(
      id: 'enq001',
      studentName: 'Sneha Patil',
      parentName: 'Sunil Patil',
      phone: '9876501234',
      classApplying: 'Class 6',
      source: 'Walk-in',
      status: 'Contacted',
      aiLeadScore: 82,
      enquiryDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    MockAdmissionEnquiry(
      id: 'enq002',
      studentName: 'Aditya Mehta',
      parentName: 'Rahul Mehta',
      phone: '9845067890',
      classApplying: 'Class 9',
      source: 'Online',
      status: 'New',
      aiLeadScore: 65,
      enquiryDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MockAdmissionEnquiry(
      id: 'enq003',
      studentName: 'Divya Rao',
      parentName: 'Prasad Rao',
      phone: '9900123456',
      classApplying: 'Class 1',
      source: 'Referral',
      status: 'Application Given',
      aiLeadScore: 91,
      enquiryDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  // ── Assets for inventory ──────────────────────────────────────────────────
  static final List<MockAsset> assets = [
    MockAsset(
      id: 'ast001',
      name: 'Dell Laptop',
      category: 'IT',
      brand: 'Dell',
      location: 'Lab 1',
      condition: 'Good',
      assignedTo: 'Computer Lab',
    ),
    MockAsset(
      id: 'ast002',
      name: 'Projector BenQ',
      category: 'AV Equipment',
      brand: 'BenQ',
      location: 'Class 9-A',
      condition: 'Good',
      assignedTo: 'Class 9-A',
    ),
    MockAsset(
      id: 'ast003',
      name: 'Science Lab Microscope',
      category: 'Lab',
      brand: 'Olympus',
      location: 'Science Lab',
      condition: 'Fair',
      assignedTo: 'Science Lab',
    ),
    MockAsset(
      id: 'ast004',
      name: 'Office Chair',
      category: 'Furniture',
      brand: 'Featherlite',
      location: 'Principal Office',
      condition: 'Good',
      assignedTo: 'Principal',
    ),
    MockAsset(
      id: 'ast005',
      name: 'Copier Machine',
      category: 'IT',
      brand: 'Canon',
      location: 'Admin Office',
      condition: 'Needs Repair',
      assignedTo: 'Admin Office',
    ),
  ];

  // ── HOD mock data ──────────────────────────────────────────────────────────

  /// HOD department (matches UserModel.hod "Kavitha Menon" → English dept)
  static const String hodDepartment = 'English';

  /// Staff leave requests pending HOD approval (department staff)
  static final List<MockStaffLeaveRequest> staffLeaveRequests = [
    MockStaffLeaveRequest(
      id: 'slr001',
      staffName: 'Deepa Nair',
      staffId: 'st_dept_01',
      department: 'English',
      type: 'Casual Leave',
      fromDate: DateTime.now().add(const Duration(days: 2)),
      toDate: DateTime.now().add(const Duration(days: 4)),
      workingDays: 3,
      reason: 'Personal work',
      status: 'pending',
    ),
    MockStaffLeaveRequest(
      id: 'slr002',
      staffName: 'Vijay Murthy',
      staffId: 'st_dept_02',
      department: 'English',
      type: 'Sick Leave',
      fromDate: DateTime.now(),
      toDate: DateTime.now().add(const Duration(days: 1)),
      workingDays: 2,
      reason: 'Doctor appointment',
      status: 'pending',
    ),
  ];
}

// ── HOD models ──────────────────────────────────────────────────────────────

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
