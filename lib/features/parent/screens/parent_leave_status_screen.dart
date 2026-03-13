import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../core/widgets/nc_empty_state.dart';
import '../../../routing/app_routes.dart';

class ParentLeaveStatusScreen extends ConsumerStatefulWidget {
  const ParentLeaveStatusScreen({super.key});

  @override
  ConsumerState<ParentLeaveStatusScreen> createState() =>
      _ParentLeaveStatusScreenState();
}

class _ParentLeaveStatusScreenState
    extends ConsumerState<ParentLeaveStatusScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  List<MockLeaveApplication> _filtered(String status) {
    if (status == 'all') return MockData.leaveApplications;
    return MockData.leaveApplications.where((l) => l.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pending = _filtered('pending').length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Status'),
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pending'),
                  if (pending > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$pending',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Approved'),
            const Tab(text: 'Rejected'),
            const Tab(text: 'All'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Balance row
          Container(
            color: AppColors.teal.withValues(alpha: 0.08),
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.lg,
            ),
            child: Row(
              children: [
                _BalanceBox('8/12', 'CL'),
                _BalanceBox('5/12', 'SL'),
                _BalanceBox('4', 'Used'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _LeaveList(
                  _filtered('pending'),
                  canCancel: true,
                  onCancel: _cancelLeave,
                ),
                _LeaveList(_filtered('approved')),
                _LeaveList(_filtered('rejected')),
                _LeaveList(_filtered('all')),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.parentLeaveApply),
        icon: const Icon(Icons.add),
        label: const Text('Apply Leave'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _cancelLeave(MockLeaveApplication leave) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Application'),
        content: const Text(
          'Are you sure you want to cancel this leave application?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Leave application cancelled.')),
              );
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

class _LeaveList extends StatelessWidget {
  const _LeaveList(this.leaves, {this.canCancel = false, this.onCancel});
  final List<MockLeaveApplication> leaves;
  final bool canCancel;
  final void Function(MockLeaveApplication)? onCancel;

  @override
  Widget build(BuildContext context) {
    if (leaves.isEmpty) {
      return const NcEmptyState(
        title: 'No leave applications yet',
        subtitle: 'Tap the button below to apply for leave.',
        icon: Icons.event_note_outlined,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: leaves.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) =>
          _LeaveCard(leaves[i], canCancel: canCancel, onCancel: onCancel),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  const _LeaveCard(this.leave, {required this.canCancel, this.onCancel});
  final MockLeaveApplication leave;
  final bool canCancel;
  final void Function(MockLeaveApplication)? onCancel;

  @override
  Widget build(BuildContext context) {
    final statusColor = leave.status == 'approved'
        ? AppColors.success
        : leave.status == 'rejected'
        ? AppColors.error
        : AppColors.warning;

    return NcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(leave.type, style: AppTypography.titleSmall),
              ),
              NcStatusChip(
                label:
                    leave.status[0].toUpperCase() + leave.status.substring(1),
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${AppFormatters.shortDate(leave.fromDate)} — ${AppFormatters.shortDate(leave.toDate)}  ·  ${leave.workingDays} working day${leave.workingDays == 1 ? '' : 's'}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            leave.reason,
            style: AppTypography.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (leave.status == 'approved' && leave.approvedBy != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Approved by: ${leave.approvedBy}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.success),
            ),
          ],
          if (leave.status == 'rejected' && leave.rejectionReason != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
              child: Text(
                'Rejected: ${leave.rejectionReason}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
              ),
            ),
          ],
          if (canCancel && leave.status == 'pending') ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => onCancel?.call(leave),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Cancel Application'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BalanceBox extends StatelessWidget {
  const _BalanceBox(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.teal,
              fontFamily: 'JetBrainsMono',
            ),
          ),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
