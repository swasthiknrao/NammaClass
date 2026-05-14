import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../domain/entities/class_section_meta.dart';

/// Result of creating a class section in the admin timetable flow.
class ClassCreateSheetResult {
  const ClassCreateSheetResult({required this.sectionId, required this.meta});

  final String sectionId;
  final ClassSectionMeta meta;
}

String _yearInputToRoman(String raw) {
  const romanNumerals = <int, String>{
    1: 'I',
    2: 'II',
    3: 'III',
    4: 'IV',
    5: 'V',
    6: 'VI',
    7: 'VII',
    8: 'VIII',
    9: 'IX',
    10: 'X',
  };
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';
  final upper = trimmed.toUpperCase();
  if (RegExp(r'^[IVXLCDM]+$').hasMatch(upper)) return upper;
  final clean = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
  final n = int.tryParse(clean);
  if (n != null && n > 0 && n <= 10) {
    return romanNumerals[n] ?? trimmed;
  }
  return trimmed;
}

/// Curated catalogue — scroll + search in sheet; admins can still type custom.
const List<String> kDepartmentCatalog = [
  'Accountancy',
  'Arts & Humanities',
  'Biology',
  'Business Studies',
  'Chemistry',
  'Commerce',
  'Computer Applications',
  'Computer Science',
  'Economics',
  'Electronics',
  'English',
  'Environmental Science',
  'Fine Arts',
  'French',
  'General Science',
  'Hindi',
  'History',
  'Home Science',
  'Kannada',
  'Mathematics',
  'Music',
  'Physical Education',
  'Physics',
  'Political Science',
  'Psychology',
  'Social Science',
  'Science',
  'Sanskrit',
  'Statistics',
  'Tamil',
  'Telugu',
];

Future<String?> _pickDepartmentFromCatalog(
  BuildContext context, {
  required String current,
  required Color panel,
  required Color text,
  required Color accent,
}) {
  return showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _DepartmentCatalogSheet(
      current: current,
      panel: panel,
      text: text,
      accent: accent,
    ),
  );
}

class _DepartmentCatalogSheet extends StatefulWidget {
  const _DepartmentCatalogSheet({
    required this.current,
    required this.panel,
    required this.text,
    required this.accent,
  });

  final String current;
  final Color panel;
  final Color text;
  final Color accent;

  @override
  State<_DepartmentCatalogSheet> createState() =>
      _DepartmentCatalogSheetState();
}

