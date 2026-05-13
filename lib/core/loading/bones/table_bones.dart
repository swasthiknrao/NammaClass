import '../bone_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Admin Web Data Table Skeleton  (Uber design system)
// Reference: Master Prompt §24.2 "Data Table Skeleton — header 48h, rows 56h"
// Layout:  Toolbar (search + actions) → table header → N data rows
// ─────────────────────────────────────────────────────────────────────────────

/// Generates a single table row at vertical offset [top] (56 px tall).
List<BoneData> _tableRow(double top) => [
  // Checkbox
  BoneData(x: 0.013, y: top + 18, w: 0.014, h: 20, radius: 4),
  // Avatar
  BoneData(x: 0.04, y: top + 10, w: 0.028, h: 36, radius: 999, isCircle: true),
  // Primary text (name)
  BoneData(x: 0.076, y: top + 14, w: 0.2, h: 14, radius: 4),
  // Secondary text (email / roll no)
  BoneData(x: 0.076, y: top + 33, w: 0.14, h: 11, radius: 4),
  // Status chip
  BoneData(x: 0.6, y: top + 16, w: 0.07, h: 24, radius: 999),
  // Column 3 value
  BoneData(x: 0.72, y: top + 20, w: 0.09, h: 14, radius: 4),
  // Actions icon
  BoneData(x: 0.94, y: top + 18, w: 0.028, h: 20, radius: 4),
];

const double _rowH = 56.0;
const double _headH = 48.0;
const double _toolH = 56.0;
const int _rows = 10;

/// Desktop (1280 px) — full table skeleton.
final List<BoneData> _tableDesktop = [
  // ── Toolbar ────────────────────────────────────────────────────────────────
  // Search input
  BoneData(x: 0.013, y: 12, w: 0.22, h: 32, radius: 8),
  // Filter button
  BoneData(x: 0.25, y: 12, w: 0.07, h: 32, radius: 8),
  // Export button
  BoneData(x: 0.9, y: 12, w: 0.087, h: 32, radius: 8),

  // ── Table header (column labels) ───────────────────────────────────────────
  BoneData(x: 0.013, y: _toolH + 14, w: 0.014, h: 20, radius: 4), // checkbox
  BoneData(x: 0.04, y: _toolH + 16, w: 0.12, h: 14, radius: 4), // name col
  BoneData(x: 0.33, y: _toolH + 16, w: 0.08, h: 14, radius: 4), // class col
  BoneData(x: 0.6, y: _toolH + 16, w: 0.07, h: 14, radius: 4), // status col
  BoneData(x: 0.72, y: _toolH + 16, w: 0.09, h: 14, radius: 4), // value col
  // ── Data rows (10) ─────────────────────────────────────────────────────────
  for (int i = 0; i < _rows; i++) ..._tableRow(_toolH + _headH + i * _rowH),
];

/// Tablet (768 px) — fewer columns visible.
final List<BoneData> _tableTablet = [
  // Toolbar
  BoneData(x: 0.026, y: 12, w: 0.35, h: 32, radius: 8),
  BoneData(x: 0.394, y: 12, w: 0.10, h: 32, radius: 8),

  // Header
  BoneData(x: 0.026, y: _toolH + 14, w: 0.3, h: 14, radius: 4),
  BoneData(x: 0.6, y: _toolH + 14, w: 0.1, h: 14, radius: 4),
  BoneData(x: 0.75, y: _toolH + 14, w: 0.1, h: 14, radius: 4),

  // 8 rows
  for (int i = 0; i < 8; i++) ..._tableRow(_toolH + _headH + i * _rowH),
];

final ResponsiveBones tableBones = {768: _tableTablet, 1280: _tableDesktop};

final Map<int, double> tableHeights = {
  768: _toolH + _headH + 8 * _rowH,
  1280: _toolH + _headH + _rows * _rowH,
};
