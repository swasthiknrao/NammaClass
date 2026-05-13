import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/di/repository_providers.dart';
import '../../../domain/constants/demo_tenant.dart';
import '../../../domain/entities/tenant_profile.dart';
import '../../../core/mock/mock_tenant_profiles.dart';
import '../../../core/services/app_logger.dart';

/// Manages the active [TenantProfile] for the current app session.
/// Initialized during splash with [kDemoTenantId]; updated when a real
/// tenant ID is extracted from the auth JWT post-login.
class TenantNotifier extends AsyncNotifier<TenantProfile> {
  @override
  Future<TenantProfile> build() async {
    return _load(kDemoTenantId);
  }

  Future<TenantProfile> _load(String tenantId) async {
    try {
      return await ref
          .read(tenantRepositoryProvider)
          .fetchTenantConfig(tenantId);
    } catch (e, st) {
      AppLogger.instance.error('TenantNotifier: load failed', e, st);
      return MockTenantProfiles.demo;
    }
  }

  /// Call this after a successful login when the JWT contains a real tenant ID.
  Future<void> loadForTenant(String tenantId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(tenantId));
  }

  /// Reloads the current tenant's profile (e.g. after subscription upgrade).
  Future<void> refresh() async {
    final current = state.valueOrNull?.tenantId ?? kDemoTenantId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(current));
  }
}

/// Global tenant provider — watched by [App] for dynamic theming and
/// throughout the app for feature gating.
final tenantProvider = AsyncNotifierProvider<TenantNotifier, TenantProfile>(
  TenantNotifier.new,
);

/// Synchronous convenience — returns the loaded profile or the demo fallback.
/// Avoids AsyncValue boilerplate in UI code that just needs the current profile.
final tenantProfileProvider = Provider<TenantProfile>((ref) {
  return ref.watch(tenantProvider).whenData((p) => p).valueOrNull ??
      MockTenantProfiles.demo;
});
