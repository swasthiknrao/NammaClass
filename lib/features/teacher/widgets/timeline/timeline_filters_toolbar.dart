import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/agent_debug_logger.dart';
import '../../models/timeline_models.dart';
import '../../providers/teacher_providers.dart';

class TimelineFiltersToolbar extends ConsumerStatefulWidget {
  const TimelineFiltersToolbar({super.key});

  @override
  ConsumerState<TimelineFiltersToolbar> createState() =>
      _TimelineFiltersToolbarState();
}

class _TimelineFiltersToolbarState
    extends ConsumerState<TimelineFiltersToolbar> {
  static TimelineZoom? _lastLoggedZoom;

  int? _lastItemsIdentity;
  List<String> _cachedAssignees = const [];
  List<String> _cachedFeatures = const [];

  @override
  Widget build(BuildContext context) {
    final buildStart = Stopwatch()..start();
    final notifier = ref.read(teacherTimelineProvider.notifier);

    final zoom = ref.watch(
      teacherTimelineProvider.select((s) => s.zoom),
    );
    final items = ref.watch(
      teacherTimelineProvider.select((s) => s.items),
    );
    final statusFilter = ref.watch(
      teacherTimelineProvider.select((s) => s.statusFilter),
    );
    final assigneeFilter = ref.watch(
      teacherTimelineProvider.select((s) => s.assigneeFilter),
    );
    final featureFilter = ref.watch(
      teacherTimelineProvider.select((s) => s.featureFilter),
    );
    final linkMode = ref.watch(
      teacherTimelineProvider.select((s) => s.linkMode),
    );

    final shouldLog = _lastLoggedZoom == null || _lastLoggedZoom != zoom;
    if (shouldLog) {
      _lastLoggedZoom = zoom;
    }

    final itemsIdentity = identityHashCode(items);
    if (_lastItemsIdentity != itemsIdentity) {
      _lastItemsIdentity = itemsIdentity;
      _cachedAssignees = items
          .map((e) => e.assigneeName)
          .whereType<String>()
          .toSet()
          .toList()
        ..sort();
      _cachedFeatures = items
          .map((e) => e.featureName)
          .whereType<String>()
          .toSet()
          .toList()
        ..sort();
    }

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
          'items': items.length,
          'assignees': _cachedAssignees.length,
          'features': _cachedFeatures.length,
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
        _buildZoomSegment(zoom, notifier),
        _buildStatusMenu(context, statusFilter, notifier),
        _buildChipMenu(
          label: 'Assignee',
          values: _cachedAssignees,
          selected: assigneeFilter,
          onApply: notifier.setAssigneeFilter,
        ),
        _buildChipMenu(
          label: 'Feature',
          values: _cachedFeatures,
          selected: featureFilter,
          onApply: notifier.setFeatureFilter,
        ),
        FilterChip(
          selected: linkMode,
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
    Set<TimelineTaskStatus> statusFilter,
    TeacherTimelineNotifier notifier,
  ) {
    return PopupMenuButton<TimelineTaskStatus>(
      tooltip: 'Status Filter',
      itemBuilder: (ctx) => TimelineTaskStatus.values
          .map(
            (s) => CheckedPopupMenuItem<TimelineTaskStatus>(
              value: s,
              checked: statusFilter.contains(s),
              child: Text(_statusLabel(s)),
            ),
          )
          .toList(),
      onSelected: (value) {
        final next = {...statusFilter};
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
