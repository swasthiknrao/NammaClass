import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/demo_permissions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../providers/admin_providers.dart';
import '../../auth/providers/auth_provider.dart';

class ApprovalsScreen extends ConsumerWidget {
  const ApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approvalsAsync = ref.watch(adminApprovalsProvider);
    final canAct = ref
        .watch(demoPermissionsProvider)
        .contains(DemoPermission.approvalsWrite);

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(title: const Text('Approvals')),
      backgroundColor: Colors.transparent,
      body: approvalsAsync.when(
        loading: () =>
            const Padding(padding: EdgeInsets.all(16), child: NcShimmerList()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (approvals) => DefaultTabController(
          length: 3,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Pending'),
                  Tab(text: 'Approved'),
                  Tab(text: 'Rejected'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _ApprovalList(
                      canAct: canAct,
                      approvals: approvals
                          .where((a) => a.status == 'pending')
                          .toList(),
                    ),
                    _ApprovalList(
                      canAct: canAct,
                      approvals: approvals
                          .where((a) => a.status == 'approved')
                          .toList(),
                    ),
                    _ApprovalList(
                      canAct: canAct,
                      approvals: approvals
                          .where((a) => a.status == 'rejected')
                          .toList(),
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

class _ApprovalList extends StatelessWidget {
  const _ApprovalList({required this.approvals, required this.canAct});
  final List<MockApproval> approvals;
  final bool canAct;

  @override
  Widget build(BuildContext context) {
    if (approvals.isEmpty) {
      return const Center(child: Text('No records'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: approvals.length,
      itemBuilder: (ctx, i) {
        final a = approvals[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: NcCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    NcChip(label: a.type),
                    const Spacer(),
                    NcStatusChip(
                      type: a.status == 'approved'
                          ? NcChipType.present
                          : a.status == 'rejected'
                          ? NcChipType.absent
                          : NcChipType.pending,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(a.requestedBy, style: AppTypography.labelLarge),
                Text(
                  a.details,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  AppFormatters.timeAgo(a.date),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (a.status == 'pending' && canAct) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: NcSecondaryButton(
                          label: 'Reject',
                          color: AppColors.error,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Reject Reason'),
                                content: const TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Enter reason…',
                                  ),
                                  maxLines: 3,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                    ),
                                    child: const Text('Reject'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: NcPrimaryButton(
                          label: 'Approve',
                          color: AppColors.success,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Request approved!'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ] else if (a.status == 'pending' && !canAct) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Demo account lacks approvals:write — read-only.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
