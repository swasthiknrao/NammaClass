import '../config/tenant_policy_loader.dart';
import '../../domain/entities/nc_feature.dart';
import '../../domain/entities/tenant_profile.dart';

/// Sum of configured module rates for enabled SKUs (₹ / 1k student MAU band / month).
/// Uses [TenantPolicyLoader.moduleMrrInrPer1k] from [assets/config/module_mrr_inr.json].
int estimatedMrrInrPer1kMauBand(TenantProfile profile) {
  var sum = 0;
  final rates = TenantPolicyLoader.moduleMrrInrPer1k;
  for (final f in NcFeature.values) {
    if (!profile.hasFeature(f)) continue;
    sum += rates[f.key] ?? 0;
  }
  return sum;
}
