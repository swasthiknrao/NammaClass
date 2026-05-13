import '../../domain/entities/nc_feature.dart';

/// URL prefix gated by a product module; see [assets/config/feature_route_gates.json].
class FeatureRouteGate {
  const FeatureRouteGate(this.prefix, this.feature);

  final String prefix;
  final NcFeature feature;
}
