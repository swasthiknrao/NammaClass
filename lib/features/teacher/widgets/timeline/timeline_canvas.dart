import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/agent_debug_logger.dart';
import '../../models/timeline_models.dart';
import '../../providers/teacher_providers.dart';
import 'timeline_dependency_layer.dart';
import 'timeline_task_bar.dart';
import 'timeline_view_utils.dart';

class TimelineCanvas extends ConsumerWidget {
  const TimelineCanvas({
    super.key,
    required this.rows,
    required this.visibleDates,
    required this.cellWidth,
    required this.rowHeight,
    required this.horizontalController,
    required this.selectedTaskId,
    required this.zoom,
    required this.rowHeights,
    required this.rowTops,
    required this.laneIndexById,
  });

  final List<TeacherTimelineItem> rows;
  final List<DateTime> visibleDates;
  final double cellWidth;
  final double rowHeight;
  final ScrollController horizontalController;
  final String? selectedTaskId;
  final TimelineZoom zoom;
  final List<double> rowHeights;
  final List<double> rowTops;
  final Map<String, int> laneIndexById;

  static TimelineZoom? _lastLoggedZoomForCanvas;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buildStart = Stopwatch()..start();
    final notifier = ref.read(teacherTimelineProvider.notifier);
    if (visibleDates.isEmpty) return const SizedBox.shrink();
    final start = visibleDates.first;
    final totalWidth = visibleDates.length * cellWidth;
    final rowIndexById = <String, int>{
      for (var i = 0; i < rows.length; i++) rows[i].id: i,
    };
    // Only depend on data needed for the dependency layer so zoom changes
    // don't rebuild the heavy grid subtree.
    final dependencies = ref.watch(
      teacherTimelineProvider.select((s) => s.dependencies),
    );
    final itemsById = {for (final row in rows) row.id: row};

    double xForDate(DateTime date) {
      final minutes = normalizeDateForZoom(
        date,
        zoom,
      ).difference(start).inMinutes.toDouble();
      return (minutes / (24 * 60)) * cellWidth;
    }

    double widthForItem(TeacherTimelineItem item) {
      final minutes = item.endDate
          .difference(item.startDate)
          .inMinutes
          .toDouble();
      final dayUnits = (minutes / (24 * 60)).abs();
      final minUnits = minWidthUnitsForZoom(zoom);
      return (dayUnits.clamp(minUnits, 60.0) * cellWidth).clamp(
        cellWidth * minUnits,
        totalWidth,
      );
    }

    Duration pxToDuration(double dx) {
      final days = (dx / cellWidth).clamp(-60.0, 60.0);
      return Duration(minutes: (days * 24 * 60).round());
    }

