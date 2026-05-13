/// Boneyard-inspired skeleton data model for NammaClass.
///
/// A [BoneData] encodes one skeleton rectangle (or circle) as geometry
/// relative to its container — mirroring Boneyard's compact array format:
/// `[x%, y_px, w%, h_px, borderRadius, isCircle?]`
///
/// Using data instead of widget trees means:
/// - Bones are serialisable / versionable
/// - A single renderer widget handles every screen
/// - Responsive variants are just different lists keyed by breakpoint
library;

/// A single skeleton "bone" — one shimmer rectangle or circle.
///
/// [x] and [w] are **fractions** of the container width (0.0 – 1.0).
/// [y] and [h] are **absolute pixel** values within the skeleton container.
class BoneData {
  const BoneData({
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    this.radius = 4.0,
    this.isCircle = false,
  });

  /// Left offset as a fraction of container width (0.0 = left edge).
  final double x;

  /// Top offset in logical pixels from the container top.
  final double y;

  /// Width as a fraction of container width.
  final double w;

  /// Height in logical pixels.
  final double h;

  /// Corner radius in logical pixels. Ignored when [isCircle] is true.
  final double radius;

  /// When true the bone is rendered as a perfect circle; [radius] is ignored
  /// and the shorter dimension (h) is used as the diameter.
  final bool isCircle;

  @override
  String toString() =>
      'BoneData(x:$x, y:$y, w:$w, h:$h, r:$radius, circle:$isCircle)';
}

/// A map from viewport-width breakpoints to bone lists.
///
/// Resolution follows the Boneyard nearest-<= rule:
/// given [width], pick the largest key that is <= width.
/// Supported keys: 375 (phone), 768 (tablet), 1280 (desktop).
typedef ResponsiveBones = Map<int, List<BoneData>>;

/// Breakpoint constants — mirrors Boneyard's default breakpoints.
class NcBreakpoints {
  NcBreakpoints._();

  static const int phone = 375;
  static const int tablet = 768;
  static const int desktop = 1280;

  /// All breakpoints in ascending order.
  static const List<int> all = [phone, tablet, desktop];

  /// Returns the appropriate key from [bones] for the given [width].
  /// Falls back to the smallest key when width is narrower than all keys.
  static List<BoneData> resolve(ResponsiveBones bones, double width) {
    final keys = bones.keys.toList()..sort();
    // Walk from largest to smallest — return first key <= width.
    for (final key in keys.reversed) {
      if (width >= key) return bones[key]!;
    }
    // Narrower than all breakpoints — use smallest available.
    return bones[keys.first]!;
  }
}
