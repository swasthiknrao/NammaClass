import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/nc_feature.dart';
import '../services/app_logger.dart';
import 'feature_route_gate.dart';

/// Runtime tenant policy loaded from [assets/config/*.json] (no hard-coded matrices).
class TenantPolicyLoader {
  TenantPolicyLoader._();

  static bool _initialized = false;

  static Map<String, Set<String>> _roleToModuleKeys = {};
  static final List<FeatureRouteGate> _featureGates = [];
  static Map<String, String> _roleAliases = {};
  static List<ThemePresetOption> _themePresets = [];
  static String _defaultRolePackId = '';
  static WebUserManagementDemoData _userMgmtDemo =
      WebUserManagementDemoData.fallback();
  static Map<String, int> _moduleMrrInrPer1k = {};
  static Map<String, ModuleCatalogEntry> _moduleCatalogByKey = {};

  /// Indicative ₹ / 1k student MAU / month per module key ([assets/config/module_mrr_inr.json]).
  static Map<String, int> get moduleMrrInrPer1k =>
      Map.unmodifiable(_moduleMrrInrPer1k);

  /// Role key → required [NcFeature.key] strings (from JSON).
  static Map<String, Set<String>> get roleToModuleKeys =>
      Map.unmodifiable(_roleToModuleKeys);

  /// Longest-prefix-first route gates.
  static List<FeatureRouteGate> get featureGates =>
      List.unmodifiable(_featureGates);

  /// Product modules that have real route/feature gating in the app (see
  /// [featureGates]). Used e.g. by Super Admin "add college" so unsubscribed
  /// toggles are not offered for catalog-only enum values.
  static Set<NcFeature> get routeGatedNcFeatures =>
      _featureGates.map((g) => g.feature).toSet();

  /// Stable list for UI (sorted by module key).
  static List<NcFeature> get subscribableNcFeatures {
    final list = routeGatedNcFeatures.toList();
    list.sort((a, b) => a.key.compareTo(b.key));
    return list;
  }

  /// Friendly module metadata keyed by [NcFeature.key].
  static Map<String, ModuleCatalogEntry> get moduleCatalogByKey =>
      Map.unmodifiable(_moduleCatalogByKey);

