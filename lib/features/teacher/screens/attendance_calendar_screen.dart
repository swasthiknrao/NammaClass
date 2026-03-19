import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/screen_size.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../widgets/timeline/timeline_roadmap_view.dart';
import '../../../routing/app_routes.dart';

class AttendanceCalendarScreen extends ConsumerStatefulWidget {
  const AttendanceCalendarScreen({super.key});

  @override
  ConsumerState<AttendanceCalendarScreen> createState() =>
      _AttendanceCalendarScreenState();
}

class _AttendanceCalendarScreenState
    extends ConsumerState<AttendanceCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final ValueNotifier<MockAttendanceSession?> _selectedSessionNotifier =
      ValueNotifier(null);
  CalendarFormat _calendarFormat = CalendarFormat.week;
  bool _showFilterPanel = true;
  bool _showDetailsPanel = true;
  final Set<String> _filterClasses = {'8-A', '8-B', '9-A'};
  final Set<String> _filterSubjects = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    final todaySessions = _sessionsFor(_selectedDay!);
    if (todaySessions.isNotEmpty) {
      _selectedSessionNotifier.value = todaySessions.first;
    }
  }

  @override
  void dispose() {
    _selectedSessionNotifier.dispose();
    super.dispose();
  }

  List<MockAttendanceSession> _sessionsFor(DateTime date) {
    return MockData.attendanceSessions.where((s) {
      if (s.date.year != date.year ||
          s.date.month != date.month ||
          s.date.day != date.day)
        return false;
      if (!_filterClasses.contains(s.classSection)) return false;
      if (_filterSubjects.isNotEmpty && !_filterSubjects.contains(s.subject))
        return false;
      return true;
    }).toList()..sort((a, b) => a.period.compareTo(b.period));
  }

  void _syncSelectionToSessionsForSelectedDay() {
    if (_selectedDay == null) return;
    final daySessions = _sessionsFor(_selectedDay!);
    final cur = _selectedSessionNotifier.value;
    if (daySessions.isEmpty) {
      _selectedSessionNotifier.value = null;
    } else if (cur == null || !daySessions.any((s) => s.id == cur.id)) {
      _selectedSessionNotifier.value = daySessions.first;
    }
  }

  int _totalInRange(DateTime start, DateTime end) {
    return MockData.attendanceSessions.where((s) {
      if (s.date.isBefore(start) || s.date.isAfter(end)) return false;
      if (!_filterClasses.contains(s.classSection)) return false;
      if (_filterSubjects.isNotEmpty && !_filterSubjects.contains(s.subject))
        return false;
      return true;
    }).length;
  }

  int _markedInRange(DateTime start, DateTime end) {
    return MockData.attendanceSessions.where((s) {
      if (s.date.isBefore(start) || s.date.isAfter(end)) return false;
      if (s.status != 'marked') return false;
      if (!_filterClasses.contains(s.classSection)) return false;
      if (_filterSubjects.isNotEmpty && !_filterSubjects.contains(s.subject))
        return false;
      return true;
    }).length;
  }

  bool _isWide(BuildContext c) =>
      ScreenSize.isDesktop(c) || ScreenSize.isTablet(c);

  double _calendarViewportHeight(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    final isMobile = ScreenSize.isMobile(context);
    if (!isMobile) return 700;
    return (screenH * 0.62).clamp(400.0, 560.0);
  }

  List<MockAttendanceSession> _sessionHistory(MockAttendanceSession session) {
    final items =
        MockData.attendanceSessions
            .where(
              (s) =>
                  s.classSection == session.classSection &&
                  s.subject == session.subject &&
                  s.date.isBefore(session.date),
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    return items.take(5).toList();
  }

  void _shiftFocusedRange(int direction) {
    final days = _calendarFormat == CalendarFormat.week ? 7 : 14;
    setState(() {
      _focusedDay = _focusedDay.add(Duration(days: days * direction));
    });
  }

  void _showMobileTaskDetailsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final sessions = _selectedDay != null
            ? _sessionsFor(_selectedDay!)
            : <MockAttendanceSession>[];
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.82,
          ),
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: _buildDetailsPanelContent(
              context,
              sessions,
              scrollable: true,
              mobileSheet: true,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _selectedDay != null
        ? _sessionsFor(_selectedDay!)
        : <MockAttendanceSession>[];
    DateTime rangeStart, rangeEnd;
    switch (_calendarFormat) {
      case CalendarFormat.week:
        rangeStart = _focusedDay.subtract(
          Duration(days: _focusedDay.weekday - 1),
        );
        rangeEnd = rangeStart.add(const Duration(days: 6));
        break;
      case CalendarFormat.month:
        rangeStart = DateTime(_focusedDay.year, _focusedDay.month, 1);
        rangeEnd = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
        break;
      case CalendarFormat.twoWeeks:
        rangeStart = _focusedDay.subtract(
          Duration(days: _focusedDay.weekday - 1),
        );
        rangeEnd = rangeStart.add(const Duration(days: 13));
        break;
    }
    final total = _totalInRange(rangeStart, rangeEnd);
    final marked = _markedInRange(rangeStart, rangeEnd);
    final pending = total - marked;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(
              title: const Text('Attendance Calendar'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.how_to_reg_rounded),
                  onPressed: () => context.go(AppRoutes.teacherAttendanceMark),
                  tooltip: 'Mark Attendance',
                ),
              ],
            ),
      body: _isWide(context)
          ? _buildDesktop(context, sessions, total, marked, pending)
          : _buildMobile(context, sessions, total, marked, pending),
    );
  }

  Widget _buildDesktop(
    BuildContext context,
    List<MockAttendanceSession> sessions,
    int total,
    int marked,
    int pending,
  ) {
    final width = MediaQuery.sizeOf(context).width;
    final isTabletLayout = width < 1240;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_showFilterPanel && !isTabletLayout) _buildFilterPanel(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSummaryCards(context, total, marked, pending),
                const SizedBox(height: AppSpacing.md),
                _buildCalendarControls(context),
                const SizedBox(height: AppSpacing.sm),
                _buildCalendarContent(context),
              ],
            ),
          ),
        ),
        if (_showDetailsPanel) _buildDetailsPanel(context, sessions),
      ],
    );
  }

  Widget _buildMobile(
    BuildContext context,
    List<MockAttendanceSession> sessions,
    int total,
    int marked,
    int pending,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        MediaQuery.paddingOf(context).bottom + AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSummaryCards(context, total, marked, pending),
          const SizedBox(height: AppSpacing.md),
          _buildCalendarControls(context),
          const SizedBox(height: AppSpacing.sm),
          _buildCalendarContent(context),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.divider.withValues(alpha: 0.7),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: Text(
                    'Task Details',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  height: 360,
                  child: _buildDetailsPanelContent(
                    context,
                    sessions,
                    scrollable: true,
                    mobileSheet: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(right: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter',
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _showFilterPanel = false),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              children: [
                _FilterSection(
                  title: 'Class',
                  items: ['8-A', '8-B', '9-A'],
                  selected: _filterClasses,
                  onToggle: (v) {
                    setState(() {
                      if (_filterClasses.contains(v))
                        _filterClasses.remove(v);
                      else
                        _filterClasses.add(v);
                    });
                    _syncSelectionToSessionsForSelectedDay();
                  },
                ),
                _FilterSection(
                  title: 'Subject',
                  items:
                      MockData.attendanceSessions
                          .map((s) => s.subject)
                          .toSet()
                          .toList()
                        ..sort(),
                  selected: _filterSubjects,
                  emptyMeansAll: true,
                  onToggle: (v) {
                    setState(() {
                      final all = MockData.attendanceSessions
                          .map((s) => s.subject)
                          .toSet();
                      if (_filterSubjects.isEmpty) {
                        _filterSubjects.addAll(all);
                        _filterSubjects.remove(v);
                      } else if (_filterSubjects.contains(v)) {
                        _filterSubjects.remove(v);
                      } else {
                        _filterSubjects.add(v);
                        if (_filterSubjects.length == all.length)
                          _filterSubjects.clear();
                      }
                    });
                    _syncSelectionToSessionsForSelectedDay();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    int total,
    int marked,
    int pending,
  ) {
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    return isNarrow
        ? Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'Total',
                      value: '$total',
                      color: AppColors.primary,
                      icon: Icons.calendar_month_rounded,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Marked',
                      value: '$marked',
                      color: AppColors.success,
                      icon: Icons.check_circle_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _SummaryCard(
                label: 'Pending',
                value: '$pending',
                color: AppColors.warning,
                icon: Icons.pending_rounded,
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Total Classes',
                  value: '$total',
                  color: AppColors.primary,
                  icon: Icons.calendar_month_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _SummaryCard(
                  label: 'Marked',
                  value: '$marked',
                  color: AppColors.success,
                  icon: Icons.check_circle_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _SummaryCard(
                  label: 'Pending',
                  value: '$pending',
                  color: AppColors.warning,
                  icon: Icons.pending_rounded,
                ),
              ),
            ],
          );
  }

  String _formatTime(String t) {
    if (t.length >= 5) {
      final parts = t.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]) ?? 8;
        final m = parts[1].substring(0, 2);
        final am = h < 12 ? 'AM' : 'PM';
        final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
        return '$h12:$m $am';
      }
    }
    return t;
  }

  Widget _buildCalendarControls(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (_isWide(context)) {
                setState(() => _showDetailsPanel = !_showDetailsPanel);
              } else {
                _showMobileTaskDetailsSheet(context);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _showDetailsPanel
                    ? AppColors.teal.withValues(alpha: 0.16)
                    : AppColors.teal.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.teal.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.segment_rounded,
                    size: 18,
                    color: AppColors.teal,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Details',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        PopupMenuButton<CalendarFormat>(
          padding: EdgeInsets.zero,
          tooltip: 'View',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_month,
                  size: 18,
                  color: AppColors.teal,
                ),
                const SizedBox(width: 4),
                Text(
                  _calendarFormat == CalendarFormat.week ? 'Week' : '2 Weeks',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                  color: AppColors.teal,
                ),
              ],
            ),
          ),
          itemBuilder: (context) => const [
            PopupMenuItem(value: CalendarFormat.week, child: Text('Week')),
            PopupMenuItem(
              value: CalendarFormat.twoWeeks,
              child: Text('2 Weeks'),
            ),
          ],
          onSelected: (v) => setState(() => _calendarFormat = v),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.teal.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _shiftFocusedRange(-1),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(4),
                  minimumSize: const Size(32, 32),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatHeader(),
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.teal,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _shiftFocusedRange(1),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(4),
                  minimumSize: const Size(32, 32),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        FilledButton.icon(
          onPressed: () => context.go(AppRoutes.teacherAttendanceMark),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('+ New Agenda'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.teal,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  String _formatHeader() {
    switch (_calendarFormat) {
      case CalendarFormat.week:
        final start = _focusedDay.subtract(
          Duration(days: _focusedDay.weekday - 1),
        );
        final end = start.add(const Duration(days: 6));
        return '${DateFormat.MMMd().format(start)} – ${DateFormat.MMMd().format(end)} ${_focusedDay.year}';
      case CalendarFormat.twoWeeks:
        final start = _focusedDay.subtract(
          Duration(days: _focusedDay.weekday - 1),
        );
        final end = start.add(const Duration(days: 13));
        return '${DateFormat.MMMd().format(start)} – ${DateFormat.MMMd().format(end)} ${_focusedDay.year}';
      case CalendarFormat.month:
        return DateFormat.yMMMM().format(_focusedDay);
    }
  }

  Widget _buildCalendarContent(BuildContext context) {
    final viewportHeight = _calendarViewportHeight(context);
    return RepaintBoundary(
      child: SizedBox(
        width: double.infinity,
        height: viewportHeight,
        child: const TimelineRoadmapView(),
      ),
    );
  }

  Widget _buildDetailsPanel(
    BuildContext context,
    List<MockAttendanceSession> sessions,
  ) {
    final panelWidth = MediaQuery.sizeOf(context).width > 1400 ? 340.0 : 300.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: panelWidth,
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.98),
        border: Border(left: BorderSide(color: AppColors.divider)),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          bottomLeft: Radius.circular(14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Details Schedule',
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _showDetailsPanel = false),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
          if (_selectedDay != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                DateFormat(
                  'd MMMM yyyy',
                ).format(_selectedDay ?? DateTime.now()),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          const Divider(height: 24),
          Expanded(
            child: _buildDetailsPanelContent(
              context,
              sessions,
              scrollable: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPanelContent(
    BuildContext context,
    List<MockAttendanceSession> sessions, {
    bool scrollable = true,
    bool mobileSheet = false,
  }) {
    final edgePadding = EdgeInsets.fromLTRB(
      AppSpacing.md,
      mobileSheet ? AppSpacing.md : AppSpacing.xs,
      AppSpacing.md,
      AppSpacing.md,
    );

    return ValueListenableBuilder<MockAttendanceSession?>(
      valueListenable: _selectedSessionNotifier,
      builder: (context, selected, _) {
        final history = selected == null
            ? <MockAttendanceSession>[]
            : _sessionHistory(selected);
        final hasSelectedFromDay =
            selected != null && sessions.any((s) => s.id == selected.id);

        final slivers = <Widget>[
          SliverPadding(
            padding: edgePadding,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (mobileSheet)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Task Details',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                if (sessions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_busy_rounded,
                          size: 42,
                          color: AppColors.textDisabled,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'No classes scheduled on this date',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else ...[
                  Text(
                    'Lessons',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ]),
            ),
          ),
          if (sessions.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList.separated(
                itemCount: sessions.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final s = sessions[index];
                  final isActive = selected?.id == s.id;
                  final isMarked = s.status == 'marked';
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.teal.withValues(alpha: 0.1)
                          : isMarked
                          ? AppColors.successBg
                          : AppColors.warningBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive
                            ? AppColors.teal
                            : isMarked
                            ? AppColors.success.withValues(alpha: 0.3)
                            : AppColors.warning.withValues(alpha: 0.3),
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.teal.withValues(alpha: 0.14),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _selectedSessionNotifier.value = s,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${s.classSection} • ${s.subject}',
                                      style: AppTypography.labelLarge.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${s.concept} • P${s.period}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                '${_formatTime(s.startTime)} - ${_formatTime(s.endTime)}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          SliverPadding(
            padding: edgePadding,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (sessions.isNotEmpty) const SizedBox(height: AppSpacing.md),
                Text(
                  'Selected Lesson',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (!hasSelectedFromDay)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      sessions.isEmpty
                          ? 'Select another date to view class details.'
                          : 'Select a lesson above to view complete details.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${selected.classSection} • ${selected.subject}',
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: selected.status == 'marked'
                                    ? AppColors.success
                                    : AppColors.warning,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                selected.status == 'marked'
                                    ? 'Marked'
                                    : 'Pending',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(selected.concept, style: AppTypography.bodyMedium),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            const Icon(Icons.schedule_rounded, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Period ${selected.period} • ${_formatTime(selected.startTime)} - ${_formatTime(selected.endTime)}',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () =>
                                context.go(AppRoutes.teacherAttendanceMark),
                            icon: const Icon(
                              Icons.how_to_reg_rounded,
                              size: 16,
                            ),
                            label: Text(
                              selected.status == 'marked'
                                  ? 'Open Attendance'
                                  : 'Mark Attendance',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Notes & History',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (!hasSelectedFromDay || history.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      'No previous notes/history available for this lesson yet.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                else
                  ...history.map((h) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: h.status == 'marked'
                                  ? AppColors.success
                                  : AppColors.warning,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('dd MMM yyyy').format(h.date),
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  h.concept,
                                  style: AppTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Period ${h.period} • ${_formatTime(h.startTime)}',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ]),
            ),
          ),
        ];

        return CustomScrollView(
          shrinkWrap: !scrollable,
          physics: scrollable ? null : const NeverScrollableScrollPhysics(),
          slivers: slivers,
        );
      },
    );
  }
}

// ── Gantt-style Week View (left item list + right timeline) ───────────────────

class _WeekViewGrid extends StatefulWidget {
  const _WeekViewGrid({
    required this.focusedDay,
    required this.twoWeeks,
    required this.sessionsFor,
    required this.formatTime,
    required this.colorFor,
    required this.bgColorFor,
    required this.onDayTap,
    required this.onSessionTap,
    required this.onNavigatePrevious,
    required this.onNavigateNext,
    // ignore: unused_element_parameter
    this.selectedDay,
  });
  final DateTime focusedDay;
  final bool twoWeeks;
  final List<MockAttendanceSession> Function(DateTime) sessionsFor;
  final String Function(String) formatTime;
  final Color Function(MockAttendanceSession) colorFor;
  final Color Function(MockAttendanceSession) bgColorFor;
  final void Function(DateTime) onDayTap;
  final void Function(MockAttendanceSession) onSessionTap;
  final VoidCallback onNavigatePrevious;
  final VoidCallback onNavigateNext;
  final DateTime? selectedDay;

  @override
  State<_WeekViewGrid> createState() => _WeekViewGridState();
}

class _WeekViewGridState extends State<_WeekViewGrid> {
  late final ScrollController _verticalController;
  late final ScrollController _headerHorizontalController;
  late final ScrollController _bodyHorizontalController;
  bool _syncingHorizontalScroll = false;

  @override
  void initState() {
    super.initState();
    _verticalController = ScrollController();
    _headerHorizontalController = ScrollController();
    _bodyHorizontalController = ScrollController();
    _headerHorizontalController.addListener(_syncFromHeader);
    _bodyHorizontalController.addListener(_syncFromBody);
  }

  @override
  void dispose() {
    _headerHorizontalController.removeListener(_syncFromHeader);
    _bodyHorizontalController.removeListener(_syncFromBody);
    _verticalController.dispose();
    _headerHorizontalController.dispose();
    _bodyHorizontalController.dispose();
    super.dispose();
  }

  void _syncFromHeader() => _syncHorizontal(
    source: _headerHorizontalController,
    target: _bodyHorizontalController,
  );

  void _syncFromBody() => _syncHorizontal(
    source: _bodyHorizontalController,
    target: _headerHorizontalController,
  );

  void _syncHorizontal({
    required ScrollController source,
    required ScrollController target,
  }) {
    if (_syncingHorizontalScroll) return;
    if (!source.hasClients || !target.hasClients) return;
    _syncingHorizontalScroll = true;
    final targetOffset = source.offset.clamp(
      target.position.minScrollExtent,
      target.position.maxScrollExtent,
    );
    if ((target.offset - targetOffset).abs() > 0.5) {
      target.jumpTo(targetOffset);
    }
    _syncingHorizontalScroll = false;
  }

  static const _gridColor = Color(0xFFE8E8E8);
  static const _dayHeaderBg = Color(0xFFF5F5F5);
  static const _todayHighlight = Color(0xFFE3F2FD);
  static const _rowAltBg = Color(0xFFFAFAFA);
  static const _barGreen = Color(0xFF4CAF50);
  static const _barBlue = Color(0xFF2196F3);
  static const _barPurple = Color(0xFF9C27B0);
  static const _barYellow = Color(0xFFFFC107);
  static const _barTeal = Color(0xFF009688);
  static const _todayLineColor = Color(0xFFFF9800);
  static const _swipeVelocityThreshold = 420.0;

  void _handleHorizontalSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < _swipeVelocityThreshold) return;
    if (!_bodyHorizontalController.hasClients) return;

    final maxOffset = _bodyHorizontalController.position.maxScrollExtent;
    final offset = _bodyHorizontalController.offset;
    const edgeSlack = 16.0;

    if (velocity < 0 && offset >= (maxOffset - edgeSlack)) {
      widget.onNavigateNext();
      return;
    }
    if (velocity > 0 && offset <= edgeSlack) {
      widget.onNavigatePrevious();
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = widget.focusedDay.subtract(
      Duration(days: widget.focusedDay.weekday - 1),
    );
    final daysCount = widget.twoWeeks ? 14 : 7;
    final dayColumns = List.generate(
      daysCount,
      (i) => start.add(Duration(days: i)),
    );

    final allSessionsInWeek = <MockAttendanceSession>[];
    for (final date in dayColumns) {
      allSessionsInWeek.addAll(widget.sessionsFor(date));
    }

    final trackKeys = <String>{};
    final trackOrder = <String>[];
    for (final s in allSessionsInWeek) {
      final key = '${s.classSection} • ${s.subject}';
      if (!trackKeys.contains(key)) {
        trackKeys.add(key);
        trackOrder.add(key);
      }
    }
    trackOrder.sort();

    const rowHeight = 44.0;
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final todayIdx = dayColumns.indexWhere((d) => _isToday(d));

    final sessionMap = <String, Map<int, MockAttendanceSession>>{};
    for (final key in trackOrder) {
      sessionMap[key] = {};
    }
    for (final date in dayColumns) {
      for (final s in widget.sessionsFor(date)) {
        final key = '${s.classSection} • ${s.subject}';
        final dayIdx = dayColumns.indexWhere(
          (d) =>
              d.year == date.year && d.month == date.month && d.day == date.day,
        );
        if (sessionMap.containsKey(key) && dayIdx >= 0) {
          sessionMap[key]![dayIdx] = s;
        }
      }
    }

    final gridContentHeight = trackOrder.isEmpty
        ? 120.0
        : trackOrder.length * rowHeight;
    const headerHeight = 48.0;
    const fallbackGridHeight = 420.0;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: isMobile ? _handleHorizontalSwipe : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final leftPanelWidth = isMobile
                  ? (constraints.maxWidth * 0.37).clamp(124.0, 156.0)
                  : 200.0;
              final rightViewportWidth = (constraints.maxWidth - leftPanelWidth)
                  .clamp(120.0, 1400.0);
              final effectiveColWidth = isMobile
                  ? (rightViewportWidth / (widget.twoWeeks ? 4.6 : 3.5)).clamp(
                      74.0,
                      110.0,
                    )
                  : 100.0;
              final contentWidth = daysCount * effectiveColWidth;
              final maxBodyHeight = constraints.maxHeight.isFinite
                  ? (constraints.maxHeight - headerHeight).clamp(120.0, 900.0)
                  : fallbackGridHeight;
              final effectiveGridHeight = gridContentHeight.clamp(
                120.0,
                maxBodyHeight,
              );
              return Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: leftPanelWidth,
                        height: headerHeight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: const BoxDecoration(
                            color: _dayHeaderBg,
                            border: Border(
                              right: BorderSide(color: _gridColor),
                              bottom: BorderSide(color: _gridColor),
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Class • Subject',
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _headerHorizontalController,
                          scrollDirection: Axis.horizontal,
                          physics: const ClampingScrollPhysics(),
                          child: SizedBox(
                            width: contentWidth,
                            height: headerHeight,
                            child: Row(
                              children: dayColumns.map((date) {
                                final isToday = _isToday(date);
                                final isSelected =
                                    widget.selectedDay != null &&
                                    isSameDay(widget.selectedDay, date);
                                return GestureDetector(
                                  onTap: () => widget.onDayTap(date),
                                  child: Container(
                                    width: effectiveColWidth,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.teal.withValues(
                                              alpha: 0.16,
                                            )
                                          : isToday
                                          ? _todayHighlight
                                          : _dayHeaderBg,
                                      border: Border(
                                        right: BorderSide(color: _gridColor),
                                        bottom: BorderSide(color: _gridColor),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${_dayName(date.weekday)} ${date.day}',
                                        style: AppTypography.labelMedium
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? AppColors.teal
                                                  : isToday
                                                  ? _todayLineColor
                                                  : AppColors.textSecondary,
                                            ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: effectiveGridHeight,
                    child: Scrollbar(
                      controller: _verticalController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _verticalController,
                        scrollDirection: Axis.vertical,
                        physics: const ClampingScrollPhysics(),
                        child: SizedBox(
                          height: gridContentHeight,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: leftPanelWidth,
                                height: gridContentHeight,
                                child: Column(
                                  children: List.generate(trackOrder.length, (
                                    r,
                                  ) {
                                    final key = trackOrder[r];
                                    final isAlt = r.isOdd;
                                    return Container(
                                      height: rowHeight,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isAlt ? _rowAltBg : Colors.white,
                                        border: Border(
                                          right: BorderSide(color: _gridColor),
                                          bottom: BorderSide(
                                            color: _gridColor.withValues(
                                              alpha: 0.7,
                                            ),
                                          ),
                                        ),
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: _barColorForTrack(r),
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              key,
                                              style: AppTypography.bodySmall
                                                  .copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              Expanded(
                                child: Scrollbar(
                                  controller: _bodyHorizontalController,
                                  thumbVisibility: true,
                                  child: SingleChildScrollView(
                                    controller: _bodyHorizontalController,
                                    scrollDirection: Axis.horizontal,
                                    physics: const ClampingScrollPhysics(),
                                    child: SizedBox(
                                      width: contentWidth,
                                      height: gridContentHeight,
                                      child: Stack(
                                        children: [
                                          Row(
                                            children: List.generate(daysCount, (
                                              colIdx,
                                            ) {
                                              final date = dayColumns[colIdx];
                                              final isToday = _isToday(date);
                                              return Container(
                                                width: effectiveColWidth,
                                                decoration: BoxDecoration(
                                                  color: isToday
                                                      ? _todayHighlight
                                                            .withValues(
                                                              alpha: 0.2,
                                                            )
                                                      : Colors.transparent,
                                                  border: Border(
                                                    right: BorderSide(
                                                      color: _gridColor,
                                                    ),
                                                  ),
                                                ),
                                                child: Column(
                                                  children: List.generate(trackOrder.length, (
                                                    r,
                                                  ) {
                                                    final key = trackOrder[r];
                                                    final session =
                                                        sessionMap[key]?[colIdx];
                                                    final isAlt = r.isOdd;
                                                    return GestureDetector(
                                                      onTap: session != null
                                                          ? () => widget
                                                                .onSessionTap(
                                                                  session,
                                                                )
                                                          : null,
                                                      child: Container(
                                                        height: rowHeight,
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 4,
                                                              vertical: 4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: isAlt
                                                              ? _rowAltBg
                                                              : Colors.white,
                                                          border: Border(
                                                            bottom: BorderSide(
                                                              color: _gridColor
                                                                  .withValues(
                                                                    alpha: 0.7,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                        child: session != null
                                                            ? Center(
                                                                child: Material(
                                                                  color: Colors
                                                                      .transparent,
                                                                  child: InkWell(
                                                                    onTap: () =>
                                                                        widget.onSessionTap(
                                                                          session,
                                                                        ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          6,
                                                                        ),
                                                                    child: Container(
                                                                      width: double
                                                                          .infinity,
                                                                      padding: const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            6,
                                                                        vertical:
                                                                            4,
                                                                      ),
                                                                      decoration: BoxDecoration(
                                                                        color:
                                                                            session.status ==
                                                                                'marked'
                                                                            ? _barBlue
                                                                            : _barGreen,
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              6,
                                                                            ),
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color: Colors.black.withValues(
                                                                              alpha: 0.08,
                                                                            ),
                                                                            blurRadius:
                                                                                2,
                                                                            offset: const Offset(
                                                                              0,
                                                                              1,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      child: FittedBox(
                                                                        fit: BoxFit
                                                                            .scaleDown,
                                                                        alignment:
                                                                            Alignment.centerLeft,
                                                                        child: Text(
                                                                          '${session.subject} P${session.period} ${_formatTimeCompact(session.startTime)}',
                                                                          style: AppTypography.labelSmall.copyWith(
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontSize:
                                                                                9,
                                                                          ),
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            : const SizedBox.shrink(),
                                                      ),
                                                    );
                                                  }),
                                                ),
                                              );
                                            }),
                                          ),
                                          if (todayIdx >= 0)
                                            Positioned(
                                              left:
                                                  todayIdx * effectiveColWidth +
                                                  effectiveColWidth / 2 -
                                                  1,
                                              top: 0,
                                              bottom: 0,
                                              child: IgnorePointer(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    CustomPaint(
                                                      size: const Size(12, 8),
                                                      painter:
                                                          _TodayMarkerPainter(
                                                            color:
                                                                _todayLineColor,
                                                          ),
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        width: 2,
                                                        color: _todayLineColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Color _barColorForTrack(int index) {
    const colors = [_barGreen, _barBlue, _barPurple, _barYellow, _barTeal];
    return colors[index % colors.length];
  }

  String _formatTimeCompact(String t) {
    final parts = t.split(':');
    if (parts.length < 2) return t;
    final h = int.tryParse(parts[0]) ?? 8;
    final m = parts[1].length >= 2 ? parts[1].substring(0, 2) : '00';
    if (h < 12) return '$h:$m AM';
    return '${h == 12 ? 12 : h - 12}:$m PM';
  }

  bool _isToday(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }

  String _dayName(int w) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(w - 1) % 7];
  }
}

class _TodayMarkerPainter extends CustomPainter {
  _TodayMarkerPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TodayMarkerPainter old) => old.color != color;
}

// ── Shared widgets ───────────────────────────────────────────────────────────

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.items,
    required this.selected,
    required this.onToggle,
    this.emptyMeansAll = false,
  });
  final String title;
  final List<String> items;
  final Set<String> selected;
  final void Function(String) onToggle;
  final bool emptyMeansAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Text(
            title,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ...items.map((item) {
          final isSelected =
              (emptyMeansAll && selected.isEmpty) || selected.contains(item);
          return CheckboxListTile(
            title: Text(item, style: AppTypography.bodyMedium),
            value: isSelected,
            onChanged: (_) => onToggle(item),
            activeColor: AppColors.teal,
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 0,
            ),
          );
        }),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.headlineMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
