/// NammaClass Skeleton Loading — Boneyard-Inspired System
///
/// Single import for all consumers:
/// ```dart
/// import 'package:nammaclass/core/loading/loading.dart';
/// ```
///
/// ## Quick-start
///
/// ```dart
/// // Wrap any async screen in NcSkeleton:
/// NcSkeleton(
///   name: 'parent-home',   // matches a key in NcBoneRegistry
///   loading: ref.watch(dashboardProvider).isLoading,
///   child: DashboardContent(...),
/// )
/// ```
///
/// ## Available skeleton names
/// | Name           | Screen                          |
/// |----------------|---------------------------------|
/// | parent-home    | Parent & Student home dashboard |
/// | student-home   | Same layout, student role       |
/// | attendance     | Attendance calendar + tiles     |
/// | fee-list       | Fee list with balance card      |
/// | canteen        | Canteen menu grid (Starbucks)   |
/// | chat           | Chat conversation list          |
/// | admin-table    | Admin web data table            |
/// | notice-list    | Notices / circulars list        |
/// | bus-tracking   | Bus tracking map + sheet        |
///
/// ## Architecture
/// Ported from **Boneyard** (boneyard-js) — each skeleton is a flat
/// `List<BoneData>` of positioned rectangles/circles. A single
/// [NcBoneRenderer] draws any list using `LayoutBuilder + Stack`.
/// [NcSkeleton] owns the 400 ms minimum-display timer and the
/// 300 ms `AnimatedSwitcher` fade transition.
library;

export 'bone_data.dart';
export 'bone_registry.dart';
export 'nc_bone_renderer.dart';
export 'nc_skeleton.dart';

// Individual bone definition maps (re-exported for advanced use)
export 'bones/attendance_bones.dart';
export 'bones/bus_bones.dart';
export 'bones/canteen_bones.dart';
export 'bones/chat_bones.dart';
export 'bones/dashboard_bones.dart';
export 'bones/fee_list_bones.dart';
export 'bones/notice_bones.dart';
export 'bones/table_bones.dart';
