import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../domain/entities/timetable_period_definition.dart';
import '../timetable_limits.dart';
import '../utils/timetable_bell_math.dart';
import 'timetable_time_roller_picker.dart';
import 'timetable_ui_tokens.dart';

/// Shared bell math UI: simple template or complex breaks + live preview.
class TimetableBellScheduleSection extends StatefulWidget {
  const TimetableBellScheduleSection({
    super.key,
    this.showDescription = true,
    this.padding = EdgeInsets.zero,
    this.periodCount = 8,
  });

  final bool showDescription;
  final EdgeInsets padding;

  /// Number of bell rows preview / apply should match.
  final int periodCount;

  @override
  TimetableBellScheduleSectionState createState() =>
      TimetableBellScheduleSectionState();
}

class TimetableBellScheduleSectionState
    extends State<TimetableBellScheduleSection> {
  TimeOfDay _dayStart = const TimeOfDay(hour: 8, minute: 50);
  bool _useComplexBreaks = false;

  // Simple mode
  double _periodLen = 50;
  double _gap = 5;
  double _longPause = 40;
  double _longPauseAfterPeriod = 4;

  // Complex mode
  double _shortBreak = 5;
  double _longBreak = 10;
  double _longEvery = 2;
  double _lunchGap = 40;
  double _lunchAfterPeriod = 4;
  bool _hasLunch = true;

  void _haptic() => HapticFeedback.selectionClick();

  List<TimetablePeriodDefinition> computePreview() {
    final n = widget.periodCount.clamp(1, kTimetablePeriodHardCap);
    final lunchClampMax = n > 1 ? n - 1 : 1;
    if (_useComplexBreaks) {
      return generatePeriodScheduleComplex(
        dayStart: _dayStart,
        periodCount: n,
        periodLengthMinutes: _periodLen.round(),
        shortBreakMinutes: _shortBreak.round(),
        longBreakMinutes: _longBreak.round(),
        longBreakEveryPeriods: _longEvery.round().clamp(1, math.max(1, n)),
        hasLunch: _hasLunch && n > 1,
        lunchAfterPeriod: _lunchAfterPeriod.round().clamp(1, lunchClampMax),
        lunchGapMinutes: _lunchGap.round(),
      );
    }
    return generatePeriodScheduleSimple(
      dayStart: _dayStart,
      periodCount: n,
      periodLengthMinutes: _periodLen.round(),
      gapMinutes: _gap.round(),
      longPauseMinutes: _longPause.round(),
      longPauseAfterPeriod: _longPauseAfterPeriod.round().clamp(
        1,
        lunchClampMax,
      ),
      hasLongPause: _longPause > 0 && n > 1,
    );
  }

  Future<void> _pickStart() async {
    final t = await showTimetableTimeRollerPicker(
      context,
      initialTime: _dayStart,
    );
    if (t != null) {
      _haptic();
      setState(() => _dayStart = t);
    }
  }

  int get _pauseAfterMax =>
      math.max(1, widget.periodCount - 1).clamp(1, 63).toInt();

  @override
  Widget build(BuildContext context) {
    final preview = computePreview();
    final text = TimetableUiTokens.textPrimary(context);
    final accent = TimetableUiTokens.accent(context);
    final muted = TimetableUiTokens.textMuted(context);
    final card = TimetableUiTokens.card(context);

    return Padding(
      padding: widget.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showDescription) ...[
            Text(
              'Dial the day like a studio deck — tap rings and chips; preview '
              'tracks every change. Apply writes all ${widget.periodCount} bell rows.',
              style: TextStyle(
                color: text.withValues(alpha: 0.88),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
          ],
          _BreakPatternShell(
            accent: accent,
            text: text,
            muted: muted,
            value: _useComplexBreaks,
            onChanged: (v) {
              _haptic();
              setState(() => _useComplexBreaks = v);
            },
          ),
          const SizedBox(height: 14),
          _FirstBellAuraCard(
            accent: accent,
            text: text,
            muted: muted,
            label: formatBellLabel(_dayStart),
            onTap: _pickStart,
          ),
          const SizedBox(height: 14),
          _DialMetricCard(
            icon: Icons.school_rounded,
            title: 'Lesson length',
            hint: 'Minutes per teaching block',
            accent: accent,
            text: text,
            muted: muted,
            card: card,
            value: _periodLen.round().clamp(30, 95),
            min: 30,
            max: 95,
            step: 5,
            unit: 'min',
            quickPicks: const [40, 45, 48, 50, 55, 60, 70],
            onChanged: (v) => setState(() => _periodLen = v.toDouble()),
            onTick: _haptic,
          ),
          if (!_useComplexBreaks) ...[
            const SizedBox(height: 12),
            _DialMetricCard(
              icon: Icons.linear_scale_rounded,
              title: 'Breathing room',
              hint: 'Gap between back-to-back classes',
              accent: accent,
              text: text,
              muted: muted,
              card: card,
              value: _gap.round().clamp(0, 20),
              min: 0,
              max: 20,
              step: 1,
              unit: 'min',
              quickPicks: const [0, 3, 5, 8, 10, 15, 20],
              onChanged: (v) => setState(() => _gap = v.toDouble()),
              onTick: _haptic,
            ),
            const SizedBox(height: 12),
            _DialMetricCard(
              icon: Icons.restaurant_rounded,
              title: 'Long pause (lunch / assembly)',
              hint: 'Set to 0 for a straight run with only small gaps',
              accent: accent,
              text: text,
              muted: muted,
              card: card,
              value: _longPause.round().clamp(0, 90),
              min: 0,
              max: 90,
              step: 5,
              unit: 'min',
              quickPicks: const [0, 30, 35, 40, 45, 50, 55, 60],
              onChanged: (v) => setState(() => _longPause = v.toDouble()),
              onTick: _haptic,
            ),
            if (widget.periodCount > 1) ...[
              const SizedBox(height: 12),
              _PauseAfterStrip(
                accent: accent,
                text: text,
                muted: muted,
                card: card,
                title: 'Long pause lands after…',
                subtitle: 'Tap the period that ends before the break',
                maxSlot: _pauseAfterMax,
                selected: _longPauseAfterPeriod.round().clamp(
                  1,
                  _pauseAfterMax,
                ),
                onSelect: (v) {
                  _haptic();
                  setState(() => _longPauseAfterPeriod = v.toDouble());
                },
              ),
            ],
          ] else ...[
            const SizedBox(height: 12),
            _LunchToggleRibbon(
              accent: accent,
              text: text,
              value: _hasLunch,
              onChanged: (v) {
                _haptic();
                setState(() => _hasLunch = v);
              },
            ),
            if (_hasLunch && widget.periodCount > 1) ...[
              const SizedBox(height: 12),
              _DialMetricCard(
                icon: Icons.restaurant_menu_rounded,
                title: 'Lunch corridor',
                hint: 'How long the campus clears for lunch',
                accent: accent,
                text: text,
                muted: muted,
                card: card,
                value: _lunchGap.round().clamp(15, 90),
                min: 15,
                max: 90,
                step: 5,
                unit: 'min',
                quickPicks: const [25, 30, 35, 40, 45, 50, 55, 60],
                onChanged: (v) => setState(() => _lunchGap = v.toDouble()),
                onTick: _haptic,
              ),
              const SizedBox(height: 12),
              _PauseAfterStrip(
                accent: accent,
                text: text,
                muted: muted,
                card: card,
                title: 'Lunch after period',
                subtitle: 'Which block finishes right before lunch?',
                maxSlot: _pauseAfterMax,
                selected: _lunchAfterPeriod.round().clamp(1, _pauseAfterMax),
                onSelect: (v) {
                  _haptic();
                  setState(() => _lunchAfterPeriod = v.toDouble());
                },
              ),
            ],
            const SizedBox(height: 12),
            _DialMetricCard(
              icon: Icons.more_time_rounded,
              title: 'Short break',
              hint: 'Between most periods',
              accent: accent,
              text: text,
              muted: muted,
              card: card,
              value: _shortBreak.round().clamp(0, 15),
              min: 0,
              max: 15,
              step: 1,
              unit: 'min',
              quickPicks: const [0, 3, 5, 7, 10, 12, 15],
              onChanged: (v) => setState(() => _shortBreak = v.toDouble()),
              onTick: _haptic,
            ),
            const SizedBox(height: 12),
            _DialMetricCard(
              icon: Icons.pause_circle_filled_rounded,
              title: 'Long break',
              hint: 'Inserted every N lessons (see rhythm below)',
              accent: accent,
              text: text,
              muted: muted,
              card: card,
              value: _longBreak.round().clamp(5, 30),
              min: 5,
              max: 30,
              step: 5,
              unit: 'min',
              quickPicks: const [5, 10, 15, 20, 25, 30],
              onChanged: (v) => setState(() => _longBreak = v.toDouble()),
              onTick: _haptic,
            ),
            const SizedBox(height: 12),
            _RhythmStrip(
              accent: accent,
              text: text,
              muted: muted,
              card: card,
              selected: _longEvery.round().clamp(2, 4).toInt(),
              onSelect: (v) {
                _haptic();
                setState(() => _longEvery = v.toDouble());
              },
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(Icons.timeline_rounded, color: accent, size: 22),
              const SizedBox(width: 8),
              Text(
                'Live runway',
                style: TextStyle(
                  color: text,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...preview.asMap().entries.map((e) {
            final i = e.key;
            final p = e.value;
            final last = i == preview.length - 1;
            return _PreviewTimelineTile(
              accent: accent,
              text: text,
              card: card,
              index: i,
              label: p.label,
              range: '${p.startLabel} – ${p.endLabel}',
              isLast: last,
            );
          }),
        ],
      ),
    );
  }
}

class _BreakPatternShell extends StatelessWidget {
  const _BreakPatternShell({
    required this.accent,
    required this.text,
    required this.muted,
    required this.value,
    required this.onChanged,
  });

  final Color accent;
  final Color text;
  final Color muted;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: TimetableUiTokens.sectionShell(context, radius: 16),
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.auto_awesome_motion_rounded,
            color: accent,
            size: 22,
          ),
        ),
        title: Text(
          'Complex break pattern',
          style: TextStyle(color: text, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          value
              ? 'Short, long, and lunch gaps weave between periods.'
              : 'One steady gap + a single long pause (classic day).',
          style: TextStyle(color: muted, fontSize: 12, height: 1.25),
        ),
        value: value,
        activeThumbColor: accent,
        onChanged: onChanged,
      ),
    );
  }
}