class _DepartmentCatalogSheetState extends State<_DepartmentCatalogSheet> {
  final _searchCtrl = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final h = MediaQuery.sizeOf(context).height * 0.62;
    final filtered = kDepartmentCatalog
        .where((d) => d.toLowerCase().contains(_q.trim().toLowerCase()))
        .toList();

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: widget.panel,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: SizedBox(
            height: h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: widget.text.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 8, 8),
                  child: Row(
                    children: [
                      Icon(Icons.apartment_rounded, color: widget.accent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Departments',
                          style: TextStyle(
                            color: widget.text,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, ''),
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            color: widget.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          color: widget.text.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _q = v),
                    style: TextStyle(color: widget.text),
                    decoration: InputDecoration(
                      hintText: 'Search departments…',
                      hintStyle: TextStyle(
                        color: widget.text.withValues(alpha: 0.45),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: widget.accent,
                      ),
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: widget.accent.withValues(alpha: 0.25),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: widget.accent, width: 2),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final d = filtered[i];
                      final sel =
                          widget.current.trim().toLowerCase() ==
                          d.toLowerCase();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.pop(context, d),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(
                                  alpha: sel ? 0.22 : 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: sel
                                      ? widget.accent.withValues(alpha: 0.55)
                                      : widget.accent.withValues(alpha: 0.12),
                                  width: sel ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      d,
                                      style: TextStyle(
                                        color: widget.text,
                                        fontWeight: sel
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  if (sel)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: widget.accent,
                                      size: 20,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact bottom sheet: program, optional department (chips + catalogue),
/// year & section in one row, then create.
Future<ClassCreateSheetResult?> showAdminClassCreateSheet(
  BuildContext context, {
  required Set<String> existingSectionIds,
}) {
  return showModalBottomSheet<ClassCreateSheetResult>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) =>
        _ClassCreateSheetBody(existingSectionIds: existingSectionIds),
  );
}

class _ClassCreateSheetBody extends StatefulWidget {
  const _ClassCreateSheetBody({required this.existingSectionIds});

  final Set<String> existingSectionIds;

  @override
  State<_ClassCreateSheetBody> createState() => _ClassCreateSheetBodyState();
}

class _ClassCreateSheetBodyState extends State<_ClassCreateSheetBody> {
  final _programCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _sectionCtrl = TextEditingController();
  final _deptCustomCtrl = TextEditingController();
  String? _error;
  String _deptChosen = '';

  static const _panel = Color(0xFF22272A);
  static const _panelLift = Color(0xFF2A3034);
  static const _text = Color(0xFF9FA0A2);
  static const _accent = Color(0xFF99371E);

  static const _quickDept = [
    'Science',
    'Commerce',
    'Computer Science',
    'Mathematics',
    'English',
    'Arts & Humanities',
  ];

  @override
  void dispose() {
    _programCtrl.dispose();
    _yearCtrl.dispose();
    _sectionCtrl.dispose();
    _deptCustomCtrl.dispose();
    super.dispose();
  }

  String get _effectiveDepartment {
    final c = _deptCustomCtrl.text.trim();
    if (c.isNotEmpty) return c;
    return _deptChosen.trim();
  }

  Future<void> _openCatalog(BuildContext context) async {
    final picked = await _pickDepartmentFromCatalog(
      context,
      current: _effectiveDepartment,
      panel: _panel,
      text: _text,
      accent: _accent,
    );
    if (!mounted || picked == null) return;
    setState(() {
      if (picked.isEmpty) {
        _deptChosen = '';
        _deptCustomCtrl.clear();
      } else {
        _deptChosen = picked;
        _deptCustomCtrl.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.58;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 440, maxHeight: maxH),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            border: Border.all(color: _accent.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 22,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _accent,
                      Color.lerp(_accent, const Color(0xFF2A1510), 0.38)!,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 10, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Create class',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Department is optional — it powers smarter staff suggestions.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: 11.5,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SheetField(
                        controller: _programCtrl,
                        label: 'Program / stream',
                        hint: 'e.g. BCA, Class 8',
                        accent: _accent,
                        icon: Icons.auto_stories_outlined,
                        dense: true,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Department (optional)',
                        style: TextStyle(
                          color: _text.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _quickDept.length + 1,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            if (i == _quickDept.length) {
                              return ActionChip(
                                avatar: Icon(
                                  Icons.grid_view_rounded,
                                  size: 16,
                                  color: _accent,
                                ),
                                label: Text(
                                  'Browse all (${kDepartmentCatalog.length})',
                                  style: TextStyle(
                                    color: _text,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: Colors.black.withValues(
                                  alpha: 0.2,
                                ),
                                side: BorderSide(
                                  color: _accent.withValues(alpha: 0.4),
                                ),
                                onPressed: () => _openCatalog(context),
                              );
                            }
                            final d = _quickDept[i];
                            final on =
                                _effectiveDepartment.toLowerCase() ==
                                d.toLowerCase();
                            return FilterChip(
                              selected: on,
                              showCheckmark: false,
                              label: Text(
                                d,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: on
                                      ? _text
                                      : _text.withValues(alpha: 0.8),
                                ),
                              ),
                              selectedColor: _accent.withValues(alpha: 0.28),
                              backgroundColor: Colors.black.withValues(
                                alpha: 0.14,
                              ),
                              side: BorderSide(
                                color: on
                                    ? _accent
                                    : _text.withValues(alpha: 0.12),
                              ),
                              onSelected: (v) => setState(() {
                                if (!v) {
                                  _deptChosen = '';
                                  return;
                                }
                                _deptChosen = d;
                                _deptCustomCtrl.clear();
                              }),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _deptCustomCtrl,
                        onChanged: (_) => setState(() {
                          if (_deptCustomCtrl.text.trim().isNotEmpty) {
                            _deptChosen = '';
                          }
                        }),
                        style: const TextStyle(
                          color: Color(0xFF1B1B1B),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Custom department',
                          hintText: 'Type if not in list above',
                          labelStyle: TextStyle(
                            color: _accent.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                          prefixIcon: Icon(
                            Icons.edit_outlined,
                            color: _accent.withValues(alpha: 0.8),
                            size: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _accent.withValues(alpha: 0.22),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _accent, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                      if (_effectiveDepartment.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _panelLift,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _accent.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.label_outline_rounded,
                                  size: 16,
                                  color: _accent,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _effectiveDepartment,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: _text,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _SheetField(
                              controller: _yearCtrl,
                              label: 'Year',
                              hint: '8 or VIII',
                              accent: _accent,
                              icon: Icons.format_list_numbered_rtl,
                              dense: true,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9IVivxlcdmCDM\s]'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SheetField(
                              controller: _sectionCtrl,
                              label: 'Section',
                              hint: 'A',
                              accent: _accent,
                              icon: Icons.view_module_outlined,
                              dense: true,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[A-Za-z]'),
                                ),
                                LengthLimitingTextInputFormatter(3),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: const TextStyle(
                            color: Color(0xFFFF8A65),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.22),
                  border: Border(
                    top: BorderSide(color: _accent.withValues(alpha: 0.15)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _text,
                          side: BorderSide(
                            color: _text.withValues(alpha: 0.35),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: () {
                          final yearRoman = _yearInputToRoman(_yearCtrl.text);
                          final sec = _sectionCtrl.text.trim().toUpperCase();
                          if (yearRoman.isEmpty || sec.isEmpty) {
                            setState(() => _error = 'Enter year and section.');
                            return;
                          }
                          final sectionId = '$yearRoman-$sec';
                          if (widget.existingSectionIds.contains(sectionId)) {
                            setState(
                              () => _error = 'Class $sectionId already exists.',
                            );
                            return;
                          }
                          final meta = ClassSectionMeta(
                            programName: _programCtrl.text.trim(),
                            yearLabel: yearRoman,
                            sectionLetter: sec,
                            departmentName: _effectiveDepartment,
                          );
                          HapticFeedback.selectionClick();
                          Navigator.pop(
                            context,
                            ClassCreateSheetResult(
                              sectionId: sectionId,
                              meta: meta,
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Create & select',
                          style: TextStyle(fontWeight: FontWeight.bold),
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
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.accent,
    required this.icon,
    this.inputFormatters,
    this.dense = false,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final Color accent;
  final IconData icon;
  final List<TextInputFormatter>? inputFormatters;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Color(0xFF1B1B1B), fontSize: 15),
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        isDense: dense,
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: accent.withValues(alpha: 0.95),
          fontSize: dense ? 12 : 13,
        ),
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        prefixIcon: Icon(icon, color: accent.withValues(alpha: 0.85), size: 22),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent.withValues(alpha: 0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: dense ? 10 : 14,
        ),
      ),
    );
  }
}
