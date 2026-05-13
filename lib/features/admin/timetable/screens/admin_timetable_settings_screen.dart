import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/screen_size.dart';
import '../../../../core/widgets/shell_layout_scope.dart';
import '../../../../domain/entities/timetable_period_definition.dart';
import '../providers/timetable_notifier.dart';
import '../timetable_limits.dart';
import '../utils/timetable_bell_presets.dart';
import '../widgets/timetable_bell_schedule_section.dart';
import '../widgets/timetable_period_wizard.dart';
import '../widgets/timetable_settings_summary.dart';
import '../widgets/timetable_ui_tokens.dart';

/// How many numbered slots to paint on the tap rail (grows with your counts).
int _timetableStripSlotExtent(
  TimetableState s, {
  required int selectionHint,
  int? dayIndex,
}) {
  var peak = s.periods.length;
  if (s.maxPeriodsConfigured > peak) peak = s.maxPeriodsConfigured;
  if (selectionHint > peak) peak = selectionHint;
  if (dayIndex == null) {
    for (final v in s.periodsPerDay) {
      if (v > peak) peak = v;
    }
  } else {
    final v = s.periodsPerDay[dayIndex];
    if (v > peak) peak = v;
  }
  return math
      .max(peak + 12, selectionHint + 24)
      .clamp(16, kTimetablePeriodHardCap);
}

/// Bell lab: working week, period rows, wizard, summary — responsive (mobile / tablet / desktop).
class AdminTimetableSettingsScreen extends ConsumerStatefulWidget {
  const AdminTimetableSettingsScreen({super.key});

  @override
  ConsumerState<AdminTimetableSettingsScreen> createState() =>
      _AdminTimetableSettingsScreenState();
}

