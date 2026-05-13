import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nammaclass/app.dart';
import 'package:nammaclass/core/config/tenant_policy_loader.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await TenantPolicyLoader.loadAll();
  });

  tearDownAll(() {
    TenantPolicyLoader.resetForTest();
  });

  testWidgets('App loads and shows shell content', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
