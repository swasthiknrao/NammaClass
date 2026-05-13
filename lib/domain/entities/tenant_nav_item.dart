/// One entry in the tenant navigation manifest (`nav_graph` array).
class TenantNavItem {
  const TenantNavItem({
    required this.id,
    required this.routePrefix,
    this.labelKey,
    this.icon,
    this.requiredFeature,
    this.rolesAllow = const [],
  });

  final String id;
  final String? labelKey;
  final String? icon;
  final String routePrefix;
  final String? requiredFeature;
  final List<String> rolesAllow;

  factory TenantNavItem.fromJson(Map<String, dynamic> json) {
    return TenantNavItem(
      id: json['id'] as String? ?? '',
      labelKey: json['label_key'] as String? ?? json['labelKey'] as String?,
      icon: json['icon'] as String?,
      routePrefix:
          json['route_prefix'] as String? ??
          json['routePrefix'] as String? ??
          '',
      requiredFeature:
          json['required_feature'] as String? ??
          json['requiredFeature'] as String?,
      rolesAllow: List<String>.from(
        json['roles_allow'] as List? ?? json['rolesAllow'] as List? ?? const [],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (labelKey != null) 'label_key': labelKey,
    if (icon != null) 'icon': icon,
    'route_prefix': routePrefix,
    if (requiredFeature != null) 'required_feature': requiredFeature,
    if (rolesAllow.isNotEmpty) 'roles_allow': rolesAllow,
  };
}
