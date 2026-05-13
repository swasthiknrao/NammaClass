import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';
import 'bone_data.dart';

/// Renders a [List<BoneData>] as a shimmer skeleton layer.
///
/// Uses [LayoutBuilder] to convert fractional x/w values into real pixels,
/// then positions every bone inside a [Stack] of fixed height [containerHeight].
///
/// Each bone fades in individually with a [staggerMs] delay between bones
/// (Boneyard equivalent: `stagger: 50`). The shimmer sweep is shared across
/// all bones via a single [Shimmer.fromColors] ancestor, which is both more
/// performant and ensures the highlight travels as one wave — exactly as the
/// Boneyard web implementation animates.
///
/// Dark mode is detected from [ThemeData.brightness] and uses separate
/// base/highlight colours (mirrors Boneyard's `.dark` class detection).
class NcBoneRenderer extends StatelessWidget {
  const NcBoneRenderer({
    super.key,
    required this.bones,
    required this.containerHeight,
    this.stagger = true,
    this.staggerMs = 50,
  });

  /// Bone definitions to render.
  final List<BoneData> bones;

  /// Total height of the skeleton container in logical pixels.
  /// Should match the real content's height so layout does not jump.
  final double containerHeight;

  /// Whether to stagger bone entry animations.
  final bool stagger;

  /// Milliseconds between each bone's fade-in when [stagger] is true.
  final int staggerMs;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF2A2A2A) : AppColors.shimmerBase;
    final highlightColor = isDark
        ? const Color(0xFF3A3A3A)
        : AppColors.shimmerHighlight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;

        // Single Shimmer ancestor — highlight sweeps as one wave across all bones.
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          period: const Duration(milliseconds: 1600),
          child: SizedBox(
            width: containerWidth,
            height: containerHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (int i = 0; i < bones.length; i++)
                  _BoneTile(
                    key: ValueKey(i),
                    bone: bones[i],
                    containerWidth: containerWidth,
                    baseColor: baseColor,
                    staggerDelay: stagger
                        ? Duration(milliseconds: i * staggerMs)
                        : Duration.zero,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A single positioned shimmer bone inside the renderer stack.
class _BoneTile extends StatelessWidget {
  const _BoneTile({
    super.key,
    required this.bone,
    required this.containerWidth,
    required this.baseColor,
    required this.staggerDelay,
  });

  final BoneData bone;
  final double containerWidth;
  final Color baseColor;
  final Duration staggerDelay;

  @override
  Widget build(BuildContext context) {
    final left = bone.x * containerWidth;
    final width = bone.w * containerWidth;
    final height = bone.h;
    final top = bone.y;

    // For circle bones the spec says "use h as diameter" — clip to circle.
    final borderRadius = bone.isCircle
        ? BorderRadius.circular(height / 2)
        : BorderRadius.circular(bone.radius);

    final tile = Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(color: baseColor, borderRadius: borderRadius),
      ),
    );

    if (staggerDelay == Duration.zero) return tile;

    // Stagger: fade in from 0 opacity, slide in very slightly from right —
    // identical visual to the Boneyard shimmer bone entry.
    return tile
        .animate(delay: staggerDelay)
        .fadeIn(duration: 200.ms, curve: Curves.easeOut);
  }
}
