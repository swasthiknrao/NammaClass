import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../providers/student_providers.dart';

/// Weekday names for mapping DateTime.weekday (1=Mon) to timetable key.
const _weekdays = [
  '',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

class AcademicsScreen extends ConsumerWidget {
  const AcademicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeworkAsync = ref.watch(studentHomeworkProvider);
    final timetableAsync = ref.watch(studentTimetableProvider);
    final attendanceAsync = ref.watch(studentAttendanceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Academics')),
      backgroundColor: Colors.transparent,
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Homework', icon: Icon(Icons.assignment, size: 16)),
                Tab(text: 'Timetable', icon: Icon(Icons.table_chart, size: 16)),
                Tab(
                  text: 'Attendance',
                  icon: Icon(Icons.event_available, size: 16),
                ),
                Tab(text: 'Report Cards', icon: Icon(Icons.grade, size: 16)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Homework tab
                  homeworkAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16),
                      child: NcShimmerList(),
                    ),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (entries) => ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: entries.length,
                      itemBuilder: (ctx, i) {
                        final e = entries[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: NcCard(
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: e.subject.subjectColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.subject,
                                        style: AppTypography.labelLarge,
                                      ),
                                      Text(
                                        e.homework,
                                        style: AppTypography.bodySmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (e.dueDate != null)
                                        Text(
                                          'Due: ${AppFormatters.formatDate(e.dueDate!)}',
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                color: AppColors.warning,
                                              ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (e.completed)
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.success,
                                  )
                                else
                                  const Icon(
                                    Icons.radio_button_unchecked,
                                    color: AppColors.textSecondary,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Timetable tab — show "class finished" and today P/A
                  _TimetableTab(
                    timetableAsync: timetableAsync,
                    attendanceAsync: attendanceAsync,
                  ),

                  // Attendance tab — overall + per-subject stats (e.g. 10/13)
                  _AttendanceTab(
                    timetableAsync: timetableAsync,
                    attendanceAsync: attendanceAsync,
                  ),

                  // Report Cards tab
                  const _ReportCardsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Timetable tab: class finished + today P/A ───────────────────────────────────

class _TimetableTab extends StatelessWidget {
  const _TimetableTab({
    required this.timetableAsync,
    required this.attendanceAsync,
  });

  final AsyncValue<Map<String, List<MockPeriod>>> timetableAsync;
  final AsyncValue<List<MockAttendanceDay>> attendanceAsync;

  static const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  bool _isPeriodOver(String endTime) {
    final parts = endTime.split(':');
    if (parts.length < 2) return false;
    final now = DateTime.now();
    final endHour = int.tryParse(parts[0]) ?? 0;
    final endMin = int.tryParse(parts[1]) ?? 0;
    final end = DateTime(now.year, now.month, now.day, endHour, endMin);
    return now.isAfter(end);
  }

  @override
  Widget build(BuildContext context) {
    return timetableAsync.when(
      loading: () =>
          const Padding(padding: EdgeInsets.all(16), child: NcShimmerList()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (timetable) {
        final attendanceList = attendanceAsync.valueOrNull ?? [];
        final today = DateTime.now();
        final todayWeekday = _weekdays[today.weekday];
        MockAttendanceDay? todayRecord;
        for (final d in attendanceList) {
          if (d.date.year == today.year &&
              d.date.month == today.month &&
              d.date.day == today.day) {
            todayRecord = d;
            break;
          }
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: _days.length,
          itemBuilder: (ctx, di) {
            final day = _days[di];
            final periods = timetable[day] ?? [];
            final isToday = day == todayWeekday;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(day, style: AppTypography.headlineSmall),
                    if (isToday && todayRecord != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      _DayStatusChip(status: todayRecord.status),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                ...periods.map((p) {
                  final isOver = isToday && _isPeriodOver(p.endTime);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: NcCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 36,
                            decoration: BoxDecoration(
                              color: p.subject.subjectColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      p.subject,
                                      style: AppTypography.labelMedium,
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: p.subject.subjectColor
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        p.subject.subjectCode,
                                        style: AppTypography.labelSmall
                                            .copyWith(
                                              color: p.subject.subjectColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${p.startTime} – ${p.endTime}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline_rounded,
                                      size: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      p.teacher,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (isOver)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 14,
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    'Done',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                const Divider(),
              ],
            );
          },
        );
      },
    );
  }
}

class _DayStatusChip extends StatelessWidget {
  const _DayStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isPresent = status == 'present';
    final isAbsent = status == 'absent';
    final isLeave = status == 'leave';

    Color bg;
    Color fg;
    String label;
    IconData icon;

    if (isPresent) {
      bg = AppColors.successBg;
      fg = AppColors.success;
      label = 'Present';
      icon = Icons.check_circle_rounded;
    } else if (isAbsent) {
      bg = AppColors.errorBg;
      fg = AppColors.error;
      label = 'Absent';
      icon = Icons.cancel_rounded;
    } else if (isLeave) {
      bg = AppColors.leaveBg;
      fg = AppColors.purple;
      label = 'Leave';
      icon = Icons.event_busy_rounded;
    } else {
      bg = AppColors.warningBg;
      fg = AppColors.warning;
      label = status == 'holiday' ? 'Holiday' : status;
      icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Report Cards tab ──────────────────────────────────────────────────────────

class _ReportCardsTab extends StatelessWidget {
  const _ReportCardsTab();

  static final _terms = [
    _TermCardData(
      'Term 1',
      'Apr – Jun 2025',
      1,
      false,
      overallPercent: 84,
      grade: 'A',
      subjectMarks: [
        _SubjectMark('Mathematics', 92, 100),
        _SubjectMark('Science', 88, 100),
        _SubjectMark('English', 82, 100),
        _SubjectMark('Social Studies', 79, 100),
        _SubjectMark('Kannada', 85, 100),
        _SubjectMark('Computer Science', 78, 100),
      ],
    ),
    _TermCardData(
      'Term 2',
      'Jul – Sep 2025',
      2,
      false,
      overallPercent: 87,
      grade: 'A',
      subjectMarks: [
        _SubjectMark('Mathematics', 90, 100),
        _SubjectMark('Science', 91, 100),
        _SubjectMark('English', 85, 100),
        _SubjectMark('Social Studies', 83, 100),
        _SubjectMark('Kannada', 86, 100),
        _SubjectMark('Computer Science', 88, 100),
      ],
    ),
    _TermCardData(
      'Term 3',
      'Oct – Dec 2025',
      3,
      true,
      overallPercent: 89,
      grade: 'A+',
      subjectMarks: [
        _SubjectMark('Mathematics', 94, 100),
        _SubjectMark('Science', 90, 100),
        _SubjectMark('English', 88, 100),
        _SubjectMark('Social Studies', 85, 100),
        _SubjectMark('Kannada', 87, 100),
        _SubjectMark('Computer Science', 90, 100),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Hero header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xl,
            horizontal: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Your Report Cards',
                style: AppTypography.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'View and download term-wise performance',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Available terms',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ..._terms.map((term) => _ReportCardTile(data: term)),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: Text(
            'Tap a card to view or download PDF',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SubjectMark {
  const _SubjectMark(this.subject, this.marks, this.maxMarks);
  final String subject;
  final int marks;
  final int maxMarks;
}

class _TermCardData {
  const _TermCardData(
    this.title,
    this.subtitle,
    this.termNumber,
    this.isLatest, {
    required this.overallPercent,
    required this.grade,
    required this.subjectMarks,
  });
  final String title;
  final String subtitle;
  final int termNumber;
  final bool isLatest;
  final int overallPercent;
  final String grade;
  final List<_SubjectMark> subjectMarks;
}

class _ReportCardTile extends StatelessWidget {
  const _ReportCardTile({required this.data});

  final _TermCardData data;

  static const _accentColors = [
    AppColors.primary,
    AppColors.teal,
    AppColors.accent,
  ];

  @override
  Widget build(BuildContext context) {
    final accent = _accentColors[(data.termNumber - 1) % _accentColors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${data.title} — opening PDF...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: accent.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: icon, title, Latest, download
                Row(
                  children: [
                    Container(
                      width: 5,
                      height: 56,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.description_rounded,
                        size: 22,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.title,
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            data.subtitle,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (data.isLatest)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.accent, Color(0xFFF39C12)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Latest',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(Icons.download_rounded, size: 24, color: accent),
                  ],
                ),
                // Report data: overall % + grade
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                    horizontal: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${data.overallPercent}%',
                            style: AppTypography.headlineMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: accent,
                            ),
                          ),
                          Text(
                            'Overall',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: accent.withValues(alpha: 0.3),
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              data.grade,
                              style: AppTypography.labelLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Grade',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Subject-wise marks
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Subject marks',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: data.subjectMarks.map((m) {
                    final pct = m.maxMarks > 0
                        ? (m.marks / m.maxMarks * 100).round()
                        : 0;
                    final isHigh = pct >= 85;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isHigh
                            ? AppColors.successBg
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isHigh
                              ? AppColors.success.withValues(alpha: 0.3)
                              : AppColors.divider.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            m.subject.subjectCode,
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${m.marks}/${m.maxMarks}',
                            style: AppTypography.labelSmall.copyWith(
                              color: isHigh
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Attendance tab: overall + per-subject (e.g. 10/13) ────────────────────────

class _AttendanceTab extends StatelessWidget {
  const _AttendanceTab({
    required this.timetableAsync,
    required this.attendanceAsync,
  });

  final AsyncValue<Map<String, List<MockPeriod>>> timetableAsync;
  final AsyncValue<List<MockAttendanceDay>> attendanceAsync;

  @override
  Widget build(BuildContext context) {
    return attendanceAsync.when(
      loading: () =>
          const Padding(padding: EdgeInsets.all(16), child: NcShimmerList()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (attendanceList) {
        final timetable = timetableAsync.valueOrNull ?? {};
        final now = DateTime.now();

        // Last 30 days
        int totalWorkingDays = 0;
        int attendedDays = 0;
        final subjectTotal = <String, int>{};
        final subjectAttended = <String, int>{};

        for (var i = 0; i < 30; i++) {
          final d = now.subtract(Duration(days: 29 - i));
          final w = d.weekday;
          if (w == 6 || w == 7) continue; // Sat/Sun
          final dayName = _weekdays[w];
          final periods = timetable[dayName] ?? [];
          if (periods.isEmpty) continue;

          totalWorkingDays++;
          MockAttendanceDay? dayRecord;
          for (final a in attendanceList) {
            if (a.date.year == d.year &&
                a.date.month == d.month &&
                a.date.day == d.day) {
              dayRecord = a;
              break;
            }
          }

          final wasPresent = dayRecord != null && dayRecord.status == 'present';

          if (wasPresent) attendedDays++;

          for (final p in periods) {
            subjectTotal[p.subject] = (subjectTotal[p.subject] ?? 0) + 1;
            if (wasPresent && dayRecord.periods.contains(p.subject)) {
              subjectAttended[p.subject] =
                  (subjectAttended[p.subject] ?? 0) + 1;
            }
          }
        }

        // Subject -> teacher (first occurrence from timetable)
        final subjectTeacher = <String, String>{};
        for (final dayPeriods in timetable.values) {
          for (final p in dayPeriods) {
            subjectTeacher.putIfAbsent(p.subject, () => p.teacher);
          }
        }

        final subjectStats = subjectTotal.keys.map((s) {
          final total = subjectTotal[s]!;
          final attended = subjectAttended[s] ?? 0;
          return _SubjectAttendanceRow(
            subject: s,
            subjectCode: s.subjectCode,
            teacher: subjectTeacher[s] ?? '—',
            attended: attended,
            total: total,
          );
        }).toList()..sort((a, b) => a.subject.compareTo(b.subject));

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Overall card: "22/26 days"
            NcCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.calendar_today_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Classes attended',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$attendedDays / $totalWorkingDays days',
                              style: AppTypography.headlineSmall.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (totalWorkingDays > 0)
                        Text(
                          '${((attendedDays / totalWorkingDays) * 100).round()}%',
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: totalWorkingDays > 0
                          ? attendedDays / totalWorkingDays
                          : 0,
                      minHeight: 8,
                      backgroundColor: AppColors.divider,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'By subject',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...subjectStats,
          ],
        );
      },
    );
  }
}

class _SubjectAttendanceRow extends StatelessWidget {
  const _SubjectAttendanceRow({
    required this.subject,
    required this.subjectCode,
    required this.teacher,
    required this.attended,
    required this.total,
  });

  final String subject;
  final String subjectCode;
  final String teacher;
  final int attended;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total > 0 ? attended / total : 0.0;
    final isGood = ratio >= 0.75;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: NcCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: subject.subjectColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(subject, style: AppTypography.labelLarge),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: subject.subjectColor.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              subjectCode,
                              style: AppTypography.labelSmall.copyWith(
                                color: subject.subjectColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            teacher,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isGood ? AppColors.successBg : AppColors.warningBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$attended / $total',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isGood ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 4,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isGood ? AppColors.success : AppColors.warning,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
