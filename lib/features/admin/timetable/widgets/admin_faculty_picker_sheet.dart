import 'package:flutter/material.dart';

/// One faculty row for the admin picker (mock staff + demo teachers).
class FacultyPickerRow {
  const FacultyPickerRow({
    required this.id,
    required this.name,
    required this.department,
  });

  final String id;
  final String name;
  final String department;
}

String _deptKey(String raw) {
  final t = raw.trim();
  return t.isEmpty ? '— Unassigned' : t;
}

Iterable<String> _alphaTokens(String s) sync* {
  for (final m in RegExp(r'[a-zA-Z]{2,}').allMatches(s.toLowerCase())) {
    yield m.group(0)!;
  }
}

/// Heuristic: how well a roster department matches the class program label.
int _deptProgramScore(String department, String? programHint) {
  if (programHint == null || programHint.trim().isEmpty) return 0;
  final d = department.toLowerCase();
  final p = programHint.toLowerCase();
  if (d.isEmpty) return 0;
  if (p.contains(d)) return 4;
  final parts = d.split(RegExp(r'[\s/&,]+'));
  for (final w in parts) {
    if (w.length > 2 && p.contains(w)) return 3;
  }
  for (final t in _alphaTokens(programHint)) {
    if (t.length > 2 && d.contains(t)) return 2;
  }
  return 0;
}

