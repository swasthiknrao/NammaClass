import '../bone_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Notice / Circular List Skeleton  (Lumora design system)
// Reference: Master Prompt §24.6 "Notice List — Chip row 36h, notice cards 90h"
// Layout:  Appbar-title bone → category chip row → 5 notice cards
// ─────────────────────────────────────────────────────────────────────────────

/// Phone (375 px) — total height: 630 px
const List<BoneData> _noticePhone = [
  // ── Page title + subtitle ─────────────────────────────────────────────────
  BoneData(x: 0.043, y: 16, w: 0.35, h: 18, radius: 4),
  BoneData(x: 0.043, y: 40, w: 0.22, h: 12, radius: 4),

  // ── Category chip row (5 pills) ───────────────────────────────────────────
  BoneData(x: 0.043, y: 68, w: 0.18, h: 36, radius: 999),
  BoneData(x: 0.237, y: 68, w: 0.18, h: 36, radius: 999),
  BoneData(x: 0.431, y: 68, w: 0.18, h: 36, radius: 999),
  BoneData(x: 0.625, y: 68, w: 0.18, h: 36, radius: 999),
  BoneData(x: 0.819, y: 68, w: 0.14, h: 36, radius: 999), // partial
  // ── Notice card 1 (90 px) ─────────────────────────────────────────────────
  BoneData(x: 0.043, y: 120, w: 0.914, h: 90, radius: 12),

  // ── Notice card 2 ─────────────────────────────────────────────────────────
  BoneData(x: 0.043, y: 222, w: 0.914, h: 90, radius: 12),

  // ── Notice card 3 ─────────────────────────────────────────────────────────
  BoneData(x: 0.043, y: 324, w: 0.914, h: 90, radius: 12),

  // ── Notice card 4 ─────────────────────────────────────────────────────────
  BoneData(x: 0.043, y: 426, w: 0.914, h: 90, radius: 12),

  // ── Notice card 5 — partially visible ─────────────────────────────────────
  BoneData(x: 0.043, y: 528, w: 0.914, h: 60, radius: 12),
];

/// Tablet (768 px) — two-column notice cards.
const List<BoneData> _noticeTablet = [
  // Title
  BoneData(x: 0.026, y: 16, w: 0.25, h: 18, radius: 4),
  BoneData(x: 0.026, y: 40, w: 0.15, h: 12, radius: 4),

  // Chips (wider)
  BoneData(x: 0.026, y: 68, w: 0.13, h: 36, radius: 999),
  BoneData(x: 0.164, y: 68, w: 0.13, h: 36, radius: 999),
  BoneData(x: 0.302, y: 68, w: 0.13, h: 36, radius: 999),
  BoneData(x: 0.440, y: 68, w: 0.13, h: 36, radius: 999),
  BoneData(x: 0.578, y: 68, w: 0.13, h: 36, radius: 999),

  // Two-column cards
  BoneData(x: 0.026, y: 120, w: 0.46, h: 100, radius: 12),
  BoneData(x: 0.514, y: 120, w: 0.46, h: 100, radius: 12),
  BoneData(x: 0.026, y: 232, w: 0.46, h: 100, radius: 12),
  BoneData(x: 0.514, y: 232, w: 0.46, h: 100, radius: 12),
  BoneData(x: 0.026, y: 344, w: 0.46, h: 100, radius: 12),
  BoneData(x: 0.514, y: 344, w: 0.46, h: 100, radius: 12),
];

const ResponsiveBones noticeBones = {375: _noticePhone, 768: _noticeTablet};

const Map<int, double> noticeHeights = {375: 600, 768: 460};
