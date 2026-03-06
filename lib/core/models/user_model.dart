/// NammaClass user roles.
enum UserRole { parent, teacher, student, admin, principal, support }

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

  // Demo users for each role
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
}
