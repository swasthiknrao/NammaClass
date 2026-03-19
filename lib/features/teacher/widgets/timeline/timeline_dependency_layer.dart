import 'package:flutter/material.dart';

import '../../models/timeline_models.dart';

class TimelineDependencyLayer extends StatelessWidget {
  const TimelineDependencyLayer({
    super.key,
    required this.dependencies,
    required this.itemsById,
    required this.rowIndexById,
    required this.rowHeight,
    required this.rowTops,
    required this.xForDate,
  });

  final List<TimelineDependency> dependencies;
  final Map<String, TeacherTimelineItem> itemsById;
  final Map<String, int> rowIndexById;
  final double rowHeight;
  final List<double> rowTops;
  final double Function(DateTime) xForDate;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _DependencyPainter(
          dependencies: dependencies,
          itemsById: itemsById,
          rowIndexById: rowIndexById,
          rowHeight: rowHeight,
          rowTops: rowTops,
          xForDate: xForDate,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _DependencyPainter extends CustomPainter {
  _DependencyPainter({
    required this.dependencies,
    required this.itemsById,
    required this.rowIndexById,
    required this.rowHeight,
    required this.rowTops,
    required this.xForDate,
  });

  final List<TimelineDependency> dependencies;
  final Map<String, TeacherTimelineItem> itemsById;
  final Map<String, int> rowIndexById;
  final double rowHeight;
  final List<double> rowTops;
  final double Function(DateTime) xForDate;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final dep in dependencies) {
      final from = itemsById[dep.fromTaskId];
      final to = itemsById[dep.toTaskId];
      final fromRow = rowIndexById[dep.fromTaskId];
      final toRow = rowIndexById[dep.toTaskId];
      if (from == null || to == null || fromRow == null || toRow == null) {
        continue;
      }

      final start = Offset(
        xForDate(from.endDate),
        rowTops[fromRow] + rowHeight / 2,
      );
      final end = Offset(
        xForDate(to.startDate),
        rowTops[toRow] + rowHeight / 2,
      );
      // Skip tiny links to reduce visual clutter in dense views.
      if ((end.dx - start.dx).abs() < 12 && (end.dy - start.dy).abs() < 12) {
        continue;
      }
      final cp1 = Offset(start.dx + 18, start.dy);
      final cp2 = Offset(end.dx - 18, end.dy);

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DependencyPainter oldDelegate) {
    return oldDelegate.dependencies != dependencies ||
        oldDelegate.itemsById != itemsById ||
        oldDelegate.rowIndexById != rowIndexById ||
        oldDelegate.rowTops != rowTops;
  }
}
