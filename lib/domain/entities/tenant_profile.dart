import 'nc_feature.dart';

/// Represents a single institution's subscription and branding profile.
/// Fetched at launch via `/tenant/config` and drives the entire app experience:
/// colors, nav tabs, visible routes, and available features.
class TenantProfile {
  const TenantProfile({
    required this.tenantId,
    required this.institutionName,
    required this.logoUrl,
    required this.appIconUrl,
    required this.primaryHex,
    required this.accentHex,
    required this.features,
    required this.timezone,
    required this.currency,
    required this.languages,
  });

  final String tenantId;
  final String institutionName;

  /// URL to the institution's logo displayed in the app bar / splash.
  final String logoUrl;

  /// URL to the custom app icon (used in white-label builds).
  final String appIconUrl;

  /// 6-character hex (no '#') for the primary brand color.
  /// e.g. "1B4F72" — parsed at runtime to override AppColors.primary.
  final String primaryHex;

  /// 6-character hex (no '#') for the accent color.
  final String accentHex;

  /// Set of features this institution has subscribed to.
  /// Drives navigation visibility, route guards, and widget rendering.
  final Set<NcFeature> features;

  /// IANA timezone identifier — e.g. "Asia/Kolkata"
  final String timezone;

  /// ISO 4217 currency code — e.g. "INR"
  final String currency;

  /// Ordered list of BCP-47 language codes supported by this tenant.
  /// First entry is the default app locale.
  final List<String> languages;

  /// Returns true if this institution has subscribed to [feature].
  bool hasFeature(NcFeature feature) => features.contains(feature);

  /// Convenience getter: parsed primary color value for use in Color().
  int get primaryColorValue => int.parse('0xFF$primaryHex');

  /// Convenience getter: parsed accent color value for use in Color().
  int get accentColorValue => int.parse('0xFF$accentHex');

  /// Accepts camelCase (Flutter / client) or snake_case (API / JSON file) keys.
  factory TenantProfile.fromJson(Map<String, dynamic> json) {
    final tenantId =
        json['tenantId'] as String? ?? json['tenant_id'] as String? ?? '';
    final institutionName =
        json['institutionName'] as String? ??
        json['institution_name'] as String? ??
        '';
    final rawFeatures = (json['features'] as List<dynamic>? ?? [])
        .map((e) => NcFeatureX.fromKey(e as String))
        .whereType<NcFeature>()
        .toSet();

    return TenantProfile(
      tenantId: tenantId,
      institutionName: institutionName,
      logoUrl:
          (json['logoUrl'] as String?) ?? (json['logo_url'] as String?) ?? '',
      appIconUrl:
          (json['appIconUrl'] as String?) ??
          (json['app_icon_url'] as String?) ??
          '',
      primaryHex:
          (json['primaryHex'] as String?) ??
          (json['primary_hex'] as String?) ??
          '1B4F72',
      accentHex:
          (json['accentHex'] as String?) ??
          (json['accent_hex'] as String?) ??
          'E67E22',
      features: rawFeatures,
      timezone: (json['timezone'] as String?) ?? 'Asia/Kolkata',
      currency: (json['currency'] as String?) ?? 'INR',
      languages: List<String>.from(json['languages'] as List? ?? ['en']),
    );
  }

  Map<String, dynamic> toJson() => {
    'tenantId': tenantId,
    'institutionName': institutionName,
    'logoUrl': logoUrl,
    'appIconUrl': appIconUrl,
    'primaryHex': primaryHex,
    'accentHex': accentHex,
    'features': features.map((f) => f.key).toList(),
    'timezone': timezone,
    'currency': currency,
    'languages': languages,
  };

  TenantProfile copyWith({
    String? tenantId,
    String? institutionName,
    String? logoUrl,
    String? appIconUrl,
    String? primaryHex,
    String? accentHex,
    Set<NcFeature>? features,
    String? timezone,
    String? currency,
    List<String>? languages,
  }) {
    return TenantProfile(
      tenantId: tenantId ?? this.tenantId,
      institutionName: institutionName ?? this.institutionName,
      logoUrl: logoUrl ?? this.logoUrl,
      appIconUrl: appIconUrl ?? this.appIconUrl,
      primaryHex: primaryHex ?? this.primaryHex,
      accentHex: accentHex ?? this.accentHex,
      features: features ?? this.features,
      timezone: timezone ?? this.timezone,
      currency: currency ?? this.currency,
      languages: languages ?? this.languages,
    );
  }
}
