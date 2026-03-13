import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';

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

  final _users = [
    _User(
      'Suresh Kumar',
      'suresh@vidyashree.edu.in',
      'Super Admin',
      '2026-03-05 09:12',
      'Active',
    ),
    _User(
      'Meena Iyer',
      'meena@vidyashree.edu.in',
      'Librarian',
      '2026-03-04 14:30',
      'Active',
    ),
    _User(
      'Rajesh Gowda',
      'rajesh@vidyashree.edu.in',
      'Teacher',
      '2026-03-06 08:45',
      'Active',
    ),
    _User(
      'Priya Sharma',
      'priya@vidyashree.edu.in',
      'Accountant',
      '2026-02-28 11:00',
      'Inactive',
    ),
  ];

  final _auditLog = [
    (
      'Suresh Kumar',
      '2026-03-06 09:12',
      'Chrome / Windows',
      '192.168.1.42',
      'Bengaluru',
      true,
    ),
    (
      'Meena Iyer',
      '2026-03-06 08:58',
      'Safari / macOS',
      '192.168.1.60',
      'Bengaluru',
      true,
    ),
    (
      'Unknown',
      '2026-03-05 23:11',
      'Firefox / Linux',
      '5.6.7.8',
      'Unknown',
      false,
    ),
  ];

  static const _roles = [
    ('Super Admin', ['All Modules']),
    ('Principal', ['Dashboard', 'Academics', 'HR', 'Reports', 'Analytics']),
    ('Accountant', ['Fees & Finance', 'Reports']),
    ('Librarian', ['Library']),
    ('Driver', ['Transport']),
    ('Teacher', ['Academics', 'Attendance', 'Communication']),
    ('HR Manager', ['HR & Staff', 'Payroll', 'Reports']),
  ];

  final failedLoginAlert = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (failedLoginAlert)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            color: AppColors.error.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(Icons.security, color: AppColors.error),
                const SizedBox(width: AppSpacing.xs),
                const Expanded(
                  child: Text(
                    'Multiple failed logins from IP 5.6.7.8. Auto-blocked for 1 hour.',
                    style: TextStyle(
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
              FilledButton.icon(
                onPressed: () => _showInviteDialog(context),
                icon: const Icon(Icons.person_add),
                label: const Text('Invite User'),
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
              _UsersTab(_users),
              _RolesTab(_roles),
              _AuditTab(_auditLog),
            ],
          ),
        ),
      ],
    );
  }

  void _showInviteDialog(BuildContext context) {
    String inviteEmail = '';
    String inviteRole = _roles.first.$1;
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
                    onChanged: (v) => inviteEmail = v ?? '',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    value: inviteRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    items: _roles
                        .map(
                          (r) =>
                              DropdownMenuItem(value: r.$1, child: Text(r.$1)),
                        )
                        .toList(),
                    onChanged: (v) {
                      setDialogState(() => inviteRole = v ?? _roles.first.$1);
                    },
                  ),
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
                      content: Text('Invitation sent to $inviteEmail!'),
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

class _User {
  _User(this.name, this.email, this.role, this.lastLogin, this.status);
  final String name;
  final String email;
  final String role;
  final String lastLogin;
  final String status;
}

class _UsersTab extends StatelessWidget {
  const _UsersTab(this.users);
  final List<_User> users;

  @override
  Widget build(BuildContext context) {
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
  const _RolesTab(this.roles);
  final List<(String, List<String>)> roles;

  @override
  Widget build(BuildContext context) {
    final permissions = ['View', 'Create', 'Edit', 'Delete', 'Export'];
    final modules = [
      'Dashboard',
      'Students',
      'Academics',
      'Fees & Finance',
      'HR & Staff',
      'Communication',
      'Library',
      'Transport',
      'Inventory',
      'Reports',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: roles.map((role) {
          final isSuperAdmin = role.$1 == 'Super Admin';
          return ExpansionTile(
            title: Text(role.$1, style: AppTypography.titleSmall),
            subtitle: Text(
              'Modules: ${role.$2.join(", ")}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            trailing: isSuperAdmin
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
                          isSuperAdmin ||
                          role.$2.contains(m) ||
                          role.$2.contains('All Modules');
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
  final List<(String, String, String, String, String, bool)> logs;

  @override
  Widget build(BuildContext context) {
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
                  color: !log.$6
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
                      child: Text(log.$1, style: AppTypography.labelMedium),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        log.$2,
                        style: AppTypography.bodySmall.copyWith(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        log.$3,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        log.$4,
                        style: AppTypography.bodySmall.copyWith(
                          fontFamily: 'JetBrainsMono',
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(log.$5, style: AppTypography.bodySmall),
                    ),
                    Expanded(
                      flex: 2,
                      child: NcChip(
                        label: log.$6 ? 'Success' : 'Failed',
                        color: log.$6 ? AppColors.success : AppColors.error,
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
