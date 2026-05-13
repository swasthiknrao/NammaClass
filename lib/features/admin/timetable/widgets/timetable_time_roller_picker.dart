import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'timetable_ui_tokens.dart';

DateTime _anchor(int hour, int minute) =>
    DateTime(2000, 1, 1, hour.clamp(0, 23), minute.clamp(0, 59));

/// Cupertino-style hour / minute wheels in a centered glass popup (fade only).
Future<TimeOfDay?> showTimetableTimeRollerPicker(
  BuildContext context, {
  required TimeOfDay initialTime,
}) {
  final labels = MaterialLocalizations.of(context);
  return showGeneralDialog<TimeOfDay>(
    context: context,
    barrierDismissible: true,
    barrierLabel: labels.modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _TimeRollerPanel(
                dialogContext: dialogContext,
                initial: initialTime,
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(opacity: curved, child: child);
    },
  );
}

class _TimeRollerPanel extends StatefulWidget {
  const _TimeRollerPanel({required this.dialogContext, required this.initial});

  final BuildContext dialogContext;
  final TimeOfDay initial;

  @override
  State<_TimeRollerPanel> createState() => _TimeRollerPanelState();
}

class _TimeRollerPanelState extends State<_TimeRollerPanel> {
  late DateTime _selected;
  int _lastHapticHour = -1;
  int _lastHapticMinute = -1;

  @override
  void initState() {
    super.initState();
    _selected = _anchor(widget.initial.hour, widget.initial.minute);
    _lastHapticHour = _selected.hour;
    _lastHapticMinute = _selected.minute;
  }

  void _bump() => HapticFeedback.selectionClick();

  void _maybeWheelHaptic(int hour, int minute) {
    if (hour == _lastHapticHour && minute == _lastHapticMinute) return;
    _lastHapticHour = hour;
    _lastHapticMinute = minute;
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final accent = TimetableUiTokens.accent(context);
    final text = TimetableUiTokens.textPrimary(context);
    final muted = TimetableUiTokens.textMuted(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const radius = 28.0;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: accent.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    TimetableUiTokens.card(context).withValues(alpha: 0.94),
                    TimetableUiTokens.cardMuted(
                      context,
                    ).withValues(alpha: 0.97),
                  ],
                ),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: accent.withValues(alpha: 0.22)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Row(
                      children: [
                        Icon(Icons.schedule_rounded, color: accent, size: 26),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'First bell',
                                style: TextStyle(
                                  color: text,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              Text(
                                'Light tap each time hour or minute changes',
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // CupertinoDatePicker is laid out for 216px height; extra space
                  // misaligns the magnifier vs the wheel (especially on desktop).
                  SizedBox(
                    height: 216,
                    width: double.infinity,
                    child: Center(
                      child: CupertinoTheme(
                        data: CupertinoThemeData(
                          brightness: isDark
                              ? Brightness.dark
                              : Brightness.light,
                          primaryColor: accent,
                          textTheme: CupertinoTextThemeData(
                            dateTimePickerTextStyle: TextStyle(
                              color: text,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.time,
                          use24hFormat: true,
                          showTimeSeparator: true,
                          initialDateTime: _selected,
                          onDateTimeChanged: (dt) {
                            final next = _anchor(dt.hour, dt.minute);
                            _maybeWheelHaptic(next.hour, next.minute);
                            setState(() => _selected = next);
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 18),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(widget.dialogContext).pop(),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: muted,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: () {
                            _bump();
                            Navigator.of(widget.dialogContext).pop(
                              TimeOfDay(
                                hour: _selected.hour,
                                minute: _selected.minute,
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Done',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
