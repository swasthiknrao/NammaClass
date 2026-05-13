/// Semantic design tokens from tenant profile JSON (`theme_tokens` object).
/// Applied in app theme merge (see [AppTheme]).
class ThemeTokens {
  const ThemeTokens({
    this.presetId,
    this.density,
    this.fontFamilyPrimary,
    this.fontFamilyBody,
    this.radiusScale,
    this.motionLevel,
    this.colors = const {},
  });

  final String? presetId;
  final String? density;
  final String? fontFamilyPrimary;
  final String? fontFamilyBody;
  final double? radiusScale;
  final String? motionLevel;
  final Map<String, String> colors;

  factory ThemeTokens.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ThemeTokens();
    final rawColors = json['colors'] as Map<String, dynamic>?;
    return ThemeTokens(
      presetId: json['preset_id'] as String? ?? json['presetId'] as String?,
      density: json['density'] as String?,
      fontFamilyPrimary:
          json['font_family_primary'] as String? ??
          json['fontFamilyPrimary'] as String?,
      fontFamilyBody:
          json['font_family_body'] as String? ??
          json['fontFamilyBody'] as String?,
      radiusScale: (json['radius_scale'] as num? ?? json['radiusScale'] as num?)
          ?.toDouble(),
      motionLevel:
          json['motion_level'] as String? ?? json['motionLevel'] as String?,
      colors: rawColors == null
          ? const {}
          : rawColors.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  Map<String, dynamic> toJson() => {
    if (presetId != null) 'preset_id': presetId,
    if (density != null) 'density': density,
    if (fontFamilyPrimary != null) 'font_family_primary': fontFamilyPrimary,
    if (fontFamilyBody != null) 'font_family_body': fontFamilyBody,
    if (radiusScale != null) 'radius_scale': radiusScale,
    if (motionLevel != null) 'motion_level': motionLevel,
    if (colors.isNotEmpty) 'colors': colors,
  };
}
