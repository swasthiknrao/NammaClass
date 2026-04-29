import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../models/timeline_models.dart';
import '../../providers/teacher_providers.dart';
import 'timeline_canvas.dart';
import 'timeline_filters_toolbar.dart';
import 'timeline_header.dart';
import 'timeline_hierarchy_panel.dart';
import 'timeline_view_utils.dart';

class TimelineRoadmapView extends ConsumerStatefulWidget {
  const TimelineRoadmapView({super.key});

  @override
  ConsumerState<TimelineRoadmapView> createState() =>
      _TimelineRoadmapViewState();
}

class _TimelineRoadmapViewState extends ConsumerState<TimelineRoadmapView>
    with SingleTickerProviderStateMixin {
  late final ScrollController _hierarchyVerticalController;
  late final ScrollController _timelineVerticalController;
  late final ScrollController _headerHorizontalController;
  late final ScrollController _canvasHorizontalController;
  bool _syncingVertical = false;
  bool _syncingHorizontal = false;

  /// Last `MediaQuery` mobile breakpoint; used when morph completes off-frame.
  bool _lastIsMobile = false;

  // Cache heavy derived timeline layout so zoom-only changes stay smooth.
  _HeavyInputs? _lastHeavyInputs;
  List<TeacherTimelineItem> _cachedVisibleRows = const [];
  List<DateTime> _cachedVisibleDates = const [];
  LaneLayout _cachedLaneLayout = const LaneLayout(
    laneIndexById: {},
    laneCountById: {},
  );

  // Debug: track zoom changes (for _lastLoggedZoom guard in build).
  TimelineZoom? _lastLoggedZoom;

  // Zoom swap animation: keep rendering the previous zoom subtree while we
  // morph, then swap the cached subtree at animation end.
  AnimationController? _zoomMorphController;
  TimelineZoom? _displayZoom;
  TimelineZoom? _pendingZoom;

  /// Pixel cell width at morph start / end (lerped during animation).
  double _morphWidthStart = 56;
  double _morphWidthEnd = 56;
  Widget? _cachedLeftPanel;
  Widget? _cachedRightPanel;
  bool _timelineChildDirty = true;

  static double _cellWidthForZoom(TimelineZoom z, bool isMobile) => switch (z) {
    TimelineZoom.day => isMobile ? 46.0 : 56.0,
    TimelineZoom.week => isMobile ? 70.0 : 86.0,
    TimelineZoom.month => isMobile ? 100.0 : 140.0,
  };

  void _rescaleHorizontalScrollByRatio(double ratio) {
    if (ratio <= 0 || ratio.isNaN) return;
    void apply(ScrollController c) {
      if (!c.hasClients) return;
      final next = (c.offset * ratio).clamp(
        c.position.minScrollExtent,
        c.position.maxScrollExtent,
      );
      c.jumpTo(next);
    }

    apply(_headerHorizontalController);
    apply(_canvasHorizontalController);
  }

  void _ensureZoomMorphController() {
    if (_zoomMorphController != null) return;
    _zoomMorphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _zoomMorphController!.addStatusListener((status) {
      if (status != AnimationStatus.completed) return;
      if (_pendingZoom == null || _displayZoom == null) return;
      final oldZ = _displayZoom!;
      final newZ = _pendingZoom!;
      final oldW = _cellWidthForZoom(oldZ, _lastIsMobile);
      final newW = _cellWidthForZoom(newZ, _lastIsMobile);
      final scrollRatio = oldW > 0 ? newW / oldW : 1.0;
      setState(() {
        _displayZoom = newZ;
        _timelineChildDirty = true;
        // Reset transform so the new zoom subtree renders at scale=1.
        _zoomMorphController?.value = 0;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _rescaleHorizontalScrollByRatio(scrollRatio);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _displayZoom = ref.read(teacherTimelineProvider).zoom;
    _pendingZoom = _displayZoom;
    _ensureZoomMorphController();
    _hierarchyVerticalController = ScrollController();
    _timelineVerticalController = ScrollController();
    _headerHorizontalController = ScrollController();
    _canvasHorizontalController = ScrollController();
    _hierarchyVerticalController.addListener(_syncVerticalFromLeft);
    _timelineVerticalController.addListener(_syncVerticalFromRight);
    _headerHorizontalController.addListener(_syncHorizontalFromHeader);
    _canvasHorizontalController.addListener(_syncHorizontalFromCanvas);
  }

  @override
  void dispose() {
    _zoomMorphController?.dispose();
    _hierarchyVerticalController.removeListener(_syncVerticalFromLeft);
    _timelineVerticalController.removeListener(_syncVerticalFromRight);
    _headerHorizontalController.removeListener(_syncHorizontalFromHeader);
    _canvasHorizontalController.removeListener(_syncHorizontalFromCanvas);
    _hierarchyVerticalController.dispose();
    _timelineVerticalController.dispose();
    _headerHorizontalController.dispose();
    _canvasHorizontalController.dispose();
    super.dispose();
  }

  void _syncVerticalFromLeft() => _sync(
    source: _hierarchyVerticalController,
    target: _timelineVerticalController,
    vertical: true,
  );
  void _syncVerticalFromRight() => _sync(
    source: _timelineVerticalController,
    target: _hierarchyVerticalController,
    vertical: true,
  );
  void _syncHorizontalFromHeader() => _sync(
    source: _headerHorizontalController,
    target: _canvasHorizontalController,
    vertical: false,
  );
  void _syncHorizontalFromCanvas() => _sync(
    source: _canvasHorizontalController,
    target: _headerHorizontalController,
    vertical: false,
  );

  void _sync({
    required ScrollController source,
    required ScrollController target,
    required bool vertical,
  }) {
    if (!source.hasClients || !target.hasClients) return;
    if (vertical && _syncingVertical) return;
    if (!vertical && _syncingHorizontal) return;
    if (vertical) {
      _syncingVertical = true;
    } else {
      _syncingHorizontal = true;
    }
    final next = source.offset.clamp(
      target.position.minScrollExtent,
      target.position.maxScrollExtent,
    );
    if ((target.offset - next).abs() > 0.5) {
      target.jumpTo(next);
    }
    if (vertical) {
      _syncingVertical = false;
    } else {
      _syncingHorizontal = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    _ensureZoomMorphController();
    final zoomController = _zoomMorphController!;
    final zoom = ref.watch(teacherTimelineProvider.select((s) => s.zoom));
    _currentZoomForLogs = zoom;
    final zoomChanged = _lastLoggedZoom == null || _lastLoggedZoom != zoom;
    if (zoomChanged) {
      _syncLogForZoom = zoom;
      _syncJumpLogCount = 0;
      _lastLoggedZoom = zoom;
    }
    final selectedTaskId = ref.watch(
      teacherTimelineProvider.select((s) => s.selectedTaskId),
    );
    final linkMode = ref.watch(
      teacherTimelineProvider.select((s) => s.linkMode),
    );
    final heavyInputs = ref.watch(
      teacherTimelineProvider.select(
        (s) => _HeavyInputs(
          items: s.items,
          searchQuery: s.searchQuery,
          statusFilter: s.statusFilter,
          assigneeFilter: s.assigneeFilter,
          featureFilter: s.featureFilter,
          expandedNodeIds: s.expandedNodeIds,
        ),
      ),
    );
    final notifier = ref.read(teacherTimelineProvider.notifier);

    // Only recompute expensive timeline layout when filters/expansion change.
    if (_lastHeavyInputs != heavyInputs) {
      _timelineChildDirty = true;
      final filtered = _applyFilters(
        heavyInputs.items,
        heavyInputs.searchQuery,
        heavyInputs.statusFilter,
        heavyInputs.assigneeFilter,
        heavyInputs.featureFilter,
      );

      _cachedVisibleRows = _buildVisibleRows(
        filtered,
        heavyInputs.expandedNodeIds,
      );
      _cachedLaneLayout = buildLaneLayout(_cachedVisibleRows);
      _cachedVisibleDates = _buildVisibleDates(_cachedVisibleRows);

      _lastHeavyInputs = heavyInputs;
    }

    final visibleRows = _cachedVisibleRows;
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    _lastIsMobile = isMobile;
    final baseRowHeight = isMobile ? 54.0 : 48.0;

    final displayZoom = _displayZoom ?? zoom;

    final displayCellWidth = _cellWidthForZoom(displayZoom, isMobile);

    // Zoom morph: lerp native cell width in transform space; retarget without jumps.
    if (zoom != displayZoom) {
      if (!zoomController.isAnimating) {
        _pendingZoom = zoom;
        _morphWidthStart = displayCellWidth;
        _morphWidthEnd = _cellWidthForZoom(zoom, isMobile);
        _timelineChildDirty = false;
        zoomController.forward(from: 0);
      } else if (zoom != _pendingZoom) {
        _pendingZoom = zoom;
        final e = Curves.easeInOutCubic.transform(zoomController.value);
        final currentW =
            _morphWidthStart + (_morphWidthEnd - _morphWidthStart) * e;
        _morphWidthStart = currentW;
        _morphWidthEnd = _cellWidthForZoom(zoom, isMobile);
        zoomController.forward(from: 0);
      }
    }

    final hierarchyWidth = isMobile ? 190.0 : 280.0;
    final dates = _cachedVisibleDates;
    final laneLayout = _cachedLaneLayout;

    // Row heights: computed without Stopwatch overhead.
    final rowHeights = List<double>.generate(visibleRows.length, (i) {
      final item = visibleRows[i];
      if (item.type != TimelineNodeType.task) return baseRowHeight;
      final lanes = laneLayout.laneCountById[item.id] ?? 1;
      return (baseRowHeight + (lanes - 1) * 6).clamp(
        baseRowHeight,
        baseRowHeight + 18,
      );
    });
    final rowTops = <double>[];
    var runningTop = 0.0;
    for (final h in rowHeights) {
      rowTops.add(runningTop);
      runningTop += h;
    }

    // #region Timeline child caching (heavy subtree; timeline column morphs only)
    if (_cachedLeftPanel == null ||
        _cachedRightPanel == null ||
        _timelineChildDirty) {
      final timelineDisplayZoom = displayZoom;
      _cachedLeftPanel = SizedBox(
        width: hierarchyWidth,
        child: Scrollbar(
          controller: _hierarchyVerticalController,
          thumbVisibility: true,
          child: TimelineHierarchyPanel(
            rows: visibleRows,
            verticalController: _hierarchyVerticalController,
            expandedNodeIds: heavyInputs.expandedNodeIds,
            onToggleNode: notifier.toggleNode,
            onSelectTask: (id) {
              if (linkMode && selectedTaskId != null) {
                notifier.linkDependency(selectedTaskId, id);
              } else {
                notifier.selectTask(id);
              }
            },
            selectedTaskId: selectedTaskId,
            rowHeights: rowHeights,
          ),
        ),
      );
      _cachedRightPanel = RepaintBoundary(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: TimelineHeader(
                visibleDates: dates,
                cellWidth: displayCellWidth,
                horizontalController: _headerHorizontalController,
                zoom: timelineDisplayZoom,
              ),
            ),
            Expanded(
              child: Scrollbar(
                controller: _timelineVerticalController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _timelineVerticalController,
                  child: SizedBox(
                    height: runningTop,
                    child: TimelineCanvas(
                      rows: visibleRows,
                      visibleDates: dates,
                      cellWidth: displayCellWidth,
                      rowHeight: baseRowHeight,
                      rowHeights: rowHeights,
                      rowTops: rowTops,
                      laneIndexById: laneLayout.laneIndexById,
                      horizontalController: _canvasHorizontalController,
                      selectedTaskId: selectedTaskId,
                      zoom: timelineDisplayZoom,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
      _timelineChildDirty = false;
    }
    // #endregion

    final leftPanel = _cachedLeftPanel ?? const SizedBox.shrink();
    final rightPanel = _cachedRightPanel ?? const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            // Keep the toolbar stable so zoom morphing doesn't reset focus.
            child: const TimelineFiltersToolbar(),
          ),
          Expanded(
            child: visibleRows.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'No timeline items match current filters.\nTry Clear or update search.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      leftPanel,
                      Expanded(
                        child: AnimatedBuilder(
                          animation: zoomController,
                          child: rightPanel,
                          builder: (context, child) {
                            if (!zoomController.isAnimating &&
                                zoom == displayZoom) {
                              return child!;
                            }
                            final t = zoomController.value;
                            final eased = Curves.easeInOutCubic.transform(t);
                            final interp =
                                _morphWidthStart +
                                (_morphWidthEnd - _morphWidthStart) * eased;
                            final denom = displayCellWidth > 0
                                ? displayCellWidth
                                : 1.0;
                            final scaleX = interp / denom;
                            // Subtle vertical ease (no overshoot).
                            final scaleY = 1.0 + 0.012 * math.sin(t * math.pi);

                            return Transform(
                              alignment: Alignment.topLeft,
                              transform: Matrix4.diagonal3Values(
                                scaleX,
                                scaleY,
                                1.0,
                              ),
                              child: child,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  List<TeacherTimelineItem> _applyFilters(
    List<TeacherTimelineItem> items,
    String searchQuery,
    Set<TimelineTaskStatus> statusFilter,
    Set<String> assigneeFilter,
    Set<String> featureFilter,
  ) {
    return items.where((item) {
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final hay = '${item.taskId} ${item.title} ${item.description ?? ''}'
            .toLowerCase();
        if (!hay.contains(q)) return false;
      }
      if (statusFilter.isNotEmpty && !statusFilter.contains(item.status)) {
        return false;
      }
      if (assigneeFilter.isNotEmpty &&
          (item.assigneeName == null ||
              !assigneeFilter.contains(item.assigneeName))) {
        return false;
      }
      if (featureFilter.isNotEmpty &&
          (item.featureName == null ||
              !featureFilter.contains(item.featureName))) {
        return false;
      }
      return true;
    }).toList();
  }

  List<TeacherTimelineItem> _buildVisibleRows(
    List<TeacherTimelineItem> rows,
    Set<String> expanded,
  ) {
    final byParent = <String?, List<TeacherTimelineItem>>{};
    final idSet = rows.map((e) => e.id).toSet();
    for (final r in rows) {
      final normalizedParent =
          (r.parentId != null && !idSet.contains(r.parentId))
          ? null
          : r.parentId;
      byParent.putIfAbsent(normalizedParent, () => []).add(r);
    }
    for (final group in byParent.values) {
      group.sort((a, b) => a.startDate.compareTo(b.startDate));
    }

    final ordered = <TeacherTimelineItem>[];
    void dfs(String? parent) {
      for (final node in byParent[parent] ?? const <TeacherTimelineItem>[]) {
        ordered.add(node);
        if (expanded.contains(node.id)) {
          dfs(node.id);
        }
      }
    }

    dfs(null);
    return ordered;
  }

  List<DateTime> _buildVisibleDates(List<TeacherTimelineItem> rows) {
    if (rows.isEmpty) return [];
    final minDate = rows
        .map(
          (e) => DateTime(e.startDate.year, e.startDate.month, e.startDate.day),
        )
        .reduce((a, b) => a.isBefore(b) ? a : b)
        .subtract(const Duration(days: 3));
    final maxDate = rows
        .map((e) => DateTime(e.endDate.year, e.endDate.month, e.endDate.day))
        .reduce((a, b) => a.isAfter(b) ? a : b)
        .add(const Duration(days: 10));
    final days = maxDate.difference(minDate).inDays + 1;
    return List.generate(days, (i) => minDate.add(Duration(days: i)));
  }
}

class _HeavyInputs {
  const _HeavyInputs({
    required this.items,
    required this.searchQuery,
    required this.statusFilter,
    required this.assigneeFilter,
    required this.featureFilter,
    required this.expandedNodeIds,
  });

  final List<TeacherTimelineItem> items;
  final String searchQuery;
  final Set<TimelineTaskStatus> statusFilter;
  final Set<String> assigneeFilter;
  final Set<String> featureFilter;
  final Set<String> expandedNodeIds;

  @override
  bool operator ==(Object other) {
    return other is _HeavyInputs &&
        identical(items, other.items) &&
        searchQuery == other.searchQuery &&
        identical(statusFilter, other.statusFilter) &&
        identical(assigneeFilter, other.assigneeFilter) &&
        identical(featureFilter, other.featureFilter) &&
        identical(expandedNodeIds, other.expandedNodeIds);
  }

  @override
  int get hashCode => Object.hash(
    searchQuery,
    identityHashCode(items),
    identityHashCode(statusFilter),
    identityHashCode(assigneeFilter),
    identityHashCode(featureFilter),
    identityHashCode(expandedNodeIds),
  );
}
