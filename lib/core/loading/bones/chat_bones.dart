import '../bone_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Chat List Screen Skeleton
// Reference: Master Prompt §24.2 "Chat Screen Skeleton"
// Layout:  Search bar → 8 list tiles (avatar | title + subtitle | time + badge)
// ─────────────────────────────────────────────────────────────────────────────

/// Generates a single chat list tile row at vertical offset [top].
/// Row height is 72 px (contentPadding: 12 top + bottom + 48 content).
List<BoneData> _chatTile(double top) => [
  // Avatar circle (48 px diameter)
  BoneData(x: 0.043, y: top + 12, w: 0.128, h: 48, radius: 999, isCircle: true),
  // Contact name
  BoneData(x: 0.2, y: top + 14, w: 0.45, h: 14, radius: 4),
  // Last message preview
  BoneData(x: 0.2, y: top + 34, w: 0.55, h: 12, radius: 4),
  // Timestamp (top-right)
  BoneData(x: 0.83, y: top + 14, w: 0.127, h: 10, radius: 4),
  // Unread badge (bottom-right)
  BoneData(x: 0.878, y: top + 36, w: 0.079, h: 20, radius: 999, isCircle: true),
];

const double _tileH = 72.0;
const double _searchH = 48.0;
const double _headerPad = 16.0;

/// Phone (375 px) — 8 chat tiles + search bar = 640 px
final List<BoneData> _chatPhone = [
  // Search bar
  BoneData(x: 0.043, y: _headerPad, w: 0.914, h: _searchH, radius: 999),

  // 8 chat tiles
  ..._chatTile(_headerPad + _searchH + 12),
  ..._chatTile(_headerPad + _searchH + 12 + _tileH * 1),
  ..._chatTile(_headerPad + _searchH + 12 + _tileH * 2),
  ..._chatTile(_headerPad + _searchH + 12 + _tileH * 3),
  ..._chatTile(_headerPad + _searchH + 12 + _tileH * 4),
  ..._chatTile(_headerPad + _searchH + 12 + _tileH * 5),
  ..._chatTile(_headerPad + _searchH + 12 + _tileH * 6),
  ..._chatTile(_headerPad + _searchH + 12 + _tileH * 7),
];

final ResponsiveBones chatBones = {375: _chatPhone, 768: _chatPhone};

const Map<int, double> chatHeights = {375: 648, 768: 648};
