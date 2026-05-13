import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/nc_feature.dart';
import '../../features/tenant/providers/tenant_provider.dart';

/// Renders [child] only when the active tenant has subscribed to [feature].
/// Returns [SizedBox.shrink] (zero size, no layout cost) if not subscribed.
///
/// Usage:
/// ```dart
/// FeatureGate(
///   feature: NcFeature.transport,
///   child: BusTrackingCard(),
/// )
/// ```
///
/// For navigation items use the [tenantProfileProvider] directly so you can
/// conditionally omit list entries rather than rendering empty items.
class FeatureGate extends ConsumerWidget {
  const FeatureGate({
    super.key,
    required this.feature,
    required this.child,
    this.fallback,
  });

  final NcFeature feature;
  final Widget child;

  /// Optional widget to show when the feature is not subscribed.
  /// Defaults to [SizedBox.shrink].
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenant = ref.watch(tenantProfileProvider);
    if (!tenant.hasFeature(feature)) {
      return fallback ?? const SizedBox.shrink();
    }
    return child;
  }
}
