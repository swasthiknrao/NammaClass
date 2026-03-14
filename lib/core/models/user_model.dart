/// NammaClass user roles — covers all 12 portal personas.
/// Extended with HOD per mission brief.
enum UserRole {
  parent,
  teacher,
  student,
  admin,
  principal,
  support,
  accountant,
  // Part 2 roles
  staff,
  driver,
  librarian,
  warden,
  canteenStaff,
  // Mission brief roles
  hod,
}

/// Core user model used across all roles.
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
    this.email,
    this.avatarUrl,
    this.schoolId,
    this.classSection,
    this.employeeId,
    this.studentId,
  });

  final String id;
  final String name;
  final UserRole role;
  final String phone;
  final String? email;
  final String? avatarUrl;
  final String? schoolId;
  final String? classSection;
  final String? employeeId;
  final String? studentId;

  String get displayName => name;

  String get roleLabel {
    switch (role) {
      case UserRole.parent:
        return 'Parent';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.student:
        return 'Student';
      case UserRole.admin:
        return 'Admin';
      case UserRole.principal:
        return 'Principal';
      case UserRole.support:
        return 'Support';
      case UserRole.accountant:
        return 'Accountant';
      case UserRole.staff:
        return 'Staff';
      case UserRole.driver:
        return 'Driver';
      case UserRole.librarian:
        return 'Librarian';
      case UserRole.warden:
        return 'Warden';
      case UserRole.canteenStaff:
        return 'Canteen Staff';
      case UserRole.hod:
        return 'HOD';
    }
  }

  UserModel copyWith({
    String? id,
    String? name,
    UserRole? role,
    String? phone,
    String? email,
    String? avatarUrl,
    String? schoolId,
    String? classSection,
    String? employeeId,
    String? studentId,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      schoolId: schoolId ?? this.schoolId,
      classSection: classSection ?? this.classSection,
      employeeId: employeeId ?? this.employeeId,
      studentId: studentId ?? this.studentId,
    );
  }

  // ── Demo users for each role ───────────────────────────────────────────────

  static const parent = UserModel(
    id: 'usr_parent_001',
    name: 'Suresh Kumar',
    role: UserRole.parent,
    phone: '9876543210',
    email: 'suresh.kumar@gmail.com',
    schoolId: 'SCH_001',
  );

  static const teacher = UserModel(
    id: 'usr_teacher_001',
    name: 'Priya Sharma',
    role: UserRole.teacher,
    phone: '9845012345',
    email: 'priya.sharma@vidyashree.edu.in',
    schoolId: 'SCH_001',
    employeeId: 'EMP_1042',
    classSection: '8-A',
  );

  static const student = UserModel(
    id: 'usr_student_001',
    name: 'Arjun Kumar',
    role: UserRole.student,
    phone: '9876500001',
    email: 'arjun.kumar@student.in',
    schoolId: 'SCH_001',
    classSection: '8-A',
    studentId: 'STU_2024_0042',
  );

  static const admin = UserModel(
    id: 'usr_admin_001',
    name: 'Ramesh Naik',
    role: UserRole.admin,
    phone: '9880001111',
    email: 'admin@vidyashree.edu.in',
    schoolId: 'SCH_001',
    employeeId: 'EMP_0001',
  );

  static const principal = UserModel(
    id: 'usr_principal_001',
    name: 'Dr. Lakshmi Nair',
    role: UserRole.principal,
    phone: '9880002222',
    email: 'principal@vidyashree.edu.in',
    schoolId: 'SCH_001',
    employeeId: 'PRN_001',
  );

  static const support = UserModel(
    id: 'usr_support_001',
    name: 'Kiran Shetty',
    role: UserRole.support,
    phone: '9880003333',
    email: 'support@vidyashree.edu.in',
    schoolId: 'SCH_001',
    employeeId: 'SUP_001',
  );

  static const staff = UserModel(
    id: 'usr_staff_001',
    name: 'Rajesh Gowda',
    role: UserRole.staff,
    phone: '9845099001',
    email: 'rajesh.gowda@vidyashree.edu.in',
    schoolId: 'SCH_001',
    employeeId: 'EMP_2031',
  );

  static const driver = UserModel(
    id: 'usr_driver_001',
    name: 'Venkat Reddy',
    role: UserRole.driver,
    phone: '9900112233',
    email: 'venkat.driver@vidyashree.edu.in',
    schoolId: 'SCH_001',
    employeeId: 'DRV_007',
  );

  static const librarian = UserModel(
    id: 'usr_lib_001',
    name: 'Meena Iyer',
    role: UserRole.librarian,
    phone: '9845055678',
    email: 'meena.lib@vidyashree.edu.in',
    schoolId: 'SCH_001',
    employeeId: 'LIB_001',
  );

  static const warden = UserModel(
    id: 'usr_warden_001',
    name: 'Subbaiah B',
    role: UserRole.warden,
    phone: '9845077890',
    email: 'warden@vidyashree.edu.in',
    schoolId: 'SCH_001',
    employeeId: 'WRD_001',
  );

  static const canteenStaff = UserModel(
    id: 'usr_canteen_001',
    name: 'Lakshmi Devi',
    role: UserRole.canteenStaff,
    phone: '9845033456',
    email: 'canteen@vidyashree.edu.in',
    schoolId: 'SCH_001',
    employeeId: 'CAN_001',
  );

  static const accountant = UserModel(
    id: 'usr_accountant_001',
    name: 'Anita Rao',
    role: UserRole.accountant,
    phone: '9845011122',
    email: 'anita.rao@vidyashree.edu.in',
    schoolId: 'SCH_001',
    employeeId: 'ACC_001',
  );

  static const hod = UserModel(
    id: 'usr_hod_001',
    name: 'Kavitha Menon',
    role: UserRole.hod,
    phone: '9880005555',
    email: 'hod@vidyashree.edu.in',
    schoolId: 'SCH_001',
    employeeId: 'HOD_001',
    classSection: '8-A',
  );
}