  /// Catalog entries for modules that are actually route-gated in this build.
  static List<ModuleCatalogEntry> get visibleModuleCatalog {
    final list = subscribableNcFeatures.map(moduleCatalogForFeature).toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  static ModuleCatalogEntry moduleCatalogForFeature(NcFeature feature) {
    return _moduleCatalogByKey[feature.key] ??
        ModuleCatalogEntry.fallback(feature.key);
  }

  /// API/JWT alias → canonical [UserRole.name].
  static Map<String, String> get roleAliases => Map.unmodifiable(_roleAliases);

  static List<ThemePresetOption> get themePresets =>
      List.unmodifiable(_themePresets);

  static String get defaultRolePackId => _defaultRolePackId;

  static WebUserManagementDemoData get webUserManagementDemo => _userMgmtDemo;

  static Future<void> loadAll() async {
    if (_initialized) return;

    final roleJson = await rootBundle.loadString(
      'assets/config/role_module_requirements.json',
    );
    _applyRoleModuleRequirements(jsonDecode(roleJson) as List<dynamic>);

    final aliasJson = await rootBundle.loadString(
      'assets/config/role_entitlement_aliases.json',
    );
    _applyAliases(jsonDecode(aliasJson) as Map<String, dynamic>);

    final gatesJson = await rootBundle.loadString(
      'assets/config/feature_route_gates.json',
    );
    _applyFeatureGates(jsonDecode(gatesJson) as Map<String, dynamic>);

    final themeJson = await rootBundle.loadString(
      'assets/config/theme_presets.json',
    );
    _applyThemePresets(jsonDecode(themeJson) as Map<String, dynamic>);

    final userJson = await rootBundle.loadString(
      'assets/data/web_user_management_demo.json',
    );
    _userMgmtDemo = WebUserManagementDemoData.fromJson(
      jsonDecode(userJson) as Map<String, dynamic>,
    );

    final mrrJson = await rootBundle.loadString(
      'assets/config/module_mrr_inr.json',
    );
    _applyMrrRates(jsonDecode(mrrJson) as Map<String, dynamic>);

    final moduleCatalogJson = await rootBundle.loadString(
      'assets/config/module_catalog.json',
    );
    _applyModuleCatalog(jsonDecode(moduleCatalogJson) as Map<String, dynamic>);

    _initialized = true;
  }

  static void _applyMrrRates(Map<String, dynamic> json) {
    _moduleMrrInrPer1k = {};
    final raw = json['rates'] as Map<String, dynamic>? ?? {};
    for (final e in raw.entries) {
      final v = e.value;
      if (v is num) {
        _moduleMrrInrPer1k[e.key] = v.round();
      }
    }
  }

  static void _applyModuleCatalog(Map<String, dynamic> json) {
    final out = <String, ModuleCatalogEntry>{};
    final list = json['modules'] as List<dynamic>? ?? [];
    for (final raw in list) {
      final entry = ModuleCatalogEntry.fromJson(
        Map<String, dynamic>.from(raw as Map),
      );
      if (entry.moduleKey.isEmpty) continue;
      if (NcFeatureX.fromKey(entry.moduleKey) == null) {
        AppLogger.instance.warn(
          'TenantPolicyLoader: unknown module_catalog key "${entry.moduleKey}"',
        );
        continue;
      }
      out[entry.moduleKey] = entry;
    }
    _moduleCatalogByKey = out;
  }

  static void _applyRoleModuleRequirements(List<dynamic> list) {
    _roleToModuleKeys = {};
    for (final raw in list) {
      final o = Map<String, dynamic>.from(raw as Map);
      final roleKey = o['role_key'] as String?;
      final req = o['requires_modules'] as List<dynamic>?;
      if (roleKey == null) continue;
      _roleToModuleKeys[roleKey] = req?.map((e) => e.toString()).toSet() ?? {};
    }
  }

  static void _applyAliases(Map<String, dynamic> json) {
    final raw = json['aliases'] as Map<String, dynamic>? ?? {};
    _roleAliases = raw.map((k, v) => MapEntry(k, v.toString()));
  }

  static void _applyFeatureGates(Map<String, dynamic> json) {
    _featureGates.clear();
    final list = json['gates'] as List<dynamic>? ?? [];
    for (final raw in list) {
      final o = Map<String, dynamic>.from(raw as Map);
      final prefix = o['path_prefix'] as String?;
      final mod = o['requires_module'] as String?;
      if (prefix == null || mod == null) continue;
      final feature = NcFeatureX.fromKey(mod);
      if (feature == null) {
        AppLogger.instance.error(
          'TenantPolicyLoader: unknown requires_module "$mod" for $prefix',
          null,
          null,
        );
        continue;
      }
      _featureGates.add(FeatureRouteGate(prefix, feature));
    }
    _featureGates.sort((a, b) => b.prefix.length.compareTo(a.prefix.length));
  }

  static void _applyThemePresets(Map<String, dynamic> json) {
    final rawPack = json['default_role_pack_id'];
    _defaultRolePackId = rawPack?.toString() ?? '';
    final list = json['presets'] as List<dynamic>? ?? [];
    _themePresets = list
        .map((raw) {
          final o = Map<String, dynamic>.from(raw as Map);
          return ThemePresetOption(
            id: o['id'] as String? ?? '',
            label: o['label'] as String? ?? (o['id'] as String? ?? ''),
          );
        })
        .where((p) => p.id.isNotEmpty)
        .toList();
  }

  /// For tests — clears in-memory policy (next [loadAll] reloads from bundle).
  @visibleForTesting
  static void resetForTest() {
    _initialized = false;
    _roleToModuleKeys = {};
    _featureGates.clear();
    _roleAliases = {};
    _themePresets = [];
    _defaultRolePackId = '';
    _moduleMrrInrPer1k = {};
    _moduleCatalogByKey = {};
    _userMgmtDemo = WebUserManagementDemoData.fallback();
  }
}

class ThemePresetOption {
  const ThemePresetOption({required this.id, required this.label});

  final String id;
  final String label;
}

class ModuleCatalogEntry {
  const ModuleCatalogEntry({
    required this.moduleKey,
    required this.category,
    required this.sortOrder,
    required this.title,
    required this.question,
    required this.subtitle,
    required this.suggestedRoles,
    required this.subFeatures,
  });

  final String moduleKey;
  final String category;
  final int sortOrder;
  final String title;
  final String question;
  final String subtitle;
  final List<String> suggestedRoles;
  final List<ModuleSubFeatureOption> subFeatures;

