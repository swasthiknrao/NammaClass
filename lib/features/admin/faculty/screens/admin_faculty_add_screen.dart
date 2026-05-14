import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_input.dart';
import '../../../../core/widgets/shell_layout_scope.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../tenant/providers/tenant_provider.dart';
import '../../providers/admin_add_user_roles.dart';
import '../../providers/staff_notifier.dart';
import '../../widgets/admin_user_created_dialog.dart';

const _presetBlocks = [
  'Block A',
  'Block B',
  'Block C',
  'Block D',
  'Annexe',
  'Other',
];

IconData _roleIcon(UserRole r) {
  return switch (r) {
    UserRole.teacher => Icons.school_outlined,
    UserRole.principal => Icons.apartment_outlined,
    UserRole.hod => Icons.groups_outlined,
    UserRole.driver => Icons.directions_bus_outlined,
    UserRole.staff => Icons.engineering_outlined,
    UserRole.librarian => Icons.local_library_outlined,
    UserRole.warden => Icons.night_shelter_outlined,
    UserRole.accountant => Icons.account_balance_outlined,
    UserRole.support => Icons.headset_mic_outlined,
    UserRole.canteenStaff => Icons.restaurant_outlined,
    UserRole.admin => Icons.admin_panel_settings_outlined,
    UserRole.parent => Icons.family_restroom_outlined,
    UserRole.student => Icons.person_outline,
    UserRole.superAdmin => Icons.cloud_outlined,
  };
}

String _roleBlurb(UserRole r) {
  return switch (r) {
    UserRole.teacher => 'Classes, diary, attendance',
    UserRole.principal => 'Full school leadership',
    UserRole.hod => 'Department academics',
    UserRole.driver => 'Routes & student transport',
    UserRole.staff => 'Operations & support',
    UserRole.librarian => 'Library & circulation',
    UserRole.warden => 'Hostel & boarding',
    UserRole.accountant => 'Fees & finance views',
    UserRole.support => 'Help desk & tickets',
    UserRole.canteenStaff => 'Counter & meal service',
    UserRole.admin => 'Configuration & users',
    UserRole.parent => 'Learner-linked parent portal',
    UserRole.student => 'Learner app',
    UserRole.superAdmin => 'Platform',
  };
}

class AdminFacultyAddScreen extends ConsumerStatefulWidget {
  const AdminFacultyAddScreen({super.key});

  @override
  ConsumerState<AdminFacultyAddScreen> createState() =>
      _AdminFacultyAddScreenState();
}

class _AdminFacultyAddScreenState extends ConsumerState<AdminFacultyAddScreen> {
  static const int _stepCount = 5;

  int _step = 0;
  bool _busy = false;
  bool _deptQueryApplied = false;

  UserRole? _selectedRole;

  final _formIdentity = GlobalKey<FormState>();
  final _formPlacement = GlobalKey<FormState>();
  final _formCredentials = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _employeeCode = TextEditingController();
  final _department = TextEditingController();
  final _blockOther = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();

  DateTime _joinDate = DateTime.now();
  String _blockPreset = _presetBlocks.first;

