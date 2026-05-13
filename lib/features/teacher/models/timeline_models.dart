import '../../../core/mock/mock_data.dart';

enum TimelineNodeType { epic, feature, task, milestone }

enum TimelineTaskStatus { done, inProgress, pending }

enum TimelinePriority { low, medium, high, critical }

enum TimelineZoom { day, week, month }

class TimelineDependency {
  const TimelineDependency({required this.fromTaskId, required this.toTaskId});

  final String fromTaskId;
  final String toTaskId;
}

class TeacherTimelineItem {
  const TeacherTimelineItem({
    required this.id,
    required this.taskId,
    required this.title,
    required this.type,
    required this.status,
    required this.priority,
    required this.progress,
    required this.startDate,
    required this.endDate,
    this.assigneeName,
    this.assigneeAvatarUrl,
    this.parentId,
    this.description,
    this.featureName,
    this.sprintLabel,
    this.dependencyIds = const [],
    this.isMilestone = false,
  });

  final String id;
  final String taskId;
  final String title;
  final TimelineNodeType type;
  final TimelineTaskStatus status;
  final TimelinePriority priority;
  final int progress;
  final DateTime startDate;
  final DateTime endDate;
  final String? assigneeName;
  final String? assigneeAvatarUrl;
  final String? parentId;
  final String? description;
  final String? featureName;
  final String? sprintLabel;
  final List<String> dependencyIds;
  final bool isMilestone;

  Duration get duration => endDate.difference(startDate);

  TeacherTimelineItem copyWith({
    String? id,
    String? taskId,
    String? title,
    TimelineNodeType? type,
    TimelineTaskStatus? status,
    TimelinePriority? priority,
    int? progress,
    DateTime? startDate,
    DateTime? endDate,
    String? assigneeName,
    String? assigneeAvatarUrl,
    String? parentId,
    String? description,
    String? featureName,
    String? sprintLabel,
    List<String>? dependencyIds,
    bool? isMilestone,
  }) {
    return TeacherTimelineItem(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      progress: progress ?? this.progress,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      assigneeName: assigneeName ?? this.assigneeName,
      assigneeAvatarUrl: assigneeAvatarUrl ?? this.assigneeAvatarUrl,
      parentId: parentId ?? this.parentId,
      description: description ?? this.description,
      featureName: featureName ?? this.featureName,
      sprintLabel: sprintLabel ?? this.sprintLabel,
      dependencyIds: dependencyIds ?? this.dependencyIds,
      isMilestone: isMilestone ?? this.isMilestone,
    );
  }
}

DateTime _combineDateAndTime(DateTime d, String hhmm) {
  final parts = hhmm.split(':');
  final h = int.tryParse(parts.first) ?? 0;
  final m = parts.length > 1 ? int.tryParse(parts[1].substring(0, 2)) ?? 0 : 0;
  return DateTime(d.year, d.month, d.day, h, m);
}

TimelineTaskStatus _statusFromSession(String status) {
  switch (status) {
    case 'marked':
      return TimelineTaskStatus.done;
    default:
      return TimelineTaskStatus.pending;
  }
}

TimelinePriority _priorityFromPeriod(int period) {
  if (period <= 2) return TimelinePriority.high;
  if (period <= 5) return TimelinePriority.medium;
  return TimelinePriority.low;
}

List<TeacherTimelineItem> buildTeacherTimelineItems() {
  final epics = <String, TeacherTimelineItem>{};
  final features = <String, TeacherTimelineItem>{};
  final tasks = <TeacherTimelineItem>[];
  final diaryMilestones = <TeacherTimelineItem>[];

  for (final session in MockData.attendanceSessions) {
    final epicId = 'epic_${session.classSection}';
    final featureId = 'feature_${session.classSection}_${session.subject}';

    epics.putIfAbsent(
      epicId,
      () => TeacherTimelineItem(
        id: epicId,
        taskId: 'E-${session.classSection}',
        title: 'Class ${session.classSection}',
        type: TimelineNodeType.epic,
        status: TimelineTaskStatus.inProgress,
        priority: TimelinePriority.medium,
        progress: 48,
        startDate: DateTime(session.date.year, session.date.month, 1),
        endDate: DateTime(session.date.year, session.date.month + 1, 0),
      ),
    );

    features.putIfAbsent(
      featureId,
      () => TeacherTimelineItem(
        id: featureId,
        taskId: 'F-${session.classSection}-${session.subject.substring(0, 1)}',
        title: session.subject,
        type: TimelineNodeType.feature,
        status: TimelineTaskStatus.inProgress,
        priority: TimelinePriority.medium,
        progress: 56,
        startDate: DateTime(session.date.year, session.date.month, 1),
        endDate: DateTime(session.date.year, session.date.month + 1, 0),
        parentId: epicId,
        featureName: session.subject,
      ),
    );

    final start = _combineDateAndTime(session.date, session.startTime);
    final end = _combineDateAndTime(session.date, session.endTime);
    final safeEnd = end.isAfter(start)
        ? end
        : start.add(const Duration(hours: 1));
    tasks.add(
      TeacherTimelineItem(
        id: session.id,
        taskId: 'T-${session.period}-${session.classSection}',
        title: session.concept,
        type: TimelineNodeType.task,
        status: _statusFromSession(session.status),
        priority: _priorityFromPeriod(session.period),
        progress: session.status == 'marked' ? 100 : 35,
        startDate: start,
        endDate: safeEnd,
        parentId: featureId,
        assigneeName: 'Teacher ${session.subject}',
        description:
            '${session.classSection} • P${session.period} • ${session.subject}',
        featureName: session.subject,
        sprintLabel: 'Sprint ${((session.date.day - 1) ~/ 7) + 1}',
      ),
    );
  }

  final sortedDiary = [...MockData.diary]
    ..sort((a, b) => a.date.compareTo(b.date));
  for (var i = 0; i < sortedDiary.length; i++) {
    final d = sortedDiary[i];
    final date = d.dueDate ?? d.date;
    diaryMilestones.add(
      TeacherTimelineItem(
        id: 'milestone_$i',
        taskId: 'M-${i + 1}',
        title: '${d.subject}: Homework Checkpoint',
        type: TimelineNodeType.milestone,
        status: d.completed
            ? TimelineTaskStatus.done
            : TimelineTaskStatus.pending,
        priority: TimelinePriority.medium,
        progress: d.completed ? 100 : 0,
        startDate: DateTime(date.year, date.month, date.day, 9),
        endDate: DateTime(date.year, date.month, date.day, 10),
        description: d.homework,
        isMilestone: true,
      ),
    );
  }

  final allTasks = [...tasks]
    ..sort((a, b) => a.startDate.compareTo(b.startDate));
  final taskIds = allTasks.map((e) => e.id).toList();
  final taskWithDeps = <TeacherTimelineItem>[];
  for (var i = 0; i < allTasks.length; i++) {
    final deps = i > 0 ? [taskIds[i - 1]] : const <String>[];
    taskWithDeps.add(allTasks[i].copyWith(dependencyIds: deps));
  }

  return [
    ...epics.values,
    ...features.values,
    ...taskWithDeps,
    ...diaryMilestones,
  ];
}
