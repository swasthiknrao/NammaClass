import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/tenant_policy_loader.dart';
import '../../../core/models/user_model.dart';
import '../../../core/tenant/school_role_invite_policy.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../auth/providers/auth_provider.dart';
import '../../tenant/providers/tenant_provider.dart';

class WebUserManagementScreen extends ConsumerStatefulWidget {
  const WebUserManagementScreen({super.key});

  @override
  ConsumerState<WebUserManagementScreen> createState() =>
      _WebUserManagementScreenState();
}

class _WebUserManagementScreenState
    extends ConsumerState<WebUserManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final demo = TenantPolicyLoader.webUserManagementDemo;
    final tenant = ref.watch(tenantProfileProvider);
    final actor = ref.watch(currentUserProvider);
    final myInviteRoles = rolesInvitableByActor(actor?.role, tenant);

    return Column(
      children: [
        if (demo.failedLoginAlert)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            color: AppColors.error.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(Icons.security, color: AppColors.error),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    demo.failedLoginMessage,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('View Details')),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(
              'Who can invite whom',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              actor == null
                  ? 'Sign in to see your invitation scope.'
                  : 'Signed in as ${actor.roleLabel}.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: schoolInviteAccessMapLines()
                        .map(
                          (line) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.xs,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '• ',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    line,
                                    style: AppTypography.bodySmall.copyWith(
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'User & Role Management',
                style: AppTypography.headlineMedium,
              ),
              Tooltip(
                message: myInviteRoles.isEmpty
                    ? 'Your role cannot send invitations from this screen'
                    : 'Email an onboarding link (48h)',
                child: FilledButton.icon(
                  onPressed: myInviteRoles.isEmpty
                      ? null
                      : () => _showInviteDialog(context, myInviteRoles),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Invite User'),
                ),
              ),
            ],
          ),
        ),
        TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Roles & Permissions'),
            Tab(text: 'Login Audit'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _UsersTab(demo.users),
              _RolesTab(
                demo.roles,
                demo.rolesTabPermissionColumns,
                demo.rolesTabModuleRows,
              ),
              _AuditTab(demo.auditLog),
            ],
          ),
        ),
      ],
    );
  }

  void _showInviteDialog(BuildContext context, List<UserRole> roles) {
    if (roles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No invitation roles for your account or this tenant subscription.',
          ),
        ),
      );
      return;
    }

    String inviteEmail = '';
    var inviteRole = roles.first;
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Invite User'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (!RegExp(
                        r'^[\w.+-]+@[\w-]+\.\w{2,}$',
                      ).hasMatch(v.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                    onChanged: (v) => inviteEmail = v,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<UserRole>(
                    key: ValueKey(inviteRole),
                    initialValue: inviteRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    items: roles
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text(UserModel.roleDisplayLabel(r)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() => inviteRole = v);
                      }
                    },
                  ),
                  if (inviteRole == UserRole.student) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Tip: for roster intake with auto-generated parent login, '
                      'use Students → Add Student.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'User will receive a setup link via email. Expires in 48 hours.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  emailController.dispose();
                  Navigator.pop(ctx);
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  inviteEmail = emailController.text.trim();
                  setDialogState(() {}); // Show loading state if needed
                  await Future.delayed(const Duration(milliseconds: 600));
                  if (!ctx.mounted) return;
                  emailController.dispose();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Invitation sent to $inviteEmail as ${UserModel.roleDisplayLabel(inviteRole)}!',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text('Send Invite'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab(this.users);
  final List<WebUserMgmtUser> users;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'No users yet.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: NcCard(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              color: AppColors.background,
              child: Row(
                children: const [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Name',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Role',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Last Login',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Status',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Actions',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            ...users.map(
              (u) => Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.divider)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(u.name, style: AppTypography.labelMedium),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        u.email,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(u.role, style: AppTypography.bodySmall),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        u.lastLogin,
                        style: AppTypography.bodySmall.copyWith(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: NcChip(
                        label: u.status,
                        color: u.status == 'Active'
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 16),
                            onPressed: () {},
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: const Icon(Icons.key, size: 16),
                            onPressed: () {},
                            tooltip: 'Reset Password',
                          ),
                          IconButton(
                            icon: Icon(
                              u.status == 'Active'
                                  ? Icons.block
                                  : Icons.check_circle,
                              size: 16,
                            ),
                            onPressed: () {},
                            tooltip: u.status == 'Active'
                                ? 'Deactivate'
                                : 'Activate',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RolesTab extends StatelessWidget {
  const _RolesTab(this.roles, this.permissions, this.modules);
  final List<WebUserMgmtRole> roles;
  final List<String> permissions;
  final List<String> modules;

  @override
  Widget build(BuildContext context) {
    if (roles.isEmpty || permissions.isEmpty || modules.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Text('No role matrix data loaded.'),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: roles.map((role) {
          final hasFullAccess = role.modules.contains('All Modules');
          return ExpansionTile(
            title: Text(role.title, style: AppTypography.titleSmall),
            subtitle: Text(
              'Modules: ${role.modules.join(", ")}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            trailing: hasFullAccess
                ? const NcChip(label: 'Full Access', color: AppColors.success)
                : null,
            children: [
              NcCard(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 3,
                            child: Text(
                              'Module',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          ...permissions.map(
                            (p) => Expanded(
                              child: Text(
                                p,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...modules.map((m) {
                      final hasAccess =
                          hasFullAccess ||
                          role.modules.contains(m) ||
                          role.modules.contains('All Modules');
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(m, style: AppTypography.bodySmall),
                            ),
                            ...permissions.map(
                              (p) => Expanded(
                                child: Checkbox(
                                  value: hasAccess,
                                  onChanged: (_) {},
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _AuditTab extends StatelessWidget {
  const _AuditTab(this.logs);
  final List<WebUserMgmtAudit> logs;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'No login audit entries yet.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: NcCard(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              color: AppColors.background,
              child: Row(
                children: const [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'User',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Time',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Device',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'IP',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Location',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Result',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            ...logs.map(
              (log) => Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: !log.success
                      ? AppColors.error.withValues(alpha: 0.05)
                      : null,
                  border: const Border(
                    bottom: BorderSide(color: AppColors.divider),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(log.user, style: AppTypography.labelMedium),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        log.time,
                        style: AppTypography.bodySmall.copyWith(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        log.device,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        log.ip,
                        style: AppTypography.bodySmall.copyWith(
                          fontFamily: 'JetBrainsMono',
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(log.location, style: AppTypography.bodySmall),
                    ),
                    Expanded(
                      flex: 2,
                      child: NcChip(
                        label: log.success ? 'Success' : 'Failed',
                        color: log.success
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
