import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../models/timeline_models.dart';

class TimelineHierarchyPanel extends StatelessWidget {
  const TimelineHierarchyPanel({
    super.key,
    required this.rows,
    required this.verticalController,
    required this.expandedNodeIds,
    required this.onToggleNode,
    required this.onSelectTask,
    this.selectedTaskId,
    required this.rowHeights,
  });

  final List<TeacherTimelineItem> rows;
  final ScrollController verticalController;
  final Set<String> expandedNodeIds;
  final void Function(String) onToggleNode;
  final void Function(String) onSelectTask;
  final String? selectedTaskId;
  final List<double> rowHeights;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 52,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            border: Border(bottom: BorderSide(color: AppColors.divider)),
          ),
          child: Text(
            'Work Breakdown',
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: verticalController,
            itemCount: rows.length,
            itemBuilder: (context, i) {
              final item = rows[i];
              final indent = switch (item.type) {
                TimelineNodeType.epic => 0.0,
                TimelineNodeType.feature => 16.0,
                _ => 32.0,
              };
              final hasChildren =
                  item.type != TimelineNodeType.task &&
                  item.type != TimelineNodeType.milestone;
              final selected = item.id == selectedTaskId;
              return InkWell(
                onTap: () => onSelectTask(item.id),
                child: Container(
                  height: rowHeights[i],
                  padding: EdgeInsets.only(left: 8 + indent, right: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.teal.withValues(alpha: 0.12)
                        : (i.isEven ? Colors.white : const Color(0xFFFCFCFC)),
                    border: Border(
                      bottom: BorderSide(color: AppColors.divider),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        child: hasChildren
                            ? IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 16,
                                onPressed: () => onToggleNode(item.id),
                                icon: Icon(
                                  expandedNodeIds.contains(item.id)
                                      ? Icons.expand_more
                                      : Icons.chevron_right,
                                ),
                              )
                            : Icon(_statusIcon(item.status), size: 14),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${item.taskId} • ${item.title}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: item.type == TimelineNodeType.task
                                ? FontWeight.w500
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (item.assigneeName != null)
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: AppColors.teal.withValues(
                            alpha: 0.18,
                          ),
                          child: Text(
                            item.assigneeName!.isNotEmpty
                                ? item.assigneeName![0].toUpperCase()
                                : '?',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.teal,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _statusIcon(TimelineTaskStatus s) {
    switch (s) {
      case TimelineTaskStatus.done:
        return Icons.check_circle;
      case TimelineTaskStatus.inProgress:
        return Icons.timelapse;
      case TimelineTaskStatus.pending:
        return Icons.radio_button_unchecked;
    }
  }
}
