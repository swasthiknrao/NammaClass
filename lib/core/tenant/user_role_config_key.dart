import '../../core/models/user_model.dart';

/// Maps app [UserRole] to stable keys used in `nav_graph.roles_allow` and
/// role pack JSON (`role_key`).
extension UserRoleTenantConfig on UserRole {
  String get tenantConfigKey => switch (this) {
    UserRole.parent => 'parent',
    UserRole.teacher => 'teacher',
    UserRole.student => 'student',
    UserRole.admin => 'admin',
    UserRole.principal => 'principal',
    UserRole.support => 'support',
    UserRole.accountant => 'accountant',
    UserRole.staff => 'staff',
    UserRole.driver => 'driver',
    UserRole.librarian => 'librarian',
    UserRole.warden => 'warden',
    UserRole.canteenStaff => 'canteen_staff',
    UserRole.hod => 'hod',
    UserRole.superAdmin => 'super_admin',
  };
}
