import '../bone_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Canteen Menu Skeleton  (Starbucks design system)
// Reference: Master Prompt §24.2 "Canteen Menu Grid Skeleton" and §11
// Layout:  House-Green feature band → category chip strip →
//          2-col menu grid (4:3 image + name + price per card)
// ─────────────────────────────────────────────────────────────────────────────

/// Phone (375 px) — total height: 800 px
const List<BoneData> _canteenPhone = [
  // ── House-Green feature band (full-width) ────────────────────────────────
  BoneData(x: 0, y: 0, w: 1.0, h: 96, radius: 0),

  // ── Wallet balance pill (top-right inside band) — gold-area skeleton ─────
  BoneData(x: 0.72, y: 16, w: 0.24, h: 28, radius: 999),

  // ── Category chip strip (6 pills, horizontal) ────────────────────────────
  BoneData(x: 0.043, y: 112, w: 0.19, h: 36, radius: 999),
  BoneData(x: 0.249, y: 112, w: 0.19, h: 36, radius: 999),
  BoneData(x: 0.455, y: 112, w: 0.19, h: 36, radius: 999),
  BoneData(x: 0.661, y: 112, w: 0.19, h: 36, radius: 999),
  BoneData(x: 0.867, y: 112, w: 0.10, h: 36, radius: 999), // partial
  // ── Menu grid — 2 cols × 3 rows  (4:3 image area = ~116 px on 375w) ──────
  // ── Row 1 ─────────────────────────────────────────────────────────────────
  // Col 1 — image
  BoneData(x: 0.043, y: 164, w: 0.435, h: 116, radius: 12),
  // Col 1 — item name
  BoneData(x: 0.043, y: 288, w: 0.435, h: 14, radius: 4),
  // Col 1 — price (mono)
  BoneData(x: 0.043, y: 308, w: 0.18, h: 12, radius: 4),

  // Col 2 — image
  BoneData(x: 0.522, y: 164, w: 0.435, h: 116, radius: 12),
  // Col 2 — item name
  BoneData(x: 0.522, y: 288, w: 0.435, h: 14, radius: 4),
  // Col 2 — price
  BoneData(x: 0.522, y: 308, w: 0.18, h: 12, radius: 4),

  // ── Row 2 ─────────────────────────────────────────────────────────────────
  BoneData(x: 0.043, y: 340, w: 0.435, h: 116, radius: 12),
  BoneData(x: 0.043, y: 464, w: 0.435, h: 14, radius: 4),
  BoneData(x: 0.043, y: 484, w: 0.2, h: 12, radius: 4),

  BoneData(x: 0.522, y: 340, w: 0.435, h: 116, radius: 12),
  BoneData(x: 0.522, y: 464, w: 0.435, h: 14, radius: 4),
  BoneData(x: 0.522, y: 484, w: 0.16, h: 12, radius: 4),

  // ── Row 3 ─────────────────────────────────────────────────────────────────
  BoneData(x: 0.043, y: 516, w: 0.435, h: 116, radius: 12),
  BoneData(x: 0.043, y: 640, w: 0.435, h: 14, radius: 4),
  BoneData(x: 0.043, y: 660, w: 0.22, h: 12, radius: 4),

  BoneData(x: 0.522, y: 516, w: 0.435, h: 116, radius: 12),
  BoneData(x: 0.522, y: 640, w: 0.435, h: 14, radius: 4),
  BoneData(x: 0.522, y: 660, w: 0.17, h: 12, radius: 4),

  // ── Floating cart FAB placeholder ─────────────────────────────────────────
  BoneData(x: 0.838, y: 712, w: 0.12, h: 56, radius: 999, isCircle: true),
];

/// Tablet (768 px) — 3-col grid.
const List<BoneData> _canteenTablet = [
  // Feature band
  BoneData(x: 0, y: 0, w: 1.0, h: 112, radius: 0),
  BoneData(x: 0.78, y: 20, w: 0.18, h: 28, radius: 999),

  // Category chips (8 visible)
  BoneData(x: 0.026, y: 128, w: 0.13, h: 36, radius: 999),
  BoneData(x: 0.165, y: 128, w: 0.13, h: 36, radius: 999),
  BoneData(x: 0.304, y: 128, w: 0.13, h: 36, radius: 999),
  BoneData(x: 0.443, y: 128, w: 0.13, h: 36, radius: 999),
  BoneData(x: 0.582, y: 128, w: 0.13, h: 36, radius: 999),
  BoneData(x: 0.721, y: 128, w: 0.13, h: 36, radius: 999),

  // 3-col menu grid — 2 rows
  BoneData(x: 0.026, y: 180, w: 0.3, h: 140, radius: 12),
  BoneData(x: 0.026, y: 328, w: 0.3, h: 14, radius: 4),
  BoneData(x: 0.026, y: 348, w: 0.13, h: 12, radius: 4),

  BoneData(x: 0.345, y: 180, w: 0.3, h: 140, radius: 12),
  BoneData(x: 0.345, y: 328, w: 0.3, h: 14, radius: 4),
  BoneData(x: 0.345, y: 348, w: 0.12, h: 12, radius: 4),

  BoneData(x: 0.664, y: 180, w: 0.31, h: 140, radius: 12),
  BoneData(x: 0.664, y: 328, w: 0.31, h: 14, radius: 4),
  BoneData(x: 0.664, y: 348, w: 0.14, h: 12, radius: 4),

  BoneData(x: 0.026, y: 380, w: 0.3, h: 140, radius: 12),
  BoneData(x: 0.026, y: 528, w: 0.3, h: 14, radius: 4),
  BoneData(x: 0.026, y: 548, w: 0.11, h: 12, radius: 4),

  BoneData(x: 0.345, y: 380, w: 0.3, h: 140, radius: 12),
  BoneData(x: 0.345, y: 528, w: 0.3, h: 14, radius: 4),
  BoneData(x: 0.345, y: 548, w: 0.13, h: 12, radius: 4),

  BoneData(x: 0.664, y: 380, w: 0.31, h: 140, radius: 12),
  BoneData(x: 0.664, y: 528, w: 0.31, h: 14, radius: 4),
  BoneData(x: 0.664, y: 548, w: 0.12, h: 12, radius: 4),

  // FAB
  BoneData(x: 0.909, y: 512, w: 0.065, h: 56, radius: 999, isCircle: true),
];

const ResponsiveBones canteenBones = {375: _canteenPhone, 768: _canteenTablet};

const Map<int, double> canteenHeights = {375: 780, 768: 580};