class _FirstBellAuraCard extends StatelessWidget {
  const _FirstBellAuraCard({
    required this.accent,
    required this.text,
    required this.muted,
    required this.label,
    required this.onTap,
  });

  final Color accent;
  final Color text;
  final Color muted;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: TimetableUiTokens.heroShell(context, radius: 22),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [accent, accent.withValues(alpha: 0.65)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.alarm_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FIRST BELL',
                      style: TextStyle(
                        color: muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        color: text,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.touch_app_rounded, size: 15, color: accent),
                        const SizedBox(width: 4),
                        Text(
                          'Tap to open the clock',
                          style: TextStyle(
                            color: accent.withValues(alpha: 0.95),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: muted.withValues(alpha: 0.6),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialMetricCard extends StatelessWidget {
  const _DialMetricCard({
    required this.icon,
    required this.title,
    required this.hint,
    required this.accent,
    required this.text,
    required this.muted,
    required this.card,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.unit,
    required this.quickPicks,
    required this.onChanged,
    required this.onTick,
  });

  final IconData icon;
  final String title;
  final String hint;
  final Color accent;
  final Color text;
  final Color muted;
  final Color card;
  final int value;
  final int min;
  final int max;
  final int step;
  final String unit;
  final List<int> quickPicks;
  final ValueChanged<int> onChanged;
  final VoidCallback onTick;

  void _nudge(int delta) {
    final next = (value + delta).clamp(min, max);
    if (next != value) {
      onTick();
      onChanged(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: TimetableUiTokens.sectionShell(context, radius: 18),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: text,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hint,
                      style: TextStyle(color: muted, fontSize: 12, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _RoundMiniButton(
                icon: Icons.remove_rounded,
                accent: accent,
                muted: muted,
                onTap: () => _nudge(-step),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$value',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: text,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: -1.5,
                      ),
                    ),
                    Text(
                      unit,
                      style: TextStyle(
                        color: muted,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _RoundMiniButton(
                icon: Icons.add_rounded,
                accent: accent,
                muted: muted,
                onTap: () => _nudge(step),
              ),
            ],
          ),
          if (quickPicks.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Quick picks',
              style: TextStyle(
                color: muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final q in quickPicks)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (q != value) {
                          onTick();
                          onChanged(q.clamp(min, max));
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: q == value
                              ? LinearGradient(
                                  colors: [
                                    accent,
                                    accent.withValues(alpha: 0.75),
                                  ],
                                )
                              : null,
                          color: q == value ? null : card,
                          border: Border.all(
                            color: q == value
                                ? Colors.white.withValues(alpha: 0.35)
                                : accent.withValues(alpha: 0.16),
                          ),
                          boxShadow: q == value
                              ? [
                                  BoxShadow(
                                    color: accent.withValues(alpha: 0.28),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          '$q',
                          style: TextStyle(
                            color: q == value
                                ? Colors.white
                                : text.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RoundMiniButton extends StatelessWidget {
  const _RoundMiniButton({
    required this.icon,
    required this.accent,
    required this.muted,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final Color muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: 0.12),
            border: Border.all(color: accent.withValues(alpha: 0.28)),
          ),
          child: Icon(icon, color: accent, size: 26),
        ),
      ),
    );
  }
}

class _PauseAfterStrip extends StatelessWidget {
  const _PauseAfterStrip({
    required this.accent,
    required this.text,
    required this.muted,
    required this.card,
    required this.title,
    required this.subtitle,
    required this.maxSlot,
    required this.selected,
    required this.onSelect,
  });

  final Color accent;
  final Color text;
  final Color muted;
  final Color card;
  final String title;
  final String subtitle;
  final int maxSlot;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: TimetableUiTokens.sectionShell(context, radius: 18),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: text,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: muted, fontSize: 12, height: 1.3),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 1; i <= maxSlot; i++) ...[
                if (i > 1) const SizedBox(width: 5),
                Expanded(
                  child: _SlotCell(
                    index: i,
                    accent: accent,
                    text: text,
                    card: card,
                    filled: i <= selected,
                    isEdge: i == selected,
                    compact: maxSlot > 8,
                    onTap: () => onSelect(i),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SlotCell extends StatelessWidget {
  const _SlotCell({
    required this.index,
    required this.accent,
    required this.text,
    required this.card,
    required this.filled,
    required this.isEdge,
    required this.compact,
    required this.onTap,
  });

  final int index;
  final Color accent;
  final Color text;
  final Color card;
  final bool filled;
  final bool isEdge;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final h = compact ? 36.0 : 40.0;
    return Semantics(
      button: true,
      label: 'After period $index',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: filled
                  ? LinearGradient(
                      colors: [accent, accent.withValues(alpha: 0.78)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: filled ? null : card,
              border: Border.all(
                color: filled
                    ? Colors.white.withValues(alpha: 0.35)
                    : accent.withValues(alpha: 0.14),
              ),
              boxShadow: isEdge
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              '$index',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: compact ? 12 : 14,
                color: filled ? Colors.white : text.withValues(alpha: 0.45),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RhythmStrip extends StatelessWidget {
  const _RhythmStrip({
    required this.accent,
    required this.text,
    required this.muted,
    required this.card,
    required this.selected,
    required this.onSelect,
  });

  final Color accent;
  final Color text;
  final Color muted;
  final Color card;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: TimetableUiTokens.sectionShell(context, radius: 18),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.graphic_eq_rounded, color: accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Long break rhythm',
                  style: TextStyle(
                    color: text,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Every how many periods should the long break appear?',
            style: TextStyle(color: muted, fontSize: 12, height: 1.3),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final n in const [2, 3, 4]) ...[
                if (n > 2) const SizedBox(width: 10),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onSelect(n),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: n == selected
                              ? LinearGradient(
                                  colors: [
                                    accent,
                                    accent.withValues(alpha: 0.72),
                                  ],
                                )
                              : null,
                          color: n == selected ? null : card,
                          border: Border.all(
                            color: n == selected
                                ? Colors.white.withValues(alpha: 0.35)
                                : accent.withValues(alpha: 0.14),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$n',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: n == selected ? Colors.white : text,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              n == 2
                                  ? 'pairs'
                                  : n == 3
                                  ? 'triplets'
                                  : 'quads',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: n == selected
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _LunchToggleRibbon extends StatelessWidget {
  const _LunchToggleRibbon({
    required this.accent,
    required this.text,
    required this.value,
    required this.onChanged,
  });

  final Color accent;
  final Color text;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: TimetableUiTokens.innerWell(context, radius: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: Text(
          'Lunch block in pattern',
          style: TextStyle(color: text, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          value
              ? 'Lunch gap is woven into the complex pattern.'
              : 'Skip lunch gap in this template.',
          style: TextStyle(
            color: TimetableUiTokens.textMuted(context),
            fontSize: 12,
          ),
        ),
        value: value,
        activeThumbColor: accent,
        onChanged: onChanged,
      ),
    );
  }
}

class _PreviewTimelineTile extends StatelessWidget {
  const _PreviewTimelineTile({
    required this.accent,
    required this.text,
    required this.card,
    required this.index,
    required this.label,
    required this.range,
    required this.isLast,
  });

  final Color accent;
  final Color text;
  final Color card;
  final int index;
  final String label;
  final String range;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.9),
                      accent.withValues(alpha: 0.55),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 44,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        accent.withValues(alpha: 0.45),
                        accent.withValues(alpha: 0.08),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: text,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  range,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
