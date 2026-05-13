import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/widgets/shell_layout_scope.dart';
import '../../../../routing/app_routes.dart';
import '../../providers/staff_notifier.dart';

Color _facultyPageBg(BuildContext c) => Theme.of(c).colorScheme.surface;

Color _facultyCard(BuildContext c) =>
    Theme.of(c).colorScheme.surfaceContainerHighest;

Color _facultyBodyText(BuildContext c) =>
    Theme.of(c).colorScheme.onSurfaceVariant;

Color _facultyAccent(BuildContext c) => Theme.of(c).colorScheme.secondary;

Color _facultyOnAccent(BuildContext c) => Theme.of(c).colorScheme.onSecondary;

/// ERP-style faculty hub: department rail, search, role filter, edit/move/delete
/// on [MockStaffMember] via [staffNotifierProvider] — no Firebase.
class AdminFacultyListScreen extends ConsumerStatefulWidget {
  const AdminFacultyListScreen({super.key});

  @override
  ConsumerState<AdminFacultyListScreen> createState() =>
      _AdminFacultyListScreenState();
}

class _AdminFacultyListScreenState extends ConsumerState<AdminFacultyListScreen>
    with SingleTickerProviderStateMixin {
  String? _deptFilter;
  String _search = '';
  String? _roleFilter;
  bool _editMode = false;
  bool _multiSelect = false;
  final Set<String> _selectedIds = {};
  late AnimationController _intro;

  static const Map<String, IconData> _roleIcons = {
    'Teacher': Icons.school_outlined,
    'Dean': Icons.workspace_premium_outlined,
    'HOD': Icons.account_balance_outlined,
    'Professor': Icons.psychology_outlined,
    'Assistant': Icons.person_outline,
    'Admin': Icons.admin_panel_settings_outlined,
  };

  IconData _iconForRole(String role) {
    for (final e in _roleIcons.entries) {
      if (role.toLowerCase().contains(e.key.toLowerCase())) {
        return e.value;
      }
    }
    return Icons.badge_outlined;
  }

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  List<MockStaffMember> _filtered(List<MockStaffMember> staff) {
    return staff.where((m) {
        if (_deptFilter != null && m.department != _deptFilter) return false;
        if (_roleFilter != null && m.role != _roleFilter) return false;
        if (_search.isEmpty) return true;
        final q = _search.toLowerCase();
        return m.name.toLowerCase().contains(q) ||
            m.role.toLowerCase().contains(q) ||
            m.department.toLowerCase().contains(q) ||
            m.phone.contains(q) ||
            (m.email?.toLowerCase().contains(q) ?? false);
      }).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Set<String> _roleOptions(List<MockStaffMember> staff) {
    return {...staff.map((e) => e.role)}..removeWhere((e) => e.isEmpty);
  }

  void _exitEditMode() {
    setState(() {
      _editMode = false;
      _multiSelect = false;
      _selectedIds.clear();
    });
  }

  Future<void> _confirmDeleteMany(StaffNotifier n) async {
    if (_selectedIds.isEmpty) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _facultyCard(context),
        title: Text(
          'Remove faculty',
          style: TextStyle(color: _facultyBodyText(context)),
        ),
        content: Text(
          'Remove ${_selectedIds.length} profile(s) from the demo directory?',
          style: TextStyle(color: _facultyBodyText(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    for (final id in List<String>.from(_selectedIds)) {
      n.remove(id);
    }
    _exitEditMode();
    if (mounted) {
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: cs.inverseSurface,
          content: Text(
            'Selected faculty removed from session',
            style: TextStyle(color: cs.onInverseSurface),
          ),
        ),
      );
    }
  }

  Future<void> _pickMoveTarget(
    StaffNotifier n,
    List<String> departments,
  ) async {
    if (_selectedIds.isEmpty) return;
    final others = List<String>.from(departments);
    if (others.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No target department available')),
      );
      return;
    }
    String target = others.first;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: _facultyCard(context),
          title: Text(
            'Move to department',
            style: TextStyle(color: _facultyBodyText(context)),
          ),
          content: DropdownButtonFormField<String>(
            dropdownColor: _facultyCard(context),
            initialValue: target,
            decoration: InputDecoration(
              labelText: 'Department',
              labelStyle: TextStyle(color: _facultyBodyText(context)),
            ),
            items: others
                .map(
                  (d) => DropdownMenuItem(
                    value: d,
                    child: Text(
                      d,
                      style: TextStyle(color: _facultyBodyText(context)),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setD(() => target = v ?? target),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                n.moveMembersToDepartment(_selectedIds, target);
                Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(
                backgroundColor: _facultyAccent(context),
                foregroundColor: _facultyOnAccent(context),
              ),
              child: const Text('Move'),
            ),
          ],
        ),
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Moved ${_selectedIds.length} to $target')),
      );
    }
    _exitEditMode();
  }

  Future<void> _showAddDepartment(StaffNotifier n) async {
    final c = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _facultyCard(context),
        title: Text(
          'New department',
          style: TextStyle(color: _facultyBodyText(context)),
        ),
        content: TextField(
          controller: c,
          style: TextStyle(color: _facultyBodyText(context)),
          decoration: InputDecoration(
            hintText: 'e.g. Computer Science',
            hintStyle: TextStyle(color: _facultyBodyText(context)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: _facultyAccent(context),
              foregroundColor: _facultyOnAccent(context),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (ok == true && c.text.trim().isNotEmpty) {
      n.addDepartmentBucket(c.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Department “${c.text.trim()}” ready')),
        );
      }
    }
    c.dispose();
  }

  Future<void> _dissolveDepartmentDialog(
    StaffNotifier n,
    String department,
    List<String> allDepts,
  ) async {
    final targets = allDepts.where((d) => d != department).toList();
    if (targets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create another department first')),
      );
      return;
    }
    String target = targets.first;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: _facultyCard(context),
          title: Text(
            'Reassign “$department”',
            style: TextStyle(color: _facultyBodyText(context)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${n.staffCountInDepartment(department)} staff will move.',
                style: TextStyle(color: _facultyBodyText(context)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                dropdownColor: _facultyCard(context),
                initialValue: target,
                decoration: InputDecoration(
                  labelText: 'Move everyone to',
                  labelStyle: TextStyle(color: _facultyBodyText(context)),
                ),
                items: targets
                    .map(
                      (d) => DropdownMenuItem(
                        value: d,
                        child: Text(
                          d,
                          style: TextStyle(color: _facultyBodyText(context)),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setD(() => target = v ?? target),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await n.dissolveDepartment(
                  department: department,
                  targetDepartment: target,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(
                backgroundColor: _facultyAccent(context),
                foregroundColor: _facultyOnAccent(context),
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
    setState(() {
      if (_deptFilter == department) _deptFilter = null;
    });
  }

  void _openQuickEdit(StaffNotifier n, MockStaffMember m) {
    final name = TextEditingController(text: m.name);
    final role = TextEditingController(text: m.role);
    final phone = TextEditingController(text: m.phone);
    final email = TextEditingController(text: m.email ?? '');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _facultyCard(context),
        title: Text(
          'Quick edit',
          style: TextStyle(color: _facultyBodyText(context)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _erpField(ctx, name, 'Name', Icons.person),
              const SizedBox(height: 10),
              _erpField(ctx, role, 'Role', Icons.badge_outlined),
              const SizedBox(height: 10),
              _erpField(ctx, phone, 'Phone', Icons.phone),
              const SizedBox(height: 10),
              _erpField(ctx, email, 'Email', Icons.email),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              n.update(
                m.copyWith(
                  name: name.text.trim().isEmpty ? m.name : name.text.trim(),
                  role: role.text.trim().isEmpty ? m.role : role.text.trim(),
                  phone: phone.text.trim().isEmpty
                      ? m.phone
                      : phone.text.trim(),
                  email: email.text.trim().isEmpty ? null : email.text.trim(),
                  clearEmail: email.text.trim().isEmpty,
                ),
              );
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: _facultyAccent(context),
              foregroundColor: _facultyOnAccent(context),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    ).then((_) {
      name.dispose();
      role.dispose();
      phone.dispose();
      email.dispose();
    });
  }

  Widget _erpField(
    BuildContext fieldContext,
    TextEditingController c,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: c,
      style: TextStyle(color: _facultyBodyText(fieldContext)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _facultyBodyText(fieldContext)),
        prefixIcon: Icon(icon, color: _facultyAccent(fieldContext)),
        filled: true,
        fillColor: _facultyPageBg(fieldContext),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: _facultyAccent(fieldContext).withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }

  void _pushAddFaculty() {
    final dept = _deptFilter;
    if (dept != null && dept.isNotEmpty) {
      context.push(
        '${AppRoutes.adminFacultyAdd}?dept=${Uri.encodeQueryComponent(dept)}',
      );
    } else {
      context.push(AppRoutes.adminFacultyAdd);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hideAppBar =
        ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true;
    final staffAsync = ref.watch(staffNotifierProvider);
    final n = ref.read(staffNotifierProvider.notifier);

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: _facultyPageBg(context),
        appBarTheme: AppBarTheme(
          backgroundColor: _facultyCard(context),
          foregroundColor: _facultyBodyText(context),
          elevation: 0,
        ),
      ),
      child: Scaffold(
        backgroundColor: _facultyPageBg(context),
        appBar: hideAppBar
            ? null
            : AppBar(
                title: const Text('Faculty management'),
                actions: [
                  if (_editMode)
                    TextButton(
                      onPressed: _exitEditMode,
                      child: const Text('Done'),
                    )
                  else
                    IconButton(
                      tooltip: 'Edit mode',
                      icon: const Icon(Icons.tune),
                      onPressed: () => setState(() => _editMode = true),
                    ),
                  IconButton(
                    tooltip: 'Add faculty',
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    onPressed: _pushAddFaculty,
                  ),
                ],
              ),
        body: staffAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: _facultyAccent(context)),
          ),
          error: (e, _) => Center(child: Text('$e')),
          data: (staff) {
            final departments = n.allDepartments();
            final filtered = _filtered(staff);
            final roles = _roleOptions(staff).toList()..sort();

            return FadeTransition(
              opacity: CurvedAnimation(parent: _intro, curve: Curves.easeOut),
              child: Column(
                children: [
                  if (hideAppBar)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        12,
                        MediaQuery.paddingOf(context).top + 8,
                        12,
                        0,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: _facultyAccent(context),
                            ),
                            onPressed: () => context.pop(),
                          ),
                          Expanded(
                            child: Text(
                              'Faculty management',
                              style: TextStyle(
                                color: _facultyBodyText(context),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (_editMode)
                            TextButton(
                              onPressed: _exitEditMode,
                              child: const Text('Done'),
                            ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _DepartmentRail(
                      departments: departments,
                      selected: _deptFilter,
                      onAll: () => setState(() => _deptFilter = null),
                      onPick: (d) => setState(() => _deptFilter = d),
                      onAddDept: () => _showAddDepartment(n),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _facultyCard(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: _facultyAccent(context),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: (v) => setState(() => _search = v),
                              style: TextStyle(
                                color: _facultyBodyText(context),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search name, role, phone…',
                                hintStyle: TextStyle(
                                  color: _facultyBodyText(context),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          if (roles.isNotEmpty)
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String?>(
                                dropdownColor: _facultyCard(context),
                                value: _roleFilter,
                                hint: Text(
                                  'Role',
                                  style: TextStyle(
                                    color: _facultyBodyText(context),
                                    fontSize: 13,
                                  ),
                                ),
                                items: [
                                  DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text(
                                      'All roles',
                                      style: TextStyle(
                                        color: _facultyBodyText(context),
                                      ),
                                    ),
                                  ),
                                  ...roles.map(
                                    (r) => DropdownMenuItem<String>(
                                      value: r,
                                      child: Text(
                                        r,
                                        style: TextStyle(
                                          color: _facultyBodyText(context),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (v) =>
                                    setState(() => _roleFilter = v),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (_editMode) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          FilterChip(
                            label: Text(
                              _multiSelect ? 'Multi-select on' : 'Multi-select',
                            ),
                            selected: _multiSelect,
                            onSelected: (v) => setState(() {
                              _multiSelect = v;
                              if (!v) _selectedIds.clear();
                            }),
                            selectedColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer
                                .withValues(alpha: 0.85),
                            checkmarkColor: _facultyAccent(context),
                            labelStyle: TextStyle(
                              color: _multiSelect
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.onSecondaryContainer
                                  : _facultyBodyText(context),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_deptFilter != null)
                            ActionChip(
                              label: const Text('Reassign dept…'),
                              onPressed: () => _dissolveDepartmentDialog(
                                n,
                                _deptFilter!,
                                departments,
                              ),
                            ),
                          const Spacer(),
                          if (_multiSelect && _selectedIds.isNotEmpty) ...[
                            TextButton(
                              onPressed: () => _pickMoveTarget(n, departments),
                              child: const Text('Move'),
                            ),
                            TextButton(
                              onPressed: () => _confirmDeleteMany(n),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 56,
                                  color: _facultyAccent(
                                    context,
                                  ).withValues(alpha: 0.45),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No matches',
                                  style: TextStyle(
                                    color: _facultyBodyText(context),
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                FilledButton.icon(
                                  onPressed: _pushAddFaculty,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add faculty'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _facultyAccent(context),
                                    foregroundColor: _facultyOnAccent(context),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                            itemCount: filtered.length,
                            itemBuilder: (ctx, i) {
                              final m = filtered[i];
                              final selected = _selectedIds.contains(m.id);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _FacultyErpCard(
                                  member: m,
                                  selected: selected,
                                  editMode: _editMode,
                                  multiSelect: _multiSelect,
                                  roleIcon: _iconForRole(m.role),
                                  accent: _facultyAccent(context),
                                  bg: _facultyPageBg(context),
                                  textColor: _facultyBodyText(context),
                                  onTap: () {
                                    if (_editMode && _multiSelect) {
                                      setState(() {
                                        if (selected) {
                                          _selectedIds.remove(m.id);
                                        } else {
                                          _selectedIds.add(m.id);
                                        }
                                      });
                                    } else if (_editMode) {
                                      _openActionSheet(n, m, departments);
                                    } else {
                                      context.go(
                                        AppRoutes.adminFacultyDetailPath(m.id),
                                      );
                                    }
                                  },
                                  onLongPress: () {
                                    if (!_editMode) {
                                      setState(() {
                                        _editMode = true;
                                        _multiSelect = true;
                                        _selectedIds.add(m.id);
                                      });
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_editMode && _multiSelect && _selectedIds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: _facultyCard(context),
                  borderRadius: BorderRadius.circular(20),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_selectedIds.length} selected',
                          style: TextStyle(
                            color: _facultyBodyText(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          color: _facultyBodyText(context),
                          onPressed: () => setState(_selectedIds.clear),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            FloatingActionButton.extended(
              heroTag: 'fab_add_fac',
              onPressed: _pushAddFaculty,
              backgroundColor: _facultyAccent(context),
              foregroundColor: _facultyOnAccent(context),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add faculty'),
            ),
          ],
        ),
      ),
    );
  }

  void _openActionSheet(
    StaffNotifier n,
    MockStaffMember m,
    List<String> departments,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _facultyCard(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.open_in_new, color: _facultyAccent(ctx)),
              title: Text(
                'Open profile',
                style: TextStyle(color: _facultyBodyText(ctx)),
              ),
              onTap: () {
                Navigator.pop(ctx);
                context.go(AppRoutes.adminFacultyDetailPath(m.id));
              },
            ),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: _facultyAccent(ctx)),
              title: Text(
                'Quick edit',
                style: TextStyle(color: _facultyBodyText(ctx)),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _openQuickEdit(n, m);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.drive_file_move_outline,
                color: _facultyAccent(ctx),
              ),
              title: Text(
                'Move to…',
                style: TextStyle(color: _facultyBodyText(ctx)),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _selectedIds
                  ..clear()
                  ..add(m.id);
                _pickMoveTarget(n, departments);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Remove',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (c2) => AlertDialog(
                    title: const Text('Remove faculty?'),
                    content: Text('Remove ${m.name} from the demo directory?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c2, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(c2, true),
                        child: const Text('Remove'),
                      ),
                    ],
                  ),
                );
                if (ok == true) n.remove(m.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DepartmentRail extends StatelessWidget {
  const _DepartmentRail({
    required this.departments,
    required this.selected,
    required this.onAll,
    required this.onPick,
    required this.onAddDept,
  });

  final List<String> departments;
  final String? selected;
  final VoidCallback onAll;
  final ValueChanged<String> onPick;
  final VoidCallback onAddDept;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 118,
      decoration: BoxDecoration(
        color: _facultyCard(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [cs.secondaryContainer, cs.primaryContainer],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Icon(
                    Icons.account_tree_outlined,
                    color: cs.secondary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Departments',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onAddDept,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New'),
                  style: TextButton.styleFrom(foregroundColor: cs.secondary),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              children: [
                _DeptChip(
                  label: 'All',
                  selected: selected == null,
                  onTap: onAll,
                ),
                ...departments.map(
                  (d) => _DeptChip(
                    label: d,
                    selected: selected == d,
                    onTap: () => onPick(d),
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

class _DeptChip extends StatelessWidget {
  const _DeptChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? _facultyAccent(context)
                  : _facultyPageBg(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? _facultyAccent(context)
                    : _facultyAccent(context).withValues(alpha: 0.3),
              ),
            ),
            child: Center(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected
                      ? _facultyOnAccent(context)
                      : _facultyBodyText(context),
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FacultyErpCard extends StatelessWidget {
  const _FacultyErpCard({
    required this.member,
    required this.selected,
    required this.editMode,
    required this.multiSelect,
    required this.roleIcon,
    required this.accent,
    required this.bg,
    required this.textColor,
    required this.onTap,
    required this.onLongPress,
  });

  final MockStaffMember member;
  final bool selected;
  final bool editMode;
  final bool multiSelect;
  final IconData roleIcon;
  final Color accent;
  final Color bg;
  final Color textColor;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.12) : bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? accent : accent.withValues(alpha: 0.2),
              width: selected ? 1.8 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.18),
                  border: Border.all(color: accent.withValues(alpha: 0.5)),
                ),
                child: editMode && multiSelect && selected
                    ? Icon(Icons.check_circle, color: accent, size: 28)
                    : Icon(roleIcon, color: accent, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${member.role} · ${member.department}',
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.75),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (member.phone.isNotEmpty)
                      Text(
                        member.phone,
                        style: TextStyle(
                          color: accent.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              if (editMode && !multiSelect)
                Icon(Icons.more_horiz, color: accent.withValues(alpha: 0.8)),
              if (!editMode)
                Icon(Icons.chevron_right, color: accent.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}
