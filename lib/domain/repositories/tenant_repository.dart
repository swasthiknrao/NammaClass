import '../entities/tenant_profile.dart';

/// Contract for fetching and caching a tenant's subscription profile.
/// The implementation decides whether to call the remote API or return mock data
/// based on [EnvConfig.apiBaseUrl].
abstract class TenantRepository {
  /// Fetches the tenant configuration for [tenantId].
  /// Returns the [TenantProfile] on success, or throws on unrecoverable error.
  Future<TenantProfile> fetchTenantConfig(String tenantId);
}
