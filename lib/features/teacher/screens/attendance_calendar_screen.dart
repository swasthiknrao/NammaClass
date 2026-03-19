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
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _showFilterPanel = true;
  bool _showDetailsPanel = true;
  final Set<String> _filterClasses = {'8-A', '8-B', '9-A'};
  final Set<String> _filterSubjects = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_showFilterPanel) _buildFilterPanel(),
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
                SizedBox(height: 700, child: _buildCalendarContent(context)),
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
          SizedBox(height: 700, child: _buildCalendarContent(context)),
          if (sessions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildDetailsPanelContent(context, sessions, scrollable: false),
          ],
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.6,
        ),
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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

  static Color _colorForSession(MockAttendanceSession s) =>
      s.status == 'marked' ? AppColors.success : AppColors.warning;
  static Color _bgColorForSession(MockAttendanceSession s) =>
      s.status == 'marked' ? AppColors.successBg : AppColors.warningBg;

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
        PopupMenuButton<DateTime>(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          tooltip: 'Month & year',
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
                Text(
                  DateFormat.yMMMM().format(_focusedDay),
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.teal),
              ],
            ),
          ),
          itemBuilder: (context) {
            final items = <PopupMenuEntry<DateTime>>[];
            for (
              var y = DateTime.now().year - 1;
              y <= DateTime.now().year + 1;
              y++
            ) {
              for (var m = 1; m <= 12; m++) {
                final d = DateTime(y, m, 1);
                items.add(
                  PopupMenuItem(
                    value: d,
                    child: Text(DateFormat.yMMMM().format(d)),
                  ),
                );
              }
            }
            return items;
          },
          onSelected: (d) => setState(
            () => _focusedDay = DateTime(
              d.year,
              d.month,
              _focusedDay.day.clamp(1, 28),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (_isWide(context))
                setState(() => _showFilterPanel = !_showFilterPanel);
              else
                _showFilterSheet(context);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.teal.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.filter_list,
                    size: 18,
                    color: AppColors.teal,
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    size: 18,
                    color: AppColors.teal,
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
                  _calendarFormat == CalendarFormat.month
                      ? 'Month'
                      : _calendarFormat == CalendarFormat.week
                      ? 'Week'
                      : '2 Weeks',
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
            PopupMenuItem(value: CalendarFormat.month, child: Text('Month')),
          ],
          onSelected: (v) => setState(() => _calendarFormat = v),
        ),
        if (_calendarFormat != CalendarFormat.month)
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
                  onPressed: () => setState(() {
                    _focusedDay = _focusedDay.subtract(
                      Duration(
                        days: _calendarFormat == CalendarFormat.week ? 7 : 14,
                      ),
                    );
                  }),
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
                  onPressed: () => setState(() {
                    _focusedDay = _focusedDay.add(
                      Duration(
                        days: _calendarFormat == CalendarFormat.week ? 7 : 14,
                      ),
                    );
                  }),
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(4),
                    minimumSize: const Size(32, 32),
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            _formatHeader(),
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        if (_calendarFormat == CalendarFormat.month) ...[
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(
              () => _focusedDay = DateTime(
                _focusedDay.year,
                _focusedDay.month - 1,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(
              () => _focusedDay = DateTime(
                _focusedDay.year,
                _focusedDay.month + 1,
              ),
            ),
          ),
        ],
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
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: SizedBox(
        key: ValueKey(
          _calendarFormat == CalendarFormat.week ||
                  _calendarFormat == CalendarFormat.twoWeeks
              ? 'week_${_focusedDay.millisecondsSinceEpoch}'
              : 'month',
        ),
        width: double.infinity,
        height: 700,
        child:
            _calendarFormat == CalendarFormat.week ||
                _calendarFormat == CalendarFormat.twoWeeks
            ? _WeekViewGrid(
                focusedDay: _focusedDay,
                twoWeeks: _calendarFormat == CalendarFormat.twoWeeks,
                sessionsFor: _sessionsFor,
                formatTime: _formatTime,
                colorFor: _colorForSession,
                bgColorFor: _bgColorForSession,
                onDayTap: (d) => setState(() => _selectedDay = d),
                selectedDay: _selectedDay,
              )
            : _buildMonthCalendar(context, key: const ValueKey('month')),
      ),
    );
  }

  Widget _buildMonthCalendar(BuildContext context, {Key? key}) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        boxShadow: [AppColors.shadowSm],
      ),
      child: TableCalendar<MockAttendanceSession>(
        firstDay: DateTime(2020, 1, 1),
        lastDay: DateTime(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: CalendarFormat.month,
        rowHeight: ScreenSize.isMobile(context) ? 85 : 115,
        selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
        onDaySelected: (selected, focused) => setState(() {
          _selectedDay = selected;
          _focusedDay = focused;
        }),
        onPageChanged: (focused) => setState(() => _focusedDay = focused),
        eventLoader: (date) => _sessionsFor(date),
        calendarStyle: CalendarStyle(
          defaultTextStyle: AppTypography.bodyMedium,
          weekendTextStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          outsideTextStyle: AppTypography.bodySmall.copyWith(
            color: AppColors.textDisabled,
          ),
          selectedDecoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.2),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.teal, width: 2),
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.15),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.teal, width: 1),
          ),
          outsideDaysVisible: true,
        ),
        calendarBuilders: CalendarBuilders<MockAttendanceSession>(
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return null;
            final isMobile = ScreenSize.isMobile(context);
            final maxEvents = isMobile ? 2 : 3;
            final eventList = events.take(maxEvents).toList();
            final hasMore = events.length > maxEvents;
            return LayoutBuilder(
              builder: (context, constraints) {
                final maxW =
                    constraints.maxWidth.isFinite && constraints.maxWidth > 0
                    ? constraints.maxWidth
                    : 120.0;
                final usableHeight =
                    constraints.maxHeight.isFinite && constraints.maxHeight > 0
                    ? constraints.maxHeight
                    : 80.0;
                final maxH = (usableHeight * 0.5).clamp(48.0, 75.0);
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: maxW,
                    height: maxH,
                    child: ClipRect(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ...eventList.map<Widget>((s) {
                              return _CalendarEventBlock(
                                session: s,
                                formatTime: _formatTime,
                                colorFor: _colorForSession,
                                bgColorFor: _bgColorForSession,
                                compact: true,
                              );
                            }),
                            if (hasMore)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  '+${events.length - maxEvents} more',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        headerVisible: true,
      ),
    );
  }

  Widget _buildDetailsPanel(
    BuildContext context,
    List<MockAttendanceSession> sessions,
  ) {
    final panelWidth = MediaQuery.sizeOf(context).width > 1400 ? 340.0 : 300.0;
    return Container(
      width: panelWidth,
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(left: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
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
  }) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 48,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No classes scheduled',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: !scrollable,
      physics: scrollable ? null : const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      itemCount: sessions.length,
      itemBuilder: (ctx, i) {
        final s = sessions[i];
        final isMarked = s.status == 'marked';
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: isMarked ? AppColors.successBg : AppColors.warningBg,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            border: Border.all(
              color: isMarked
                  ? AppColors.success.withValues(alpha: 0.3)
                  : AppColors.warning.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isMarked ? AppColors.success : AppColors.warning,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isMarked ? 'Marked' : 'Pending',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${s.classSection} • P${s.period}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                s.subject,
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                s.concept,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${s.startTime} – ${s.endTime}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.teacherAttendanceMark),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  child: Text(isMarked ? 'View' : 'Mark Attendance'),
                ),
              ),
            ],
          ),
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
    this.selectedDay,
  });
  final DateTime focusedDay;
  final bool twoWeeks;
  final List<MockAttendanceSession> Function(DateTime) sessionsFor;
  final String Function(String) formatTime;
  final Color Function(MockAttendanceSession) colorFor;
  final Color Function(MockAttendanceSession) bgColorFor;
  final void Function(DateTime) onDayTap;
  final DateTime? selectedDay;

  @override
  State<_WeekViewGrid> createState() => _WeekViewGridState();
}

