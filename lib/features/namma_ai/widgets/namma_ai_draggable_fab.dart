import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/nc_feature.dart';
import '../../../routing/app_routes.dart';
import '../../tenant/providers/tenant_provider.dart';
import '../providers/namma_ai_fab_layout_provider.dart';
import '../providers/namma_ai_panel_provider.dart';

const _fabSize = 56.0;
const _edge = 8.0;

/// Smart, draggable Namma AI launcher. Hidden while the side panel is open.
class NammaAiDraggableFab extends ConsumerStatefulWidget {
  const NammaAiDraggableFab({super.key, required this.dockAboveBottomNav});

  /// When true, reserves space for [NavigationBar] / pill nav (~88dp + padding).
  final bool dockAboveBottomNav;

  @override
  ConsumerState<NammaAiDraggableFab> createState() =>
      _NammaAiDraggableFabState();
}

class _NammaAiDraggableFabState extends ConsumerState<NammaAiDraggableFab> {
  @override
  Widget build(BuildContext context) {
    final tenant = ref.watch(tenantProfileProvider);
    final panel = ref.watch(nammaAiPanelProvider);
    final path = GoRouterState.of(context).uri.path;
    final mq = MediaQuery.of(context);
    final size = mq.size;

    final eligible =
        tenant.hasFeature(NcFeature.aiInsights) &&
        path != AppRoutes.nammaAi &&
        !panel.visible;
    if (!eligible) return const SizedBox.shrink();

    final safeTop = mq.padding.top + _edge;
    final navClearance = widget.dockAboveBottomNav
        ? 88.0 + mq.padding.bottom
        : 24.0 + mq.padding.bottom;
    final defaultBottom = navClearance + _edge;
    final defaultRight = 16.0;

    final custom = ref.watch(nammaAiFabAnchorProvider);
    final fromRight = custom?.fromRight ?? defaultRight;
    final fromBottom = custom?.fromBottom ?? defaultBottom;

    final maxRight = (size.width - _fabSize - _edge).clamp(
      _edge,
      double.infinity,
    );
    final maxBottom = (size.height - _fabSize - safeTop).clamp(
      navClearance,
      double.infinity,
    );
    final minRight = _edge;
    final minBottom = navClearance;

    final clamped =
        NammaAiFabAnchor(fromRight: fromRight, fromBottom: fromBottom).clamp(
          minRight: minRight,
          maxRight: maxRight,
          minBottom: minBottom,
          maxBottom: maxBottom,
        );

    return Positioned(
      right: clamped.fromRight,
      bottom: clamped.fromBottom,
      child: Tooltip(
        message: 'Namma AI — drag to move · double-tap to reset position',
        child: Material(
          elevation: 8,
          shadowColor: Colors.black54,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: GestureDetector(
            onTap: () => ref.read(nammaAiPanelProvider.notifier).open(),
            onDoubleTap: () =>
                ref.read(nammaAiFabAnchorProvider.notifier).reset(),
            onPanUpdate: (details) {
              final current =
                  ref.read(nammaAiFabAnchorProvider) ??
                  NammaAiFabAnchor(
                    fromRight: defaultRight,
                    fromBottom: defaultBottom,
                  );
              final next =
                  NammaAiFabAnchor(
                    fromRight: current.fromRight - details.delta.dx,
                    fromBottom: current.fromBottom - details.delta.dy,
                  ).clamp(
                    minRight: minRight,
                    maxRight: maxRight,
                    minBottom: minBottom,
                    maxBottom: maxBottom,
                  );
              ref.read(nammaAiFabAnchorProvider.notifier).setAnchor(next);
            },
            child: Container(
              width: _fabSize,
              height: _fabSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.75),
                    Theme.of(context).colorScheme.tertiary,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    blurRadius: 16,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 26),
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: Icon(
                      Icons.drag_indicator,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
