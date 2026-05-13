import 'bone_data.dart';
import 'nc_skeleton.dart';

// Bone definitions
import 'bones/attendance_bones.dart';
import 'bones/bus_bones.dart';
import 'bones/canteen_bones.dart';
import 'bones/chat_bones.dart';
import 'bones/dashboard_bones.dart';
import 'bones/fee_list_bones.dart';
import 'bones/notice_bones.dart';
import 'bones/table_bones.dart';

/// Central registry that maps screen names to [ResponsiveBones].
///
/// Mirrors the Boneyard `registry.js` concept: import once at app start and
/// every [NcSkeleton] automatically resolves its bones by name.
///
/// Adding a new skeleton:
/// 1. Create `lib/core/loading/bones/<name>_bones.dart`
/// 2. Add an entry to [_registry] and [_heights]
/// 3. Use `NcSkeleton(name: '<your-key>', ...)` in the screen
class NcBoneRegistry {
  NcBoneRegistry._();

  /// Maps a screen key → [ResponsiveBones].
  /// Keys follow kebab-case to match Boneyard convention.
  static final Map<String, ResponsiveBones> _registry = {
    'parent-home': dashboardBones,
    'student-home': dashboardBones, // shares the same layout
    'attendance': attendanceBones,
    'fee-list': feeListBones,
    'canteen': canteenBones,
    'chat': chatBones,
    'admin-table': tableBones,
    'notice-list': noticeBones,
    'bus-tracking': busBones,
  };

  /// Total container heights per screen key and breakpoint.
  static final Map<String, Map<int, double>> _heights = {
    'parent-home': dashboardHeights,
    'student-home': dashboardHeights,
    'attendance': attendanceHeights,
    'fee-list': feeListHeights,
    'canteen': canteenHeights,
    'chat': chatHeights,
    'admin-table': tableHeights,
    'notice-list': noticeHeights,
    'bus-tracking': busHeights,
  };

  /// Resolves the correct [ResolvedBones] for the given [name] and [width].
  ///
  /// Returns null when [name] is not registered so the caller can show a
  /// generic fallback without crashing.
  static ResolvedBones? resolve(String name, double width) {
    final responsiveBones = _registry[name];
    final responsiveHeights = _heights[name];

    if (responsiveBones == null || responsiveHeights == null) return null;

    final bones = NcBreakpoints.resolve(responsiveBones, width);
    final height = _resolveHeight(responsiveHeights, width);

    return ResolvedBones(bones: bones, height: height);
  }

  /// Returns all registered screen keys — useful for debugging / testing.
  static List<String> get registeredKeys => _registry.keys.toList();

  /// Nearest-<= breakpoint resolution for height map.
  static double _resolveHeight(Map<int, double> heights, double width) {
    final keys = heights.keys.toList()..sort();
    for (final key in keys.reversed) {
      if (width >= key) return heights[key]!;
    }
    return heights[keys.first]!;
  }
}
