import 'package:flutter_test/flutter_test.dart';

import 'package:nammaclass/core/config/tenant_policy_loader.dart';
import 'package:nammaclass/core/models/user_model.dart';
import 'package:nammaclass/core/tenant/school_role_invite_policy.dart';
import 'package:nammaclass/domain/entities/entitlement_snapshot.dart';
import 'package:nammaclass/domain/entities/nc_feature.dart';
import 'package:nammaclass/domain/entities/tenant_profile.dart';

TenantProfile _allModulesProfile() {
  return TenantProfile(
    tenantId: 't1',
    institutionName: 'Test',
    logoUrl: '',
    appIconUrl: '',
    primaryHex: '000000',
    accentHex: 'FFFFFF',
    features: {},
    timezone: 'UTC',
    currency: 'INR',
    languages: const ['en'],
    entitlementSnapshot: EntitlementSnapshot(
      schemaVersion: 1,
      snapshotVersion: 1,
      tenantId: 't1',
      modules: {
        for (final f in NcFeature.values)
          f.key: const ModuleEntitlement(enabled: true),
      },
    ),
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await TenantPolicyLoader.loadAll();
  });

  tearDownAll(() {
    TenantPolicyLoader.resetForTest();
  });

  test('teacher may only invite students when tenant allows', () {
    final p = _allModulesProfile();
    final roles = rolesInvitableByActor(UserRole.teacher, p);
    expect(roles, [UserRole.student]);
  });

  test('HOD invites teachers and students', () {
    final p = _allModulesProfile();
    final roles = rolesInvitableByActor(UserRole.hod, p);
    expect(roles.contains(UserRole.teacher), true);
    expect(roles.contains(UserRole.student), true);
    expect(roles.contains(UserRole.principal), false);
  });

  test('admin invites ops heads but not teachers', () {
    final p = _allModulesProfile();
    final roles = rolesInvitableByActor(UserRole.admin, p);
    expect(roles.contains(UserRole.hod), true);
    expect(roles.contains(UserRole.teacher), false);
    expect(roles.contains(UserRole.principal), true);
  });

  test('principal includes HOD-level academic invites', () {
    final p = _allModulesProfile();
    final roles = rolesInvitableByActor(UserRole.principal, p);
    expect(roles.contains(UserRole.teacher), true);
    expect(roles.contains(UserRole.student), true);
    expect(roles.contains(UserRole.driver), true);
  });
}
