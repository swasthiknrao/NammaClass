import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_avatar.dart';

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

  @override
  void initState() {
    super.initState();
    for (final s in _students) {
      _reasonCtrls[s.id] = TextEditingController(text: s.absentReason ?? '');
    }
  }

  @override
  void dispose() {
    for (final ctrl in _reasonCtrls.values) {
      ctrl.dispose();
    }
    super.dispose();
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
      appBar: AppBar(title: const Text('Evening Roll Call')),
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
              itemCount: _roomGroups.length,
              itemBuilder: (_, i) {
                final room = _roomGroups.keys.elementAt(i);
                final roomStudents = _roomGroups[room]!;
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
                              child: TextField(
                                controller: _reasonCtrls[s.id],
                                onChanged: (v) => s.absentReason = v,
                                decoration: const InputDecoration(
                                  hintText:
                                      'Reason: On approved leave / Hospital / Unauthorised',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                maxLength: 200,
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
