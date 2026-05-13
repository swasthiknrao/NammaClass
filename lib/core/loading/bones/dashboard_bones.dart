import '../bone_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Parent / Student Home Dashboard Skeleton
// Reference: Master Prompt §24.2 "Student/Parent Home Dashboard Skeleton"
// Layout:  SliverAppBar band → child chips → today-summary card →
//          2×2 quick-action grid → 3 notice list tiles
// ─────────────────────────────────────────────────────────────────────────────

/// Phone (375 px) — total container height: 596 px
const List<BoneData> _dashboardPhone = [
  // ── AppBar hero band ──────────────────────────────────────────────────────
  BoneData(x: 0, y: 0, w: 1.0, h: 120, radius: 0),

  // ── Child-switcher chips (2 pills) ───────────────────────────────────────
  BoneData(x: 0.043, y: 136, w: 0.21, h: 32, radius: 999),
  BoneData(x: 0.275, y: 136, w: 0.21, h: 32, radius: 999),

  // ── Today-summary card ───────────────────────────────────────────────────
  BoneData(x: 0.043, y: 184, w: 0.914, h: 88, radius: 12),

  // ── Quick-action grid (2 cols × 2 rows) ──────────────────────────────────
  BoneData(x: 0.043, y: 288, w: 0.435, h: 72, radius: 12),
  BoneData(x: 0.522, y: 288, w: 0.435, h: 72, radius: 12),
  BoneData(x: 0.043, y: 372, w: 0.435, h: 72, radius: 12),
  BoneData(x: 0.522, y: 372, w: 0.435, h: 72, radius: 12),

  // ── Notice tile 1 ─────────────────────────────────────────────────────────
  BoneData(x: 0.043, y: 460, w: 0.128, h: 48, radius: 999, isCircle: true),
  BoneData(x: 0.2, y: 463, w: 0.65, h: 14, radius: 4),
  BoneData(x: 0.2, y: 483, w: 0.45, h: 12, radius: 4),

  // ── Notice tile 2 ─────────────────────────────────────────────────────────
  BoneData(x: 0.043, y: 524, w: 0.128, h: 48, radius: 999, isCircle: true),
  BoneData(x: 0.2, y: 527, w: 0.6, h: 14, radius: 4),
  BoneData(x: 0.2, y: 547, w: 0.38, h: 12, radius: 4),
];

/// Tablet (768 px) — wider quick-action row, 4-col grid, bigger cards.
const List<BoneData> _dashboardTablet = [
  // AppBar
  BoneData(x: 0, y: 0, w: 1.0, h: 140, radius: 0),

  // Child chips
  BoneData(x: 0.026, y: 156, w: 0.14, h: 36, radius: 999),
  BoneData(x: 0.174, y: 156, w: 0.14, h: 36, radius: 999),
  BoneData(x: 0.322, y: 156, w: 0.14, h: 36, radius: 999),

  // Today-summary card — full row
  BoneData(x: 0.026, y: 208, w: 0.948, h: 96, radius: 14),

  // Quick-action grid — 4 columns
  BoneData(x: 0.026, y: 320, w: 0.22, h: 80, radius: 12),
  BoneData(x: 0.259, y: 320, w: 0.22, h: 80, radius: 12),
  BoneData(x: 0.492, y: 320, w: 0.22, h: 80, radius: 12),
  BoneData(x: 0.725, y: 320, w: 0.249, h: 80, radius: 12),

  // Notice tiles (3) — wider text areas
  BoneData(x: 0.026, y: 416, w: 0.065, h: 48, radius: 999, isCircle: true),
  BoneData(x: 0.105, y: 419, w: 0.7, h: 14, radius: 4),
  BoneData(x: 0.105, y: 439, w: 0.5, h: 12, radius: 4),

  BoneData(x: 0.026, y: 480, w: 0.065, h: 48, radius: 999, isCircle: true),
  BoneData(x: 0.105, y: 483, w: 0.65, h: 14, radius: 4),
  BoneData(x: 0.105, y: 503, w: 0.4, h: 12, radius: 4),

  BoneData(x: 0.026, y: 544, w: 0.065, h: 48, radius: 999, isCircle: true),
  BoneData(x: 0.105, y: 547, w: 0.55, h: 14, radius: 4),
  BoneData(x: 0.105, y: 567, w: 0.35, h: 12, radius: 4),
];

/// Desktop (1280 px) — two-column layout; stats on right, tiles on left.
const List<BoneData> _dashboardDesktop = [
  // AppBar
  BoneData(x: 0, y: 0, w: 1.0, h: 64, radius: 0),

  // Left column: today card + quick actions
  BoneData(x: 0.016, y: 80, w: 0.46, h: 100, radius: 14),

  BoneData(x: 0.016, y: 196, w: 0.107, h: 80, radius: 12),
  BoneData(x: 0.133, y: 196, w: 0.107, h: 80, radius: 12),
  BoneData(x: 0.250, y: 196, w: 0.107, h: 80, radius: 12),
  BoneData(x: 0.367, y: 196, w: 0.107, h: 80, radius: 12),

  // Right column: KPI stat cards
  BoneData(x: 0.492, y: 80, w: 0.234, h: 100, radius: 14),
  BoneData(x: 0.742, y: 80, w: 0.242, h: 100, radius: 14),
  BoneData(x: 0.492, y: 196, w: 0.234, h: 80, radius: 12),
  BoneData(x: 0.742, y: 196, w: 0.242, h: 80, radius: 12),

  // Notice list (3 tiles)
  BoneData(x: 0.016, y: 292, w: 0.032, h: 48, radius: 999, isCircle: true),
  BoneData(x: 0.057, y: 296, w: 0.35, h: 14, radius: 4),
  BoneData(x: 0.057, y: 316, w: 0.26, h: 12, radius: 4),

  BoneData(x: 0.016, y: 356, w: 0.032, h: 48, radius: 999, isCircle: true),
  BoneData(x: 0.057, y: 360, w: 0.32, h: 14, radius: 4),
  BoneData(x: 0.057, y: 380, w: 0.22, h: 12, radius: 4),

  BoneData(x: 0.016, y: 420, w: 0.032, h: 48, radius: 999, isCircle: true),
  BoneData(x: 0.057, y: 424, w: 0.28, h: 14, radius: 4),
  BoneData(x: 0.057, y: 444, w: 0.20, h: 12, radius: 4),
];

/// Responsive bones map — keyed by Boneyard-standard breakpoints.
const ResponsiveBones dashboardBones = {
  375: _dashboardPhone,
  768: _dashboardTablet,
  1280: _dashboardDesktop,
};

/// Total container heights per breakpoint.
const Map<int, double> dashboardHeights = {375: 580, 768: 628, 1280: 480};