class _AdminTimetableSettingsScreenState
    extends ConsumerState<AdminTimetableSettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final GlobalKey<TimetableBellScheduleSectionState> _bellFormKey =
      GlobalKey<TimetableBellScheduleSectionState>();

  Color get _cAccent => TimetableUiTokens.accent(context);

  Color get _cText => TimetableUiTokens.textPrimary(context);

  Color get _cBg => TimetableUiTokens.bg(context);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.65, curve: Curves.easeOut),
      ),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0, 0.65, curve: Curves.easeOutCubic),
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _introHeader(BuildContext context) {
    final isDesktop = ScreenSize.isDesktop(context);
    final isTablet = ScreenSize.isTablet(context);
    final titleSize = isDesktop ? 30.0 : (isTablet ? 26.0 : 24.0);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 22 : 18,
        isDesktop ? 22 : 18,
        isDesktop ? 22 : 18,
        isDesktop ? 20 : 18,
      ),
      decoration: TimetableUiTokens.heroShell(
        context,
        radius: isDesktop ? 22 : 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _cAccent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _cAccent.withValues(alpha: 0.35)),
            ),
            child: Text(
              'BELL LAB',
              style: TextStyle(
                color: _cAccent.withValues(alpha: 0.95),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
          ),
          SizedBox(height: isDesktop ? 14 : 12),
          Text(
            'Shape your teaching week',
            style: TextStyle(
              color: _cText,
              fontSize: titleSize,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Working days, bells, and presets feed the day builder, week grid, '
            'and teacher views — tuned for your campus rhythm.',
            style: TextStyle(
              color: _cText.withValues(alpha: 0.78),
              fontSize: isDesktop ? 15 : 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _workingDaysCard(
    BuildContext context,
    WidgetRef ref,
    List<bool> working,
  ) {
    final n = ref.read(timetableNotifierProvider.notifier);
    final compact = ScreenSize.isMobile(context);
    return _SectionCard(
      icon: Icons.calendar_month_rounded,
      title: 'Working week',
      subtitle:
          'Tap a day to include or exclude it from your teaching count. '
          'Mon–Sun rows appear in the builder; off-days stay dimmed.',
      child: Wrap(
        spacing: compact ? 8 : 10,
        runSpacing: compact ? 8 : 10,
        alignment: WrapAlignment.start,
        children: List.generate(working.length, (i) {
          final on = working[i];
          final label = TimetableNotifier.dayLabels[i];
          final short = compact && label.length > 3
              ? label.substring(0, 3)
              : label;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => n.setWorkingDay(i, !on),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 12 : 16,
                  vertical: compact ? 10 : 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: on
                      ? LinearGradient(
                          colors: [
                            _cAccent.withValues(alpha: 0.45),
                            _cAccent.withValues(alpha: 0.22),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: on ? null : TimetableUiTokens.bg(context),
                  border: Border.all(
                    color: on
                        ? _cAccent.withValues(alpha: 0.55)
                        : _cAccent.withValues(alpha: 0.18),
                    width: 1.2,
                  ),
                  boxShadow: on
                      ? [
                          BoxShadow(
                            color: _cAccent.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      on ? Icons.check_circle_rounded : Icons.circle_outlined,
                      size: 18,
                      color: on ? Colors.white : _cText.withValues(alpha: 0.45),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      short,
                      style: TextStyle(
                        color: on
                            ? Colors.white
                            : _cText.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w700,
                        fontSize: compact ? 12.5 : 13.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _periodLayoutCard(
    BuildContext context,
    WidgetRef ref,
    TimetableState s,
  ) {
    final n = ref.read(timetableNotifierProvider.notifier);
    final text = _cText;
    final compact = ScreenSize.isMobile(context);
    final globalCount = s.periodsPerDay.isNotEmpty
        ? s.periodsPerDay.first
        : s.periods.length;

    return _SectionCard(
      icon: Icons.view_week_rounded,
      title: 'Periods per day',
      subtitle: s.usePerDayCounts
          ? 'Bell columns = your labels. The tap rail keeps growing — swipe for big counts (engine cap $kTimetablePeriodHardCap).'
          : 'Same count Mon–Sun. Tap any number on the endless rail — it lengthens as you reach further (cap $kTimetablePeriodHardCap).',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Per-day period counts',
              style: TextStyle(color: text, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              s.usePerDayCounts
                  ? 'Independent counts Mon–Sun'
                  : 'One count for all days',
              style: TextStyle(
                color: text.withValues(alpha: 0.68),
                fontSize: 12,
              ),
            ),
            value: s.usePerDayCounts,
            onChanged: n.setUsePerDayCounts,
            activeThumbColor: _cAccent,
          ),
          if (!s.usePerDayCounts) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$globalCount',
                  style: TextStyle(
                    color: _cAccent,
                    fontWeight: FontWeight.w900,
                    fontSize: compact ? 40 : 48,
                    height: 1,
                    letterSpacing: -1.5,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'periods\nper day',
                    style: TextStyle(
                      color: text.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w600,
                      fontSize: compact ? 13 : 14,
                      height: 1.15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: 16,
                  color: _cAccent.withValues(alpha: 0.75),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Bracket train — tap where the school day should end.',
                    style: TextStyle(
                      color: text.withValues(alpha: 0.55),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _TapPeriodStrip(
              slotCount: _timetableStripSlotExtent(
                s,
                selectionHint: globalCount,
              ),
              selected: globalCount.clamp(1, kTimetablePeriodHardCap),
              onSelect: n.setGlobalPeriodCount,
              compact: compact,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.all_inclusive_rounded,
                    size: 16,
                    color: _cAccent.withValues(alpha: 0.75),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Rail auto-lengthens. Swipe for huge counts; labels stay yours (hard stop $kTimetablePeriodHardCap).',
                      style: TextStyle(
                        color: text.withValues(alpha: 0.52),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 4),
            ...List.generate(TimetableNotifier.dayLabels.length, (i) {
              final label = TimetableNotifier.dayLabels[i];
              final short = label.length >= 3 ? label.substring(0, 3) : label;
              final count = s.periodsPerDay[i];
              final rowSlots = _timetableStripSlotExtent(
                s,
                selectionHint: count,
                dayIndex: i,
              );
              return Padding(
                padding: EdgeInsets.only(bottom: compact ? 10 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: _cAccent.withValues(alpha: 0.55),
                                width: 3,
                              ),
                            ),
                          ),
                          child: Text(
                            short,
                            style: TextStyle(
                              color: text,
                              fontWeight: FontWeight.w800,
                              fontSize: compact ? 12 : 13,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: TextStyle(
                            color: text.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _cAccent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              color: _cAccent,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _TapPeriodStrip(
                      slotCount: rowSlots,
                      selected: count.clamp(1, kTimetablePeriodHardCap),
                      onSelect: (v) => n.setPeriodsCountForDay(i, v),
                      compact: true,
                    ),
                  ],
                ),
              );
            }),
            if (s.usePerDayCounts)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    Icon(
                      Icons.all_inclusive_rounded,
                      size: 15,
                      color: _cAccent.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Each rail grows with that day — same $kTimetablePeriodHardCap safety ceiling.',
                        style: TextStyle(
                          color: text.withValues(alpha: 0.52),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: n.reconcilePeriodColumnsToMaxPerDay,
              icon: Icon(Icons.unfold_more, color: _cAccent, size: 18),
              label: Text(
                'Add columns up to max day',
                style: TextStyle(color: _cAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridContractCard(BuildContext context, int periodCount) {
    final mobile = ScreenSize.isMobile(context);
    final mid = (periodCount / 2).ceil().clamp(1, periodCount);
    final chips = [
      for (var i = 0; i < periodCount; i++)
        Container(
          margin: const EdgeInsets.only(right: 8, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: TimetableUiTokens.bg(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: i < mid
                  ? TimetableUiTokens.accent(context).withValues(alpha: 0.42)
                  : TimetableUiTokens.primary(context).withValues(alpha: 0.38),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                i < mid ? Icons.wb_sunny_rounded : Icons.nights_stay_outlined,
                size: 16,
                color: i < mid
                    ? TimetableUiTokens.accent(context)
                    : TimetableUiTokens.primary(context),
              ),
              const SizedBox(width: 6),
              Text(
                'P${i + 1}',
                style: TextStyle(
                  color: _cText,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
    ];

    return _SectionCard(
      icon: Icons.grid_view_rounded,
      title: 'Period grid',
      subtitle:
          '$periodCount bell slots (columns). Morning / afternoon styling splits '
          'at the midpoint; per-day usage is configured below.',
      child: mobile
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(children: chips),
            )
          : Wrap(children: chips),
    );
  }

  Future<void> _confirmApplyPreset(
    BuildContext context,
    WidgetRef ref,
    TimetableBellPreset preset,
  ) async {
    final pc = ref.read(timetableNotifierProvider).periods.length;
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: TimetableUiTokens.card(ctx),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: BorderSide(
                color: TimetableUiTokens.accent(ctx).withValues(alpha: 0.35),
              ),
            ),
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TimetableUiTokens.accent(ctx).withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: TimetableUiTokens.accent(ctx).withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.layers_rounded,
                color: TimetableUiTokens.accent(ctx),
                size: 28,
              ),
            ),
            title: Text(
              'Apply preset?',
              style: TextStyle(
                color: TimetableUiTokens.textPrimary(ctx),
                fontWeight: FontWeight.w800,
              ),
            ),
            content: Text(
              '"${preset.title}" replaces all $pc period start/end labels. '
              'You can still fine-tune each row afterwards.',
              style: TextStyle(
                color: TimetableUiTokens.textPrimary(
                  ctx,
                ).withValues(alpha: 0.88),
                height: 1.4,
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TimetableUiTokens.textPrimary(ctx),
                        side: BorderSide(
                          color: TimetableUiTokens.textPrimary(
                            ctx,
                          ).withValues(alpha: 0.35),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: TimetableUiTokens.accent(ctx),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Apply preset'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ) ??
        false;
    if (!ok || !context.mounted) return;
    ref
        .read(timetableNotifierProvider.notifier)
        .applyAllPeriodsAndResize(preset.buildSchedule(periodCount: pc));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied "${preset.title}" preset'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _cAccent,
      ),
    );
  }

  int _presetColumnCount(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= 1100) return 3;
    if (w >= 560) return 2;
    return 1;
  }

  Widget _creativePresetsCard(BuildContext context, WidgetRef ref) {
    final columns = _presetColumnCount(context);
    final pc = ref.watch(timetableNotifierProvider).periods.length;
    return _SectionCard(
      icon: Icons.auto_awesome_mosaic_rounded,
      title: 'Creative period builder',
      subtitle:
          'Curated bell curves for typical college rhythms. '
          'Each preset fills all current slots — tap a tile to confirm and apply.',
      child: LayoutBuilder(
        builder: (context, c) {
          final spacing = 12.0;
          final tileW = (c.maxWidth - spacing * (columns - 1)) / columns;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: TimetableBellPreset.values.map((p) {
              return SizedBox(
                width: tileW.clamp(120, 400),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _confirmApplyPreset(context, ref, p),
                    borderRadius: BorderRadius.circular(16),
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            TimetableUiTokens.bg(context),
                            TimetableUiTokens.cardMuted(
                              context,
                            ).withValues(alpha: 0.9),
                          ],
                        ),
                        border: Border.all(
                          color: _cAccent.withValues(alpha: 0.22),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _cAccent.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    p.icon,
                                    color: _cAccent,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    p.title,
                                    style: TextStyle(
                                      color: _cText,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              p.subtitleFor(pc),
                              style: TextStyle(
                                color: _cText.withValues(alpha: 0.68),
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  /// Phones: one **Bell studio** entry (full editor lives in the sheet — no second copy
  /// on this scroll). Tablet/desktop: **Time configuration** inline with Apply.
  Widget _bellStudioSection(BuildContext context, WidgetRef ref) {
    if (ScreenSize.isMobile(context)) {
      final pc = ref.watch(timetableNotifierProvider).periods.length;
      return _SectionCard(
        icon: Icons.schedule_rounded,
        title: 'Bell times',
        subtitle:
            'First bell, lesson length, breaks, and live runway — open the studio; '
            'Apply there writes the same bell rows as on larger screens.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'You have $pc bell row${pc == 1 ? '' : 's'} configured.',
              style: TextStyle(
                color: _cText.withValues(alpha: 0.72),
                fontSize: 13,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () =>
                  showTimetablePeriodWizard(context, ref, useSideDialog: false),
              style: FilledButton.styleFrom(
                backgroundColor: _cAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.auto_awesome_rounded, size: 22),
              label: const Text(
                'Open bell studio',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ],
        ),
      );
    }
    return _timeConfigurationCard(context, ref);
  }

  Widget _timeConfigurationCard(BuildContext context, WidgetRef ref) {
    final wide = ScreenSize.isDesktop(context);
    final periodCount = ref.watch(timetableNotifierProvider).periods.length;
    return _SectionCard(
      icon: Icons.schedule_rounded,
      title: 'Time configuration',
      subtitle:
          'Dial in first bell, lesson length, and gaps. Live preview below; '
          'Apply pushes all $periodCount rows at once.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: TimetableUiTokens.innerWell(context, radius: 16),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                wide ? 18 : 14,
                wide ? 16 : 12,
                wide ? 18 : 14,
                wide ? 14 : 10,
              ),
              child: TimetableBellScheduleSection(
                key: _bellFormKey,
                showDescription: false,
                periodCount: periodCount,
              ),
            ),
          ),
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [_cAccent, Color.lerp(_cAccent, Colors.black, 0.18)!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _cAccent.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  final list = _bellFormKey.currentState?.computePreview();
                  final expect = ref
                      .read(timetableNotifierProvider)
                      .periods
                      .length;
                  if (list == null || list.length != expect) return;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!context.mounted) return;
                    ref
                        .read(timetableNotifierProvider.notifier)
                        .applyAllPeriodsAndResize(list);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Bells updated from time configuration',
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: _cAccent,
                      ),
                    );
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Apply generated bells',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodsPanel(List<TimetablePeriodDefinition> periods, bool dense) {
    return _SectionCard(
      icon: Icons.edit_calendar_rounded,
      title: 'Manual period rows',
      subtitle: dense
          ? 'Dense editor for wide screens — apply each row when ready.'
          : 'Fine-tune labels and bell strings (e.g. 8:50, 1:05).',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...periods.asMap().entries.map((e) {
            final i = e.key;
            final p = e.value;
            final isLast = i == periods.length - 1;
            return _PeriodBlock(
              key: ValueKey('p$i|${p.label}|${p.startLabel}|${p.endLabel}'),
              index: i,
              initial: p,
              isLast: isLast,
              dense: dense,
              accentColor: _cAccent,
              textColor: _cText,
              backgroundColor: _cBg,
            );
          }),
        ],
      ),
    );
  }

  Widget _leftColumn(BuildContext context, WidgetRef ref, TimetableState tt) {
    final periods = tt.periods;
    final working = tt.workingWeekdays;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _introHeader(context),
          const SizedBox(height: 16),
          TimetableSettingsSummary(
            periods: periods,
            workingWeekdays: working,
            dayLabels: TimetableNotifier.dayLabels,
            periodsPerDay: tt.periodsPerDay,
            usePerDayCounts: tt.usePerDayCounts,
          ),
          const SizedBox(height: 16),
          _workingDaysCard(context, ref, working),
          const SizedBox(height: 16),
          _periodLayoutCard(context, ref, tt),
          const SizedBox(height: 16),
          _gridContractCard(context, periods.length),
          const SizedBox(height: 16),
          _bellStudioSection(context, ref),
          const SizedBox(height: 16),
          _creativePresetsCard(context, ref),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(timetableNotifierProvider);
    final periods = state.periods;
    final working = state.workingWeekdays;
    final hideAppBar =
        ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true;

    final isMobile = ScreenSize.isMobile(context);
    final isDesktop = ScreenSize.isDesktop(context);
    final isTablet = ScreenSize.isTablet(context);
    final padH = isDesktop ? 28.0 : (isTablet ? 22.0 : 16.0);

    final body = FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: isMobile
            ? Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        padH,
                        hideAppBar ? MediaQuery.paddingOf(context).top + 12 : 8,
                        padH,
                        8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (hideAppBar) ...[
                            Row(
                              children: [
                                IconButton(
                                  style: IconButton.styleFrom(
                                    backgroundColor: _cAccent.withValues(
                                      alpha: 0.12,
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.arrow_back_rounded,
                                    color: _cAccent,
                                  ),
                                  onPressed: () => context.pop(),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Timetable settings',
                                    style: TextStyle(
                                      color: _cText,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                          _introHeader(context),
                          const SizedBox(height: 14),
                          TimetableSettingsSummary(
                            periods: periods,
                            workingWeekdays: working,
                            dayLabels: TimetableNotifier.dayLabels,
                            periodsPerDay: state.periodsPerDay,
                            usePerDayCounts: state.usePerDayCounts,
                          ),
                          const SizedBox(height: 16),
                          _workingDaysCard(context, ref, working),
                          const SizedBox(height: 16),
                          _periodLayoutCard(context, ref, state),
                          const SizedBox(height: 16),
                          _gridContractCard(context, periods.length),
                          const SizedBox(height: 16),
                          _bellStudioSection(context, ref),
                          const SizedBox(height: 16),
                          _creativePresetsCard(context, ref),
                          const SizedBox(height: 20),
                          _periodsPanel(periods, false),
                          const SizedBox(height: 20),
                          _doneButton(context),
                        ],
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            TimetableUiTokens.card(context),
                            TimetableUiTokens.cardMuted(context),
                          ],
                        ),
                        border: Border(
                          top: BorderSide(
                            color: TimetableUiTokens.accent(
                              context,
                            ).withValues(alpha: 0.45),
                            width: 3,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 24,
                            offset: const Offset(0, -6),
                          ),
                        ],
                      ),
                      child: TimetableSettingsSummary(
                        periods: periods,
                        workingWeekdays: working,
                        dayLabels: TimetableNotifier.dayLabels,
                        periodsPerDay: state.periodsPerDay,
                        usePerDayCounts: state.usePerDayCounts,
                        compact: true,
                      ),
                    ),
                  ),
                ],
              )
            : Padding(
                padding: EdgeInsets.fromLTRB(
                  padH,
                  hideAppBar ? MediaQuery.paddingOf(context).top + 12 : 12,
                  padH,
                  16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: isDesktop ? 2 : 1,
                      child: _leftColumn(context, ref, state),
                    ),
                    SizedBox(width: isDesktop ? 28 : 16),
                    Expanded(
                      flex: isDesktop ? 3 : 1,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (hideAppBar && !isDesktop) ...[
                              Row(
                                children: [
                                  IconButton(
                                    style: IconButton.styleFrom(
                                      backgroundColor: _cAccent.withValues(
                                        alpha: 0.12,
                                      ),
                                    ),
                                    icon: Icon(
                                      Icons.arrow_back_rounded,
                                      color: _cAccent,
                                    ),
                                    onPressed: () => context.pop(),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Timetable settings',
                                      style: TextStyle(
                                        color: _cText,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (hideAppBar && isDesktop)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    IconButton(
                                      style: IconButton.styleFrom(
                                        backgroundColor: _cAccent.withValues(
                                          alpha: 0.12,
                                        ),
                                      ),
                                      icon: Icon(
                                        Icons.arrow_back_rounded,
                                        color: _cAccent,
                                      ),
                                      onPressed: () => context.pop(),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Timetable settings',
                                      style: TextStyle(
                                        color: _cText,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            _periodsPanel(periods, true),
                            const SizedBox(height: 24),
                            _doneButton(context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: _cBg,
        appBarTheme: AppBarTheme(
          backgroundColor: _cBg,
          foregroundColor: _cText,
          elevation: 0,
        ),
      ),
      child: Scaffold(
        backgroundColor: _cBg,
        appBar: hideAppBar
            ? null
            : AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: _cAccent),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  'Timetable settings',
                  style: TextStyle(
                    color: _cText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        body: body,
      ),
    );
  }

  Widget _doneButton(BuildContext context) {
    final wide = ScreenSize.isDesktop(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [_cAccent, Color.lerp(_cAccent, Colors.black, 0.2)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _cAccent.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.pop(),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: wide ? 17 : 15),
            child: const Center(
              child: Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontally scrolling tap rail: slots **1…slotCount** (virtualized).
class _TapPeriodStrip extends StatefulWidget {
  const _TapPeriodStrip({
    required this.slotCount,
    required this.selected,
    required this.onSelect,
    this.compact = false,
  });

  final int slotCount;
  final int selected;
  final ValueChanged<int> onSelect;
  final bool compact;

  @override
  State<_TapPeriodStrip> createState() => _TapPeriodStripState();
}

class _TapPeriodStripState extends State<_TapPeriodStrip> {
  final ScrollController _scroll = ScrollController();

  double get _cellW => widget.compact ? 36.0 : 44.0;

  double get _gap => widget.compact ? 3.0 : 5.0;

  double get _cellPitch => _cellW + _gap;

  int get _n => widget.slotCount.clamp(0, kTimetablePeriodHardCap);

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToSelected(animate: false),
    );
  }

  @override
  void didUpdateWidget(covariant _TapPeriodStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected ||
        oldWidget.compact != widget.compact ||
        oldWidget.slotCount != widget.slotCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  void _scrollToSelected({bool animate = true}) {
    if (!_scroll.hasClients || _n <= 0) return;
    final vp = _scroll.position.viewportDimension;
    final maxExt = _scroll.position.maxScrollExtent;
    final idx = (widget.selected - 1).clamp(0, _n - 1);
    final center = idx * _cellPitch + _cellW / 2;
    final target = (center - vp / 2).clamp(0.0, maxExt);
    if (animate) {
      _scroll.animateTo(
        target,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scroll.jumpTo(target);
    }
  }

  double _fontForIndex(int i) {
    if (i >= 1000) return widget.compact ? 8.5 : 9.5;
    if (i >= 100) return widget.compact ? 9.5 : 11;
    if (i >= 10 && widget.compact) return 11;
    return widget.compact ? 12 : 14;
  }

  @override
  Widget build(BuildContext context) {
    final accent = TimetableUiTokens.accent(context);
    final surface = TimetableUiTokens.card(context);
    final muted = TimetableUiTokens.textPrimary(
      context,
    ).withValues(alpha: 0.45);
    final h = widget.compact ? 34.0 : 42.0;
    if (_n <= 0) return const SizedBox.shrink();

    return Scrollbar(
      controller: _scroll,
      thumbVisibility: true,
      radius: const Radius.circular(8),
      child: SizedBox(
        height: h + 6,
        child: ListView.builder(
          controller: _scroll,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 4),
          itemCount: _n,
          itemBuilder: (context, index) {
            final i = index + 1;
            final fs = _fontForIndex(i);
            return Padding(
              padding: EdgeInsets.only(right: index < _n - 1 ? _gap : 0),
              child: SizedBox(
                width: _cellW,
                height: h,
                child: Semantics(
                  button: true,
                  label: 'Use $i ${i == 1 ? 'period' : 'periods'}',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (i != widget.selected) {
                          HapticFeedback.selectionClick();
                          widget.onSelect(i);
                        }
                      },
                      borderRadius: BorderRadius.circular(
                        widget.compact ? 8 : 10,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        height: h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            widget.compact ? 8 : 10,
                          ),
                          gradient: i <= widget.selected
                              ? LinearGradient(
                                  colors: [
                                    accent,
                                    accent.withValues(alpha: 0.78),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: i <= widget.selected ? null : surface,
                          border: Border.all(
                            color: i <= widget.selected
                                ? Colors.white.withValues(alpha: 0.35)
                                : accent.withValues(alpha: 0.14),
                            width: i <= widget.selected ? 1.2 : 1,
                          ),
                          boxShadow: i == widget.selected
                              ? [
                                  BoxShadow(
                                    color: accent.withValues(alpha: 0.38),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          '$i',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: fs,
                            color: i <= widget.selected ? Colors.white : muted,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = ScreenSize.isDesktop(context) ? 20.0 : 18.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: TimetableUiTokens.sectionShell(
                context,
                radius: radius,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    TimetableUiTokens.accent(context),
                    TimetableUiTokens.accent(context).withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              ScreenSize.isDesktop(context) ? 20 : 18,
              18,
              ScreenSize.isDesktop(context) ? 20 : 18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: TimetableUiTokens.accent(
                          context,
                        ).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: TimetableUiTokens.accent(
                            context,
                          ).withValues(alpha: 0.35),
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: TimetableUiTokens.accent(context),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: TimetableUiTokens.textPrimary(context),
                              fontSize: ScreenSize.isDesktop(context) ? 19 : 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: TimetableUiTokens.textPrimary(
                                context,
                              ).withValues(alpha: 0.72),
                              fontSize: 12.5,
                              height: 1.38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodBlock extends ConsumerStatefulWidget {
  const _PeriodBlock({
    super.key,
    required this.index,
    required this.initial,
    required this.isLast,
    required this.dense,
    required this.accentColor,
    required this.textColor,
    required this.backgroundColor,
  });

  final int index;
  final TimetablePeriodDefinition initial;
  final bool isLast;
  final bool dense;
  final Color accentColor;
  final Color textColor;
  final Color backgroundColor;

  @override
  ConsumerState<_PeriodBlock> createState() => _PeriodBlockState();
}

class _PeriodBlockState extends ConsumerState<_PeriodBlock> {
  late final TextEditingController _label;
  late final TextEditingController _start;
  late final TextEditingController _end;

  @override
  void initState() {
    super.initState();
    _label = TextEditingController(text: widget.initial.label);
    _start = TextEditingController(text: widget.initial.startLabel);
    _end = TextEditingController(text: widget.initial.endLabel);
  }

  @override
  void didUpdateWidget(covariant _PeriodBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial.label != widget.initial.label) {
      _label.text = widget.initial.label;
    }
    if (oldWidget.initial.startLabel != widget.initial.startLabel) {
      _start.text = widget.initial.startLabel;
    }
    if (oldWidget.initial.endLabel != widget.initial.endLabel) {
      _end.text = widget.initial.endLabel;
    }
  }

  @override
  void dispose() {
    _label.dispose();
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  InputDecoration _decoration(
    String hint, {
    IconData? icon,
    bool compact = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: widget.textColor.withValues(alpha: 0.45)),
      prefixIcon: icon == null
          ? null
          : Icon(icon, color: widget.accentColor, size: compact ? 18 : 20),
      filled: true,
      fillColor: widget.backgroundColor,
      contentPadding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 8 : 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: widget.accentColor.withValues(alpha: 0.25),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: widget.accentColor.withValues(alpha: 0.25),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: widget.accentColor, width: 2),
      ),
    );
  }

  void _apply() {
    ref
        .read(timetableNotifierProvider.notifier)
        .setPeriodDefinition(
          widget.index,
          TimetablePeriodDefinition(
            index: widget.index,
            label: _label.text.trim().isEmpty
                ? 'Period ${widget.index + 1}'
                : _label.text.trim(),
            startLabel: _start.text.trim(),
            endLabel: _end.text.trim(),
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Period ${widget.index + 1} updated'),
        backgroundColor: widget.accentColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final border = widget.isLast
        ? null
        : Border(
            bottom: BorderSide(
              color: widget.accentColor.withValues(alpha: 0.12),
              width: 1,
            ),
          );

    if (widget.dense) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
        decoration: BoxDecoration(
          color: widget.backgroundColor.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.accentColor.withValues(alpha: 0.18)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    widget.accentColor.withValues(alpha: 0.9),
                    widget.accentColor.withValues(alpha: 0.45),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                '${widget.index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: TextField(
                controller: _label,
                style: TextStyle(color: widget.textColor, fontSize: 13),
                cursorColor: widget.accentColor,
                decoration: _decoration(
                  'Label',
                  icon: Icons.label_outline,
                  compact: true,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _start,
                style: TextStyle(color: widget.textColor, fontSize: 13),
                cursorColor: widget.accentColor,
                decoration: _decoration(
                  'Start',
                  icon: Icons.schedule_outlined,
                  compact: true,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _end,
                style: TextStyle(color: widget.textColor, fontSize: 13),
                cursorColor: widget.accentColor,
                decoration: _decoration(
                  'End',
                  icon: Icons.schedule_outlined,
                  compact: true,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Apply',
              onPressed: _apply,
              style: IconButton.styleFrom(
                backgroundColor: widget.accentColor.withValues(alpha: 0.12),
              ),
              icon: Icon(Icons.check_rounded, color: widget.accentColor),
            ),
          ],
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Period ${widget.index + 1}',
            style: TextStyle(
              color: widget.textColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _label,
            style: TextStyle(color: widget.textColor, fontSize: 15),
            cursorColor: widget.accentColor,
            decoration: _decoration(
              'Label (e.g. Period 1)',
              icon: Icons.label_outline,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _start,
                  style: TextStyle(color: widget.textColor, fontSize: 15),
                  cursorColor: widget.accentColor,
                  decoration: _decoration(
                    'Start',
                    icon: Icons.schedule_outlined,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _end,
                  style: TextStyle(color: widget.textColor, fontSize: 15),
                  cursorColor: widget.accentColor,
                  decoration: _decoration('End', icon: Icons.schedule_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _apply,
              style: TextButton.styleFrom(foregroundColor: widget.accentColor),
              child: const Text(
                'Apply row',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