/// Picks the department block to surface first (program match, else largest pool).
String _inferPrimaryDepartment(
  List<FacultyPickerRow> rows,
  String? programHint,
) {
  final counts = <String, int>{};
  for (final r in rows) {
    final k = _deptKey(r.department);
    counts[k] = (counts[k] ?? 0) + 1;
  }
  if (counts.isEmpty) return '';

  var best = counts.keys.first;
  var bestScore = -1;
  var bestCount = -1;
  for (final e in counts.entries) {
    final sc = _deptProgramScore(e.key, programHint);
    if (sc > bestScore || (sc == bestScore && e.value > bestCount)) {
      bestScore = sc;
      bestCount = e.value;
      best = e.key;
    }
  }
  if (bestScore == 0) {
    best = counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
  return best;
}

Map<String, List<FacultyPickerRow>> _groupByDepartment(
  List<FacultyPickerRow> rows,
) {
  final m = <String, List<FacultyPickerRow>>{};
  for (final r in rows) {
    m.putIfAbsent(_deptKey(r.department), () => []).add(r);
  }
  for (final e in m.entries) {
    e.value.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
  }
  return m;
}

Future<void> showAdminFacultyPickerSheet(
  BuildContext context, {
  required List<FacultyPickerRow> rows,
  required String dayPeriodLine,
  required bool Function(String facultyId) isEngaged,
  required void Function(String id, String name) onSelect,
  required void Function(String id, String name) onShowSchedule,
  required Color panelColor,
  required Color textColor,
  required Color accentColor,
  required Color engageColor,
  String? classProgramHint,
  String? classDisplayLabel,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _FacultyPickerBody(
      rows: rows,
      dayPeriodLine: dayPeriodLine,
      isEngaged: isEngaged,
      onSelect: onSelect,
      onShowSchedule: onShowSchedule,
      panelColor: panelColor,
      textColor: textColor,
      accentColor: accentColor,
      engageColor: engageColor,
      classProgramHint: classProgramHint,
      classDisplayLabel: classDisplayLabel,
    ),
  );
}

class _FacultyPickerBody extends StatefulWidget {
  const _FacultyPickerBody({
    required this.rows,
    required this.dayPeriodLine,
    required this.isEngaged,
    required this.onSelect,
    required this.onShowSchedule,
    required this.panelColor,
    required this.textColor,
    required this.accentColor,
    required this.engageColor,
    this.classProgramHint,
    this.classDisplayLabel,
  });

  final List<FacultyPickerRow> rows;
  final String dayPeriodLine;
  final bool Function(String facultyId) isEngaged;
  final void Function(String id, String name) onSelect;
  final void Function(String id, String name) onShowSchedule;
  final Color panelColor;
  final Color textColor;
  final Color accentColor;
  final Color engageColor;
  final String? classProgramHint;
  final String? classDisplayLabel;

  @override
  State<_FacultyPickerBody> createState() => _FacultyPickerBodyState();
}

class _FacultyPickerBodyState extends State<_FacultyPickerBody> {
  final _searchCtrl = TextEditingController();
  final _scrollController = ScrollController();
  final _letterKeys = <String, GlobalKey>{};
  bool _sortByName = true;
  String _query = '';
  String? _primaryDeptOverride;
  String? _expandedOtherDept;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String get _inferredPrimary =>
      _inferPrimaryDepartment(widget.rows, widget.classProgramHint);

  String get _effectivePrimary => _primaryDeptOverride ?? _inferredPrimary;

  List<FacultyPickerRow> _filteredSorted() {
    var list = List<FacultyPickerRow>.from(widget.rows);
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((r) {
        return r.name.toLowerCase().contains(q) ||
            r.department.toLowerCase().contains(q);
      }).toList();
    }
    list.sort((a, b) {
      if (_sortByName) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      return a.department.toLowerCase().compareTo(b.department.toLowerCase());
    });
    return list;
  }

  Map<String, List<FacultyPickerRow>> _groupByLetter(
    List<FacultyPickerRow> list,
  ) {
    final map = <String, List<FacultyPickerRow>>{};
    for (final r in list) {
      if (r.name.isEmpty) continue;
      final L = r.name[0].toUpperCase();
      map.putIfAbsent(L, () => []).add(r);
    }
    final keys = map.keys.toList()..sort();
    return {for (final k in keys) k: map[k]!};
  }

  void _scrollToLetter(String letter) {
    final key = _letterKeys[letter];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _pickRow(BuildContext context, FacultyPickerRow r) async {
    final engaged = widget.isEngaged(r.id);
    if (engaged) {
      final go = await showDialog<bool>(
        context: context,
        useRootNavigator: true,
        builder: (dCtx) => AlertDialog(
          backgroundColor: widget.panelColor,
          title: Text(
            'Already teaching elsewhere',
            style: TextStyle(color: widget.textColor),
          ),
          content: Text(
            '${r.name} is already teaching another section '
            'this period. Assign here anyway?',
            style: TextStyle(color: widget.textColor.withValues(alpha: 0.9)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dCtx, false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: widget.textColor.withValues(alpha: 0.8),
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dCtx, true),
              style: FilledButton.styleFrom(
                backgroundColor: widget.engageColor,
              ),
              child: const Text('Assign anyway'),
            ),
          ],
        ),
      );
      if (go != true || !context.mounted) return;
    }
    widget.onSelect(r.id, r.name);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredSorted();
    final grouped = _groupByLetter(filtered);
    final letters = grouped.keys.toList();
    final h = MediaQuery.sizeOf(context).height * 0.72;
    final searching = _query.trim().isNotEmpty;

    for (final L in letters) {
      _letterKeys.putIfAbsent(L, GlobalKey.new);
    }

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: widget.panelColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: SizedBox(
            height: h,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        color: widget.accentColor,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select staff',
                              style: TextStyle(
                                color: widget.textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            if (widget.classDisplayLabel != null &&
                                widget.classDisplayLabel!.trim().isNotEmpty)
                              Text(
                                widget.classDisplayLabel!.trim(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: widget.textColor.withValues(
                                    alpha: 0.62,
                                  ),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: widget.textColor.withValues(alpha: 0.8),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: widget.accentColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: widget.accentColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.dayPeriodLine,
                            style: TextStyle(
                              color: widget.accentColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() {
                      _query = v;
                      if (v.trim().isNotEmpty) _expandedOtherDept = null;
                    }),
                    style: TextStyle(color: widget.textColor),
                    decoration: InputDecoration(
                      hintText: searching
                          ? 'Searching everyone…'
                          : 'Search any name or department…',
                      hintStyle: TextStyle(
                        color: widget.textColor.withValues(alpha: 0.55),
                      ),
                      prefixIcon: Icon(Icons.search, color: widget.accentColor),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: widget.accentColor,
                              ),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                            ),
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: widget.accentColor.withValues(alpha: 0.35),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: widget.accentColor.withValues(alpha: 0.35),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: widget.accentColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SortToggle(
                    sortByName: _sortByName,
                    accent: widget.accentColor,
                    text: widget.textColor,
                    onChanged: (v) => setState(() => _sortByName = v),
                  ),
                ),
                if (!searching) ...[
                  const SizedBox(height: 8),
                  _DepartmentQuickStrip(
                    byDept: _groupByDepartment(widget.rows),
                    inferred: _inferredPrimary,
                    selected: _effectivePrimary,
                    accent: widget.accentColor,
                    text: widget.textColor,
                    onCommit: (d, v) => setState(() {
                      if (!v) {
                        _primaryDeptOverride = null;
                      } else {
                        _primaryDeptOverride = d == _inferredPrimary ? null : d;
                      }
                      _expandedOtherDept = null;
                    }),
                  ),
                ],
                const SizedBox(height: 6),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          child: ListView(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(12, 0, 4, 16),
                            children: searching
                                ? _buildSearchSlivers(
                                    context,
                                    filtered,
                                    grouped,
                                    letters,
                                  )
                                : _buildBrowseSlivers(context),
                          ),
                        ),
                      ),
                      if (searching && MediaQuery.sizeOf(context).width > 560)
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 6,
                            top: 8,
                            bottom: 8,
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                children: [
                                  for (final c in letters)
                                    InkWell(
                                      onTap: () => _scrollToLetter(c),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 3,
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          c,
                                          style: TextStyle(
                                            color: widget.accentColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSearchSlivers(
    BuildContext context,
    List<FacultyPickerRow> filtered,
    Map<String, List<FacultyPickerRow>> grouped,
    List<String> letters,
  ) {
    if (filtered.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No matches',
            textAlign: TextAlign.center,
            style: TextStyle(color: widget.textColor.withValues(alpha: 0.7)),
          ),
        ),
      ];
    }
    final out = <Widget>[];
    for (final letter in letters) {
      out.add(
        Padding(
          key: _letterKeys[letter],
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
          child: Text(
            letter,
            style: TextStyle(
              color: widget.accentColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
      for (final r in grouped[letter]!) {
        out.add(
          _FacultyPickerTile(
            row: r,
            engaged: widget.isEngaged(r.id),
            textColor: widget.textColor,
            accentColor: widget.accentColor,
            engageColor: widget.engageColor,
            onPick: () => _pickRow(context, r),
            onShowSchedule: () => widget.onShowSchedule(r.id, r.name),
          ),
        );
      }
    }
    return out;
  }

  List<Widget> _buildBrowseSlivers(BuildContext context) {
    final byDept = _groupByDepartment(widget.rows);
    final primary = _effectivePrimary;
    final primaryRows = byDept[primary] ?? const <FacultyPickerRow>[];
    final otherKeys = byDept.keys.where((k) => k != primary).toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final hint = widget.classProgramHint?.trim();
    final autoPinned =
        _primaryDeptOverride == null &&
        hint != null &&
        hint.isNotEmpty &&
        _deptProgramScore(primary, hint) > 0;

    final out = <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
        child: Row(
          children: [
            Icon(Icons.push_pin_outlined, size: 16, color: widget.accentColor),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Primary roster · $primary',
                style: TextStyle(
                  color: widget.textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
            ),
            if (autoPinned)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.accentColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  'Smart',
                  style: TextStyle(
                    color: widget.accentColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
      ),
      Text(
        'Tap a chip above to jump departments. Other pools stay folded.',
        style: TextStyle(
          color: widget.textColor.withValues(alpha: 0.55),
          fontSize: 11.5,
          height: 1.3,
        ),
      ),
      const SizedBox(height: 8),
      if (primaryRows.isEmpty)
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No staff in this department.',
            style: TextStyle(color: widget.textColor.withValues(alpha: 0.65)),
          ),
        )
      else
        for (final r in primaryRows)
          _FacultyPickerTile(
            row: r,
            engaged: widget.isEngaged(r.id),
            textColor: widget.textColor,
            accentColor: widget.accentColor,
            engageColor: widget.engageColor,
            onPick: () => _pickRow(context, r),
            onShowSchedule: () => widget.onShowSchedule(r.id, r.name),
          ),
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
        child: Row(
          children: [
            Expanded(
              child: Divider(color: widget.textColor.withValues(alpha: 0.18)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'OTHER DEPARTMENTS (${otherKeys.length})',
                style: TextStyle(
                  color: widget.textColor.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w800,
                  fontSize: 10.5,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: widget.textColor.withValues(alpha: 0.18)),
            ),
          ],
        ),
      ),
    ];

    for (final dept in otherKeys) {
      final rows = byDept[dept]!;
      final open = _expandedOtherDept == dept;
      out.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() {
                _expandedOtherDept = open ? null : dept;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: open
                        ? widget.accentColor.withValues(alpha: 0.45)
                        : widget.accentColor.withValues(alpha: 0.15),
                    width: open ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      open
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: widget.accentColor,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        dept,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: widget.textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${rows.length}',
                        style: TextStyle(
                          color: widget.accentColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
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
      if (open) {
        out.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 4, bottom: 8),
            child: Container(
              padding: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: widget.accentColor.withValues(alpha: 0.35),
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                children: [
                  for (final r in rows)
                    _FacultyPickerTile(
                      row: r,
                      engaged: widget.isEngaged(r.id),
                      textColor: widget.textColor,
                      accentColor: widget.accentColor,
                      engageColor: widget.engageColor,
                      onPick: () => _pickRow(context, r),
                      onShowSchedule: () => widget.onShowSchedule(r.id, r.name),
                    ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return out;
  }
}

/// Horizontal department chips — scales to many departments via scroll.
class _DepartmentQuickStrip extends StatelessWidget {
  const _DepartmentQuickStrip({
    required this.byDept,
    required this.inferred,
    required this.selected,
    required this.accent,
    required this.text,
    required this.onCommit,
  });

  final Map<String, List<FacultyPickerRow>> byDept;
  final String inferred;
  final String selected;
  final Color accent;
  final Color text;
  final void Function(String department, bool selected) onCommit;

  @override
  Widget build(BuildContext context) {
    final keys = byDept.keys.toList()
      ..sort((a, b) {
        final ai = a == inferred ? 0 : 1;
        final bi = b == inferred ? 0 : 1;
        if (ai != bi) return ai.compareTo(bi);
        return a.toLowerCase().compareTo(b.toLowerCase());
      });

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: keys.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final d = keys[i];
          final n = byDept[d]?.length ?? 0;
          final isSel = d == selected;
          final isInf = d == inferred;
          return FilterChip(
            selected: isSel,
            showCheckmark: false,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isInf)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(Icons.auto_awesome, size: 14, color: accent),
                  ),
                Flexible(
                  child: Text(
                    d,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: isSel ? text : text.withValues(alpha: 0.82),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '$n',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    color: isSel ? accent : text.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            selectedColor: accent.withValues(alpha: 0.28),
            backgroundColor: Colors.black.withValues(alpha: 0.14),
            side: BorderSide(
              color: isSel ? accent : text.withValues(alpha: 0.12),
            ),
            onSelected: (v) => onCommit(d, v),
          );
        },
      ),
    );
  }
}

class _FacultyPickerTile extends StatelessWidget {
  const _FacultyPickerTile({
    required this.row,
    required this.engaged,
    required this.textColor,
    required this.accentColor,
    required this.engageColor,
    required this.onPick,
    required this.onShowSchedule,
  });

  final FacultyPickerRow row;
  final bool engaged;
  final Color textColor;
  final Color accentColor;
  final Color engageColor;
  final Future<void> Function() onPick;
  final VoidCallback onShowSchedule;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPick,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: engaged
                    ? engageColor.withValues(alpha: 0.55)
                    : accentColor.withValues(alpha: 0.22),
                width: engaged ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      backgroundColor: engaged
                          ? engageColor.withValues(alpha: 0.2)
                          : accentColor.withValues(alpha: 0.2),
                      child: Text(
                        row.name.isNotEmpty ? row.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: engaged ? engageColor : accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (engaged)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.schedule,
                            size: 12,
                            color: engageColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              row.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: engaged ? engageColor : textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (engaged) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: engageColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: engageColor.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                'Engaged',
                                style: TextStyle(
                                  color: engageColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        row.department,
                        style: TextStyle(
                          color: engaged
                              ? engageColor.withValues(alpha: 0.85)
                              : accentColor,
                          fontSize: 13,
                        ),
                      ),
                      if (engaged)
                        Text(
                          'Teaching another section this period',
                          style: TextStyle(
                            color: engageColor.withValues(alpha: 0.85),
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onShowSchedule,
                  style: TextButton.styleFrom(
                    foregroundColor: engaged ? engageColor : accentColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text(
                    'Schedule',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: textColor.withValues(alpha: 0.45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SortToggle extends StatelessWidget {
  const _SortToggle({
    required this.sortByName,
    required this.accent,
    required this.text,
    required this.onChanged,
  });

  final bool sortByName;
  final Color accent;
  final Color text;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (d) {
        if (d.delta.dx > 4) onChanged(true);
        if (d.delta.dx < -4) onChanged(false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                alignment: sortByName
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onChanged(true),
                        child: Center(
                          child: Text(
                            'Name',
                            style: TextStyle(
                              color: sortByName
                                  ? Colors.white
                                  : text.withValues(alpha: 0.65),
                              fontWeight: sortByName
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onChanged(false),
                        child: Center(
                          child: Text(
                            'Department',
                            style: TextStyle(
                              color: !sortByName
                                  ? Colors.white
                                  : text.withValues(alpha: 0.65),
                              fontWeight: !sortByName
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
