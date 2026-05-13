import 'entitlement_snapshot.dart';
import 'nc_feature.dart';
import 'tenant_nav_item.dart';
import 'theme_tokens.dart';

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
    this.schemaVersion = 1,
    this.entitlementSnapshot,
    this.themeTokens,
    this.navGraph = const [],
    this.rolePackIds = const [],
    this.intake,
  });

  /// JSON / API schema breaking-change version for this document.
  final int schemaVersion;

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
  /// When [entitlementSnapshot] lists modules, it takes precedence.
  final Set<NcFeature> features;

  /// Billing-backed module toggles and limits (optional until backend ships).
  final EntitlementSnapshot? entitlementSnapshot;

  /// Semantic theme tokens (preset, fonts, density).
  final ThemeTokens? themeTokens;

  /// Dynamic shell navigation entries.
  final List<TenantNavItem> navGraph;

  /// Role pack ids applied at provisioning (informational on client).
  final List<String> rolePackIds;

  /// Onboarding questionnaire blob (optional).
  final Map<String, dynamic>? intake;

  /// IANA timezone identifier — e.g. "Asia/Kolkata"
  final String timezone;

  /// ISO 4217 currency code — e.g. "INR"
  final String currency;

  /// Ordered list of BCP-47 language codes supported by this tenant.
  /// First entry is the default app locale.
  final List<String> languages;

  /// Returns true if this institution has subscribed to [feature].
  bool hasFeature(NcFeature feature) {
    final snap = entitlementSnapshot;
    if (snap != null && snap.modules.isNotEmpty) {
      return snap.modules[feature.key]?.enabled ?? false;
    }
    return features.contains(feature);
  }

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

    EntitlementSnapshot? snap;
    final rawSnap =
        json['entitlement_snapshot'] as Map<String, dynamic>? ??
        json['entitlementSnapshot'] as Map<String, dynamic>?;
    if (rawSnap != null) {
      snap = EntitlementSnapshot.fromJson(rawSnap);
    }

    ThemeTokens? tokens;
    final rawTheme =
        json['theme_tokens'] as Map<String, dynamic>? ??
        json['themeTokens'] as Map<String, dynamic>?;
    if (rawTheme != null) {
      tokens = ThemeTokens.fromJson(rawTheme);
    }

    final rawNav = json['nav_graph'] as List? ?? json['navGraph'] as List?;
    final nav = <TenantNavItem>[];
    if (rawNav != null) {
      for (final e in rawNav) {
        if (e is Map<String, dynamic>) {
          nav.add(TenantNavItem.fromJson(e));
        }
      }
    }

    return TenantProfile(
      schemaVersion:
          json['schema_version'] as int? ?? json['schemaVersion'] as int? ?? 1,
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
      entitlementSnapshot: snap,
      themeTokens: tokens,
      navGraph: nav,
      rolePackIds: List<String>.from(
        json['role_pack_ids'] as List? ??
            json['rolePackIds'] as List? ??
            const [],
      ),
      intake: json['intake'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['intake'] as Map)
          : null,
      timezone: (json['timezone'] as String?) ?? 'Asia/Kolkata',
      currency: (json['currency'] as String?) ?? 'INR',
      languages: List<String>.from(json['languages'] as List? ?? ['en']),
    );
  }

  Map<String, dynamic> toJson() => {
    'schema_version': schemaVersion,
    'tenantId': tenantId,
    'institutionName': institutionName,
    'logoUrl': logoUrl,
    'appIconUrl': appIconUrl,
    'primaryHex': primaryHex,
    'accentHex': accentHex,
    'features': features.map((f) => f.key).toList(),
    if (entitlementSnapshot != null)
      'entitlement_snapshot': entitlementSnapshot!.toJson(),
    if (themeTokens != null) 'theme_tokens': themeTokens!.toJson(),
    if (navGraph.isNotEmpty)
      'nav_graph': navGraph.map((e) => e.toJson()).toList(),
    if (rolePackIds.isNotEmpty) 'role_pack_ids': rolePackIds,
    if (intake != null) 'intake': intake,
    'timezone': timezone,
    'currency': currency,
    'languages': languages,
  };

  TenantProfile copyWith({
    int? schemaVersion,
    String? tenantId,
    String? institutionName,
    String? logoUrl,
    String? appIconUrl,
    String? primaryHex,
    String? accentHex,
    Set<NcFeature>? features,
    EntitlementSnapshot? entitlementSnapshot,
    ThemeTokens? themeTokens,
    List<TenantNavItem>? navGraph,
    List<String>? rolePackIds,
    Map<String, dynamic>? intake,
    String? timezone,
    String? currency,
    List<String>? languages,
  }) {
    return TenantProfile(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      tenantId: tenantId ?? this.tenantId,
      institutionName: institutionName ?? this.institutionName,
      logoUrl: logoUrl ?? this.logoUrl,
      appIconUrl: appIconUrl ?? this.appIconUrl,
      primaryHex: primaryHex ?? this.primaryHex,
      accentHex: accentHex ?? this.accentHex,
      features: features ?? this.features,
      entitlementSnapshot: entitlementSnapshot ?? this.entitlementSnapshot,
      themeTokens: themeTokens ?? this.themeTokens,
      navGraph: navGraph ?? this.navGraph,
      rolePackIds: rolePackIds ?? this.rolePackIds,
      intake: intake ?? this.intake,
      timezone: timezone ?? this.timezone,
      currency: currency ?? this.currency,
      languages: languages ?? this.languages,
    );
  }
}
