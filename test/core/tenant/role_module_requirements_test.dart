import 'package:flutter_test/flutter_test.dart';

import 'package:nammaclass/core/config/tenant_policy_loader.dart';
import 'package:nammaclass/core/tenant/role_module_requirements.dart';
import 'package:nammaclass/core/models/user_model.dart';
import 'package:nammaclass/domain/entities/entitlement_snapshot.dart';
import 'package:nammaclass/domain/entities/nc_feature.dart';
import 'package:nammaclass/domain/entities/tenant_profile.dart';

TenantProfile _profileWithModules(Set<String> enabledKeys) {
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
          f.key: ModuleEntitlement(enabled: enabledKeys.contains(f.key)),
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

  test('driver role requires transport module', () {
    final withTransport = _profileWithModules({NcFeature.transport.key});
    final noTransport = _profileWithModules({});
    expect(isRoleAllowedForTenant(UserRole.driver, withTransport), true);
    expect(isRoleAllowedForTenant(UserRole.driver, noTransport), false);
  });

  test('assignableRolesForInvite excludes librarian without library', () {
    final schoolLike = _profileWithModules({
      NcFeature.transport.key,
      NcFeature.canteen.key,
    });
    final roles = assignableRolesForInvite(schoolLike);
    expect(roles.contains(UserRole.librarian), false);
    expect(roles.contains(UserRole.driver), true);
  });

  test('allowedRoleKeys from server is filtered by module rules', () {
    final p = _profileWithModules({NcFeature.transport.key}).copyWith(
      entitlementSnapshot: EntitlementSnapshot(
        schemaVersion: 1,
        snapshotVersion: 2,
        tenantId: 't1',
        modules: {
          NcFeature.transport.key: const ModuleEntitlement(enabled: true),
          NcFeature.library.key: const ModuleEntitlement(enabled: false),
        },
        allowedRoleKeys: const ['librarian', 'driver'],
      ),
    );
    final roles = assignableRolesForInvite(p);
    expect(roles.contains(UserRole.driver), true);
    expect(roles.contains(UserRole.librarian), false);
  });
}
