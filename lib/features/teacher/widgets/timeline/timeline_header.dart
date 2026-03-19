import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../models/timeline_models.dart';

class TimelineHeader extends StatelessWidget {
  const TimelineHeader({
    super.key,
    required this.visibleDates,
    required this.cellWidth,
    required this.horizontalController,
    required this.zoom,
  });

  final List<DateTime> visibleDates;
  final double cellWidth;
  final ScrollController horizontalController;
  final TimelineZoom zoom;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: SingleChildScrollView(
        controller: horizontalController,
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            Row(children: _monthSegments()),
            Row(
              children: visibleDates
                  .map(
                    (d) => Container(
                      width: cellWidth,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: AppColors.divider),
                          bottom: BorderSide(color: AppColors.divider),
                        ),
                      ),
                      child: Text(
                        _subLabel(d),
                        style: AppTypography.labelSmall,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _monthSegments() {
    final widgets = <Widget>[];
    if (visibleDates.isEmpty) return widgets;
    var cursor = 0;
    while (cursor < visibleDates.length) {
      final current = visibleDates[cursor];
      var end = cursor;
      while (end + 1 < visibleDates.length &&
          visibleDates[end + 1].month == current.month &&
          visibleDates[end + 1].year == current.year) {
        end++;
      }
      final count = end - cursor + 1;
      widgets.add(
        Container(
          width: count * cellWidth,
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.08),
            border: Border(
              right: BorderSide(color: AppColors.divider),
              bottom: BorderSide(color: AppColors.divider),
            ),
          ),
          child: Text(
            DateFormat.yMMM().format(current),
            style: AppTypography.labelSmall,
          ),
        ),
      );
      cursor = end + 1;
    }
    return widgets;
  }

  String _subLabel(DateTime d) {
    return switch (zoom) {
      TimelineZoom.day => DateFormat('d').format(d),
      TimelineZoom.week => 'S${((d.day - 1) ~/ 7) + 1}',
      TimelineZoom.month => DateFormat('MMM').format(d),
    };
  }
}
