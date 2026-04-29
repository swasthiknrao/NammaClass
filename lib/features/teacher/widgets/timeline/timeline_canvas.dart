import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/agent_debug_logger.dart';
import '../../models/timeline_models.dart';
import '../../providers/teacher_providers.dart';
import 'timeline_dependency_layer.dart';
import 'timeline_task_bar.dart';
import 'timeline_view_utils.dart';

class TimelineCanvas extends ConsumerStatefulWidget {
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

  @override
  ConsumerState<TimelineCanvas> createState() => _TimelineCanvasState();
}

class _TimelineCanvasState extends ConsumerState<TimelineCanvas> {
  int? _lastRowsIdentity;
  Map<String, int>? _cachedRowIndexById;
  Map<String, TeacherTimelineItem>? _cachedItemsById;

  static TimelineZoom? _lastLoggedZoomForCanvas;

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final buildStart = Stopwatch()..start();
    final notifier = ref.read(teacherTimelineProvider.notifier);
    if (widget.visibleDates.isEmpty) return const SizedBox.shrink();
    final start = widget.visibleDates.first;
    final totalWidth = widget.visibleDates.length * widget.cellWidth;

    final rowsIdentity = identityHashCode(widget.rows);
    if (_lastRowsIdentity != rowsIdentity ||
        _cachedRowIndexById == null ||
        _cachedItemsById == null) {
      _lastRowsIdentity = rowsIdentity;
      _cachedRowIndexById = <String, int>{
        for (var i = 0; i < widget.rows.length; i++) widget.rows[i].id: i,
      };
      _cachedItemsById = {for (final row in widget.rows) row.id: row};
    }

    final rowIndexById = _cachedRowIndexById!;
    // Only depend on data needed for the dependency layer so zoom changes
    // don't rebuild the heavy grid subtree.
    final dependencies = ref.watch(
      teacherTimelineProvider.select((s) => s.dependencies),
    );
    final itemsById = _cachedItemsById!;

    double xForDate(DateTime date) {
      final minutes = normalizeDateForZoom(
        date,
        widget.zoom,
      ).difference(start).inMinutes.toDouble();
      return (minutes / (24 * 60)) * widget.cellWidth;
    }

    double widthForItem(TeacherTimelineItem item) {
      final minutes = item.endDate
          .difference(item.startDate)
          .inMinutes
          .toDouble();
      final dayUnits = (minutes / (24 * 60)).abs();
      final minUnits = minWidthUnitsForZoom(widget.zoom);
      return (dayUnits.clamp(minUnits, 60.0) * widget.cellWidth).clamp(
        widget.cellWidth * minUnits,
        totalWidth,
      );
    }

    Duration pxToDuration(double dx) {
      final days = (dx / widget.cellWidth).clamp(-60.0, 60.0);
      return Duration(minutes: (days * 24 * 60).round());
    }

    final timelineScrollView = SingleChildScrollView(
      controller: widget.horizontalController,
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: math.max(totalWidth, 200),
        child: Stack(
          children: [
            Positioned.fill(
              child: _GridBackground(
                rowCount: widget.rows.length,
                rowHeights: widget.rowHeights,
                colCount: widget.visibleDates.length,
                colWidth: widget.cellWidth,
                zoom: widget.zoom,
              ),
            ),
            Positioned.fill(
              child: TimelineDependencyLayer(
                dependencies: dependencies,
                itemsById: itemsById,
                rowIndexById: rowIndexById,
                rowHeight: widget.rowHeight,
                rowTops: widget.rowTops,
                xForDate: xForDate,
              ),
            ),
            for (final item in widget.rows)
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
                        widget.rowTops[rowIndexById[item.id]!] +
                        8 +
                        (widget.laneIndexById[item.id] ?? 0) * 6,
                    // RepaintBoundary: each bar repaints in isolation;
                    // selecting one bar no longer repaints the whole canvas.
                    child: RepaintBoundary(
                      child: TimelineTaskBar(
                        item: item,
                        selected: widget.selectedTaskId == item.id,
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
                    ),
                  );
                }(),
            _TodayLineOverlay(
              start: start,
              cellWidth: widget.cellWidth,
              rowHeight: widget.rowHeight,
              rowCount: widget.rows.length,
            ),
          ],
        ),
      ),
    );

    buildStart.stop();
    final logThisZoom =
        _lastLoggedZoomForCanvas == null ||
        _lastLoggedZoomForCanvas != widget.zoom;
    if (logThisZoom) _lastLoggedZoomForCanvas = widget.zoom;

    if (logThisZoom && kDebugMode) {
      AgentDebugLogger.log(
        hypothesisId: 'H11_timeline_canvas_build_ms',
        runId: 'pre-fix',
        location: 'timeline_canvas.dart:build',
        message: 'TimelineCanvas build finished',
        data: <String, Object?>{
          'zoom': widget.zoom.name,
          'rows': widget.rows.length,
          'visibleDates': widget.visibleDates.length,
          'buildMs': buildStart.elapsedMilliseconds,
        },
      );
    }
    return timelineScrollView;
  }
}

/// Paints the grid background using Canvas — O(1) widgets regardless of row/col count.
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

  @override
  Widget build(BuildContext context) {
    // Total height = sum of all row heights
    final totalHeight = rowHeights.fold(0.0, (a, b) => a + b);
    final totalWidth = colCount * colWidth;
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(totalWidth, totalHeight),
        painter: _GridPainter(
          rowHeights: rowHeights,
          colCount: colCount,
          colWidth: colWidth,
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({
    required this.rowHeights,
    required this.colCount,
    required this.colWidth,
  });

  final List<double> rowHeights;
  final int colCount;
  final double colWidth;

  // Precomputed paint objects — avoid re-allocating on every paint.
  static final _evenEvenFill = Paint()..color = const Color(0xFFFFFFFF);
  static final _evenOddFill  = Paint()..color = const Color(0xFFFAFBFC);
  static final _oddEvenFill  = Paint()..color = const Color(0xFFFCFCFC);
  static final _oddOddFill   = Paint()..color = const Color(0xFFF7F9FB);
  static final _borderH = Paint()
    ..color = const Color(0xFFE0E0E0)
    ..strokeWidth = 0.5;
  static final _borderV = Paint()
    ..color = const Color(0xFFDEDEDE)
    ..strokeWidth = 0.5;

  @override
  void paint(Canvas canvas, Size size) {
    double rowTop = 0;
    for (int r = 0; r < rowHeights.length; r++) {
      final rowH = rowHeights[r];
      double colLeft = 0;
      for (int c = 0; c < colCount; c++) {
        final fill = r.isEven
            ? (c.isEven ? _evenEvenFill : _evenOddFill)
            : (c.isEven ? _oddEvenFill  : _oddOddFill);
        canvas.drawRect(
          Rect.fromLTWH(colLeft, rowTop, colWidth, rowH),
          fill,
        );
        colLeft += colWidth;
      }
      // Horizontal separator
      canvas.drawLine(
        Offset(0, rowTop + rowH),
        Offset(size.width, rowTop + rowH),
        _borderH,
      );
      rowTop += rowH;
    }
    // Vertical separators
    double x = colWidth;
    for (int c = 0; c < colCount - 1; c++) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), _borderV);
      x += colWidth;
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) =>
      !identical(rowHeights, old.rowHeights) ||
      colCount != old.colCount ||
      colWidth != old.colWidth;
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
