import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_preset_provider.dart';
import '../theme/app_typography.dart';
import '../theme/theme_presets.dart';

// ── Public entry point ─────────────────────────────────────────────────────

Future<void> showThemePickerSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (_) => const _ThemePickerSheet(),
  );
}

// ── Main sheet widget ──────────────────────────────────────────────────────

class _ThemePickerSheet extends ConsumerStatefulWidget {
  const _ThemePickerSheet();

  @override
  ConsumerState<_ThemePickerSheet> createState() => _ThemePickerSheetState();
}

class _ThemePickerSheetState extends ConsumerState<_ThemePickerSheet>
    with TickerProviderStateMixin {
  late String _selectedId;
  late double _selectedFontScale;
  late AnimationController _shimmerCtrl;
  late PageController _pageCtrl;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    final presetAsync = ref.read(themePresetProvider);
    _selectedId = presetAsync.valueOrNull ?? AppThemePresets.oceanBlue.id;
    _selectedFontScale = ref.read(fontScaleProvider);

    final initialPage = AppThemePresets.all.indexWhere(
      (p) => p.id == _selectedId,
    );
    _currentPage = initialPage < 0 ? 0 : initialPage;
    _pageCtrl = PageController(
      viewportFraction: 0.82,
      initialPage: _currentPage,
    );

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _saveAndClose() {
    ref.read(themePresetProvider.notifier).select(_selectedId);
    ref.read(fontScaleProvider.notifier).setScale(_selectedFontScale);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final surface = isDark ? const Color(0xFF16213E) : const Color(0xFFF8F9FB);

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 40,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: CustomScrollView(
                controller: scrollCtrl,
                slivers: [
                  SliverToBoxAdapter(child: _Header(isDark: isDark)),
                  SliverToBoxAdapter(
                    child: _PresetCarousel(
                      selectedId: _selectedId,
                      shimmerCtrl: _shimmerCtrl,
                      pageCtrl: _pageCtrl,
                      currentPage: _currentPage,
                      isDark: isDark,
                      onSelected: (id, page) {
                        setState(() {
                          _selectedId = id;
                          _currentPage = page;
                        });
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _PageIndicator(
                      count: AppThemePresets.all.length,
                      current: _currentPage,
                      selectedId: _selectedId,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _FontSizeSection(
                      surface: surface,
                      isDark: isDark,
                      value: _selectedFontScale,
                      onChanged: (v) => setState(() => _selectedFontScale = v),
                    ),
                  ),
                  SliverToBoxAdapter(child: _PreviewLabel(isDark: isDark)),
                  SliverToBoxAdapter(
                    child: _ThreeResolutionPreview(
                      preset: AppThemePresets.byId(_selectedId),
                      isDark: isDark,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
            _ActionBar(
              isDark: isDark,
              onSave: _saveAndClose,
              onCancel: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.palette_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Your Theme',
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
              Text(
                'Pick a style to transform the entire app',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.55)
                      : Colors.black.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Preset carousel ────────────────────────────────────────────────────────

class _PresetCarousel extends StatelessWidget {
  const _PresetCarousel({
    required this.selectedId,
    required this.shimmerCtrl,
    required this.pageCtrl,
    required this.currentPage,
    required this.isDark,
    required this.onSelected,
  });

  final String selectedId;
  final AnimationController shimmerCtrl;
  final PageController pageCtrl;
  final int currentPage;
  final bool isDark;
  final void Function(String id, int page) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: PageView.builder(
        controller: pageCtrl,
        itemCount: AppThemePresets.all.length,
        onPageChanged: (i) => onSelected(AppThemePresets.all[i].id, i),
        itemBuilder: (ctx, i) {
          final preset = AppThemePresets.all[i];
          final isSelected = preset.id == selectedId;
          return AnimatedBuilder(
            animation: pageCtrl,
            builder: (_, child) {
              double scale = 1.0;
              if (pageCtrl.position.hasContentDimensions) {
                final diff = (pageCtrl.page ?? i.toDouble()) - i;
                scale = (1 - diff.abs() * 0.08).clamp(0.92, 1.0);
              }
              return Transform.scale(scale: scale, child: child);
            },
            child: _PresetCard(
              preset: preset,
              isSelected: isSelected,
              shimmerCtrl: shimmerCtrl,
              isDark: isDark,
              onTap: () => onSelected(preset.id, i),
            ),
          );
        },
      ),
    );
  }
}

class _PresetCard extends StatefulWidget {
  const _PresetCard({
    required this.preset,
    required this.isSelected,
    required this.shimmerCtrl,
    required this.isDark,
    required this.onTap,
  });

  final AppThemePreset preset;
  final bool isSelected;
  final AnimationController shimmerCtrl;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_PresetCard> createState() => _PresetCardState();
}

class _PresetCardState extends State<_PresetCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pressAnim = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = widget.isDark
        ? const Color(0xFF1E2340)
        : const Color(0xFFF0F2FF);

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _pressAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: widget.isSelected
                    ? widget.preset.primaryColor
                    : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: [
                if (widget.isSelected)
                  BoxShadow(
                    color: widget.preset.primaryColor.withValues(alpha: 0.45),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  )
                else
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: name + selected check
                  Row(
                    children: [
                      Text(
                        widget.preset.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.preset.name,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: widget.isDark
                                ? Colors.white
                                : const Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                      if (widget.isSelected)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: widget.preset.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.preset.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: widget.isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.black.withValues(alpha: 0.4),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // Color swatches
                  Row(
                    children: [
                      _ColorDot(
                        color: widget.preset.primaryColor,
                        label: 'Primary',
                      ),
                      const SizedBox(width: 8),
                      _ColorDot(
                        color: widget.preset.accentColor,
                        label: 'Accent',
                      ),
                      const SizedBox(width: 8),
                      _LayoutBadge(
                        tokens: widget.preset.tokens,
                        isDark: widget.isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Mini palette bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 8,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(color: widget.preset.primaryColor),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              color: widget.preset.primaryColor.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(color: widget.preset.accentColor),
                          ),
                          Expanded(
                            child: Container(
                              color: widget.preset.accentColor.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Shimmer overlay on selected
                  if (widget.isSelected) ...[
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: widget.shimmerCtrl,
                      builder: (_, __) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                stops: [
                                  (widget.shimmerCtrl.value - 0.3).clamp(
                                    0.0,
                                    1.0,
                                  ),
                                  widget.shimmerCtrl.value.clamp(0.0, 1.0),
                                  (widget.shimmerCtrl.value + 0.3).clamp(
                                    0.0,
                                    1.0,
                                  ),
                                ],
                                colors: [
                                  widget.preset.primaryColor.withValues(
                                    alpha: 0.2,
                                  ),
                                  widget.preset.accentColor,
                                  widget.preset.primaryColor.withValues(
                                    alpha: 0.2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFF888888),
          ),
        ),
      ],
    );
  }
}

class _LayoutBadge extends StatelessWidget {
  const _LayoutBadge({required this.tokens, required this.isDark});
  final dynamic tokens;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    String label = 'Standard';
    if (tokens?.density == 'compact') label = 'Compact';
    if (tokens?.radiusScale != null) {
      final r = (tokens.radiusScale as double);
      if (r >= 1.3) label = 'Rounded';
      if (r <= 0.85) label = 'Sharp';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color(0xFF888888),
        ),
      ),
    );
  }
}

// ── Page indicator ─────────────────────────────────────────────────────────

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.count,
    required this.current,
    required this.selectedId,
  });
  final int count;
  final int current;
  final String selectedId;

  @override
  Widget build(BuildContext context) {
    final preset = AppThemePresets.byId(selectedId);
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          final active = i == current;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: active
                  ? preset.primaryColor
                  : preset.primaryColor.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}

// ── Font size section ──────────────────────────────────────────────────────

class _FontSizeSection extends StatelessWidget {
  const _FontSizeSection({
    required this.surface,
    required this.isDark,
    required this.value,
    required this.onChanged,
  });
  final Color surface;
  final bool isDark;
  final double value;
  final ValueChanged<double> onChanged;

  static const _options = [('Small', 0.9), ('Medium', 1.0), ('Large', 1.15)];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.format_size_rounded,
                  size: 18,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.black.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  'Adjust Font Size',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _options.map((opt) {
                final (label, scale) = opt;
                final active = (value - scale).abs() < 0.01;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _PillButton(
                    label: label,
                    active: active,
                    isDark: isDark,
                    onTap: () => onChanged(scale),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.active,
    required this.isDark,
    required this.onTap,
  });
  final String label;
  final bool active;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: active
                ? Theme.of(context).colorScheme.primary
                : isDark
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active
                ? Colors.white
                : isDark
                ? Colors.white.withValues(alpha: 0.7)
                : Colors.black.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}

// ── 3-resolution preview section ──────────────────────────────────────────

class _PreviewLabel extends StatelessWidget {
  const _PreviewLabel({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Live Preview',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'across all screen sizes',
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.45)
                  : Colors.black.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreeResolutionPreview extends StatelessWidget {
  const _ThreeResolutionPreview({required this.preset, required this.isDark});

  final AppThemePreset preset;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Mobile
          Expanded(
            flex: 25,
            child: _DeviceFrame(
              label: 'Mobile',
              icon: Icons.smartphone_rounded,
              aspectRatio: 9 / 19,
              preset: preset,
              isDark: isDark,
              deviceType: _DeviceType.mobile,
            ),
          ),
          const SizedBox(width: 10),
          // Tablet
          Expanded(
            flex: 38,
            child: _DeviceFrame(
              label: 'Tablet',
              icon: Icons.tablet_rounded,
              aspectRatio: 4 / 6,
              preset: preset,
              isDark: isDark,
              deviceType: _DeviceType.tablet,
            ),
          ),
          const SizedBox(width: 10),
          // Desktop
          Expanded(
            flex: 55,
            child: _DeviceFrame(
              label: 'Desktop',
              icon: Icons.desktop_mac_rounded,
              aspectRatio: 16 / 10,
              preset: preset,
              isDark: isDark,
              deviceType: _DeviceType.desktop,
            ),
          ),
        ],
      ),
    );
  }
}

enum _DeviceType { mobile, tablet, desktop }

class _DeviceFrame extends StatelessWidget {
  const _DeviceFrame({
    required this.label,
    required this.icon,
    required this.aspectRatio,
    required this.preset,
    required this.isDark,
    required this.deviceType,
  });

  final String label;
  final IconData icon;
  final double aspectRatio;
  final AppThemePreset preset;
  final bool isDark;
  final _DeviceType deviceType;

  @override
  Widget build(BuildContext context) {
    final frameColor = isDark
        ? const Color(0xFF2A2A3E)
        : const Color(0xFFE8E8F0);
    final screenBg = isDark ? const Color(0xFF141420) : const Color(0xFFF6F7FA);

    return Column(
      children: [
        // Frame
        Container(
          decoration: BoxDecoration(
            color: frameColor,
            borderRadius: BorderRadius.circular(
              deviceType == _DeviceType.desktop ? 8 : 16,
            ),
            boxShadow: [
              BoxShadow(
                color: preset.primaryColor.withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: EdgeInsets.all(deviceType == _DeviceType.mobile ? 5 : 6),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                deviceType == _DeviceType.desktop ? 4 : 12,
              ),
              child: Container(
                color: screenBg,
                child: _MockScreen(
                  preset: preset,
                  isDark: isDark,
                  deviceType: deviceType,
                ),
              ),
            ),
          ),
        ),
        if (deviceType == _DeviceType.desktop)
          // Monitor stand
          Center(
            child: Column(
              children: [
                Container(width: 20, height: 12, color: frameColor),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: frameColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 12,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.45)
                  : Colors.black.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.45)
                    : Colors.black.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Mock screen content ────────────────────────────────────────────────────

class _MockScreen extends StatelessWidget {
  const _MockScreen({
    required this.preset,
    required this.isDark,
    required this.deviceType,
  });

  final AppThemePreset preset;
  final bool isDark;
  final _DeviceType deviceType;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MockScreenPainter(
        preset: preset,
        isDark: isDark,
        deviceType: deviceType,
      ),
    );
  }
}

class _MockScreenPainter extends CustomPainter {
  _MockScreenPainter({
    required this.preset,
    required this.isDark,
    required this.deviceType,
  });

  final AppThemePreset preset;
  final bool isDark;
  final _DeviceType deviceType;

  @override
  void paint(Canvas canvas, Size size) {
    switch (deviceType) {
      case _DeviceType.mobile:
        _paintMobile(canvas, size);
      case _DeviceType.tablet:
        _paintTablet(canvas, size);
      case _DeviceType.desktop:
        _paintDesktop(canvas, size);
    }
  }

  Color get _bg => isDark ? const Color(0xFF141420) : const Color(0xFFF6F7FA);
  Color get _card => isDark ? const Color(0xFF1E2235) : Colors.white;
  Color get _divider => isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.07);
  Color get _textMuted => isDark
      ? Colors.white.withValues(alpha: 0.18)
      : Colors.black.withValues(alpha: 0.12);

  // Radius for cards based on preset
  double get _cardRadius {
    final r = preset.tokens.radiusScale ?? 1.0;
    return (8 * r).clamp(2.0, 14.0);
  }

  Paint _fill(Color c) => Paint()
    ..color = c
    ..style = PaintingStyle.fill;

  void _rect(Canvas c, Rect r, Color color, {double radius = 2}) {
    c.drawRRect(
      RRect.fromRectAndRadius(r, Radius.circular(radius)),
      _fill(color),
    );
  }

  void _line(Canvas c, Offset a, Offset b, Color color, {double w = 1}) {
    c.drawLine(
      a,
      b,
      Paint()
        ..color = color
        ..strokeWidth = w
        ..strokeCap = StrokeCap.round,
    );
  }

  // ── Mobile layout ──────────────────────────────────────────────────────
  void _paintMobile(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;

    // Status bar
    _rect(canvas, Rect.fromLTWH(0, 0, w, h * 0.06), preset.primaryColor);

    // AppBar
    _rect(
      canvas,
      Rect.fromLTWH(0, h * 0.06, w, h * 0.1),
      preset.primaryColor.withValues(alpha: 0.9),
    );

    // App title line
    _rect(
      canvas,
      Rect.fromLTWH(w * 0.12, h * 0.09, w * 0.4, h * 0.025),
      Colors.white.withValues(alpha: 0.9),
      radius: 2,
    );

    // Avatar circle
    final avR = w * 0.045;
    canvas.drawCircle(
      Offset(w - avR - w * 0.06, h * 0.11),
      avR,
      _fill(Colors.white.withValues(alpha: 0.3)),
    );

    // Content area background
    _rect(canvas, Rect.fromLTWH(0, h * 0.16, w, h * 0.84), _bg);

    // Stats row
    final statW = (w - 3 * w * 0.03) / 2;
    final statH = h * 0.11;
    final statY = h * 0.18;
    for (var i = 0; i < 2; i++) {
      final x = w * 0.03 + i * (statW + w * 0.03);
      _rect(
        canvas,
        Rect.fromLTWH(x, statY, statW, statH),
        _card,
        radius: _cardRadius,
      );
      _rect(
        canvas,
        Rect.fromLTWH(
          x + statW * 0.15,
          statY + statH * 0.2,
          statW * 0.35,
          statH * 0.3,
        ),
        preset.primaryColor.withValues(alpha: 0.25),
        radius: 3,
      );
      _rect(
        canvas,
        Rect.fromLTWH(
          x + statW * 0.15,
          statY + statH * 0.6,
          statW * 0.6,
          statH * 0.15,
        ),
        _textMuted,
        radius: 2,
      );
    }

    // List items
    final listY = statY + statH + h * 0.025;
    for (var i = 0; i < 4; i++) {
      final y = listY + i * (h * 0.1 + h * 0.012);
      _rect(
        canvas,
        Rect.fromLTWH(w * 0.03, y, w * 0.94, h * 0.1),
        _card,
        radius: _cardRadius,
      );
      // Icon circle
      canvas.drawCircle(
        Offset(w * 0.03 + w * 0.07, y + h * 0.05),
        w * 0.045,
        _fill(
          i.isEven
              ? preset.primaryColor.withValues(alpha: 0.15)
              : preset.accentColor.withValues(alpha: 0.15),
        ),
      );
      // Text lines
      _rect(
        canvas,
        Rect.fromLTWH(w * 0.19, y + h * 0.025, w * 0.45, h * 0.025),
        _textMuted.withValues(alpha: 0.6),
        radius: 2,
      );
      _rect(
        canvas,
        Rect.fromLTWH(w * 0.19, y + h * 0.058, w * 0.3, h * 0.018),
        _textMuted,
        radius: 2,
      );
      // Accent dot
      canvas.drawCircle(
        Offset(w * 0.88, y + h * 0.05),
        w * 0.022,
        _fill(i == 0 ? preset.accentColor : _textMuted),
      );
    }

    // Bottom nav — matches real layout personality per preset
    _paintPresetNav(canvas, w, h);
  }

  void _paintPresetNav(Canvas canvas, double w, double h) {
    const n = 4;
    switch (preset.id) {
      case 'royal_purple':
        // Floating icon-only pill
        final navW = w * 0.7;
        final navH = h * 0.078;
        final navX = (w - navW) / 2;
        final navY = h * 0.912;
        _rect(
          canvas,
          Rect.fromLTWH(navX, navY, navW, navH),
          preset.primaryColor,
          radius: 40,
        );
        for (var i = 0; i < n; i++) {
          final ix = navX + navW / n * i + navW / n / 2;
          canvas.drawCircle(
            Offset(ix, navY + navH / 2),
            w * 0.028,
            _fill(i == 0 ? Colors.white : Colors.white.withValues(alpha: 0.4)),
          );
        }
      case 'crimson_red':
        // Straight flush bar
        _rect(
          canvas,
          Rect.fromLTWH(0, h * 0.91, w, h * 0.09),
          _card,
          radius: 0,
        );
        _line(canvas, Offset(0, h * 0.91), Offset(w, h * 0.91), _divider);
        for (var i = 0; i < n; i++) {
          final nx = w / n * i + w / n / 2;
          if (i == 0) {
            _rect(
              canvas,
              Rect.fromLTWH(nx - w * 0.08, h * 0.918, w * 0.16, h * 0.065),
              preset.primaryColor.withValues(alpha: 0.15),
              radius: _cardRadius * 0.5,
            );
          }
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(nx - w * 0.035, h * 0.932, w * 0.07, h * 0.022),
              const Radius.circular(1.5),
            ),
            _fill(i == 0 ? preset.primaryColor : _textMuted),
          );
        }
      case 'solar_orange':
        // Transparent ghost nav
        for (var i = 0; i < n; i++) {
          final nx = w / n * i + w / n / 2;
          if (i == 0) {
            _rect(
              canvas,
              Rect.fromLTWH(nx - w * 0.1, h * 0.908, w * 0.2, h * 0.084),
              preset.primaryColor.withValues(alpha: 0.1),
              radius: 8,
            );
          }
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(nx - w * 0.04, h * 0.93, w * 0.08, h * 0.025),
              const Radius.circular(2),
            ),
            _fill(i == 0 ? preset.primaryColor : _textMuted),
          );
        }
      case 'midnight_steel':
        // Tab bar with top-edge indicator
        _rect(canvas, Rect.fromLTWH(0, h * 0.9, w, h * 0.1), _card, radius: 0);
        _line(canvas, Offset(0, h * 0.9), Offset(w, h * 0.9), _divider);
        _rect(
          canvas,
          Rect.fromLTWH(0, h * 0.9, w / n, 2.5),
          preset.primaryColor,
          radius: 0,
        );
        for (var i = 0; i < n; i++) {
          final nx = w / n * i + w / n / 2;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(nx - w * 0.04, h * 0.932, w * 0.08, h * 0.028),
              const Radius.circular(2),
            ),
            _fill(i == 0 ? preset.primaryColor : _textMuted),
          );
        }
      default:
        // Floating pill (ocean_blue / forest_green)
        final navR = preset.id == 'forest_green' ? 32.0 : 22.0;
        final padH = preset.id == 'forest_green' ? w * 0.045 : w * 0.03;
        _rect(
          canvas,
          Rect.fromLTWH(padH, h * 0.904, w - 2 * padH, h * 0.082),
          _card,
          radius: navR,
        );
        final navW2 = w - 2 * padH;
        for (var i = 0; i < n; i++) {
          final nx = padH + navW2 / n * i + navW2 / n / 2;
          if (i == 0) {
            _rect(
              canvas,
              Rect.fromLTWH(nx - w * 0.065, h * 0.916, w * 0.13, h * 0.056),
              preset.primaryColor.withValues(alpha: 0.15),
              radius: navR * 0.55,
            );
          }
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(nx - w * 0.038, h * 0.932, w * 0.076, h * 0.024),
              const Radius.circular(2),
            ),
            _fill(i == 0 ? preset.primaryColor : _textMuted),
          );
        }
    }
  }

  // ── Tablet layout ──────────────────────────────────────────────────────
  void _paintTablet(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    final sidebarW = w * 0.28;

    // Sidebar
    _rect(canvas, Rect.fromLTWH(0, 0, sidebarW, h), preset.primaryColor);

    // Sidebar logo area
    _rect(
      canvas,
      Rect.fromLTWH(sidebarW * 0.12, h * 0.04, sidebarW * 0.76, h * 0.07),
      Colors.white.withValues(alpha: 0.2),
      radius: 6,
    );

    // Sidebar nav items
    for (var i = 0; i < 6; i++) {
      final y = h * 0.14 + i * h * 0.1;
      final active = i == 0;
      if (active) {
        _rect(
          canvas,
          Rect.fromLTWH(sidebarW * 0.06, y, sidebarW * 0.88, h * 0.07),
          Colors.white.withValues(alpha: 0.2),
          radius: 8,
        );
      }
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            sidebarW * 0.15,
            y + h * 0.018,
            sidebarW * 0.2,
            h * 0.03,
          ),
          const Radius.circular(2),
        ),
        _fill(Colors.white.withValues(alpha: active ? 0.9 : 0.4)),
      );
      _rect(
        canvas,
        Rect.fromLTWH(
          sidebarW * 0.42,
          y + h * 0.024,
          sidebarW * 0.45,
          h * 0.022,
        ),
        Colors.white.withValues(alpha: active ? 0.7 : 0.25),
        radius: 2,
      );
    }

    // Main content area
    _rect(canvas, Rect.fromLTWH(sidebarW, 0, w - sidebarW, h), _bg);

    // Topbar
    _rect(canvas, Rect.fromLTWH(sidebarW, 0, w - sidebarW, h * 0.09), _card);
    _line(canvas, Offset(sidebarW, h * 0.09), Offset(w, h * 0.09), _divider);
    _rect(
      canvas,
      Rect.fromLTWH(
        sidebarW + (w - sidebarW) * 0.04,
        h * 0.028,
        (w - sidebarW) * 0.35,
        h * 0.035,
      ),
      _textMuted,
      radius: 3,
    );

    // Stat cards
    final cw = (w - sidebarW - 4 * (w - sidebarW) * 0.025) / 3;
    final ch = h * 0.13;
    final cy = h * 0.11;
    for (var i = 0; i < 3; i++) {
      final cx =
          sidebarW + (w - sidebarW) * 0.025 + i * (cw + (w - sidebarW) * 0.025);
      _rect(canvas, Rect.fromLTWH(cx, cy, cw, ch), _card, radius: _cardRadius);
      _rect(
        canvas,
        Rect.fromLTWH(cx + cw * 0.1, cy + ch * 0.15, cw * 0.3, ch * 0.35),
        (i == 1 ? preset.accentColor : preset.primaryColor).withValues(
          alpha: 0.2,
        ),
        radius: 4,
      );
      _rect(
        canvas,
        Rect.fromLTWH(cx + cw * 0.1, cy + ch * 0.62, cw * 0.65, ch * 0.18),
        _textMuted,
        radius: 2,
      );
    }

    // Chart area
    final chartX = sidebarW + (w - sidebarW) * 0.025;
    final chartY = h * 0.26;
    final chartW = (w - sidebarW) * 0.62;
    final chartH = h * 0.38;
    _rect(
      canvas,
      Rect.fromLTWH(chartX, chartY, chartW, chartH),
      _card,
      radius: _cardRadius,
    );
    _paintMiniBarChart(
      canvas,
      Rect.fromLTWH(
        chartX + chartW * 0.05,
        chartY + chartH * 0.2,
        chartW * 0.9,
        chartH * 0.65,
      ),
      preset,
    );

    // Side list
    final listX = chartX + chartW + (w - sidebarW) * 0.025;
    final listW = (w - sidebarW) - chartW - 3 * (w - sidebarW) * 0.025;
    _rect(
      canvas,
      Rect.fromLTWH(listX, chartY, listW, chartH),
      _card,
      radius: _cardRadius,
    );
    for (var i = 0; i < 4; i++) {
      final ry = chartY + chartH * 0.08 + i * chartH * 0.22;
      _rect(
        canvas,
        Rect.fromLTWH(listX + listW * 0.08, ry, listW * 0.84, chartH * 0.16),
        _bg,
        radius: 4,
      );
    }
  }

  // ── Desktop layout ─────────────────────────────────────────────────────
  void _paintDesktop(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    final sideW = w * 0.2;
    final topH = h * 0.1;

    // Top bar
    _rect(canvas, Rect.fromLTWH(0, 0, w, topH), _card);
    _line(canvas, Offset(0, topH), Offset(w, topH), _divider);
    // Logo
    _rect(
      canvas,
      Rect.fromLTWH(w * 0.01, topH * 0.2, sideW * 0.7, topH * 0.6),
      preset.primaryColor.withValues(alpha: 0.15),
      radius: 4,
    );
    _rect(
      canvas,
      Rect.fromLTWH(w * 0.015, topH * 0.3, sideW * 0.35, topH * 0.4),
      preset.primaryColor,
      radius: 3,
    );
    // Nav links
    final navLabels = 5;
    for (var i = 0; i < navLabels; i++) {
      final nx = sideW + w * 0.05 + i * w * 0.1;
      final active = i == 0;
      if (active) {
        _rect(
          canvas,
          Rect.fromLTWH(nx - w * 0.012, topH * 0.1, w * 0.09, topH * 0.8),
          preset.primaryColor.withValues(alpha: 0.08),
          radius: 4,
        );
      }
      _rect(
        canvas,
        Rect.fromLTWH(nx, topH * 0.38, w * 0.065, topH * 0.26),
        active ? preset.primaryColor : _textMuted,
        radius: 2,
      );
    }
    // Actions
    canvas.drawCircle(
      Offset(w * 0.92, topH * 0.5),
      topH * 0.28,
      _fill(preset.primaryColor.withValues(alpha: 0.15)),
    );
    canvas.drawCircle(
      Offset(w * 0.96, topH * 0.5),
      topH * 0.28,
      _fill(preset.accentColor.withValues(alpha: 0.2)),
    );

    // Left sidebar
    _rect(
      canvas,
      Rect.fromLTWH(0, topH, sideW, h - topH),
      isDark ? const Color(0xFF0D1117) : const Color(0xFFF0F2F8),
    );
    _line(canvas, Offset(sideW, topH), Offset(sideW, h), _divider);
    for (var i = 0; i < 7; i++) {
      final sy = topH + h * 0.04 + i * h * 0.09;
      final active = i == 0;
      if (active) {
        _rect(
          canvas,
          Rect.fromLTWH(sideW * 0.04, sy - h * 0.005, sideW * 0.92, h * 0.075),
          preset.primaryColor.withValues(alpha: 0.15),
          radius: 6,
        );
        _rect(
          canvas,
          Rect.fromLTWH(sideW * 0.04, sy - h * 0.005, 3, h * 0.075),
          preset.primaryColor,
          radius: 2,
        );
      }
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(sideW * 0.12, sy + h * 0.015, sideW * 0.2, h * 0.028),
          const Radius.circular(2),
        ),
        _fill(active ? preset.primaryColor : _textMuted),
      );
      _rect(
        canvas,
        Rect.fromLTWH(sideW * 0.38, sy + h * 0.019, sideW * 0.5, h * 0.022),
        active ? preset.primaryColor.withValues(alpha: 0.6) : _textMuted,
        radius: 2,
      );
    }

    // Main content
    final mainX = sideW;
    final mainW = w - sideW;
    _rect(canvas, Rect.fromLTWH(mainX, topH, mainW, h - topH), _bg);

    // Page header
    _rect(
      canvas,
      Rect.fromLTWH(
        mainX + mainW * 0.03,
        topH + h * 0.025,
        mainW * 0.4,
        h * 0.05,
      ),
      _textMuted.withValues(alpha: 0.7),
      radius: 3,
    );

    // Stat row
    final statCount = 4;
    final statW2 = (mainW - (statCount + 1) * mainW * 0.02) / statCount;
    final statH2 = h * 0.14;
    final statY2 = topH + h * 0.1;
    for (var i = 0; i < statCount; i++) {
      final sx = mainX + mainW * 0.02 + i * (statW2 + mainW * 0.02);
      _rect(
        canvas,
        Rect.fromLTWH(sx, statY2, statW2, statH2),
        _card,
        radius: _cardRadius,
      );
      // Icon
      _rect(
        canvas,
        Rect.fromLTWH(
          sx + statW2 * 0.07,
          statY2 + statH2 * 0.15,
          statW2 * 0.28,
          statH2 * 0.42,
        ),
        (i % 2 == 0 ? preset.primaryColor : preset.accentColor).withValues(
          alpha: 0.18,
        ),
        radius: 5,
      );
      // Value
      _rect(
        canvas,
        Rect.fromLTWH(
          sx + statW2 * 0.07,
          statY2 + statH2 * 0.65,
          statW2 * 0.55,
          statH2 * 0.2,
        ),
        _textMuted,
        radius: 2,
      );
    }

    // Chart + table row
    final rowY = statY2 + statH2 + h * 0.025;
    final chartW2 = mainW * 0.55;
    final chartH2 = h * 0.35;
    _rect(
      canvas,
      Rect.fromLTWH(mainX + mainW * 0.02, rowY, chartW2, chartH2),
      _card,
      radius: _cardRadius,
    );
    _paintMiniLineChart(
      canvas,
      Rect.fromLTWH(
        mainX + mainW * 0.04,
        rowY + chartH2 * 0.15,
        chartW2 - mainW * 0.04,
        chartH2 * 0.75,
      ),
      preset,
    );

    final tableX = mainX + mainW * 0.02 + chartW2 + mainW * 0.02;
    final tableW = mainW - chartW2 - 3 * mainW * 0.02;
    _rect(
      canvas,
      Rect.fromLTWH(tableX, rowY, tableW, chartH2),
      _card,
      radius: _cardRadius,
    );
    // Table header
    _rect(
      canvas,
      Rect.fromLTWH(tableX, rowY, tableW, chartH2 * 0.18),
      preset.primaryColor.withValues(alpha: 0.08),
      radius: _cardRadius,
    );
    for (var i = 0; i < 5; i++) {
      final ty = rowY + chartH2 * 0.22 + i * chartH2 * 0.155;
      _rect(
        canvas,
        Rect.fromLTWH(tableX + tableW * 0.05, ty, tableW * 0.9, chartH2 * 0.12),
        i.isEven ? _bg : Colors.transparent,
        radius: 3,
      );
    }
    // Action button
    _rect(
      canvas,
      Rect.fromLTWH(
        mainX + mainW * 0.02,
        rowY + chartH2 + h * 0.02,
        mainW * 0.14,
        h * 0.06,
      ),
      preset.primaryColor,
      radius: 6,
    );
  }

  void _paintMiniBarChart(Canvas canvas, Rect area, AppThemePreset preset) {
    final barCount = 7;
    final barW = area.width / (barCount * 1.8);
    final gap = area.width / barCount;
    final heights = [0.6, 0.8, 0.5, 0.9, 0.7, 1.0, 0.75];
    for (var i = 0; i < barCount; i++) {
      final bh = area.height * heights[i];
      final bx = area.left + gap * i + (gap - barW) / 2;
      final by = area.bottom - bh;
      _rect(
        canvas,
        Rect.fromLTWH(bx, by, barW, bh),
        i.isEven
            ? preset.primaryColor.withValues(alpha: 0.7)
            : preset.accentColor.withValues(alpha: 0.6),
        radius: 2,
      );
    }
    // baseline
    _line(canvas, area.bottomLeft, area.bottomRight, _textMuted, w: 0.8);
  }

  void _paintMiniLineChart(Canvas canvas, Rect area, AppThemePreset preset) {
    final points = [0.7, 0.5, 0.65, 0.4, 0.6, 0.35, 0.55, 0.3, 0.45, 0.25];
    final pts = <Offset>[];
    for (var i = 0; i < points.length; i++) {
      pts.add(
        Offset(
          area.left + area.width * i / (points.length - 1),
          area.bottom - area.height * points[i],
        ),
      );
    }

    // Fill
    final fillPath = Path()..moveTo(area.left, area.bottom);
    for (final p in pts) fillPath.lineTo(p.dx, p.dy);
    fillPath
      ..lineTo(area.right, area.bottom)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..color = preset.primaryColor.withValues(alpha: 0.1)
        ..style = PaintingStyle.fill,
    );

    // Line
    final linePath = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (var i = 1; i < pts.length; i++) {
      final cp1 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i - 1].dy);
      final cp2 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i].dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = preset.primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );

    // Accent line below
    final pts2 = <Offset>[];
    final data2 = [0.4, 0.6, 0.45, 0.65, 0.5, 0.7, 0.55, 0.65, 0.6, 0.72];
    for (var i = 0; i < data2.length; i++) {
      pts2.add(
        Offset(
          area.left + area.width * i / (data2.length - 1),
          area.bottom - area.height * data2[i],
        ),
      );
    }
    final path2 = Path()..moveTo(pts2[0].dx, pts2[0].dy);
    for (var i = 1; i < pts2.length; i++) {
      final cp1 = Offset((pts2[i - 1].dx + pts2[i].dx) / 2, pts2[i - 1].dy);
      final cp2 = Offset((pts2[i - 1].dx + pts2[i].dx) / 2, pts2[i].dy);
      path2.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts2[i].dx, pts2[i].dy);
    }
    canvas.drawPath(
      path2,
      Paint()
        ..color = preset.accentColor.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );

    _line(canvas, area.bottomLeft, area.bottomRight, _textMuted, w: 0.8);
  }

  @override
  bool shouldRepaint(_MockScreenPainter old) =>
      old.preset.id != preset.id || old.isDark != isDark;
}

// ── Action bar ─────────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.isDark,
    required this.onSave,
    required this.onCancel,
  });
  final bool isDark;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).viewPadding.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.07),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.15),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.black.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text(
                'Save Preferences',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
