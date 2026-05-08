import '../../core/auth/demo_permissions.dart';
import '../../core/models/user_model.dart';
import '../../domain/entities/auth_credentials.dart';

UserModel userModelFromCredentials(AuthCredentials c) {
  final role = userRoleFromName(c.roleName) ?? UserRole.parent;
  return UserModel(
    id: c.userId,
    name: c.displayName,
    role: role,
    phone: c.phone,
    tenantId: c.tenantId,
    branchId: c.branchId,
    permissions: c.permissions,
    schoolId: c.tenantId,
  );
}
