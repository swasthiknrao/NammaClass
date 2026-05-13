import 'dart:async';

import 'package:flutter/material.dart';

import 'bone_data.dart';
import 'bone_registry.dart';
import 'nc_bone_renderer.dart';

/// Drop-in skeleton wrapper — mirrors Boneyard's `<Skeleton loading={...}>`.
///
/// Usage:
/// ```dart
/// NcSkeleton(
///   name: 'parent-home',
///   loading: state.isLoading,
///   child: _buildContent(state.data),
/// )
/// ```
///
/// Behaviour (matching Boneyard's runtime options):
/// - Looks up [name] in [NcBoneRegistry] and resolves the correct bone list
///   for the current viewport width (375 / 768 / 1280 breakpoints).
/// - Enforces a [minDisplay] floor (default 400 ms) so fast data fetches
///   don't cause a jarring flash of skeleton → content.
/// - When [loading] becomes false, fades to the [child] over [transitionMs]
///   (default 300 ms) via [AnimatedSwitcher] — Boneyard's `transition: true`.
/// - Each bone staggers in with a 50 ms delay (Boneyard: `stagger: 50`).
///
/// When the registry has no entry for [name] and [fallback] is null the widget
/// shows a simple full-width shimmer bar so the screen is never blank.
class NcSkeleton extends StatefulWidget {
  const NcSkeleton({
    super.key,
    required this.name,
    required this.loading,
    required this.child,
    this.minDisplay = const Duration(milliseconds: 400),
    this.transitionMs = 300,
    this.stagger = true,
    this.fallback,
  });

  /// Registry key — matches an entry in [NcBoneRegistry].
  final String name;

  /// Drives the skeleton. When true the skeleton is shown; when false the
  /// [child] fades in (after [minDisplay] has elapsed).
  final bool loading;

  /// Real content, rendered once [loading] is false.
  final Widget child;

  /// Minimum time the skeleton stays visible even if data arrives sooner.
  /// Prevents a jarring flash when the network is very fast.
  final Duration minDisplay;

  /// Duration of the fade-out transition in milliseconds (Boneyard: `transition`).
  final int transitionMs;

  /// Whether individual bones stagger on entry (Boneyard: `stagger: 50ms`).
  final bool stagger;

  /// Optional fallback widget shown when the registry has no entry for [name].
  /// If null a generic full-width shimmer bar is used.
  final Widget? fallback;

  @override
  State<NcSkeleton> createState() => _NcSkeletonState();
}

class _NcSkeletonState extends State<NcSkeleton> {
  /// True until both conditions hold: [widget.loading] is false AND the
  /// [widget.minDisplay] timer has fired.
  bool _showSkeleton = true;

  DateTime? _loadingStartedAt;
  Timer? _minDisplayTimer;

  @override
  void initState() {
    super.initState();
    if (widget.loading) {
      _loadingStartedAt = DateTime.now();
    } else {
      _showSkeleton = false;
    }
  }

  @override
  void didUpdateWidget(NcSkeleton old) {
    super.didUpdateWidget(old);

    // loading became true — record start time, ensure skeleton is visible.
    if (widget.loading && !old.loading) {
      _loadingStartedAt = DateTime.now();
      if (!_showSkeleton) setState(() => _showSkeleton = true);
    }

    // loading became false — wait for minDisplay floor, then reveal content.
    if (!widget.loading && old.loading) {
      _scheduleReveal();
    }
  }

  void _scheduleReveal() {
    _minDisplayTimer?.cancel();
    final elapsed = _loadingStartedAt == null
        ? widget.minDisplay
        : DateTime.now().difference(_loadingStartedAt!);

    final remaining = widget.minDisplay - elapsed;
    if (remaining <= Duration.zero) {
      // Already exceeded minimum — reveal immediately.
      if (mounted) setState(() => _showSkeleton = false);
    } else {
      _minDisplayTimer = Timer(remaining, () {
        if (mounted) setState(() => _showSkeleton = false);
      });
    }
  }

  @override
  void dispose() {
    _minDisplayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final skeletonWidget = _buildSkeleton(context, width);

        return AnimatedSwitcher(
          duration: Duration(milliseconds: widget.transitionMs),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: _showSkeleton
              ? KeyedSubtree(
                  key: const ValueKey('skeleton'),
                  child: skeletonWidget,
                )
              : KeyedSubtree(
                  key: const ValueKey('content'),
                  child: widget.child,
                ),
        );
      },
    );
  }

  Widget _buildSkeleton(BuildContext context, double width) {
    final resolved = NcBoneRegistry.resolve(widget.name, width);
    if (resolved == null) {
      return widget.fallback ?? _GenericShimmerFallback(width: width);
    }
    return NcBoneRenderer(
      bones: resolved.bones,
      containerHeight: resolved.height,
      stagger: widget.stagger,
    );
  }
}

/// Shown when the registry has no entry for the requested name.
/// A single full-width shimmer bar prevents a completely blank screen.
class _GenericShimmerFallback extends StatelessWidget {
  const _GenericShimmerFallback({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    return NcBoneRenderer(
      bones: [
        BoneData(x: 0, y: 0, w: 1.0, h: 200, radius: 12),
        BoneData(x: 0.043, y: 216, w: 0.6, h: 14, radius: 4),
        BoneData(x: 0.043, y: 238, w: 0.4, h: 12, radius: 4),
      ],
      containerHeight: 260,
    );
  }
}

/// The resolved output of [NcBoneRegistry.resolve] — bones + total height.
class ResolvedBones {
  const ResolvedBones({required this.bones, required this.height});
  final List<BoneData> bones;
  final double height;
}
