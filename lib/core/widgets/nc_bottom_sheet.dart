import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Standardised bottom sheet scaffold with drag handle, title, and scrollable body.
class NcBottomSheet extends StatelessWidget {
  const NcBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.initialChildSize = 0.5,
    this.minChildSize = 0.25,
    this.maxChildSize = 0.9,
    this.expand = false,
  });

  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final bool expand;

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    List<Widget>? actions,
    double initialChildSize = 0.5,
    double minChildSize = 0.25,
    double maxChildSize = 0.9,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => NcBottomSheet(
        title: title,
        actions: actions,
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: expand,
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.md),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (title != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title!,
                          style: AppTypography.headlineMedium,
                        ),
                      ),
                      ...?actions,
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, size: 20),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
              ],
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
