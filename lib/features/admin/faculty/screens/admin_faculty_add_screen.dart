import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_input.dart';
import '../../../../core/widgets/shell_layout_scope.dart';
import '../../providers/staff_notifier.dart';

class AdminFacultyAddScreen extends ConsumerStatefulWidget {
  const AdminFacultyAddScreen({super.key});

  @override
  ConsumerState<AdminFacultyAddScreen> createState() =>
      _AdminFacultyAddScreenState();
}

class _AdminFacultyAddScreenState extends ConsumerState<AdminFacultyAddScreen> {
  final _name = TextEditingController();
  final _role = TextEditingController(text: 'Teacher');
  final _dept = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  bool _busy = false;
  bool _appliedDeptQuery = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_appliedDeptQuery) return;
    final dept = GoRouterState.of(context).uri.queryParameters['dept'];
    if (dept != null && dept.trim().isNotEmpty) {
      _dept.text = dept.trim();
      _appliedDeptQuery = true;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    _dept.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty || _phone.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and phone are required')),
      );
      return;
    }
    setState(() => _busy = true);
    await Future.delayed(const Duration(milliseconds: 200));
    final id = 'staff_${DateTime.now().millisecondsSinceEpoch}';
    ref
        .read(staffNotifierProvider.notifier)
        .add(
          MockStaffMember(
            id: id,
            name: _name.text.trim(),
            role: _role.text.trim().isEmpty ? 'Teacher' : _role.text.trim(),
            department: _dept.text.trim().isEmpty
                ? 'General'
                : _dept.text.trim(),
            phone: _phone.text.trim(),
            email: _email.text.trim().isEmpty ? null : _email.text.trim(),
            joinDate: DateTime.now(),
          ),
        );
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Faculty added')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(title: const Text('Add faculty')),
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Creates a teaching staff record for timetable assignment.',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            NcTextField(
              controller: _name,
              label: 'Full name',
              hint: 'Dr. A. Rao',
            ),
            const SizedBox(height: AppSpacing.sm),
            NcTextField(controller: _role, label: 'Role', hint: 'Teacher'),
            const SizedBox(height: AppSpacing.sm),
            NcTextField(
              controller: _dept,
              label: 'Department',
              hint: 'Science',
            ),
            const SizedBox(height: AppSpacing.sm),
            NcTextField(controller: _phone, label: 'Phone', hint: '9876543210'),
            const SizedBox(height: AppSpacing.sm),
            NcTextField(controller: _email, label: 'Email (optional)'),
            const SizedBox(height: AppSpacing.lg),
            NcPrimaryButton(label: 'Save', loading: _busy, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
