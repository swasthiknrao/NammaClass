import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nammaclass/features/teacher/widgets/timeline/timeline_roadmap_view.dart';

void main() {
  testWidgets('timeline roadmap renders toolbar and sections', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(height: 700, child: TimelineRoadmapView()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Work Breakdown'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
    expect(find.text('Link Mode'), findsOneWidget);
  });
}
