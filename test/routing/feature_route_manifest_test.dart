import 'package:flutter_test/flutter_test.dart';

import 'package:nammaclass/core/config/tenant_policy_loader.dart';
import 'package:nammaclass/routing/app_routes.dart';
import 'package:nammaclass/routing/feature_route_manifest.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await TenantPolicyLoader.loadAll();
  });

  tearDownAll(() {
    TenantPolicyLoader.resetForTest();
  });

  test('featureRouteGates are sorted with longer prefixes first', () {
    for (var i = 0; i < featureRouteGates.length - 1; i++) {
      expect(
        featureRouteGates[i].prefix.length >=
            featureRouteGates[i + 1].prefix.length,
        true,
        reason:
            '${featureRouteGates[i].prefix} should not precede a longer prefix ${featureRouteGates[i + 1].prefix}',
      );
    }
  });

  test('/web/transport/routes precedes /web/transport in list order', () {
    final iRoutes = featureRouteGates.indexWhere(
      (g) => g.prefix == AppRoutes.webTransportRoutes,
    );
    final iBase = featureRouteGates.indexWhere(
      (g) => g.prefix == AppRoutes.webTransport,
    );
    expect(iRoutes >= 0, true);
    expect(iBase >= 0, true);
    expect(iRoutes < iBase, true);
  });
}
