import '../../../core/models/user_model.dart';
import '../../../core/tenant/school_role_invite_policy.dart';
import '../../../domain/entities/tenant_profile.dart';

/// Roles the current actor may create **manually** in the admin shell (no email invite).
/// Excludes [UserRole.student] — learners are added on the web Students roster.
List<UserRole> manualAddUserRoles(UserRole? actor, TenantProfile profile) {
  return rolesInvitableByActor(
    actor,
    profile,
  ).where((r) => r != UserRole.student).toList();
}
