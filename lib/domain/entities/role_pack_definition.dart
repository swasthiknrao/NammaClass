/// Platform-defined role pack template (onboarding / Super Admin).
/// See [docs/schemas/role_pack.schema.json].
class RolePackDefinition {
  const RolePackDefinition({
    required this.schemaVersion,
    required this.packId,
    required this.displayName,
    required this.entries,
    this.description,
    this.requiredModules = const [],
  });

  final int schemaVersion;
  final String packId;
  final String displayName;
  final String? description;
  final List<String> requiredModules;
  final List<RolePackEntry> entries;

  factory RolePackDefinition.fromJson(Map<String, dynamic> json) {
    final raw = json['entries'] as List<dynamic>? ?? const [];
    return RolePackDefinition(
      schemaVersion: json['schema_version'] as int? ?? 1,
      packId: json['pack_id'] as String? ?? json['packId'] as String? ?? '',
      displayName:
          json['display_name'] as String? ??
          json['displayName'] as String? ??
          '',
      description: json['description'] as String?,
      requiredModules: List<String>.from(
        json['required_modules'] as List? ??
            json['requiredModules'] as List? ??
            const [],
      ),
      entries: raw
          .map(
            (e) => RolePackEntry.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'schema_version': schemaVersion,
    'pack_id': packId,
    'display_name': displayName,
    if (description != null) 'description': description,
    'required_modules': requiredModules,
    'entries': entries.map((e) => e.toJson()).toList(),
  };
}

class RolePackEntry {
  const RolePackEntry({
    required this.roleKey,
    this.permissions = const [],
    this.homeWidgets = const [],
    this.routePrefixesAllow = const [],
  });

  final String roleKey;
  final List<String> permissions;
  final List<String> homeWidgets;
  final List<String> routePrefixesAllow;

  factory RolePackEntry.fromJson(Map<String, dynamic> json) {
    return RolePackEntry(
      roleKey: json['role_key'] as String? ?? json['roleKey'] as String? ?? '',
      permissions: List<String>.from(json['permissions'] as List? ?? const []),
      homeWidgets: List<String>.from(
        json['home_widgets'] as List? ??
            json['homeWidgets'] as List? ??
            const [],
      ),
      routePrefixesAllow: List<String>.from(
        json['route_prefixes_allow'] as List? ??
            json['routePrefixesAllow'] as List? ??
            const [],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'role_key': roleKey,
    'permissions': permissions,
    'home_widgets': homeWidgets,
    'route_prefixes_allow': routePrefixesAllow,
  };
}
