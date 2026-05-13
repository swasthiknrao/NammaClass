import '../models/user_model.dart';

/// Demo permission strings until backend JWT drives claims.
List<String> demoPermissionsForRole(UserRole role) {
  switch (role) {
    case UserRole.admin:
    case UserRole.principal:
      return [
        'students:read',
        'students:write',
        'fees:read',
        'fees:write',
        'attendance:read',
        'attendance:write',
        'inventory:read',
        'support:read',
        'web:access',
      ];
    case UserRole.accountant:
      return ['fees:read', 'fees:write', 'students:read', 'web:access'];
    case UserRole.teacher:
      return [
        'students:read',
        'attendance:read',
        'attendance:write',
        'web:access',
      ];
    case UserRole.librarian:
      return ['students:read', 'library:read', 'library:write', 'web:access'];
    case UserRole.support:
      return ['support:read', 'support:write', 'students:read', 'web:access'];
    case UserRole.hod:
      return ['students:read', 'staff:read', 'attendance:read', 'web:access'];
    case UserRole.superAdmin:
      return [
        'platform:tenants',
        'platform:billing',
        'platform:modules',
        'platform:audit',
        'students:read',
        'students:write',
        'web:access',
      ];
    case UserRole.parent:
      return ['students:read', 'fees:read', 'messages:read'];
    case UserRole.student:
      return ['students:read'];
    case UserRole.staff:
      return ['staff:self', 'attendance:read'];
    case UserRole.driver:
      return ['transport:read'];
    case UserRole.warden:
      return ['hostel:read', 'hostel:write'];
    case UserRole.canteenStaff:
      return ['canteen:read', 'canteen:write'];
  }
}

UserRole? userRoleFromName(String name) {
  final key = name.trim().toLowerCase();
  if (key == 'super admin' || key == 'super_admin') {
    return UserRole.superAdmin;
  }
  for (final r in UserRole.values) {
    if (r.name == name) return r;
  }
  return null;
}