  @override
  void dispose() {
    _name.dispose();
    _employeeCode.dispose();
    _department.dispose();
    _blockOther.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_deptQueryApplied) {
      final dept = GoRouterState.of(context).uri.queryParameters['dept'];
      if (dept != null && dept.trim().isNotEmpty) {
        _department.text = dept.trim();
      }
      _deptQueryApplied = true;
    }
    final actor = ref.read(currentUserProvider);
    final tenant = ref.read(tenantProfileProvider);
    final roles = manualAddUserRoles(actor?.role, tenant);
    if (_selectedRole == null && roles.isNotEmpty) {
      _selectedRole = roles.first;
    }
  }

  String _nextStaffId() {
    final n = ref.read(staffNotifierProvider).valueOrNull?.length ?? 0;
    return 'usr_${DateTime.now().millisecondsSinceEpoch}_$n';
  }

  String? _resolvedCampusBlock() {
    if (_blockPreset == 'Other') {
      final t = _blockOther.text.trim();
      return t.isEmpty ? null : t;
    }
    return _blockPreset;
  }

  Future<void> _pickJoinDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joinDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _joinDate = picked);
  }

  bool _validateCurrentStep() {
    switch (_step) {
      case 0:
        final roles = _rolesForActor();
        if (_selectedRole == null || roles.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Choose a role to continue')),
          );
          return false;
        }
        if (!roles.contains(_selectedRole)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('That role is not available here')),
          );
          return false;
        }
        return true;
      case 1:
        return _formIdentity.currentState?.validate() ?? false;
      case 2:
        return _formPlacement.currentState?.validate() ?? false;
      case 3:
        return _formCredentials.currentState?.validate() ?? false;
      default:
        return true;
    }
  }

  List<UserRole> _rolesForActor() {
    final actor = ref.read(currentUserProvider);
    final tenant = ref.read(tenantProfileProvider);
    return manualAddUserRoles(actor?.role, tenant);
  }

  void _goNext() {
    if (!_validateCurrentStep()) return;
    if (_step < _stepCount - 1) {
      setState(() => _step++);
    }
  }

  void _goBack() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      context.pop();
    }
  }

  Future<void> _submit() async {
    if (!_validateCurrentStep()) return;
    final role = _selectedRole;
    if (role == null) return;

    final name = _name.text.trim();
    final phone = _phone.text.trim();
    final email = _email.text.trim();
    var dept = _department.text.trim();
    if (dept.isEmpty) dept = 'General';

    final emp = _employeeCode.text.trim();
    final block = _resolvedCampusBlock();

    setState(() => _busy = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final notifier = ref.read(staffNotifierProvider.notifier);
    final existing = notifier
        .allDepartments()
        .map((e) => e.toLowerCase())
        .toSet();
    if (!existing.contains(dept.toLowerCase())) {
      notifier.addDepartmentBucket(dept);
    }

    final pin = adminGeneratedTempPin(name, phone);
    final member = MockStaffMember(
      id: _nextStaffId(),
      name: name,
      role: UserModel.roleDisplayLabel(role),
      department: dept,
      phone: phone,
      email: email,
      joinDate: _joinDate,
      status: 'active',
      employeeCode: emp.isEmpty ? null : emp,
      campusBlock: block,
    );
    notifier.add(member);

    setState(() => _busy = false);
    if (!mounted) return;

    await showAdminUserCreatedDialog(
      context,
      roleLabel: UserModel.roleDisplayLabel(role),
      name: name,
      phone: phone,
      email: email,
      pin: pin,
    );
    if (!mounted) return;
    context.pop();
  }

  String _stepTitle() {
    return switch (_step) {
      0 => 'Their portal role',
      1 => 'Identity',
      2 => 'Campus placement',
      3 => 'Login details',
      _ => 'Review & create',
    };
  }

  String _stepSubtitle() {
    return switch (_step) {
      0 =>
        'One tap on a row — then name, department, block, and login in the next steps.',
      1 => 'Legal name and staff identifiers.',
      2 => 'Department and block help timetables and directory.',
      3 =>
        'Phone and email are used for login. A temporary PIN appears after save.',
      _ => 'Confirm everything before creating the account.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final roles = manualAddUserRoles(
      ref.watch(currentUserProvider)?.role,
      ref.watch(tenantProfileProvider),
    );
    final deptOptions = ref
        .watch(staffNotifierProvider)
        .when(
          data: (_) =>
              ref.read(staffNotifierProvider.notifier).allDepartments(),
          loading: () => <String>[],
          error: (_, _) => <String>[],
        );

    final hideAppBar =
        ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true;

    if (roles.isEmpty) {
      return Scaffold(
        appBar: hideAppBar
            ? null
            : AppBar(title: const Text('Onboard team member')),
        body: Center(
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
        ),
      );
    }

    return Scaffold(
      appBar: hideAppBar
          ? null
          : AppBar(
              title: const Text('Onboard team member'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
            ),
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (_step + 1) / _stepCount,
                    minHeight: 6,
                    backgroundColor: AppColors.divider,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _step == 0
                      ? 'Step ${_step + 1} of $_stepCount · Role'
                      : 'Step ${_step + 1} of $_stepCount',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (_step != 0) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(_stepTitle(), style: AppTypography.headlineSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _stepSubtitle(),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _stepSubtitle(),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: _stepBody(roles, deptOptions),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: NcSecondaryButton(
                      label: _step == 0 ? 'Cancel' : 'Back',
                      onPressed: _busy ? null : _goBack,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _step == _stepCount - 1
                        ? NcPrimaryButton(
                            label: 'Create',
                            icon: Icons.check_rounded,
                            loading: _busy,
                            onPressed: _busy ? null : _submit,
                          )
                        : NcPrimaryButton(
                            label: 'Continue',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: _busy ? null : _goNext,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepBody(List<UserRole> roles, List<String> deptOptions) {
    switch (_step) {
      case 0:
        return _buildRoleStep(roles);
      case 1:
        return _buildIdentityStep();
      case 2:
        return _buildPlacementStep(deptOptions);
      case 3:
        return _buildCredentialsStep();
      default:
        return _buildReviewStep();
    }
  }

  Widget _buildRoleStep(List<UserRole> roles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NcCard(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.9),
                      AppColors.teal.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [AppColors.shadowSm],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome them in',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'You are provisioning a real portal login — keep it accurate and share the PIN in person.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Roles you can assign',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: roles.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
          itemBuilder: (context, i) {
            final r = roles[i];
            final selected = _selectedRole == r;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _selectedRole = r),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.06)
                        : AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      width: selected ? 2 : 1,
                      color: selected ? AppColors.primary : AppColors.divider,
                    ),
                    boxShadow: selected ? [AppColors.shadowSm] : const [],
                  ),
                  child: Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withValues(alpha: 0.14)
                              : AppColors.shimmerBase,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            _roleIcon(r),
                            size: 22,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              UserModel.roleDisplayLabel(r),
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              _roleBlurb(r),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_off_rounded,
                        size: 22,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textDisabled,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _buildIdentityStep() {
    return Form(
      key: _formIdentity,
      child: NcCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NcTextField(
              controller: _name,
              label: 'Full name',
              hint: 'As it should appear in the app',
              prefixIcon: Icons.person_outline,
              validator: AppValidators.required,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),
            NcTextField(
              controller: _employeeCode,
              label: 'Employee / staff ID (optional)',
              hint: 'e.g. EMP-2044',
              prefixIcon: Icons.badge_outlined,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.event_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Join date'),
              subtitle: Text(
                MaterialLocalizations.of(context).formatFullDate(_joinDate),
                style: AppTypography.bodyMedium,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickJoinDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlacementStep(List<String> deptOptions) {
    return Form(
      key: _formPlacement,
      child: NcCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NcTextField(
              controller: _department,
              label: 'Department',
              hint: 'Type a name or use a quick pick below',
              prefixIcon: Icons.business_outlined,
              validator: AppValidators.required,
              textInputAction: TextInputAction.next,
            ),
            if (deptOptions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Quick picks',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final d in deptOptions.take(10))
                    ActionChip(
                      label: Text(d, style: AppTypography.bodySmall),
                      onPressed: () {
                        _department.text = d;
                        setState(() {});
                      },
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Block / wing',
                prefixIcon: Icon(Icons.location_city_outlined),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _blockPreset,
                  items: _presetBlocks
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _blockPreset = v ?? _presetBlocks.first),
                ),
              ),
            ),
            if (_blockPreset == 'Other') ...[
              const SizedBox(height: AppSpacing.md),
              NcTextField(
                controller: _blockOther,
                label: 'Describe block or wing',
                hint: 'e.g. North wing, Science block',
                prefixIcon: Icons.edit_location_alt_outlined,
                validator: (v) => AppValidators.required(v),
                textInputAction: TextInputAction.done,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialsStep() {
    return Form(
      key: _formCredentials,
      child: NcCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'No invitation email is sent from this screen. Share the temporary PIN in person after you save.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            NcTextField(
              controller: _phone,
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
              controller: _email,
              label: 'Email',
              hint: 'Used for login & recovery',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  AppValidators.required(v) ?? AppValidators.email(v),
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    final r = _selectedRole;
    final block = _resolvedCampusBlock() ?? '—';
    final emp = _employeeCode.text.trim().isEmpty
        ? '—'
        : _employeeCode.text.trim();
    return NcCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _reviewRow('Role', r != null ? UserModel.roleDisplayLabel(r) : '—'),
          _reviewRow(
            'Name',
            _name.text.trim().isEmpty ? '—' : _name.text.trim(),
          ),
          _reviewRow('Employee ID', emp),
          _reviewRow(
            'Join date',
            MaterialLocalizations.of(context).formatFullDate(_joinDate),
          ),
          _reviewRow(
            'Department',
            _department.text.trim().isEmpty
                ? 'General'
                : _department.text.trim(),
          ),
          _reviewRow('Block / wing', block),
          _reviewRow(
            'Phone',
            _phone.text.trim().isEmpty ? '—' : _phone.text.trim(),
          ),
          _reviewRow(
            'Email',
            _email.text.trim().isEmpty ? '—' : _email.text.trim(),
          ),
        ],
      ),
    );
  }

  Widget _reviewRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(k, style: AppTypography.labelMedium),
          ),
          Expanded(child: Text(v, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }
}
