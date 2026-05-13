/// A staff member record (teachers, admin staff, support staff, etc.).
class StaffMember {
  const StaffMember({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.phone,
    this.email,
    this.joinDate,
    this.status = 'active',
    this.salaryCTC = 0,
    this.avatarUrl,
    this.employeeCode,
  });

  final String id;
  final String name;

  /// e.g. "teacher" | "librarian" | "admin" | "support"
  final String role;
  final String department;
  final String phone;
  final String? email;
  final DateTime? joinDate;

  /// "active" | "inactive" | "on_leave"
  final String status;

  /// Annual CTC in paise.
  final int salaryCTC;
  final String? avatarUrl;
  final String? employeeCode;

  factory StaffMember.fromJson(Map<String, dynamic> json) => StaffMember(
    id: json['id'] as String,
    name: json['name'] as String,
    role: (json['role'] as String?) ?? 'staff',
    department: (json['department'] as String?) ?? '',
    phone: (json['phone'] as String?) ?? '',
    email: json['email'] as String?,
    joinDate: json['join_date'] != null
        ? DateTime.parse(json['join_date'] as String)
        : null,
    status: (json['status'] as String?) ?? 'active',
    salaryCTC: (json['salary_ctc'] as int?) ?? 0,
    avatarUrl: json['avatar_url'] as String?,
    employeeCode: json['employee_code'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'department': department,
    'phone': phone,
    'email': email,
    'join_date': joinDate?.toIso8601String(),
    'status': status,
    'salary_ctc': salaryCTC,
    'avatar_url': avatarUrl,
    'employee_code': employeeCode,
  };
}

/// A monthly payslip for a staff member.
class Payslip {
  const Payslip({
    required this.id,
    required this.staffId,
    required this.month,
    required this.year,
    required this.grossPaise,
    required this.deductionsPaise,
    required this.netPaise,
    this.pdfUrl,
    this.paidDate,
  });

  final String id;
  final String staffId;
  final int month;
  final int year;
  final int grossPaise;
  final int deductionsPaise;
  final int netPaise;
  final String? pdfUrl;
  final DateTime? paidDate;

  factory Payslip.fromJson(Map<String, dynamic> json) => Payslip(
    id: json['id'] as String,
    staffId: json['staff_id'] as String,
    month: (json['month'] as int?) ?? 1,
    year: (json['year'] as int?) ?? DateTime.now().year,
    grossPaise: (json['gross_paise'] as int?) ?? 0,
    deductionsPaise: (json['deductions_paise'] as int?) ?? 0,
    netPaise: (json['net_paise'] as int?) ?? 0,
    pdfUrl: json['pdf_url'] as String?,
    paidDate: json['paid_date'] != null
        ? DateTime.parse(json['paid_date'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'staff_id': staffId,
    'month': month,
    'year': year,
    'gross_paise': grossPaise,
    'deductions_paise': deductionsPaise,
    'net_paise': netPaise,
    'pdf_url': pdfUrl,
    'paid_date': paidDate?.toIso8601String(),
  };
}
