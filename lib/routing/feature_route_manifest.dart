import '../core/config/feature_route_gate.dart';
import '../core/config/tenant_policy_loader.dart';

/// Feature-gated routes — populated from [assets/config/feature_route_gates.json].
List<FeatureRouteGate> get featureRouteGates => TenantPolicyLoader.featureGates;
