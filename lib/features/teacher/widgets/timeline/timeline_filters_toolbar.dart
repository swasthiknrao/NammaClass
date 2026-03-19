import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/agent_debug_logger.dart';
import '../../models/timeline_models.dart';
import '../../providers/teacher_providers.dart';

class TimelineFiltersToolbar extends ConsumerWidget {
  const TimelineFiltersToolbar({super.key});

  static TimelineZoom? _lastLoggedZoom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buildStart = Stopwatch()..start();
    final state = ref.watch(teacherTimelineProvider);
    final notifier = ref.read(teacherTimelineProvider.notifier);
    final zoom = state.zoom;
    final shouldLog = _lastLoggedZoom == null || _lastLoggedZoom != zoom;
    if (shouldLog) {
      _lastLoggedZoom = zoom;
    }
    final assignees =
        state.items
            .map((e) => e.assigneeName)
            .whereType<String>()
            .toSet()
            .toList()
          ..sort();
    final features =
        state.items
            .map((e) => e.featureName)
            .whereType<String>()
            .toSet()
            .toList()
          ..sort();

    // #region agent log H6_toolbar_build
    if (shouldLog && kDebugMode) {
      final ms = buildStart.elapsedMilliseconds;
      AgentDebugLogger.log(
        hypothesisId: 'H6_toolbar_build_ms',
        runId: 'pre-fix',
        location: 'timeline_filters_toolbar.dart:build',
        message: 'toolbar build time (zoom change)',
        data: <String, Object?>{
          'zoom': zoom.name,
          'ms': ms,
          'items': state.items.length,
          'assignees': assignees.length,
          'features': features.length,
        },
      );
    }
    // #endregion

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 8,
      children: [
        SizedBox(
          width: 220,
          child: TextField(
            onChanged: notifier.setSearchQuery,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, size: 18),
              hintText: 'Search tasks',
              isDense: true,
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.divider),
              ),
            ),
          ),
        ),
        _buildZoomSegment(state.zoom, notifier),
        _buildStatusMenu(context, state, notifier),
        _buildChipMenu(
          label: 'Assignee',
          values: assignees,
          selected: state.assigneeFilter,
          onApply: notifier.setAssigneeFilter,
        ),
        _buildChipMenu(
          label: 'Feature',
          values: features,
          selected: state.featureFilter,
          onApply: notifier.setFeatureFilter,
        ),
        FilterChip(
          selected: state.linkMode,
          onSelected: notifier.setLinkMode,
          label: const Text('Link Mode'),
          avatar: const Icon(Icons.link, size: 16),
        ),
        OutlinedButton.icon(
          onPressed: notifier.clearFilters,
          icon: const Icon(Icons.clear_all, size: 16),
          label: const Text('Clear'),
        ),
      ],
    );
  }

  Widget _buildZoomSegment(
    TimelineZoom zoom,
    TeacherTimelineNotifier notifier,
  ) {
    return SegmentedButton<TimelineZoom>(
      segments: const [
        ButtonSegment(value: TimelineZoom.day, label: Text('Day')),
        ButtonSegment(value: TimelineZoom.week, label: Text('Week')),
        ButtonSegment(value: TimelineZoom.month, label: Text('Month')),
      ],
      selected: {zoom},
      onSelectionChanged: (v) => notifier.setZoom(v.first),
    );
  }

  Widget _buildStatusMenu(
    BuildContext context,
    TeacherTimelineState state,
    TeacherTimelineNotifier notifier,
  ) {
    return PopupMenuButton<TimelineTaskStatus>(
      tooltip: 'Status Filter',
      itemBuilder: (ctx) => TimelineTaskStatus.values
          .map(
            (s) => CheckedPopupMenuItem<TimelineTaskStatus>(
              value: s,
              checked: state.statusFilter.contains(s),
              child: Text(_statusLabel(s)),
            ),
          )
          .toList(),
      onSelected: (value) {
        final next = {...state.statusFilter};
        if (next.contains(value)) {
          next.remove(value);
        } else {
          next.add(value);
        }
        notifier.setStatusFilter(next);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.divider),
          color: AppColors.card,
        ),
        child: Text('Status', style: AppTypography.bodySmall),
      ),
    );
  }

  Widget _buildChipMenu({
    required String label,
    required List<String> values,
    required Set<String> selected,
    required void Function(Set<String>) onApply,
  }) {
    return PopupMenuButton<String>(
      itemBuilder: (ctx) => values
          .map(
            (v) => CheckedPopupMenuItem<String>(
              value: v,
              checked: selected.contains(v),
              child: Text(v),
            ),
          )
          .toList(),
      onSelected: (value) {
        final next = {...selected};
        if (next.contains(value)) {
          next.remove(value);
        } else {
          next.add(value);
        }
        onApply(next);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.divider),
          color: AppColors.card,
        ),
        child: Text(label, style: AppTypography.bodySmall),
      ),
    );
  }

  String _statusLabel(TimelineTaskStatus s) {
    switch (s) {
      case TimelineTaskStatus.done:
        return 'Done';
      case TimelineTaskStatus.inProgress:
        return 'In Progress';
      case TimelineTaskStatus.pending:
        return 'Pending';
    }
  }
}
