import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/launch_utils.dart';
import '../../../core/widgets/nc_avatar.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/shell_layout_scope.dart';

class WardenRollcallScreen extends ConsumerStatefulWidget {
  const WardenRollcallScreen({super.key});

  @override
  ConsumerState<WardenRollcallScreen> createState() =>
      _WardenRollcallScreenState();
}

class _WardenRollcallScreenState extends ConsumerState<WardenRollcallScreen> {
  String _selectedBlock = 'Block A';
  final List<MockHostelStudent> _students = MockData.hostelStudents;
  final Map<String, TextEditingController> _reasonCtrls = {};
  final _searchCtrl = TextEditingController();
  static const _reasonPresets = [
    'On approved leave',
    'Hospital',
    'Family emergency',
    'Unauthorised',
  ];

  @override
  void initState() {
    super.initState();
    for (final s in _students) {
      _reasonCtrls[s.id] = TextEditingController(text: s.absentReason ?? '');
    }
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    for (final ctrl in _reasonCtrls.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Map<String, List<MockHostelStudent>> get _filteredRoomGroups {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _roomGroups;
    final map = <String, List<MockHostelStudent>>{};
    for (final s in _students) {
      if (s.name.toLowerCase().contains(q) ||
          s.classSection.toLowerCase().contains(q) ||
          s.roomNo.contains(q)) {
        map.putIfAbsent(s.roomNo, () => []).add(s);
      }
    }
    return map;
  }

  void _showStudentDetail(MockHostelStudent s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  NcAvatar(name: s.name, radius: 32),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name, style: AppTypography.titleMedium),
                        Text(
                          '${s.classSection}  ·  Room ${s.roomNo} Bed ${s.bedNo}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (s.bloodGroup != null)
                          Text(
                            'Blood: ${s.bloodGroup}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Parent / Guardian', style: AppTypography.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              NcCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.parentName ?? '—',
                            style: AppTypography.bodyLarge,
                          ),
                          Text(
                            s.parentPhone ?? '—',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (s.parentPhone != null && s.parentPhone!.length >= 10)
                      FilledButton.icon(
                        onPressed: () {
                          launchTel(context, phone: s.parentPhone!);
                        },
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text('Call'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.success,
                        ),
                      ),
                  ],
                ),
              ),
              if (s.emergencyContact != null || s.emergencyPhone != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text('Emergency Contact', style: AppTypography.labelMedium),
                const SizedBox(height: AppSpacing.xs),
                NcCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.emergencyContact ?? '—',
                              style: AppTypography.bodyLarge,
                            ),
                            Text(
                              s.emergencyPhone ?? '—',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (s.emergencyPhone != null &&
                          s.emergencyPhone!.length >= 10)
                        IconButton(
                          onPressed: () =>
                              launchTel(context, phone: s.emergencyPhone!),
                          icon: const Icon(Icons.phone),
                          color: AppColors.accent,
                        ),
                    ],
                  ),
                ),
              ],
              if (s.medicalNotes != null && s.medicalNotes!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.medical_services,
                      size: 18,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text('Medical', style: AppTypography.labelMedium),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                NcCard(
                  child: Text(s.medicalNotes!, style: AppTypography.bodySmall),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _markAllPresent() {
    setState(() {
      for (final s in _students) {
        s.isPresent = true;
        s.absentReason = null;
      }
    });
  }

  void _togglePresence(MockHostelStudent student) {
    setState(() {
      student.isPresent = !student.isPresent;
      if (student.isPresent) student.absentReason = null;
    });
  }

  Map<String, List<MockHostelStudent>> get _roomGroups {
    final map = <String, List<MockHostelStudent>>{};
    for (final s in _students) {
      map.putIfAbsent(s.roomNo, () => []).add(s);
    }
    return map;
  }

  int get _absentCount => _students.where((s) => !s.isPresent).length;

  Future<void> _submit() async {
    // Validate absent reasons
    final missingReason = _students
        .where((s) => !s.isPresent && (s.absentReason?.isEmpty ?? true))
        .toList();
    if (missingReason.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter reason for all absent students.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Roll Call'),
        content: Text(
          '${_students.length - _absentCount} present, $_absentCount absent. Parents of absent students will be notified. Submit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Roll call submitted. Parents notified.'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(title: const Text('Evening Roll Call')),
      body: Column(
        children: [
          // Roll call info + block selector
          Container(
            color: AppColors.card,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.schedule, color: AppColors.teal, size: 18),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Scheduled: 8:00 PM  ·  Actual: ${now.hour}:${now.minute.toString().padLeft(2, '0')} PM',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedBlock,
                        decoration: const InputDecoration(
                          labelText: 'Block',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: ['Block A', 'Block B', 'Block C']
                            .map(
                              (b) => DropdownMenuItem(value: b, child: Text(b)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedBlock = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Search by name, class, room…',
                    prefixIcon: Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Search by name, class, room…',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _markAllPresent,
                    icon: const Icon(Icons.done_all),
                    label: const Text('Mark All Present'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.success.withValues(
                        alpha: 0.08,
                      ),
                      foregroundColor: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Student list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: _filteredRoomGroups.length,
              itemBuilder: (_, i) {
                final room = _filteredRoomGroups.keys.elementAt(i);
                final roomStudents = _filteredRoomGroups[room]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: AppColors.background,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.xs,
                      ),
                      child: Text(
                        'Room $room — ${roomStudents.length} students',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    ...roomStudents.map(
                      (s) => Column(
                        children: [
                          ListTile(
                            onTap: () => _showStudentDetail(s),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: 4,
                            ),
                            leading: NcAvatar(name: s.name, radius: 22),
                            title: Text(s.name, style: AppTypography.bodyLarge),
                            subtitle: Text(
                              'Bed ${s.bedNo} | ${s.classSection}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  s.isPresent ? 'P' : 'A',
                                  style: TextStyle(
                                    color: s.isPresent
                                        ? AppColors.success
                                        : AppColors.error,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Switch.adaptive(
                                  value: s.isPresent,
                                  onChanged: (_) => _togglePresence(s),
                                  activeColor: AppColors.success,
                                ),
                              ],
                            ),
                          ),
                          if (!s.isPresent)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: AppSpacing.xs,
                                    runSpacing: AppSpacing.xs,
                                    children: _reasonPresets
                                        .map(
                                          (r) => ActionChip(
                                            label: Text(
                                              r,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            onPressed: () {
                                              s.absentReason = r;
                                              _reasonCtrls[s.id]?.text = r;
                                              setState(() {});
                                            },
                                          ),
                                        )
                                        .toList(),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _reasonCtrls[s.id],
                                          onChanged: (v) => s.absentReason = v,
                                          decoration: const InputDecoration(
                                            hintText: 'Or type reason…',
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                          maxLength: 200,
                                        ),
                                      ),
                                      if (s.parentPhone != null &&
                                          s.parentPhone!.length >= 10) ...[
                                        const SizedBox(width: AppSpacing.xs),
                                        FilledButton.icon(
                                          onPressed: () => launchTel(
                                            context,
                                            phone: s.parentPhone!,
                                          ),
                                          icon: const Icon(
                                            Icons.phone,
                                            size: 18,
                                          ),
                                          label: const Text('Call Parent'),
                                          style: FilledButton.styleFrom(
                                            backgroundColor: AppColors.success,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
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

          // Submit footer
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: AppColors.card,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_students.length - _absentCount} Present  ·  $_absentCount Absent',
                    style: AppTypography.titleSmall,
                  ),
                ),
                FilledButton(
                  onPressed: _submit,
                  child: const Text('Submit Roll Call'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
