import '../../domain/entities/nc_feature.dart';
import '../../domain/entities/tenant_profile.dart';
import '../config/tenant_policy_loader.dart';
import '../models/user_model.dart';

/// Declares which [NcFeature] modules must be **on** before a [UserRole]
/// can exist for a tenant (invite, login, or role pack).
///
/// Data: [assets/config/role_module_requirements.json] (see
/// [docs/schemas/role_module_requirements.json]).
Set<NcFeature> requiredModulesForRole(UserRole role) {
  final keys = TenantPolicyLoader.roleToModuleKeys[role.name];
  if (keys == null || keys.isEmpty) return const {};
  final out = <NcFeature>{};
  for (final k in keys) {
    final f = NcFeatureX.fromKey(k);
    if (f != null) out.add(f);
  }
  return out;
}

/// True if [profile] has every module required by [role].
bool isRoleAllowedForTenant(UserRole role, TenantProfile profile) {
  for (final f in requiredModulesForRole(role)) {
    if (!profile.hasFeature(f)) return false;
  }
  return true;
}

/// Roles that may be assigned for this tenant (module deps satisfied).
/// [UserRole.superAdmin] is excluded — platform-only, not institution invites.
Iterable<UserRole> assignableTenantRoles(TenantProfile profile) sync* {
  for (final r in UserRole.values) {
    if (r == UserRole.superAdmin) continue;
    if (isRoleAllowedForTenant(r, profile)) yield r;
  }
}

/// Filters [candidates] to those allowed for [profile] (and not superAdmin).
List<UserRole> filterRolesForTenant(
  Iterable<UserRole> candidates,
  TenantProfile profile,
) {
  return candidates
      .where(
        (r) => r != UserRole.superAdmin && isRoleAllowedForTenant(r, profile),
      )
      .toList();
}

/// Missing module keys (API snake_case) if [role] cannot be enabled.
List<String> missingModulesForRole(UserRole role, TenantProfile profile) {
  final out = <String>[];
  for (final f in requiredModulesForRole(role)) {
    if (!profile.hasFeature(f)) out.add(f.key);
  }
  return out;
}

/// Parses entitlement / JWT role strings (`UserRole.name` or API aliases).
UserRole? userRoleFromEntitlementKey(String key) {
  for (final r in UserRole.values) {
    if (r.name == key) return r;
  }
  final canonical = TenantPolicyLoader.roleAliases[key];
  if (canonical != null) {
    for (final r in UserRole.values) {
      if (r.name == canonical) return r;
    }
  }
  return null;
}

/// Assignable institution roles for the invite UI.
///
/// When [EntitlementSnapshot.allowedRoleKeys] is non-empty, the server-curated
/// list wins (filtered by module rules). Otherwise roles are derived from
/// enabled modules per [assignableTenantRoles].
List<UserRole> assignableRolesForInvite(TenantProfile profile) {
  final keys = profile.entitlementSnapshot?.allowedRoleKeys;
  if (keys != null && keys.isNotEmpty) {
    final out = <UserRole>[];
    final seen = <UserRole>{};
    for (final k in keys) {
      final r = userRoleFromEntitlementKey(k);
      if (r == null || r == UserRole.superAdmin) continue;
      if (!isRoleAllowedForTenant(r, profile)) continue;
      if (seen.add(r)) out.add(r);
    }
    if (out.isNotEmpty) {
      out.sort((a, b) => a.name.compareTo(b.name));
      return out;
    }
  }
  final derived = assignableTenantRoles(profile).toList()
    ..sort((a, b) => a.name.compareTo(b.name));
  return derived;
}
