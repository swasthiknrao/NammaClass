import '../../models/timeline_models.dart';

double minWidthUnitsForZoom(TimelineZoom zoom) {
  return switch (zoom) {
    TimelineZoom.day => 1.15,
    TimelineZoom.week => 0.9,
    TimelineZoom.month => 1.6,
  };
}

DateTime normalizeDateForZoom(DateTime date, TimelineZoom zoom) {
  if (zoom == TimelineZoom.day) return date;
  return DateTime(date.year, date.month, date.day);
}

String miniLabelFromTitle(String title) {
  final words = title
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return 'T';
  if (words.length == 1) {
    final w = words.first;
    return w.length >= 2 ? w.substring(0, 2).toUpperCase() : w.toUpperCase();
  }
  return '${words[0][0]}${words[1][0]}'.toUpperCase();
}

String shortLabelFromTitle(String title) {
  final trimmed = title.trim();
  if (trimmed.isEmpty) return 'Task';
  if (trimmed.length <= 12) return trimmed;
  return '${trimmed.substring(0, 12)}...';
}

class LaneLayout {
  const LaneLayout({required this.laneIndexById, required this.laneCountById});

  final Map<String, int> laneIndexById;
  final Map<String, int> laneCountById;
}

LaneLayout buildLaneLayout(List<TeacherTimelineItem> rows) {
  final tasksByParent = <String, List<TeacherTimelineItem>>{};
  for (final row in rows.where((e) => e.type == TimelineNodeType.task)) {
    final key = row.parentId ?? 'root';
    tasksByParent.putIfAbsent(key, () => []).add(row);
  }

  final laneIndexById = <String, int>{};
  final laneCountById = <String, int>{};

  for (final group in tasksByParent.values) {
    group.sort((a, b) => a.startDate.compareTo(b.startDate));
    final laneEndTimes = <DateTime>[];
    for (final task in group) {
      var lane = 0;
      while (lane < laneEndTimes.length &&
          laneEndTimes[lane].isAfter(task.startDate)) {
        lane++;
      }
      if (lane == laneEndTimes.length) {
        laneEndTimes.add(task.endDate);
      } else {
        laneEndTimes[lane] = task.endDate;
      }
      laneIndexById[task.id] = lane;
    }
    final count = laneEndTimes.isEmpty ? 1 : laneEndTimes.length;
    for (final task in group) {
      laneCountById[task.id] = count;
    }
  }

  return LaneLayout(laneIndexById: laneIndexById, laneCountById: laneCountById);
}
