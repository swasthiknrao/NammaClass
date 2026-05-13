import '../../domain/entities/nc_feature.dart';
import '../../domain/entities/tenant_nav_item.dart';
import '../../domain/entities/tenant_profile.dart';

/// Returns nav items visible for [roleKey] (e.g. `teacher`) given profile.
Iterable<TenantNavItem> visibleNavItems(
  TenantProfile profile,
  String roleKey,
) sync* {
  if (profile.navGraph.isEmpty) return;
  for (final item in profile.navGraph) {
    if (item.rolesAllow.isNotEmpty && !item.rolesAllow.contains(roleKey)) {
      continue;
    }
    if (item.requiredFeature != null) {
      final f = NcFeatureX.fromKey(item.requiredFeature!);
      if (f != null && !profile.hasFeature(f)) continue;
    }
    yield item;
  }
}