  factory ModuleCatalogEntry.fromJson(Map<String, dynamic> json) {
    final key = json['module_key']?.toString() ?? '';
    return ModuleCatalogEntry(
      moduleKey: key,
      category: json['category']?.toString() ?? 'Other',
      sortOrder: (json['sort_order'] as num?)?.round() ?? 999,
      title: json['title']?.toString() ?? _fallbackTitle(key),
      question:
          json['question']?.toString() ?? 'Enable ${_fallbackTitle(key)}?',
      subtitle: json['subtitle']?.toString() ?? '',
      suggestedRoles: List<String>.from(json['suggested_roles'] as List? ?? []),
      subFeatures: (json['sub_features'] as List<dynamic>? ?? [])
          .map(
            (raw) => ModuleSubFeatureOption.fromJson(
              Map<String, dynamic>.from(raw as Map),
            ),
          )
          .where((option) => option.id.isNotEmpty)
          .toList(),
    );
  }

  factory ModuleCatalogEntry.fallback(String moduleKey) {
    final title = _fallbackTitle(moduleKey);
    return ModuleCatalogEntry(
      moduleKey: moduleKey,
      category: 'Other',
      sortOrder: 999,
      title: title,
      question: 'Enable $title?',
      subtitle: 'Route-gated module available in this build.',
      suggestedRoles: const [],
      subFeatures: const [],
    );
  }

  static String _fallbackTitle(String key) {
    return key
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}

class ModuleSubFeatureOption {
  const ModuleSubFeatureOption({
    required this.id,
    required this.title,
    required this.question,
  });

  final String id;
  final String title;
  final String question;

  factory ModuleSubFeatureOption.fromJson(Map<String, dynamic> json) {
    return ModuleSubFeatureOption(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
    );
  }
}

class WebUserManagementDemoData {
  const WebUserManagementDemoData({
    required this.failedLoginAlert,
    required this.failedLoginMessage,
    required this.users,
    required this.roles,
    required this.auditLog,
    required this.rolesTabPermissionColumns,
    required this.rolesTabModuleRows,
  });

  final bool failedLoginAlert;
  final String failedLoginMessage;
  final List<WebUserMgmtUser> users;
  final List<WebUserMgmtRole> roles;
  final List<WebUserMgmtAudit> auditLog;
  final List<String> rolesTabPermissionColumns;
  final List<String> rolesTabModuleRows;

  factory WebUserManagementDemoData.fromJson(Map<String, dynamic> json) {
    final alert = json['failed_login_alert'] as Map<String, dynamic>?;
    final rolesTab = json['roles_tab'] as Map<String, dynamic>? ?? {};

    return WebUserManagementDemoData(
      failedLoginAlert: alert?['show'] as bool? ?? false,
      failedLoginMessage: alert?['message'] as String? ?? '',
      users: (json['users'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                WebUserMgmtUser.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                WebUserMgmtRole.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      auditLog: (json['audit_log'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                WebUserMgmtAudit.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      rolesTabPermissionColumns: List<String>.from(
        rolesTab['permission_columns'] as List? ?? [],
      ),
      rolesTabModuleRows: List<String>.from(
        rolesTab['module_rows'] as List? ?? [],
      ),
    );
  }

  factory WebUserManagementDemoData.fallback() {
    return const WebUserManagementDemoData(
      failedLoginAlert: false,
      failedLoginMessage: '',
      users: [],
      roles: [],
      auditLog: [],
      rolesTabPermissionColumns: [],
      rolesTabModuleRows: [],
    );
  }
}

class WebUserMgmtUser {
  const WebUserMgmtUser({
    required this.name,
    required this.email,
    required this.role,
    required this.lastLogin,
    required this.status,
  });

  final String name;
  final String email;
  final String role;
  final String lastLogin;
  final String status;

  factory WebUserMgmtUser.fromJson(Map<String, dynamic> json) {
    return WebUserMgmtUser(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      lastLogin: json['last_login'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}

class WebUserMgmtRole {
  const WebUserMgmtRole({required this.title, required this.modules});

  final String title;
  final List<String> modules;

  factory WebUserMgmtRole.fromJson(Map<String, dynamic> json) {
    return WebUserMgmtRole(
      title: json['title'] as String? ?? '',
      modules: List<String>.from(json['modules'] as List? ?? []),
    );
  }
}

class WebUserMgmtAudit {
  const WebUserMgmtAudit({
    required this.user,
    required this.time,
    required this.device,
    required this.ip,
    required this.location,
    required this.success,
  });

  final String user;
  final String time;
  final String device;
  final String ip;
  final String location;
  final bool success;

  factory WebUserMgmtAudit.fromJson(Map<String, dynamic> json) {
    return WebUserMgmtAudit(
      user: json['user'] as String? ?? '',
      time: json['time'] as String? ?? '',
      device: json['device'] as String? ?? '',
      ip: json['ip'] as String? ?? '',
      location: json['location'] as String? ?? '',
      success: json['success'] as bool? ?? false,
    );
  }
}
