import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Unified shimmer bone — the primary building block used by [NcBoneRenderer].
///
/// Covers both rectangular and circular bones via the [isCircle] flag,
/// matching the master prompt §24.1 `NcShimmer` specification exactly.
///
/// ```dart
/// // Rectangle
/// NcShimmer(width: 200, height: 14, radius: AppRadius.xs)
///
/// // Circle (avatar)
/// NcShimmer(width: 48, height: 48, isCircle: true)
/// ```
class NcShimmer extends StatelessWidget {
  const NcShimmer({
    super.key,
    required this.width,
    required this.height,
    this.radius = AppRadius.sm,
    this.isCircle = false,
  });

  final double width;
  final double height;

  /// Corner radius. Ignored when [isCircle] is true.
  final double radius;

  /// When true renders a circle; [radius] is derived from [width].
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF2A2A2A) : AppColors.shimmerBase;
    final highlightColor = isDark
        ? const Color(0xFF3A3A3A)
        : AppColors.shimmerHighlight;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: isCircle
              ? BorderRadius.circular(width / 2)
              : BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Shimmer box (rectangle placeholder).
class NcShimmerBox extends StatelessWidget {
  const NcShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.radius = AppRadius.xs,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Shimmer circle placeholder (e.g. avatar).
class NcShimmerCircle extends StatelessWidget {
  const NcShimmerCircle({super.key, this.radius = 20});
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.shimmerBase,
      ),
    );
  }
}

/// Full list-item shimmer card (matches NcCard dimensions).
class NcShimmerCard extends StatelessWidget {
  const NcShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 22, backgroundColor: AppColors.shimmerBase),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBase,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 120,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBase,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer list — 5 placeholder cards.
class NcShimmerList extends StatelessWidget {
  const NcShimmerList({super.key, this.itemCount = 5});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (_) => const NcShimmerCard()),
    );
  }
}

/// Shimmer stat card (for dashboards).
class NcShimmerStatCard extends StatelessWidget {
  const NcShimmerStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}
