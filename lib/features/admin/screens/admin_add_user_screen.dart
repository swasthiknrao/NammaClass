import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_input.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/tenant/providers/tenant_provider.dart';
import '../../../routing/app_routes.dart';
import '../providers/admin_add_user_roles.dart';
import '../providers/staff_notifier.dart';

/// Admin / principal (etc.) creates a portal user in-app — name, phone, email, role, temp PIN.
class AdminAddUserScreen extends ConsumerStatefulWidget {
  const AdminAddUserScreen({super.key});

  @override
  ConsumerState<AdminAddUserScreen> createState() => _AdminAddUserScreenState();
}

class _AdminAddUserScreenState extends ConsumerState<AdminAddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _departmentController = TextEditingController(text: 'General');
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  String _nextStaffId() {
    final n = ref.read(staffNotifierProvider).valueOrNull?.length ?? 0;
    return 'usr_${DateTime.now().millisecondsSinceEpoch}_$n';
  }

  String _tempPin(String name, String phone) {
    final h = Object.hash(name, phone);
    return '${100000 + h.abs() % 900000}';
  }

  Future<void> _submit(UserRole role) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final dept = _departmentController.text.trim().isEmpty
        ? 'General'
        : _departmentController.text.trim();
    final pin = _tempPin(name, phone);

    final member = MockStaffMember(
      id: _nextStaffId(),
      name: name,
      role: UserModel.roleDisplayLabel(role),
      department: dept,
      phone: phone,
      email: email,
      joinDate: DateTime.now(),
      status: 'active',
    );
    ref.read(staffNotifierProvider.notifier).add(member);

    setState(() => _saving = false);
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('User created'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${UserModel.roleDisplayLabel(role)} · $name',
                style: AppTypography.titleSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Share this temporary PIN once; ask them to change it on first login.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _CopyRow(label: 'Phone', value: phone),
              _CopyRow(label: 'Email', value: email),
              _CopyRow(label: 'Temporary PIN', value: pin, mono: true),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final tenant = ref.watch(tenantProfileProvider);
    final actor = ref.watch(currentUserProvider);
    final roles = manualAddUserRoles(actor?.role, tenant);

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(
              title: const Text('Add user'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
      body: roles.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'No roles can be added for your account on this tenant.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          : _AddUserForm(
              formKey: _formKey,
              nameController: _nameController,
              phoneController: _phoneController,
              emailController: _emailController,
              departmentController: _departmentController,
              roles: roles,
              saving: _saving,
              onSubmit: _submit,
            ),
    );
  }
}

class _AddUserForm extends StatefulWidget {
  const _AddUserForm({
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.departmentController,
    required this.roles,
    required this.saving,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController departmentController;
  final List<UserRole> roles;
  final bool saving;
  final void Function(UserRole role) onSubmit;

  @override
  State<_AddUserForm> createState() => _AddUserFormState();
}

class _AddUserFormState extends State<_AddUserForm> {
  late UserRole _role;

  @override
  void initState() {
    super.initState();
    _role = widget.roles.first;
  }

  @override
  void didUpdateWidget(covariant _AddUserForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.roles.contains(_role) && widget.roles.isNotEmpty) {
      _role = widget.roles.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: NcCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create user',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Enter their details. A temporary PIN is shown after you save — '
                'no invitation email is sent from this screen.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              NcTextField(
                controller: widget.nameController,
                label: 'Full name',
                hint: 'As it should appear in the app',
                prefixIcon: Icons.person_outline,
                validator: AppValidators.required,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.md),
              NcTextField(
                controller: widget.phoneController,
                label: 'Phone',
                hint: '10-digit mobile',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: AppValidators.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 10,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.md),
              NcTextField(
                controller: widget.emailController,
                label: 'Email',
                hint: 'Used for login & recovery',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    AppValidators.required(v) ?? AppValidators.email(v),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.md),
              NcTextField(
                controller: widget.departmentController,
                label: 'Department / notes',
                hint: 'e.g. Science, Transport',
                prefixIcon: Icons.business_outlined,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<UserRole>(
                key: ValueKey(_role.name),
                initialValue: _role,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
                items: widget.roles
                    .map(
                      (r) => DropdownMenuItem(
                        value: r,
                        child: Text(UserModel.roleDisplayLabel(r)),
                      ),
                    )
                    .toList(),
                onChanged: widget.saving
                    ? null
                    : (v) {
                        if (v != null) setState(() => _role = v);
                      },
              ),
              const SizedBox(height: AppSpacing.xl),
              NcPrimaryButton(
                label: 'Create user',
                loading: widget.saving,
                onPressed: widget.saving ? null : () => widget.onSubmit(_role),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                onPressed: widget.saving
                    ? null
                    : () => context.push(AppRoutes.webStudents),
                icon: const Icon(Icons.school_outlined),
                label: const Text('Add a student on the web roster instead'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CopyRow extends StatelessWidget {
  const _CopyRow({required this.label, required this.value, this.mono = false});
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
            width: 120,
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
