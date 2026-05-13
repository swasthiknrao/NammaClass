import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/nc_feature.dart';
import '../../domain/entities/tenant_profile.dart';
import '../services/app_logger.dart';

/// Asset path for editable tenant / institution config in mock mode (no API).
///
/// Edit [tenant_config.json] under `assets/config/` — use snake_case keys to
/// match future API / DB column style, or camelCase (both are accepted).
const String kTenantConfigAssetPath = 'assets/config/tenant_config.json';

/// Loads [TenantProfile] from the bundled JSON file.
///
/// Returns `null` if the asset is missing, invalid JSON, or fails to parse
/// into a [TenantProfile]. Callers should fall back to mock Dart profiles.
Future<TenantProfile?> loadTenantProfileFromAsset() async {
  try {
    final raw = await rootBundle.loadString(kTenantConfigAssetPath);
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final profile = TenantProfile.fromJson(map);

    // Empty `features` in JSON means "not configured yet" — keep app usable.
    if (profile.features.isEmpty) {
      return profile.copyWith(features: NcFeature.values.toSet());
    }
    return profile;
  } catch (e, st) {
    AppLogger.instance.debug(
      'tenant_config.json not loaded (using fallback)',
      e,
      st,
    );
    return null;
  }
}
