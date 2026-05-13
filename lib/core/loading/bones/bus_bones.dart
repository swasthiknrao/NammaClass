import '../bone_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Bus Tracking Screen Skeleton
// Reference: Master Prompt §24.6 "Bus Tracking — Full-screen map placeholder
//            55%, sheet 200h"
// Layout:  55% map area → draggable bottom sheet skeleton (route info + stops)
// ─────────────────────────────────────────────────────────────────────────────

/// Phone (375 px) — total height: 650 px
/// Assumes the screen body is ~720 px tall; map = ~396 px, sheet = ~254 px.
const List<BoneData> _busPhone = [
  // ── Map area (55% of screen ~= 396 px) ───────────────────────────────────
  // Full-width grey map placeholder
  BoneData(x: 0, y: 0, w: 1.0, h: 396, radius: 0),

  // Simulated road lines on map
  BoneData(x: 0.1, y: 100, w: 0.8, h: 6, radius: 3),
  BoneData(x: 0.25, y: 160, w: 0.5, h: 6, radius: 3),
  BoneData(x: 0.4, y: 220, w: 0.35, h: 6, radius: 3),

  // Bus location pin (pulsing circle)
  BoneData(x: 0.42, y: 170, w: 0.16, h: 60, radius: 999, isCircle: true),

  // ── Bottom sheet handle ───────────────────────────────────────────────────
  BoneData(x: 0.42, y: 408, w: 0.16, h: 4, radius: 999),

  // ── Route header ──────────────────────────────────────────────────────────
  BoneData(x: 0.043, y: 424, w: 0.128, h: 48, radius: 8), // route badge
  BoneData(x: 0.2, y: 427, w: 0.5, h: 14, radius: 4), // route name
  BoneData(x: 0.2, y: 447, w: 0.3, h: 12, radius: 4), // ETA
  // Live-status chip
  BoneData(x: 0.74, y: 428, w: 0.21, h: 28, radius: 999),

  // ── Stop list (3 stops) ────────────────────────────────────────────────────
  // Stop 1
  BoneData(
    x: 0.043,
    y: 488,
    w: 0.05,
    h: 50,
    radius: 999,
    isCircle: true,
  ), // stop dot
  BoneData(x: 0.12, y: 492, w: 0.45, h: 13, radius: 4), // stop name
  BoneData(x: 0.12, y: 511, w: 0.28, h: 11, radius: 4), // distance / time
  BoneData(x: 0.78, y: 492, w: 0.18, h: 28, radius: 999), // status chip
  // Stop 2
  BoneData(x: 0.043, y: 548, w: 0.05, h: 50, radius: 999, isCircle: true),
  BoneData(x: 0.12, y: 552, w: 0.4, h: 13, radius: 4),
  BoneData(x: 0.12, y: 571, w: 0.22, h: 11, radius: 4),
  BoneData(x: 0.78, y: 552, w: 0.18, h: 28, radius: 999),

  // Stop 3
  BoneData(x: 0.043, y: 608, w: 0.05, h: 50, radius: 999, isCircle: true),
  BoneData(x: 0.12, y: 612, w: 0.38, h: 13, radius: 4),
  BoneData(x: 0.12, y: 631, w: 0.2, h: 11, radius: 4),
  BoneData(x: 0.78, y: 612, w: 0.18, h: 28, radius: 999),
];

const ResponsiveBones busBones = {375: _busPhone, 768: _busPhone};

const Map<int, double> busHeights = {375: 660, 768: 660};
