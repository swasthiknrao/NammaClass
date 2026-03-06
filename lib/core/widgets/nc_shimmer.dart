import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

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
