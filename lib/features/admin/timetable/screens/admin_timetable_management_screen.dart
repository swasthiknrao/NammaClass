import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shell_layout_scope.dart';
import '../../../../domain/entities/timetable_slot_entry.dart';
import '../../../admin/providers/admin_providers.dart';
import '../../../../routing/app_routes.dart';
import '../providers/timetable_notifier.dart';
import '../widgets/admin_class_create_sheet.dart';
import '../widgets/admin_faculty_picker_sheet.dart';

/// Legacy ERP-style **day-first** timetable builder (dark chrome, period list).
/// Uses [timetableNotifierProvider] + period labels from **Timetable settings**.
/// No Firebase — faculty from mock staff + manual entry.
class AdminTimetableManagementScreen extends ConsumerStatefulWidget {
  const AdminTimetableManagementScreen({super.key});

  /// Aligned with [AppColors] dark surfaces + brand accent (tenant preset in app theme).
  static const Color _bg = AppColors.backgroundDark;
  static const Color _panel = AppColors.cardDark;
  static const Color _text = AppColors.textPrimaryDark;
  static const Color _accent = AppColors.accent;
  static const Color _engage = Color(0xFFFF8A65);

  @override
  ConsumerState<AdminTimetableManagementScreen> createState() =>
      _AdminTimetableManagementScreenState();
}

