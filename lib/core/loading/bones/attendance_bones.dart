import '../bone_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Attendance Screen Skeleton
// Reference: Master Prompt §24.6 "Attendance Calendar — Calendar grid 280h,
//            stats row 64h"
// Layout:  Month navigator → calendar grid → stat chips row → list tiles
// ─────────────────────────────────────────────────────────────────────────────

/// Phone (375 px) — total height: 620 px
const List<BoneData> _attendancePhone = [
  // ── Month navigator bar ───────────────────────────────────────────────────
  BoneData(x: 0.043, y: 16, w: 0.13, h: 36, radius: 999), // prev arrow
  BoneData(x: 0.35, y: 16, w: 0.3, h: 36, radius: 8), // month label
  BoneData(x: 0.826, y: 16, w: 0.13, h: 36, radius: 999), // next arrow
  // ── Day-of-week headers (7 columns) ──────────────────────────────────────
  BoneData(x: 0.043, y: 68, w: 0.10, h: 14, radius: 4),
  BoneData(x: 0.182, y: 68, w: 0.10, h: 14, radius: 4),
  BoneData(x: 0.321, y: 68, w: 0.10, h: 14, radius: 4),
  BoneData(x: 0.460, y: 68, w: 0.10, h: 14, radius: 4),
  BoneData(x: 0.599, y: 68, w: 0.10, h: 14, radius: 4),
  BoneData(x: 0.738, y: 68, w: 0.10, h: 14, radius: 4),
  BoneData(x: 0.857, y: 68, w: 0.10, h: 14, radius: 4),

  // ── Calendar grid — 5 rows × 7 cols (day cells 38×38) ────────────────────
  // Row 1
  BoneData(x: 0.043, y: 96, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.182, y: 96, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.321, y: 96, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.460, y: 96, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.599, y: 96, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.738, y: 96, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.857, y: 96, w: 0.10, h: 38, radius: 999),
  // Row 2
  BoneData(x: 0.043, y: 146, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.182, y: 146, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.321, y: 146, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.460, y: 146, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.599, y: 146, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.738, y: 146, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.857, y: 146, w: 0.10, h: 38, radius: 999),
  // Row 3
  BoneData(x: 0.043, y: 196, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.182, y: 196, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.321, y: 196, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.460, y: 196, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.599, y: 196, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.738, y: 196, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.857, y: 196, w: 0.10, h: 38, radius: 999),
  // Row 4
  BoneData(x: 0.043, y: 246, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.182, y: 246, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.321, y: 246, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.460, y: 246, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.599, y: 246, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.738, y: 246, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.857, y: 246, w: 0.10, h: 38, radius: 999),
  // Row 5
  BoneData(x: 0.043, y: 296, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.182, y: 296, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.321, y: 296, w: 0.10, h: 38, radius: 999),
  BoneData(x: 0.460, y: 296, w: 0.10, h: 38, radius: 999),

  // ── Stats row (3 chips: Present / Absent / Late) ──────────────────────────
  BoneData(x: 0.043, y: 354, w: 0.27, h: 64, radius: 12),
  BoneData(x: 0.363, y: 354, w: 0.27, h: 64, radius: 12),
  BoneData(x: 0.683, y: 354, w: 0.274, h: 64, radius: 12),

  // ── Recent-records list (4 tiles) ─────────────────────────────────────────
  BoneData(x: 0.043, y: 434, w: 0.128, h: 44, radius: 999, isCircle: true),
  BoneData(x: 0.2, y: 437, w: 0.55, h: 13, radius: 4),
  BoneData(x: 0.2, y: 456, w: 0.35, h: 11, radius: 4),
  BoneData(x: 0.86, y: 440, w: 0.097, h: 24, radius: 999),

  BoneData(x: 0.043, y: 494, w: 0.128, h: 44, radius: 999, isCircle: true),
  BoneData(x: 0.2, y: 497, w: 0.5, h: 13, radius: 4),
  BoneData(x: 0.2, y: 516, w: 0.3, h: 11, radius: 4),
  BoneData(x: 0.86, y: 500, w: 0.097, h: 24, radius: 999),

  BoneData(x: 0.043, y: 554, w: 0.128, h: 44, radius: 999, isCircle: true),
  BoneData(x: 0.2, y: 557, w: 0.45, h: 13, radius: 4),
  BoneData(x: 0.2, y: 576, w: 0.28, h: 11, radius: 4),
  BoneData(x: 0.86, y: 560, w: 0.097, h: 24, radius: 999),
];

const ResponsiveBones attendanceBones = {
  375: _attendancePhone,
  768:
      _attendancePhone, // tablet reuses phone; calendar layout doesn't change much
};

const Map<int, double> attendanceHeights = {375: 620, 768: 620};