class _WeekViewGridState extends State<_WeekViewGrid> {
  late final ScrollController _verticalController;
  late final ScrollController _horizontalController;

  @override
  void initState() {
    super.initState();
    _verticalController = ScrollController();
    _horizontalController = ScrollController();
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
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

    final rowHeight = 44.0;
    final leftPanelWidth = 200.0;
    final colWidth = 100.0;
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final effectiveColWidth = isMobile ? 80.0 : colWidth;
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
    // Cap grid height so Column fits in parent (700px) - reserve space for header
    const maxAvailableHeight = 650.0;
    final effectiveGridHeight = gridContentHeight.clamp(
      120.0,
      maxAvailableHeight,
    );

    return Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: daysCount * effectiveColWidth,
                      height: headerHeight,
                      child: Row(
                        children: dayColumns.map((date) {
                          final isToday = _isToday(date);
                          return GestureDetector(
                            onTap: () => widget.onDayTap(date),
                            child: Container(
                              width: effectiveColWidth,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isToday ? _todayHighlight : _dayHeaderBg,
                                border: Border(
                                  right: BorderSide(color: _gridColor),
                                  bottom: BorderSide(color: _gridColor),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${_dayName(date.weekday)} ${date.day}',
                                  style: AppTypography.labelMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isToday
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
                  child: SizedBox(
                    height: gridContentHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: leftPanelWidth,
                          height: gridContentHeight,
                          child: Column(
                            children: List.generate(trackOrder.length, (r) {
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
                                      color: _gridColor.withValues(alpha: 0.7),
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
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        key,
                                        style: AppTypography.bodySmall.copyWith(
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
                            controller: _horizontalController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _horizontalController,
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: daysCount * effectiveColWidth,
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
                                                ? _todayHighlight.withValues(
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
                                                    ? () => context.go(
                                                        AppRoutes
                                                            .teacherAttendanceMark,
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
                                                                  context.go(
                                                                    AppRoutes
                                                                        .teacherAttendanceMark,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    6,
                                                                  ),
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                padding:
                                                                    const EdgeInsets.symmetric(
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
                                                                      color: Colors
                                                                          .black
                                                                          .withValues(
                                                                            alpha:
                                                                                0.08,
                                                                          ),
                                                                      blurRadius:
                                                                          2,
                                                                      offset:
                                                                          const Offset(
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
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child: Text(
                                                                    '${session.subject} P${session.period} ${_formatTimeCompact(session.startTime)}',
                                                                    style: AppTypography.labelSmall.copyWith(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          9,
                                                                    ),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
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
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CustomPaint(
                                                size: const Size(12, 8),
                                                painter: _TodayMarkerPainter(
                                                  color: _todayLineColor,
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

class _CalendarEventBlock extends StatelessWidget {
  const _CalendarEventBlock({
    required this.session,
    required this.formatTime,
    required this.colorFor,
    required this.bgColorFor,
    this.compact = false,
  });
  final MockAttendanceSession session;
  final String Function(String) formatTime;
  final Color Function(MockAttendanceSession) colorFor;
  final Color Function(MockAttendanceSession) bgColorFor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = colorFor(session);
    final bg = bgColorFor(session);
    return Container(
      margin: EdgeInsets.only(top: compact ? 1 : 2),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 3 : 4,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            session.classSection,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: compact ? 8 : 9,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            session.concept,
            style: AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: compact ? 9 : 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Text(
                formatTime(session.startTime),
                style: AppTypography.labelSmall.copyWith(
                  fontSize: compact ? 8 : 9,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                width: compact ? 5 : 6,
                height: compact ? 5 : 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