    final widget = SingleChildScrollView(
      controller: horizontalController,
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: math.max(totalWidth, 200),
        child: Stack(
          children: [
            Positioned.fill(
              child: _GridBackground(
                rowCount: rows.length,
                rowHeights: rowHeights,
                colCount: visibleDates.length,
                colWidth: cellWidth,
                zoom: zoom,
              ),
            ),
            Positioned.fill(
              child: TimelineDependencyLayer(
                dependencies: dependencies,
                itemsById: itemsById,
                rowIndexById: rowIndexById,
                rowHeight: rowHeight,
                rowTops: rowTops,
                xForDate: xForDate,
              ),
            ),
            for (final item in rows)
              if (item.type == TimelineNodeType.task ||
                  item.type == TimelineNodeType.milestone)
                () {
                  final left = xForDate(
                    item.startDate,
                  ).clamp(0.0, totalWidth - 4.0);
                  final maxAllowedWidth = (totalWidth - left).clamp(
                    12.0,
                    totalWidth,
                  );
                  final width = widthForItem(item).clamp(12.0, maxAllowedWidth);
                  return Positioned(
                    left: left,
                    top:
                        rowTops[rowIndexById[item.id]!] +
                        8 +
                        (laneIndexById[item.id] ?? 0) * 6,
                    child: TimelineTaskBar(
                      item: item,
                      selected: selectedTaskId == item.id,
                      width: width,
                      onMove: (dx) =>
                          notifier.moveTask(item.id, pxToDuration(dx)),
                      onResizeStart: (dx) => notifier.resizeTask(
                        item.id,
                        startDelta: pxToDuration(dx),
                      ),
                      onResizeEnd: (dx) => notifier.resizeTask(
                        item.id,
                        endDelta: pxToDuration(dx),
                      ),
                    ),
                  );
                }(),
            _TodayLineOverlay(
              start: start,
              cellWidth: cellWidth,
              rowHeight: rowHeight,
              rowCount: rows.length,
            ),
          ],
        ),
      ),
    );

    buildStart.stop();
    final logThisZoom =
        _lastLoggedZoomForCanvas == null || _lastLoggedZoomForCanvas != zoom;
    if (logThisZoom) _lastLoggedZoomForCanvas = zoom;

    if (logThisZoom && kDebugMode) {
      AgentDebugLogger.log(
        hypothesisId: 'H11_timeline_canvas_build_ms',
        runId: 'pre-fix',
        location: 'timeline_canvas.dart:build',
        message: 'TimelineCanvas build finished',
        data: <String, Object?>{
          'zoom': zoom.name,
          'rows': rows.length,
          'visibleDates': visibleDates.length,
          'buildMs': buildStart.elapsedMilliseconds,
        },
      );
    }
    return widget;
  }
}

class _GridBackground extends StatelessWidget {
  const _GridBackground({
    required this.rowCount,
    required this.rowHeights,
    required this.colCount,
    required this.colWidth,
    required this.zoom,
  });

  final int rowCount;
  final List<double> rowHeights;
  final int colCount;
  final double colWidth;
  final TimelineZoom zoom;

  static TimelineZoom? _lastLoggedZoom;

  @override
  Widget build(BuildContext context) {
    final logThisZoom = _lastLoggedZoom == null || _lastLoggedZoom != zoom;
    if (logThisZoom) _lastLoggedZoom = zoom;

    final buildStart = Stopwatch()..start();
    final widget = Column(
      children: List.generate(rowCount, (r) {
        return SizedBox(
          height: rowHeights[r],
          child: Row(
            children: List.generate(colCount, (c) {
              return Container(
                width: colWidth,
                decoration: BoxDecoration(
                  color: r.isEven
                      ? ((c % 2 == 0)
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xFFFAFBFC))
                      : ((c % 2 == 0)
                            ? const Color(0xFFFCFCFC)
                            : const Color(0xFFF7F9FB)),
                  border: Border(
                    right: BorderSide(
                      color: AppColors.divider.withValues(alpha: 0.78),
                    ),
                    bottom: BorderSide(
                      color: AppColors.divider.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
    buildStart.stop();
    if (logThisZoom && kDebugMode) {
      AgentDebugLogger.log(
        hypothesisId: 'H12_grid_background_build_ms',
        runId: 'pre-fix',
        location: 'timeline_canvas.dart:_GridBackground',
        message: 'Grid background built (containers)',
        data: <String, Object?>{
          'zoom': zoom.name,
          'rowCount': rowCount,
          'colCount': colCount,
          'buildMs': buildStart.elapsedMilliseconds,
        },
      );
    }
    return widget;
  }
}

class _TodayLineOverlay extends StatelessWidget {
  const _TodayLineOverlay({
    required this.start,
    required this.cellWidth,
    required this.rowHeight,
    required this.rowCount,
  });

  final DateTime start;
  final double cellWidth;
  final double rowHeight;
  final int rowCount;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dx = (now.difference(start).inMinutes / (24 * 60)) * cellWidth;
    if (dx.isNaN || dx < 0) return const SizedBox.shrink();
    return Positioned(
      left: dx,
      top: 0,
      bottom: 0,
      child: IgnorePointer(
        child: Container(
          width: 2,
          color: const Color(0xFFD32F2F),
          height: rowHeight * rowCount,
        ),
      ),
    );
  }
}
