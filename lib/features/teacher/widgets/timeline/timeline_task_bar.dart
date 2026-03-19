import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_typography.dart';
import '../../models/timeline_models.dart';
import 'timeline_view_utils.dart';

class TimelineTaskBar extends StatefulWidget {
  const TimelineTaskBar({
    super.key,
    required this.item,
    required this.width,
    required this.onMove,
    required this.onResizeStart,
    required this.onResizeEnd,
    this.selected = false,
  });

  final TeacherTimelineItem item;
  final double width;
  final void Function(double deltaPx) onMove;
  final void Function(double deltaPx) onResizeStart;
  final void Function(double deltaPx) onResizeEnd;
  final bool selected;

  @override
  State<TimelineTaskBar> createState() => _TimelineTaskBarState();
}

class _TimelineTaskBarState extends State<TimelineTaskBar> {
  @override
  Widget build(BuildContext context) {
    final baseColor = _barColor(widget.item);
    final fmt = DateFormat('dd MMM, hh:mm a');
    final barWidth = widget.width.clamp(12.0, double.infinity);
    return Tooltip(
      message:
          '${widget.item.title}\n${widget.item.description ?? ''}\n${fmt.format(widget.item.startDate)} -> ${fmt.format(widget.item.endDate)}\nOwner: ${widget.item.assigneeName ?? '-'}',
      child: GestureDetector(
        onHorizontalDragUpdate: (d) => widget.onMove(d.delta.dx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: barWidth,
          height: widget.item.type == TimelineNodeType.task ? 30 : 22,
          decoration: BoxDecoration(
            color: baseColor.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.selected
                  ? Colors.white
                  : baseColor.withValues(alpha: 0.6),
              width: widget.selected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final effectiveWidth = constraints.maxWidth;
                final ultraCompact = effectiveWidth < 22;
                final compactMode = effectiveWidth >= 22 && effectiveWidth < 40;
                final shortMode = effectiveWidth >= 40 && effectiveWidth < 100;
                final showHandles = effectiveWidth >= 112;
                final miniLabel = miniLabelFromTitle(widget.item.title);
                final shortLabel = shortLabelFromTitle(widget.item.title);
                return Stack(
                  children: [
                    Positioned.fill(
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (widget.item.progress / 100).clamp(0, 1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    if (ultraCompact)
                      const SizedBox.shrink()
                    else if (compactMode)
                      Center(
                        child: Text(
                          miniLabel,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 8.5,
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          if (showHandles)
                            _resizeHandle(
                              (delta) => widget.onResizeStart(delta),
                            )
                          else
                            const SizedBox(width: 3),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                shortMode
                                    ? '$shortLabel ${widget.item.progress}%'
                                    : '${widget.item.title} ${widget.item.progress}%',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: shortMode ? 9.2 : 10.2,
                                ),
                              ),
                            ),
                          ),
                          if (showHandles)
                            _resizeHandle((delta) => widget.onResizeEnd(delta))
                          else
                            const SizedBox(width: 3),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _resizeHandle(void Function(double deltaPx) onDrag) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (d) => onDrag(d.delta.dx),
      child: const SizedBox(
        width: 10,
        child: Center(
          child: Icon(Icons.drag_handle, size: 10, color: Colors.white70),
        ),
      ),
    );
  }

  Color _barColor(TeacherTimelineItem item) {
    if (item.type == TimelineNodeType.milestone) return const Color(0xFFFF9800);
    return switch (item.status) {
      TimelineTaskStatus.done => const Color(0xFF2E7D32),
      TimelineTaskStatus.inProgress => const Color(0xFF1976D2),
      TimelineTaskStatus.pending => switch (item.priority) {
        TimelinePriority.critical => const Color(0xFFD32F2F),
        TimelinePriority.high => const Color(0xFFEF6C00),
        TimelinePriority.medium => const Color(0xFF6A1B9A),
        TimelinePriority.low => const Color(0xFF00897B),
      },
    };
  }
}
