import '../../domain/entities/entitlement_snapshot.dart';
import '../../domain/entities/tenant_profile.dart';

/// Optional helpers for merging remote tenant payloads.
///
/// Server may deliver profile and entitlements in one `GET /tenant/config`
/// body (embedded `entitlement_snapshot`) or as separate resources; parsing
/// is centralized in [TenantProfile.fromJson].
class TenantConfigLoader {
  TenantConfigLoader._();

  /// Merges a partial entitlement-only payload into an existing profile.
  /// Keys should match [EntitlementSnapshot.toJson] snake_case.
  static TenantProfile mergeEntitlementJson(
    TenantProfile base,
    Map<String, dynamic> entitlementJson,
  ) {
    return base.copyWith(
      entitlementSnapshot: EntitlementSnapshot.fromJson(entitlementJson),
    );
  }
}
