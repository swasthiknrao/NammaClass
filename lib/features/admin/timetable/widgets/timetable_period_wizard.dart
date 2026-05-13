import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/timetable_period_definition.dart';
import '../providers/timetable_notifier.dart';
import 'timetable_bell_schedule_section.dart';
import 'timetable_ui_tokens.dart';

/// Opens the bell wizard: full-width bottom sheet on narrow screens, dialog on wide.
Future<void> showTimetablePeriodWizard(
  BuildContext context,
  WidgetRef ref, {
  required bool useSideDialog,
}) async {
  final hostContext = context;

  void applyAfterClose(List<TimetablePeriodDefinition> list) {
    ref.read(timetableNotifierProvider.notifier).applyAllPeriodsAndResize(list);
  }

  void popThenApply(NavigatorState nav, List<TimetablePeriodDefinition> list) {
    nav.pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!hostContext.mounted) return;
      applyAfterClose(list);
      ScaffoldMessenger.of(hostContext).showSnackBar(
        const SnackBar(
          content: Text('Bell template applied'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  if (useSideDialog) {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
        backgroundColor: TimetableUiTokens.card(ctx),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
          child: _TimetablePeriodWizardBody(
            onApply: (list) {
              popThenApply(Navigator.of(ctx), list);
            },
            onCancel: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
    );
  } else {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: TimetableUiTokens.card(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: SizedBox(
          height: MediaQuery.sizeOf(ctx).height * 0.9,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: _TimetablePeriodWizardBody(
                  onApply: (list) {
                    popThenApply(Navigator.of(ctx), list);
                  },
                  onCancel: () => Navigator.of(ctx).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimetablePeriodWizardBody extends ConsumerStatefulWidget {
  const _TimetablePeriodWizardBody({
    required this.onApply,
    required this.onCancel,
  });

  final void Function(List<TimetablePeriodDefinition>) onApply;
  final VoidCallback onCancel;

  @override
  ConsumerState<_TimetablePeriodWizardBody> createState() =>
      _TimetablePeriodWizardBodyState();
}

class _TimetablePeriodWizardBodyState
    extends ConsumerState<_TimetablePeriodWizardBody> {
  final GlobalKey<TimetableBellScheduleSectionState> _scheduleKey =
      GlobalKey<TimetableBellScheduleSectionState>();

  @override
  Widget build(BuildContext context) {
    final text = TimetableUiTokens.textPrimary(context);
    final accent = TimetableUiTokens.accent(context);
    final periodCount = ref.watch(timetableNotifierProvider).periods.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.auto_awesome, color: accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Bell studio',
                  style: TextStyle(
                    color: text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onCancel,
                icon: Icon(Icons.close, color: text),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: TimetableBellScheduleSection(
              key: _scheduleKey,
              showDescription: true,
              periodCount: periodCount,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: accent),
                  onPressed: () {
                    final list =
                        _scheduleKey.currentState?.computePreview() ?? [];
                    if (list.length == periodCount) {
                      widget.onApply(list);
                    }
                  },
                  child: const Text('Apply to bells'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
