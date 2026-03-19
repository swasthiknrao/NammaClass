import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nammaclass/features/teacher/providers/teacher_providers.dart';

void main() {
  test('timeline move propagates to dependent tasks', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(teacherTimelineProvider.notifier);
    final initial = container.read(teacherTimelineProvider);
    final root = initial.dependencies.first.fromTaskId;
    final dependent = initial.dependencies.first.toTaskId;

    final rootBefore = initial.items.firstWhere((e) => e.id == root);
    final dependentBefore = initial.items.firstWhere((e) => e.id == dependent);

    notifier.moveTask(root, const Duration(days: 2));

    final next = container.read(teacherTimelineProvider);
    final rootAfter = next.items.firstWhere((e) => e.id == root);
    final dependentAfter = next.items.firstWhere((e) => e.id == dependent);

    expect(
      rootAfter.startDate.difference(rootBefore.startDate),
      const Duration(days: 2),
    );
    expect(
      dependentAfter.startDate.difference(dependentBefore.startDate),
      const Duration(days: 2),
    );
  });
}
