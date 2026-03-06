import 'package:flutter/material.dart';

import '../feedback/app_skeleton_list.dart';

/// List wrapper with optional empty state and loading skeleton.
class AppListView<T> extends StatelessWidget {
  const AppListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.loading = false,
    this.emptyMessage = 'No items',
    this.emptyWidget,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final bool loading;
  final String emptyMessage;
  final Widget? emptyWidget;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return AppSkeletonList();
    }
    if (itemCount == 0) {
      return Center(
        child: emptyWidget ??
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                emptyMessage,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
      );
    }
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
