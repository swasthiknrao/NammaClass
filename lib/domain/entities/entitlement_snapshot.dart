/// Billing-backed entitlement document (server source of truth).
/// Parsed from `GET /v1/tenants/{id}/entitlements` or embedded
/// `entitlement_snapshot` on tenant profile JSON.
class EntitlementSnapshot {
  const EntitlementSnapshot({
    required this.schemaVersion,
    required this.snapshotVersion,
    required this.tenantId,
    required this.modules,
    this.planTier,
    this.limits = const EntitlementLimits.empty(),
    this.integrationAllowlist = const [],
    this.allowedRoleKeys = const [],
  });

  final int schemaVersion;
  final int snapshotVersion;
  final String tenantId;
  final String? planTier;
  final Map<String, ModuleEntitlement> modules;
  final EntitlementLimits limits;
  final List<String> integrationAllowlist;

  /// Roles the tenant may assign to institution users (invite / PATCH role).
  /// When empty, clients derive from modules via [role_module_requirements].
  final List<String> allowedRoleKeys;

  bool isModuleEnabled(String moduleKey) =>
      modules[moduleKey]?.enabled ?? false;

  factory EntitlementSnapshot.fromJson(Map<String, dynamic> json) {
    final rawModules =
        json['modules'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return EntitlementSnapshot(
      schemaVersion: json['schema_version'] as int? ?? 1,
      snapshotVersion: json['snapshot_version'] as int? ?? 1,
      tenantId:
          json['tenant_id'] as String? ?? json['tenantId'] as String? ?? '',
      planTier: json['plan_tier'] as String? ?? json['planTier'] as String?,
      modules: rawModules.map(
        (k, v) => MapEntry(
          k,
          ModuleEntitlement.fromJson(Map<String, dynamic>.from(v as Map)),
        ),
      ),
      limits: EntitlementLimits.fromJson(
        json['limits'] as Map<String, dynamic>?,
      ),
      integrationAllowlist: List<String>.from(
        json['integration_allowlist'] as List? ??
            json['integrationAllowlist'] as List? ??
            const [],
      ),
      allowedRoleKeys: List<String>.from(
        json['allowed_role_keys'] as List? ??
            json['allowedRoleKeys'] as List? ??
            const [],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'schema_version': schemaVersion,
    'snapshot_version': snapshotVersion,
    'tenant_id': tenantId,
    if (planTier != null) 'plan_tier': planTier,
    'modules': modules.map((k, v) => MapEntry(k, v.toJson())),
    'limits': limits.toJson(),
    'integration_allowlist': integrationAllowlist,
    if (allowedRoleKeys.isNotEmpty) 'allowed_role_keys': allowedRoleKeys,
  };

  EntitlementSnapshot copyWith({
    int? schemaVersion,
    int? snapshotVersion,
    String? tenantId,
    String? planTier,
    Map<String, ModuleEntitlement>? modules,
    EntitlementLimits? limits,
    List<String>? integrationAllowlist,
    List<String>? allowedRoleKeys,
  }) {
    return EntitlementSnapshot(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      snapshotVersion: snapshotVersion ?? this.snapshotVersion,
      tenantId: tenantId ?? this.tenantId,
      planTier: planTier ?? this.planTier,
      modules: modules ?? this.modules,
      limits: limits ?? this.limits,
      integrationAllowlist: integrationAllowlist ?? this.integrationAllowlist,
      allowedRoleKeys: allowedRoleKeys ?? this.allowedRoleKeys,
    );
  }
}

class ModuleEntitlement {
  const ModuleEntitlement({
    required this.enabled,
    this.sku,
    this.flags = const {},
  });

  final bool enabled;
  final String? sku;
  final Map<String, dynamic> flags;

  factory ModuleEntitlement.fromJson(Map<String, dynamic> json) {
    return ModuleEntitlement(
      enabled: json['enabled'] as bool? ?? false,
      sku: json['sku'] as String?,
      flags: Map<String, dynamic>.from(json['flags'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    if (sku != null) 'sku': sku,
    'flags': flags,
  };
}

class EntitlementLimits {
  const EntitlementLimits({
    this.apiRequestsPerMinute,
    this.storageGbIncluded,
    this.smsSegmentsPerMonth,
    this.whatsappConversationUnitsPerMonth,
    this.aiTokensPerMonth,
    this.maxActiveStudents,
    this.maxStaffSeats,
  });

  const EntitlementLimits.empty()
    : apiRequestsPerMinute = null,
      storageGbIncluded = null,
      smsSegmentsPerMonth = null,
      whatsappConversationUnitsPerMonth = null,
      aiTokensPerMonth = null,
      maxActiveStudents = null,
      maxStaffSeats = null;

  final int? apiRequestsPerMinute;
  final double? storageGbIncluded;
  final int? smsSegmentsPerMonth;
  final int? whatsappConversationUnitsPerMonth;
  final int? aiTokensPerMonth;
  final int? maxActiveStudents;
  final int? maxStaffSeats;

  factory EntitlementLimits.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EntitlementLimits.empty();
    return EntitlementLimits(
      apiRequestsPerMinute:
          json['api_requests_per_minute'] as int? ??
          json['apiRequestsPerMinute'] as int?,
      storageGbIncluded:
          (json['storage_gb_included'] as num?)?.toDouble() ??
          (json['storageGbIncluded'] as num?)?.toDouble(),
      smsSegmentsPerMonth:
          json['sms_segments_per_month'] as int? ??
          json['smsSegmentsPerMonth'] as int?,
      whatsappConversationUnitsPerMonth:
          json['whatsapp_conversation_units_per_month'] as int? ??
          json['whatsappConversationUnitsPerMonth'] as int?,
      aiTokensPerMonth:
          json['ai_tokens_per_month'] as int? ??
          json['aiTokensPerMonth'] as int?,
      maxActiveStudents:
          json['max_active_students'] as int? ??
          json['maxActiveStudents'] as int?,
      maxStaffSeats:
          json['max_staff_seats'] as int? ?? json['maxStaffSeats'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (apiRequestsPerMinute != null)
      'api_requests_per_minute': apiRequestsPerMinute,
    if (storageGbIncluded != null) 'storage_gb_included': storageGbIncluded,
    if (smsSegmentsPerMonth != null)
      'sms_segments_per_month': smsSegmentsPerMonth,
    if (whatsappConversationUnitsPerMonth != null)
      'whatsapp_conversation_units_per_month':
          whatsappConversationUnitsPerMonth,
    if (aiTokensPerMonth != null) 'ai_tokens_per_month': aiTokensPerMonth,
    if (maxActiveStudents != null) 'max_active_students': maxActiveStudents,
    if (maxStaffSeats != null) 'max_staff_seats': maxStaffSeats,
  };
}
