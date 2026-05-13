import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/providers/data_sync_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_size.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_avatar.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../../../features/admin/providers/admin_providers.dart';

class WebStudentsScreen extends ConsumerWidget {
  const WebStudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(adminStudentsProvider);
    final isMobile = ScreenSize.isMobile(context);
    final padding = isMobile ? AppSpacing.sm : AppSpacing.lg;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FilterBar(
            isMobile: isMobile,
            onAddStudent: () => _AddStudentFlow.show(context, ref),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: studentsAsync.when(
              loading: () => const NcShimmerList(itemCount: 8),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (students) => isMobile
                  ? _MobileStudentList(students: students)
                  : _DesktopStudentTable(students: students),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.isMobile, required this.onAddStudent});
  final bool isMobile;
  final VoidCallback onAddStudent;

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SearchBar(
            hintText: 'Search…',
            leading: const Icon(Icons.search, size: 20),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            backgroundColor: const WidgetStatePropertyAll(AppColors.card),
            elevation: const WidgetStatePropertyAll(0),
            side: const WidgetStatePropertyAll(
              BorderSide(color: AppColors.divider),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                NcChip(label: 'All', selected: true),
                const SizedBox(width: AppSpacing.xs),
                NcChip(label: 'Active', selected: false),
                const SizedBox(width: AppSpacing.xs),
                NcChip(label: 'Overdue', selected: false),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          NcPrimaryButton(
            label: 'Add Student',
            icon: Icons.add,
            onPressed: onAddStudent,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SearchBar(
            hintText: 'Search students…',
            leading: const Icon(Icons.search),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 16),
            ),
            backgroundColor: const WidgetStatePropertyAll(AppColors.card),
            elevation: const WidgetStatePropertyAll(0),
            side: const WidgetStatePropertyAll(
              BorderSide(color: AppColors.divider),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        ...['All Classes', 'Active', 'Fee Overdue'].map(
          (f) => Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: NcChip(label: f, selected: f == 'All Classes'),
          ),
        ),
        const Spacer(),
        NcPrimaryButton(
          label: 'Add Student',
          icon: Icons.add,
          onPressed: onAddStudent,
        ),
      ],
    );
  }
}

