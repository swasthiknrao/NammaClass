import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/notification_icon_button.dart';
import '../../../routing/app_routes.dart';

/// Search + notifications for warden mobile AppBars.
class WardenPortalBarActions extends ConsumerWidget {
  const WardenPortalBarActions({
    super.key,
    this.iconColor = Colors.white,
    this.dense = false,
  });

  final Color iconColor;
  final bool dense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sz = dense ? 20.0 : 22.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Search',
          icon: Icon(Icons.search, color: iconColor, size: sz + 2),
          onPressed: () => context.go(AppRoutes.search),
        ),
        NotificationIconButton(iconColor: iconColor, iconSize: sz + 2),
      ],
    );
  }
}