class _AdminTimetableManagementScreenState
    extends ConsumerState<AdminTimetableManagementScreen>
    with TickerProviderStateMixin {
  int _dayIndex = 0;
  bool _dirty = false;
  bool _dismissedSettingsHint = false;
  late AnimationController _gridAnim;

  @override
  void initState() {
    super.initState();
    _gridAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..forward();
  }

  @override
  void dispose() {
    _gridAnim.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  void _saveMock() {
    setState(() => _dirty = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Timetable saved to session'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }

  static const Color _slotDialogFieldFill = Color(0xFFF5F3F1);

  InputDecoration _slotDialogFieldDeco({required String label, String? hint}) {
    final accent = AdminTimetableManagementScreen._accent;
    return InputDecoration(
      filled: true,
      fillColor: _slotDialogFieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: TextStyle(
        color: accent.withValues(alpha: 0.88),
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      hintStyle: TextStyle(
        color: AdminTimetableManagementScreen._text.withValues(alpha: 0.45),
        fontSize: 14,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: accent.withValues(alpha: 0.22)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: accent, width: 2),
      ),
    );
  }

  /// Faculty already teaching this period in **another** class section.
  bool _crossClassConflict(
    TimetableState tt,
    String facultyId,
    int day,
    int period,
    String excludeSection,
  ) {
    for (final sec in tt.classSections) {
      if (sec == excludeSection) continue;
      final g = tt.gridFor(sec);
      final slot = g[day][period];
      if (slot != null && slot.facultyId == facultyId) return true;
    }
    return false;
  }

  List<Map<String, String>> _facultyOptionRows() {
    final staffAsync = ref.read(adminStaffProvider);
    final staff = staffAsync.valueOrNull ?? const <MockStaffMember>[];
    return [
      {
        'id': kTeacherDemoId,
        'name': kTeacherDemoName,
        'department': 'Mathematics',
      },
      {
        'id': 'staff_demo_phy',
        'name': 'Dr. Meera Iyer',
        'department': 'Physics',
      },
      {
        'id': 'staff_demo_soc',
        'name': 'Karthik Rao',
        'department': 'Social Science',
      },
      {'id': 'staff_demo_kn', 'name': 'Lakshmi Bhat', 'department': 'Kannada'},
      {
        'id': 'staff_demo_cs',
        'name': 'Ananya Krishnan',
        'department': 'Computer Science',
      },
      {
        'id': 'staff_demo_en',
        'name': 'James O\'Brien',
        'department': 'English',
      },
      {
        'id': 'staff_demo_ch',
        'name': 'Priya Nambiar',
        'department': 'Chemistry',
      },
      {
        'id': 'staff_demo_pe',
        'name': 'Vikram Singh',
        'department': 'Physical Education',
      },
      {'id': 'staff_demo_mu', 'name': 'Deepa Fernandes', 'department': 'Music'},
      {
        'id': 'staff_demo_ar',
        'name': 'Salma Rahman',
        'department': 'Fine Arts',
      },
      {
        'id': 'staff_demo_eco',
        'name': 'Naveen Patil',
        'department': 'Economics',
      },
      ...staff.map(
        (s) => {'id': s.id, 'name': s.name, 'department': s.department},
      ),
    ];
  }

  String _settingsChipSummary(TimetableState tt) {
    final maxP = tt.maxPeriodsConfigured;
    final w = tt.workingWeekdays;
    final short = <String>[];
    for (
      var i = 0;
      i < w.length && i < TimetableNotifier.dayLabels.length;
      i++
    ) {
      if (w[i]) short.add(TimetableNotifier.dayLabels[i].substring(0, 3));
    }
    final dayPart = short.isEmpty
        ? '—'
        : (short.length <= 5 ? short.join('·') : '${short.length} days');
    return '$maxP periods · $dayPart';
  }

  Future<void> _openCreateClassSheet() async {
    final tt = ref.read(timetableNotifierProvider);
    final existing = tt.classSections.toSet();
    final result = await showAdminClassCreateSheet(
      context,
      existingSectionIds: existing,
    );
    if (!mounted || result == null) return;
    ref
        .read(timetableNotifierProvider.notifier)
        .addClassSection(result.sectionId, meta: result.meta);
    _gridAnim.forward(from: 0);
    setState(() {});
  }

  void _showFacultyMiniSchedule(String facultyId, String facultyName) {
    final tt = ref.read(timetableNotifierProvider);
    final entries = <String>[];
    for (var d = 0; d < TimetableNotifier.dayLabels.length; d++) {
      for (final sec in tt.classSections) {
        final grid = tt.gridFor(sec);
        for (var p = 0; p < tt.periods.length; p++) {
          if (!TimetableNotifier.isPeriodWritable(tt, d, p)) continue;
          final slot = grid[d][p];
          if (slot == null) continue;
          if (slot.facultyId != facultyId) continue;
          if (slot.isLab && _isLabContinuationForDay(grid, d, p)) continue;
          final time = ref
              .read(timetableNotifierProvider.notifier)
              .periodTimeRange(p);
          final lab = slot.isLab ? ' (Lab x${slot.labSpan})' : '';
          entries.add(
            '${TimetableNotifier.dayLabels[d]} · P${p + 1} ($time) · $sec · ${slot.subject}$lab',
          );
        }
      }
    }
    showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: AdminTimetableManagementScreen._panel,
        title: Row(
          children: [
            Icon(Icons.person, color: AdminTimetableManagementScreen._accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                facultyName,
                style: const TextStyle(
                  color: AdminTimetableManagementScreen._text,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: entries.isEmpty
              ? Text(
                  'No other slots in this mock timetable.',
                  style: TextStyle(
                    color: AdminTimetableManagementScreen._text.withValues(
                      alpha: 0.85,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: entries
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              e,
                              style: const TextStyle(
                                color: AdminTimetableManagementScreen._text,
                                height: 1.35,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  bool _isLabContinuationForDay(
    List<List<TimetableSlotEntry?>> grid,
    int day,
    int period,
  ) {
    for (var k = 1; k <= period; k++) {
      final prev = grid[day][period - k];
      if (prev != null && prev.isLab && prev.labSpan > k) {
        return true;
      }
    }
    return false;
  }

  /// Clears any theory or lab block that overlaps `[from, toExclusive)` on this day.
  void _clearOverlappingAssignments(
    String section,
    int day,
    int from,
    int toExclusive,
  ) {
    final n = ref.read(timetableNotifierProvider.notifier);
    for (var guard = 0; guard < 32; guard++) {
      final tt = ref.read(timetableNotifierProvider);
      final row = tt.gridFor(section)[day];
      var clearedOne = false;
      for (var start = 0; start < tt.periods.length; start++) {
        final s = row[start];
        if (s == null) continue;
        final span = s.isLab ? s.labSpan : 1;
        final blockEnd = start + span;
        if (start < toExclusive && blockEnd > from) {
          if (s.isLab) {
            n.clearLabSpan(
              classSection: section,
              dayIndex: day,
              startPeriod: start,
              span: span,
            );
          } else {
            n.setCell(
              classSection: section,
              dayIndex: day,
              periodIndex: start,
              slot: null,
            );
          }
          clearedOne = true;
          break;
        }
      }
      if (!clearedOne) return;
    }
  }

  Future<void> _pickFacultyFromSheet(
    BuildContext context,
    int periodIndex, {
    required void Function(String id, String name) onPick,
  }) async {
    final rows = _facultyOptionRows();
    final tt = ref.read(timetableNotifierProvider);
    final section = tt.selectedClassSection;
    final dayLine =
        '${TimetableNotifier.dayLabels[_dayIndex]} · Period ${periodIndex + 1} '
        '(${ref.read(timetableNotifierProvider.notifier).periodTimeRange(periodIndex)})';
    final pickerRows = rows
        .map(
          (r) => FacultyPickerRow(
            id: r['id']!,
            name: r['name']!,
            department: r['department'] ?? '',
          ),
        )
        .toList();

    final meta = tt.metaBySection[section];
    final rawHint = meta == null
        ? ''
        : '${meta.programName} ${meta.yearLabel} ${meta.departmentName}'.trim();
    final classProgramHint = rawHint.isEmpty ? null : rawHint;
    final classDisplayLabel = meta?.dropdownLabel;

    await showAdminFacultyPickerSheet(
      context,
      rows: pickerRows,
      dayPeriodLine: dayLine,
      isEngaged: (fid) =>
          _crossClassConflict(tt, fid, _dayIndex, periodIndex, section),
      onSelect: onPick,
      onShowSchedule: (id, name) => _showFacultyMiniSchedule(id, name),
      panelColor: AdminTimetableManagementScreen._panel,
      textColor: AdminTimetableManagementScreen._text,
      accentColor: AdminTimetableManagementScreen._accent,
      engageColor: AdminTimetableManagementScreen._engage,
      classProgramHint: classProgramHint,
      classDisplayLabel: classDisplayLabel,
    );
  }

  Future<void> _openPeriodEditor(int periodIndex) async {
    final tt = ref.read(timetableNotifierProvider);
    if (!TimetableNotifier.isPeriodWritable(tt, _dayIndex, periodIndex)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'This bell is not scheduled on ${TimetableNotifier.dayLabels[_dayIndex]} '
            '(${tt.periodsPerDay[_dayIndex]} periods).',
          ),
        ),
      );
      return;
    }
    final section = tt.selectedClassSection;
    final grid = tt.gridFor(section);
    final existing = grid[_dayIndex][periodIndex];
    final ids = _facultyOptionRows().map((e) => e['id']!).toSet();

    final maxSpanSlots = (tt.periodsPerDay[_dayIndex] - periodIndex).clamp(
      1,
      tt.periods.length - periodIndex,
    );

    final subjectCtrl = TextEditingController(text: existing?.subject ?? '');
    var isLab = existing?.isLab ?? false;
    var labSpan = existing?.isLab == true
        ? existing!.labSpan.clamp(1, maxSpanSlots)
        : 1;
    var facultyId = existing?.facultyId;
    var facultyName = existing?.facultyName;
    if (facultyId != null && !ids.contains(facultyId)) {
      facultyId = null;
      facultyName = null;
    }

    final facultyDisplayCtrl = TextEditingController(text: facultyName ?? '');

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) {
          final n = ref.read(timetableNotifierProvider.notifier);
          final ttNow = ref.read(timetableNotifierProvider);
          final fidForConflict = facultyId;
          final engaged =
              fidForConflict != null &&
              _crossClassConflict(
                ttNow,
                fidForConflict,
                _dayIndex,
                periodIndex,
                section,
              );

          void apply() {
            final sub = subjectCtrl.text.trim();
            if (sub.isEmpty || (facultyId ?? '').isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Subject and staff assignee are required'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            final fid = facultyId!;
            final name = facultyName ?? '';
            final dayMax = ttNow.periodsPerDay[_dayIndex];
            final gridMax = ttNow.periods.length;
            final toExclusive = isLab
                ? math.min(periodIndex + labSpan, dayMax)
                : periodIndex + 1;
            _clearOverlappingAssignments(
              section,
              _dayIndex,
              periodIndex,
              toExclusive,
            );
            final notifier = ref.read(timetableNotifierProvider.notifier);
            if (isLab) {
              for (
                var k = 0;
                k < labSpan &&
                    periodIndex + k < dayMax &&
                    periodIndex + k < gridMax;
                k++
              ) {
                notifier.setCell(
                  classSection: section,
                  dayIndex: _dayIndex,
                  periodIndex: periodIndex + k,
                  slot: TimetableSlotEntry(
                    subject: sub,
                    facultyId: fid,
                    facultyName: name,
                    isLab: true,
                    labSpan: labSpan,
                  ),
                );
              }
            } else {
              notifier.setCell(
                classSection: section,
                dayIndex: _dayIndex,
                periodIndex: periodIndex,
                slot: TimetableSlotEntry(
                  subject: sub,
                  facultyId: fid,
                  facultyName: name,
                ),
              );
            }
            _markDirty();
            Navigator.pop(ctx);
            setState(() {});
          }

          final accent = AdminTimetableManagementScreen._accent;
          final panel = AdminTimetableManagementScreen._panel;
          final textCol = AdminTimetableManagementScreen._text;
          final bgDeep = AdminTimetableManagementScreen._bg;
          final isAdd = existing == null;

          Future<void> openLabSpanSheet() async {
            final spanBox = <int>[labSpan.clamp(1, maxSpanSlots)];
            await showModalBottomSheet<void>(
              context: ctx,
              useRootNavigator: true,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (bc) {
                final bottomInset = MediaQuery.viewInsetsOf(bc).bottom;
                return Padding(
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Material(
                        color: panel,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
                        clipBehavior: Clip.antiAlias,
                        elevation: 18,
                        shadowColor: Colors.black54,
                        child: StatefulBuilder(
                          builder: (sc, setS) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 10),
                                Container(
                                  width: 42,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: textCol.withValues(alpha: 0.22),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                ),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        accent,
                                        Color.lerp(
                                          accent,
                                          const Color(0xFF2A1510),
                                          0.35,
                                        )!,
                                      ],
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      14,
                                      20,
                                      16,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.2,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.science_rounded,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Lab block',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 18,
                                                  letterSpacing: -0.3,
                                                ),
                                              ),
                                              Text(
                                                'Pick how many bells merge.',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.88),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    18,
                                    20,
                                    18,
                                    10,
                                  ),
                                  child: Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    alignment: WrapAlignment.center,
                                    children: List.generate(maxSpanSlots, (i) {
                                      final n = i + 1;
                                      final sel = spanBox[0] == n;
                                      return FilterChip(
                                        selected: sel,
                                        showCheckmark: false,
                                        label: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: Text(
                                            n == 1 ? '1 bell' : '$n bells',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: sel
                                                  ? textCol
                                                  : textCol.withValues(
                                                      alpha: 0.75,
                                                    ),
                                            ),
                                          ),
                                        ),
                                        selectedColor: accent.withValues(
                                          alpha: 0.35,
                                        ),
                                        backgroundColor: bgDeep.withValues(
                                          alpha: 0.5,
                                        ),
                                        side: BorderSide(
                                          color: sel
                                              ? accent
                                              : textCol.withValues(alpha: 0.15),
                                        ),
                                        onSelected: (_) =>
                                            setS(() => spanBox[0] = n),
                                      );
                                    }),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    18,
                                    0,
                                    18,
                                    18,
                                  ),
                                  child: Row(
                                    children: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(bc),
                                        child: Text(
                                          'Close',
                                          style: TextStyle(
                                            color: textCol.withValues(
                                              alpha: 0.85,
                                            ),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      FilledButton(
                                        onPressed: () {
                                          setD(
                                            () => labSpan = spanBox[0].clamp(
                                              1,
                                              maxSpanSlots,
                                            ),
                                          );
                                          Navigator.pop(bc);
                                        },
                                        style: FilledButton.styleFrom(
                                          backgroundColor: accent,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 22,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Apply',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 400,
                maxHeight: MediaQuery.sizeOf(ctx).height * 0.88,
              ),
              child: Material(
                elevation: 28,
                shadowColor: Colors.black.withValues(alpha: 0.5),
                color: panel,
                borderRadius: BorderRadius.circular(26),
                clipBehavior: Clip.antiAlias,
                child: ListView(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                accent,
                                Color.lerp(
                                  accent,
                                  const Color(0xFF2A1510),
                                  0.35,
                                )!,
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 16, 6, 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.22),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.35,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isAdd
                                        ? Icons.add_rounded
                                        : Icons.edit_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isAdd ? 'Add slot' : 'Edit slot',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.4,
                                          height: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.schedule_rounded,
                                            color: Colors.white.withValues(
                                              alpha: 0.92,
                                            ),
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            n.periodTimeRange(periodIndex),
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.94,
                                              ),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Close',
                                  onPressed: () => Navigator.pop(ctx),
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: Colors.white.withValues(alpha: 0.92),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: subjectCtrl,
                                style: const TextStyle(
                                  color: Color(0xFF1E1E1E),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: _slotDialogFieldDeco(
                                  label: 'Subject',
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: facultyDisplayCtrl,
                                readOnly: true,
                                onTap: () async {
                                  await _pickFacultyFromSheet(
                                    ctx,
                                    periodIndex,
                                    onPick: (id, name) {
                                      setD(() {
                                        facultyId = id;
                                        facultyName = name;
                                        facultyDisplayCtrl.text = name;
                                      });
                                    },
                                  );
                                  setD(() {});
                                },
                                style: const TextStyle(
                                  color: Color(0xFF1E1E1E),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration:
                                    _slotDialogFieldDeco(
                                      label: 'Staff',
                                      hint: (facultyName?.isEmpty ?? true)
                                          ? 'Choose staff'
                                          : null,
                                    ).copyWith(
                                      suffixIcon: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: accent.withValues(alpha: 0.9),
                                        size: 28,
                                      ),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              TextButton.icon(
                                onPressed: () async {
                                  await _pickFacultyFromSheet(
                                    ctx,
                                    periodIndex,
                                    onPick: (id, name) {
                                      setD(() {
                                        facultyId = id;
                                        facultyName = name;
                                        facultyDisplayCtrl.text = name;
                                      });
                                    },
                                  );
                                  setD(() {});
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: accent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  alignment: Alignment.centerLeft,
                                ),
                                icon: Icon(
                                  Icons.groups_2_outlined,
                                  size: 20,
                                  color: accent,
                                ),
                                label: Text(
                                  'Full roster',
                                  style: TextStyle(
                                    color: accent,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              if (engaged) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AdminTimetableManagementScreen
                                        ._engage
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AdminTimetableManagementScreen
                                          ._engage
                                          .withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        size: 18,
                                        color: AdminTimetableManagementScreen
                                            ._engage,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'This person is already booked in another section '
                                          'for this bell — you can still save.',
                                          style: TextStyle(
                                            color: textCol.withValues(
                                              alpha: 0.92,
                                            ),
                                            fontSize: 12.5,
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 14),
                              Text(
                                'Session type',
                                style: TextStyle(
                                  color: textCol.withValues(alpha: 0.75),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: bgDeep.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: accent.withValues(alpha: 0.15),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Material(
                                        color: !isLab
                                            ? accent.withValues(alpha: 0.22)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          onTap: () => setD(() {
                                            isLab = false;
                                            labSpan = 1;
                                          }),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 11,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.menu_book_rounded,
                                                  size: 19,
                                                  color: !isLab
                                                      ? accent
                                                      : textCol.withValues(
                                                          alpha: 0.45,
                                                        ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Classroom',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 13,
                                                    color: !isLab
                                                        ? textCol
                                                        : textCol.withValues(
                                                            alpha: 0.55,
                                                          ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Material(
                                        color: isLab
                                            ? accent.withValues(alpha: 0.22)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          onTap: () => setD(() {
                                            isLab = true;
                                            labSpan = labSpan.clamp(
                                              1,
                                              maxSpanSlots,
                                            );
                                          }),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 11,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.science_rounded,
                                                  size: 19,
                                                  color: isLab
                                                      ? accent
                                                      : textCol.withValues(
                                                          alpha: 0.45,
                                                        ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Laboratory',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 13,
                                                    color: isLab
                                                        ? textCol
                                                        : textCol.withValues(
                                                            alpha: 0.55,
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
                              if (isLab) ...[
                                const SizedBox(height: 10),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () async {
                                      await openLabSpanSheet();
                                      setD(() {});
                                    },
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            accent.withValues(alpha: 0.2),
                                            accent.withValues(alpha: 0.06),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: accent.withValues(alpha: 0.38),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.hourglass_top_rounded,
                                              size: 20,
                                              color: accent,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Block length',
                                                    style: TextStyle(
                                                      color: textCol,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    labSpan == 1
                                                        ? '1 consecutive period'
                                                        : '$labSpan consecutive periods',
                                                    style: TextStyle(
                                                      color: textCol.withValues(
                                                        alpha: 0.68,
                                                      ),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              Icons.open_in_new_rounded,
                                              size: 18,
                                              color: accent.withValues(
                                                alpha: 0.9,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                          decoration: BoxDecoration(
                            color: bgDeep.withValues(alpha: 0.4),
                            border: Border(
                              top: BorderSide(
                                color: accent.withValues(alpha: 0.12),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                style: TextButton.styleFrom(
                                  foregroundColor: textCol.withValues(
                                    alpha: 0.85,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: accent,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shadowColor: accent.withValues(alpha: 0.45),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: apply,
                                icon: const Icon(Icons.check_rounded, size: 20),
                                label: const Text(
                                  'Save',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    subjectCtrl.dispose();
    facultyDisplayCtrl.dispose();
  }

  Future<bool> _confirmDelete(TimetableSlotEntry? slot, int period) async {
    if (slot == null) return false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AdminTimetableManagementScreen._panel,
        title: const Text(
          'Remove period?',
          style: TextStyle(color: AdminTimetableManagementScreen._text),
        ),
        content: Text(
          slot.isLab
              ? 'Clears this lab block (${slot.labSpan} slots).'
              : 'Remove ${slot.subject}?',
          style: const TextStyle(color: AdminTimetableManagementScreen._text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return false;
    final tt = ref.read(timetableNotifierProvider);
    final sec = tt.selectedClassSection;
    final n = ref.read(timetableNotifierProvider.notifier);
    if (slot.isLab) {
      n.clearLabSpan(
        classSection: sec,
        dayIndex: _dayIndex,
        startPeriod: period,
        span: slot.labSpan,
      );
    } else {
      n.setCell(
        classSection: sec,
        dayIndex: _dayIndex,
        periodIndex: period,
        slot: null,
      );
    }
    _markDirty();
    setState(() {});
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final tt = ref.watch(timetableNotifierProvider);
    final n = ref.read(timetableNotifierProvider.notifier);
    final hideBar =
        ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true;

    if (tt.classSections.isEmpty) {
      return Theme(
        data: Theme.of(
          context,
        ).copyWith(scaffoldBackgroundColor: AdminTimetableManagementScreen._bg),
        child: Scaffold(
          backgroundColor: AdminTimetableManagementScreen._bg,
          appBar: hideBar
              ? null
              : AppBar(
                  backgroundColor: AdminTimetableManagementScreen._panel,
                  elevation: 0,
                  title: const Text(
                    'Timetable — day view',
                    style: TextStyle(
                      color: AdminTimetableManagementScreen._text,
                      fontSize: 18,
                    ),
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'Bell schedule',
                      onPressed: () =>
                          context.push(AppRoutes.adminTimetableSettings),
                      icon: const Icon(
                        Icons.tune,
                        color: AdminTimetableManagementScreen._accent,
                      ),
                    ),
                  ],
                ),
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 72,
                      color: AdminTimetableManagementScreen._accent.withValues(
                        alpha: 0.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Create your first class',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AdminTimetableManagementScreen._text,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Add a program, year, and section before filling periods. '
                      'Bell times and working days are controlled in Timetable settings.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AdminTimetableManagementScreen._text.withValues(
                          alpha: 0.75,
                        ),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    FilledButton.icon(
                      onPressed: _openCreateClassSheet,
                      style: FilledButton.styleFrom(
                        backgroundColor: AdminTimetableManagementScreen._accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text(
                        'Create class',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () =>
                          context.push(AppRoutes.adminTimetableSettings),
                      icon: Icon(
                        Icons.tune,
                        color: AdminTimetableManagementScreen._accent,
                      ),
                      label: Text(
                        'Timetable settings',
                        style: TextStyle(
                          color: AdminTimetableManagementScreen._accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final section = tt.classSections.contains(tt.selectedClassSection)
        ? tt.selectedClassSection
        : tt.classSections.first;
    final grid = tt.gridFor(section);

    return Theme(
      data: Theme.of(
        context,
      ).copyWith(scaffoldBackgroundColor: AdminTimetableManagementScreen._bg),
      child: Scaffold(
        backgroundColor: AdminTimetableManagementScreen._bg,
        appBar: hideBar
            ? null
            : AppBar(
                backgroundColor: AdminTimetableManagementScreen._panel,
                elevation: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Timetable — day view',
                      style: TextStyle(
                        color: AdminTimetableManagementScreen._text,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Class ${tt.labelForSection(section)}',
                      style: const TextStyle(
                        color: AdminTimetableManagementScreen._accent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                actions: [
                  if (_dirty)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AdminTimetableManagementScreen._accent
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AdminTimetableManagementScreen._accent
                                  .withValues(alpha: 0.45),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 16,
                                color: AdminTimetableManagementScreen._accent,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Unsaved',
                                style: TextStyle(
                                  color: AdminTimetableManagementScreen._accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  IconButton(
                    tooltip: 'Bell schedule',
                    onPressed: () =>
                        context.push(AppRoutes.adminTimetableSettings),
                    icon: const Icon(
                      Icons.tune,
                      color: AdminTimetableManagementScreen._accent,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Week grid',
                    onPressed: () => context.go(AppRoutes.adminTimetableView),
                    icon: const Icon(
                      Icons.grid_view,
                      color: AdminTimetableManagementScreen._accent,
                    ),
                  ),
                  TextButton(
                    onPressed: _saveMock,
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: AdminTimetableManagementScreen._accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
        body: Column(
          children: [
            if (hideBar)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  8,
                  MediaQuery.paddingOf(context).top + 4,
                  8,
                  0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AdminTimetableManagementScreen._accent,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Class ${tt.labelForSection(section)}',
                        style: const TextStyle(
                          color: AdminTimetableManagementScreen._text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Settings',
                      onPressed: () =>
                          context.push(AppRoutes.adminTimetableSettings),
                      icon: const Icon(
                        Icons.tune,
                        color: AdminTimetableManagementScreen._accent,
                      ),
                    ),
                    TextButton(
                      onPressed: _saveMock,
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: AdminTimetableManagementScreen._accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.class_outlined,
                    color: AdminTimetableManagementScreen._accent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Class',
                    style: TextStyle(
                      color: AdminTimetableManagementScreen._text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: section,
                        isExpanded: true,
                        dropdownColor: AdminTimetableManagementScreen._panel,
                        style: const TextStyle(
                          color: AdminTimetableManagementScreen._text,
                        ),
                        items: tt.classSections
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(tt.labelForSection(c)),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          ref
                              .read(timetableNotifierProvider.notifier)
                              .selectClass(v);
                          _gridAnim.forward(from: 0);
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Add class',
                    onPressed: _openCreateClassSheet,
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: AdminTimetableManagementScreen._accent,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        context.push(AppRoutes.adminTimetableSettings),
                    icon: const Icon(Icons.schedule, size: 18),
                    label: const Text('Bells'),
                    style: TextButton.styleFrom(
                      foregroundColor: AdminTimetableManagementScreen._accent,
                    ),
                  ),
                ],
              ),
            ),
            if (!_dismissedSettingsHint)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Material(
                  color: AdminTimetableManagementScreen._panel,
                  borderRadius: BorderRadius.circular(12),
                  child: ListTile(
                    leading: Icon(
                      Icons.lightbulb_outline,
                      color: AdminTimetableManagementScreen._accent,
                    ),
                    title: Text(
                      'Period times follow Timetable settings.',
                      style: TextStyle(
                        color: AdminTimetableManagementScreen._text,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      'Tap the chip below to open the bell lab.',
                      style: TextStyle(
                        color: AdminTimetableManagementScreen._text.withValues(
                          alpha: 0.7,
                        ),
                        fontSize: 12,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AdminTimetableManagementScreen._text.withValues(
                          alpha: 0.65,
                        ),
                      ),
                      onPressed: () =>
                          setState(() => _dismissedSettingsHint = true),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.push(AppRoutes.adminTimetableSettings),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AdminTimetableManagementScreen._panel,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AdminTimetableManagementScreen._accent.withValues(
                        alpha: 0.35,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: AdminTimetableManagementScreen._accent,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Timetable settings',
                              style: TextStyle(
                                color: AdminTimetableManagementScreen._text,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              _settingsChipSummary(tt),
                              style: TextStyle(
                                color: AdminTimetableManagementScreen._text
                                    .withValues(alpha: 0.72),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: AdminTimetableManagementScreen._accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AdminTimetableManagementScreen._accent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _DayStrip(
              dayIndex: _dayIndex,
              workingWeekdays: tt.workingWeekdays,
              onSelect: (i) {
                setState(() => _dayIndex = i);
                _gridAnim.forward(from: 0);
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AdminTimetableManagementScreen._panel,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              color: AdminTimetableManagementScreen._accent,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                TimetableNotifier.dayLabels[_dayIndex],
                                style: const TextStyle(
                                  color: AdminTimetableManagementScreen._text,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: FadeTransition(
                          opacity: CurvedAnimation(
                            parent: _gridAnim,
                            curve: Curves.easeOut,
                          ),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                            itemCount: tt.periods.length,
                            itemBuilder: (ctx, periodIndex) {
                              final writable =
                                  TimetableNotifier.isPeriodWritable(
                                    tt,
                                    _dayIndex,
                                    periodIndex,
                                  );
                              final slot = grid[_dayIndex][periodIndex];
                              if (writable &&
                                  _isLabContinuation(grid, periodIndex)) {
                                return const SizedBox.shrink();
                              }
                              if (!writable) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Material(
                                    color: AdminTimetableManagementScreen._bg
                                        .withValues(alpha: 0.45),
                                    borderRadius: BorderRadius.circular(12),
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.block,
                                        color: AdminTimetableManagementScreen
                                            ._text
                                            .withValues(alpha: 0.35),
                                      ),
                                      title: Text(
                                        'Period ${periodIndex + 1} — not used',
                                        style: TextStyle(
                                          color: AdminTimetableManagementScreen
                                              ._text
                                              .withValues(alpha: 0.45),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Text(
                                        n.periodTimeRange(periodIndex),
                                        style: TextStyle(
                                          color: AdminTimetableManagementScreen
                                              ._text
                                              .withValues(alpha: 0.35),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Dismissible(
                                  key: ValueKey(
                                    '$section-$_dayIndex-$periodIndex-${slot?.subject}',
                                  ),
                                  direction: slot != null
                                      ? DismissDirection.startToEnd
                                      : DismissDirection.none,
                                  confirmDismiss: (_) =>
                                      _confirmDelete(slot, periodIndex),
                                  background: Container(
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 16),
                                    decoration: BoxDecoration(
                                      color: AdminTimetableManagementScreen
                                          ._accent
                                          .withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Remove',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  child: Material(
                                    color: AdminTimetableManagementScreen._bg,
                                    borderRadius: BorderRadius.circular(12),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () =>
                                          _openPeriodEditor(periodIndex),
                                      child: ListTile(
                                        leading: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.access_time,
                                              color:
                                                  AdminTimetableManagementScreen
                                                      ._accent,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${periodIndex + 1}',
                                              style: const TextStyle(
                                                color:
                                                    AdminTimetableManagementScreen
                                                        ._text,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        title: Text(
                                          slot == null
                                              ? 'Tap to assign'
                                              : slot.isLab
                                              ? '${slot.subject} (Lab x${slot.labSpan})\n${slot.facultyName}'
                                              : '${slot.subject}\n${slot.facultyName}',
                                          style: const TextStyle(
                                            color:
                                                AdminTimetableManagementScreen
                                                    ._text,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        subtitle: Text(
                                          n.periodTimeRange(periodIndex),
                                          style: const TextStyle(
                                            color:
                                                AdminTimetableManagementScreen
                                                    ._accent,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        trailing: Icon(
                                          slot != null ? Icons.edit : Icons.add,
                                          color: AdminTimetableManagementScreen
                                              ._accent,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isLabContinuation(List<List<TimetableSlotEntry?>> grid, int period) {
    for (var k = 1; k <= period; k++) {
      final prev = grid[_dayIndex][period - k];
      if (prev != null && prev.isLab && prev.labSpan > k) {
        return true;
      }
    }
    return false;
  }
}

class _DayStrip extends StatelessWidget {
  const _DayStrip({
    required this.dayIndex,
    required this.workingWeekdays,
    required this.onSelect,
  });

  final int dayIndex;
  final List<bool> workingWeekdays;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AdminTimetableManagementScreen._panel,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 8, 8, 4),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: AdminTimetableManagementScreen._accent,
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Select day',
                    style: TextStyle(
                      color: AdminTimetableManagementScreen._text,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final narrow = c.maxWidth < 520;
                  final w = narrow ? 72.0 : 84.0;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    itemCount: TimetableNotifier.dayLabels.length,
                    itemBuilder: (_, i) {
                      final day = TimetableNotifier.dayLabels[i];
                      final sel = dayIndex == i;
                      final on =
                          i < workingWeekdays.length && workingWeekdays[i];
                      return Opacity(
                        opacity: on ? 1 : 0.45,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 280),
                            width: w,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => onSelect(i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 280),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: sel
                                        ? AdminTimetableManagementScreen._accent
                                        : AdminTimetableManagementScreen._bg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: sel
                                          ? AdminTimetableManagementScreen
                                                ._accent
                                          : AdminTimetableManagementScreen
                                                ._accent
                                                .withValues(alpha: 0.35),
                                      width: sel ? 2 : 1,
                                    ),
                                    boxShadow: sel
                                        ? [
                                            BoxShadow(
                                              color:
                                                  AdminTimetableManagementScreen
                                                      ._accent
                                                      .withValues(alpha: 0.35),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      narrow ? day.substring(0, 3) : day,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: sel
                                            ? Colors.white
                                            : AdminTimetableManagementScreen
                                                  ._text,
                                        fontSize: narrow ? 12 : 13,
                                        fontWeight: sel
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