class _MobileStudentList extends StatelessWidget {
  const _MobileStudentList({required this.students});
  final List<dynamic> students;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: students.length + 1,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (ctx, i) {
        if (i == students.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${students.length} students',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(onPressed: () {}, child: const Text('Prev')),
                    TextButton(onPressed: () {}, child: const Text('Next')),
                  ],
                ),
              ],
            ),
          );
        }
        final s = students[i];
        return _StudentCard(student: s);
      },
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student});
  final dynamic student;

  @override
  Widget build(BuildContext context) {
    final attColor = student.attendancePercent >= 0.85
        ? AppColors.success
        : AppColors.error;

    return NcCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: InkWell(
        onTap: () {
          // Could navigate to student profile
        },
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                NcAvatar(name: student.name, radius: 24),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${student.classSection} • Roll ${student.rollNo}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _MiniChip(
                  '${(student.attendancePercent * 100).round()}%',
                  attColor,
                  Icons.trending_up,
                ),
                const SizedBox(width: AppSpacing.sm),
                NcStatusChip(
                  type: student.feeStatus == 'paid'
                      ? NcChipType.paid
                      : student.feeStatus == 'overdue'
                      ? NcChipType.overdue
                      : NcChipType.pending,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, size: 20),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopStudentTable extends StatelessWidget {
  const _DesktopStudentTable({required this.students});
  final List<dynamic> students;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            color: AppColors.background,
            child: Row(
              children: [
                const SizedBox(width: 36),
                _HeaderCell('Name', flex: 3),
                _HeaderCell('Roll No', flex: 1),
                _HeaderCell('Class', flex: 1),
                _HeaderCell('Attendance', flex: 1),
                _HeaderCell('Fee Status', flex: 1),
                _HeaderCell('Actions', flex: 1),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: students.length,
              separatorBuilder: (_, i) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final s = students[i];
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Checkbox(value: false, onChanged: (_) {}),
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            NcAvatar(name: s.name, radius: 16),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                s.name,
                                style: AppTypography.labelMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(s.rollNo, style: AppTypography.bodyMedium),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          s.classSection,
                          style: AppTypography.bodyMedium,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${(s.attendancePercent * 100).round()}%',
                          style: AppTypography.bodyMedium.copyWith(
                            color: s.attendancePercent >= 0.85
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: NcStatusChip(
                          type: s.feeStatus == 'paid'
                              ? NcChipType.paid
                              : s.feeStatus == 'overdue'
                              ? NcChipType.overdue
                              : NcChipType.pending,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.visibility_outlined,
                                size: 18,
                              ),
                              onPressed: () {},
                              tooltip: 'View',
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () {},
                              tooltip: 'Edit',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            color: AppColors.background,
            child: Row(
              children: [
                Text(
                  'Showing ${students.length} students',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('← Previous')),
                TextButton(onPressed: () {}, child: const Text('Next →')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Add learner + mint guardian portal credentials (local-first demo).
class _AddStudentFlow {
  static void show(BuildContext outerContext, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final classCtrl = TextEditingController(text: '10-A');
    final rollCtrl = TextEditingController();
    final parentNameCtrl = TextEditingController();

    showDialog<void>(
      context: outerContext,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Add student'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'A parent / guardian portal account is created automatically. '
                    'You will see login details after saving.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Student full name',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: classCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Class / section',
                      hintText: 'e.g. 10-A',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: rollCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Roll number',
                      hintText: 'Leave blank for auto',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: parentNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Guardian display name (optional)',
                      hintText: 'Defaults to “Parent of …”',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final name = nameCtrl.text.trim();
                final classSection = classCtrl.text.trim();
                var roll = rollCtrl.text.trim();
                if (roll.isEmpty) {
                  roll = '${1000 + DateTime.now().millisecond % 9000}';
                }
                final parentName = parentNameCtrl.text.trim().isEmpty
                    ? 'Parent of $name'
                    : parentNameCtrl.text.trim();
                final h = Object.hash(name, roll, classSection);
                final pin = '${100000 + h.abs() % 900000}';
                final slug = name.toLowerCase().replaceAll(
                  RegExp(r'[^a-z0-9]+'),
                  '',
                );
                final baseSlug = slug.isEmpty ? 'student' : slug;
                final login = 'par_${baseSlug}_$roll';
                final email = '$login@parents.nammaclass.in';
                final phone =
                    '9876${(h.abs() % 1000000).toString().padLeft(6, '0')}';

                MockData.appendStudent(
                  MockStudent(
                    id: 'stu_${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    rollNo: roll,
                    classSection: classSection,
                    attendancePercent: 0.92,
                    parentName: parentName,
                    parentPhone: phone,
                    feeStatus: 'pending',
                  ),
                );
                ref.read(dataSyncProvider.notifier).bump();
                Navigator.pop(dialogCtx);

                Future.microtask(() {
                  if (!outerContext.mounted) return;
                  showDialog<void>(
                    context: outerContext,
                    builder: (c2) => AlertDialog(
                      title: const Text('Parent portal credentials'),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Share once with the guardian. They should change '
                              'the PIN on first login.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _ParentCredLine(
                              label: 'Login ID',
                              value: login,
                              mono: true,
                            ),
                            _ParentCredLine(
                              label: 'Email',
                              value: email,
                              mono: false,
                            ),
                            _ParentCredLine(
                              label: 'Temporary PIN',
                              value: pin,
                              mono: true,
                            ),
                            _ParentCredLine(
                              label: 'Linked phone',
                              value: phone,
                              mono: true,
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        FilledButton(
                          onPressed: () => Navigator.pop(c2),
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  );
                });
              },
              child: const Text('Save & show parent login'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      nameCtrl.dispose();
      classCtrl.dispose();
      rollCtrl.dispose();
      parentNameCtrl.dispose();
    });
  }
}

class _ParentCredLine extends StatelessWidget {
  const _ParentCredLine({
    required this.label,
    required this.value,
    this.mono = false,
  });
  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTypography.labelMedium),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: AppTypography.bodyMedium.copyWith(
                fontFamily: mono ? 'JetBrainsMono' : null,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            tooltip: 'Copy',
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: value));
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('$label copied')));
            },
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label, {this.flex = 1});
  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
