import '../../domain/entities/tenant_profile.dart';
import '../models/user_model.dart';
import 'role_module_requirements.dart';

/// Leadership & operations roles the **school admin** onboards first.
/// Parent accounts are normally minted with each learner (see Students flow).
Set<UserRole> get schoolAdminOpsInviteRoles => {
  UserRole.principal,
  UserRole.hod,
  UserRole.driver,
  UserRole.staff,
  UserRole.librarian,
  UserRole.warden,
  UserRole.accountant,
  UserRole.support,
  UserRole.canteenStaff,
};

/// Academic roles the **HOD** invites under their department.
Set<UserRole> get hodAcademicInviteRoles => {
  UserRole.teacher,
  UserRole.student,
};

/// Human-readable lines for the User Management “access map” panel.
List<String> schoolInviteAccessMapLines() => const [
  'Admin — principal, HOD, librarian, warden, accountant, driver, general staff, support & canteen (when modules allow).',
  'Principal — everything the admin can invite, plus teachers and students (same authority as HOD for academics).',
  'HOD — teachers and students in their scope.',
  'Teacher — students only (parents get portal credentials when you add a learner on the Students page).',
  'Platform super-admin — any role the tenant subscription permits.',
];

/// Roles this actor may invite, intersected with [assignableRolesForInvite].
List<UserRole> rolesInvitableByActor(UserRole? actor, TenantProfile profile) {
  final tenantWide = assignableRolesForInvite(profile).toSet();
  if (actor == null) return const [];

  final Set<UserRole> picked;
  switch (actor) {
    case UserRole.superAdmin:
      picked = tenantWide;
      break;
    case UserRole.admin:
      picked = tenantWide.intersection(schoolAdminOpsInviteRoles);
      break;
    case UserRole.principal:
      picked = tenantWide.intersection(
        schoolAdminOpsInviteRoles.union(hodAcademicInviteRoles),
      );
      break;
    case UserRole.hod:
      picked = tenantWide.intersection(hodAcademicInviteRoles);
      break;
    case UserRole.teacher:
      picked = tenantWide.intersection({UserRole.student});
      break;
    default:
      picked = {};
  }

  final out = picked.toList()..sort((a, b) => a.name.compareTo(b.name));
  return out;
}
