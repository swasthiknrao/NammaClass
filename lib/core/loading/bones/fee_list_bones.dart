import '../bone_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fee List Screen Skeleton  (Uber design system)
// Reference: Master Prompt §24.6 "Fee List — Balance card 100h,
//            installment cards 80h"
// Layout:  Balance hero card → section header → installment list (5 cards)
// ─────────────────────────────────────────────────────────────────────────────

/// Phone (375 px) — total height: 620 px
const List<BoneData> _feePhone = [
  // ── Balance hero card ─────────────────────────────────────────────────────
  BoneData(x: 0.043, y: 16, w: 0.914, h: 100, radius: 16),

  // ── Section-header text + filter chips ───────────────────────────────────
  BoneData(x: 0.043, y: 132, w: 0.35, h: 18, radius: 4),
  BoneData(x: 0.043, y: 162, w: 0.18, h: 30, radius: 999),
  BoneData(x: 0.235, y: 162, w: 0.18, h: 30, radius: 999),
  BoneData(x: 0.427, y: 162, w: 0.18, h: 30, radius: 999),

  // ── Installment cards (5 × 80 px) ─────────────────────────────────────────
  // Card 1
  BoneData(x: 0.043, y: 208, w: 0.914, h: 80, radius: 12),
  // Card 2
  BoneData(x: 0.043, y: 300, w: 0.914, h: 80, radius: 12),
  // Card 3
  BoneData(x: 0.043, y: 392, w: 0.914, h: 80, radius: 12),
  // Card 4
  BoneData(x: 0.043, y: 484, w: 0.914, h: 80, radius: 12),
  // Card 5 — partially visible, indicating more below
  BoneData(x: 0.043, y: 576, w: 0.914, h: 56, radius: 12),
];

/// Tablet (768 px) — two-column layout for installment cards.
const List<BoneData> _feeTablet = [
  // Balance card — wide
  BoneData(x: 0.026, y: 16, w: 0.948, h: 112, radius: 16),

  // Header + chips
  BoneData(x: 0.026, y: 144, w: 0.25, h: 18, radius: 4),
  BoneData(x: 0.026, y: 174, w: 0.14, h: 30, radius: 999),
  BoneData(x: 0.177, y: 174, w: 0.14, h: 30, radius: 999),
  BoneData(x: 0.328, y: 174, w: 0.14, h: 30, radius: 999),

  // Two-column cards
  BoneData(x: 0.026, y: 220, w: 0.46, h: 80, radius: 12),
  BoneData(x: 0.514, y: 220, w: 0.46, h: 80, radius: 12),
  BoneData(x: 0.026, y: 312, w: 0.46, h: 80, radius: 12),
  BoneData(x: 0.514, y: 312, w: 0.46, h: 80, radius: 12),
  BoneData(x: 0.026, y: 404, w: 0.46, h: 80, radius: 12),
  BoneData(x: 0.514, y: 404, w: 0.46, h: 80, radius: 12),
];

const ResponsiveBones feeListBones = {375: _feePhone, 768: _feeTablet};

const Map<int, double> feeListHeights = {375: 644, 768: 500};
