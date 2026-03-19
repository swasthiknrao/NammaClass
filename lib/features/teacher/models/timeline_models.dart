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

List<TeacherTimelineItem> _buildRoadmapDummyData(DateTime anchorDate) {
  final quarterStart = DateTime(anchorDate.year, anchorDate.month - 1, 1);
  const epicId = 'epic_product_delivery';
  const featurePlanning = 'feature_planning';
  const featureExecution = 'feature_execution';
  const featureQuality = 'feature_quality';

  return [
    TeacherTimelineItem(
      id: epicId,
      taskId: 'E-PM-01',
      title: 'Product Delivery Roadmap',
      type: TimelineNodeType.epic,
      status: TimelineTaskStatus.inProgress,
      priority: TimelinePriority.high,
      progress: 58,
      startDate: quarterStart,
      endDate: quarterStart.add(const Duration(days: 92)),
      description: 'Umbrella epic for Q roadmap delivery.',
    ),
    TeacherTimelineItem(
      id: featurePlanning,
      taskId: 'F-PLN-01',
      title: 'Planning & Discovery',
      type: TimelineNodeType.feature,
      status: TimelineTaskStatus.done,
      priority: TimelinePriority.medium,
      progress: 100,
      startDate: quarterStart,
      endDate: quarterStart.add(const Duration(days: 20)),
      parentId: epicId,
      featureName: 'Planning',
    ),
    TeacherTimelineItem(
      id: featureExecution,
      taskId: 'F-EXE-01',
      title: 'Execution Sprint Train',
      type: TimelineNodeType.feature,
      status: TimelineTaskStatus.inProgress,
      priority: TimelinePriority.high,
      progress: 62,
      startDate: quarterStart.add(const Duration(days: 18)),
      endDate: quarterStart.add(const Duration(days: 76)),
      parentId: epicId,
      featureName: 'Execution',
    ),
    TeacherTimelineItem(
      id: featureQuality,
      taskId: 'F-QA-01',
      title: 'Quality, UAT & Release',
      type: TimelineNodeType.feature,
      status: TimelineTaskStatus.pending,
      priority: TimelinePriority.critical,
      progress: 22,
      startDate: quarterStart.add(const Duration(days: 58)),
      endDate: quarterStart.add(const Duration(days: 92)),
      parentId: epicId,
      featureName: 'Quality',
    ),
    TeacherTimelineItem(
      id: 'task_discovery_workshops',
      taskId: 'T-PLN-101',
      title: 'Discovery Workshops',
      type: TimelineNodeType.task,
      status: TimelineTaskStatus.done,
      priority: TimelinePriority.medium,
      progress: 100,
      startDate: quarterStart.add(const Duration(days: 1)),
      endDate: quarterStart.add(const Duration(days: 5)),
      parentId: featurePlanning,
      assigneeName: 'Asha',
      description: 'Stakeholder interviews and scope baseline.',
      featureName: 'Planning',
      sprintLabel: 'Sprint 1',
    ),
    TeacherTimelineItem(
      id: 'task_scope_freeze',
      taskId: 'T-PLN-102',
      title: 'Scope Freeze',
      type: TimelineNodeType.task,
      status: TimelineTaskStatus.done,
      priority: TimelinePriority.high,
      progress: 100,
      startDate: quarterStart.add(const Duration(days: 6)),
      endDate: quarterStart.add(const Duration(days: 10)),
      parentId: featurePlanning,
      assigneeName: 'Rohit',
      description: 'Freeze MVP backlog and acceptance criteria.',
      featureName: 'Planning',
      sprintLabel: 'Sprint 2',
      dependencyIds: const ['task_discovery_workshops'],
    ),
    TeacherTimelineItem(
      id: 'task_ui_build',
      taskId: 'T-EXE-201',
      title: 'UI Build & Integrations',
      type: TimelineNodeType.task,
      status: TimelineTaskStatus.inProgress,
      priority: TimelinePriority.high,
      progress: 70,
      startDate: quarterStart.add(const Duration(days: 20)),
      endDate: quarterStart.add(const Duration(days: 42)),
      parentId: featureExecution,
      assigneeName: 'Keerthi',
      description: 'Build timeline UI and connect provider state.',
      featureName: 'Execution',
      sprintLabel: 'Sprint 4',
      dependencyIds: const ['task_scope_freeze'],
    ),
    TeacherTimelineItem(
      id: 'task_dependency_engine',
      taskId: 'T-EXE-202',
      title: 'Dependency Engine',
      type: TimelineNodeType.task,
      status: TimelineTaskStatus.inProgress,
      priority: TimelinePriority.critical,
      progress: 58,
      startDate: quarterStart.add(const Duration(days: 35)),
      endDate: quarterStart.add(const Duration(days: 56)),
      parentId: featureExecution,
      assigneeName: 'Nikhil',
      description: 'Auto-shift, cycle guard, deterministic propagation.',
      featureName: 'Execution',
      sprintLabel: 'Sprint 6',
      dependencyIds: const ['task_ui_build'],
    ),
    TeacherTimelineItem(
      id: 'task_uat',
      taskId: 'T-QA-301',
      title: 'User Acceptance Testing',
      type: TimelineNodeType.task,
      status: TimelineTaskStatus.pending,
      priority: TimelinePriority.high,
      progress: 15,
      startDate: quarterStart.add(const Duration(days: 60)),
      endDate: quarterStart.add(const Duration(days: 77)),
      parentId: featureQuality,
      assigneeName: 'Megha',
      description: 'Cross-role validation and bug triage.',
      featureName: 'Quality',
      sprintLabel: 'Sprint 9',
      dependencyIds: const ['task_dependency_engine'],
    ),
    TeacherTimelineItem(
      id: 'task_release_hardening',
      taskId: 'T-QA-302',
      title: 'Release Hardening',
      type: TimelineNodeType.task,
      status: TimelineTaskStatus.pending,
      priority: TimelinePriority.critical,
      progress: 8,
      startDate: quarterStart.add(const Duration(days: 74)),
      endDate: quarterStart.add(const Duration(days: 89)),
      parentId: featureQuality,
      assigneeName: 'Akshay',
      description: 'Performance and release readiness checks.',
      featureName: 'Quality',
      sprintLabel: 'Sprint 10',
      dependencyIds: const ['task_uat'],
    ),
    TeacherTimelineItem(
      id: 'milestone_beta_release',
      taskId: 'M-BETA-01',
      title: 'Beta Release',
      type: TimelineNodeType.milestone,
      status: TimelineTaskStatus.pending,
      priority: TimelinePriority.high,
      progress: 0,
      startDate: quarterStart.add(const Duration(days: 78)),
      endDate: quarterStart.add(const Duration(days: 79)),
      description: 'Internal beta cut for pilot users.',
      isMilestone: true,
    ),
  ];
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

  final roadmapSeed = _buildRoadmapDummyData(DateTime.now());

  return [
    ...epics.values,
    ...features.values,
    ...taskWithDeps,
    ...diaryMilestones,
    ...roadmapSeed,
  ];
}
