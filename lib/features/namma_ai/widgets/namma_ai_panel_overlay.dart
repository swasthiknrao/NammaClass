import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/namma_ai_panel_provider.dart';
import 'namma_ai_chat_view.dart';

/// Full-screen dim barrier + sliding glass panel from the right.
class NammaAiPanelOverlay extends ConsumerWidget {
  const NammaAiPanelOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panel = ref.watch(nammaAiPanelProvider);
    final notifier = ref.read(nammaAiPanelProvider.notifier);
    final size = MediaQuery.sizeOf(context);
    final expandedW = (size.width - 24).clamp(480.0, 960.0);
    final dockedW = (size.width * 0.44).clamp(300.0, 440.0);
    final width = panel.expanded ? expandedW : dockedW;

    return IgnorePointer(
      ignoring: !panel.visible,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: panel.visible ? 1 : 0,
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: notifier.close,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: panel.visible ? 2 : 0,
                  sigmaY: panel.visible ? 2 : 0,
                ),
                child: Container(
                  color: Colors.black.withValues(
                    alpha: panel.visible ? 0.38 : 0,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                offset: panel.visible ? Offset.zero : const Offset(1.05, 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  width: panel.visible ? width : 0,
                  height: size.height,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(),
                  child: panel.visible
                      ? _PanelChrome(
                          expanded: panel.expanded,
                          onClose: notifier.close,
                          onToggleExpand: notifier.toggleExpand,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelChrome extends StatelessWidget {
  const _PanelChrome({
    required this.expanded,
    required this.onClose,
    required this.onToggleExpand,
  });

  final bool expanded;
  final VoidCallback onClose;
  final VoidCallback onToggleExpand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 24,
      color: Colors.transparent,
      shadowColor: Colors.black54,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          bottomLeft: Radius.circular(28),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surfaceContainerLowest,
              ],
            ),
            border: Border(
              left: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                blurRadius: 40,
                spreadRadius: -4,
                offset: const Offset(-8, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.82),
                      theme.colorScheme.tertiary.withValues(alpha: 0.9),
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Namma AI',
                              style: AppTypography.titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              expanded
                                  ? 'Expanded workspace'
                                  : 'Copilot · tap expand for more room',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.88),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: expanded ? 'Dock panel' : 'Expand',
                        onPressed: onToggleExpand,
                        icon: Icon(
                          expanded
                              ? Icons.unfold_less_rounded
                              : Icons.open_in_full_rounded,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: onClose,
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Expanded(
                child: NammaAiChatView(embedded: true, compactPadding: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
