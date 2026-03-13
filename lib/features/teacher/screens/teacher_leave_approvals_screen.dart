import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_avatar.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../core/widgets/nc_empty_state.dart';

class TeacherLeaveApprovalsScreen extends ConsumerStatefulWidget {
  const TeacherLeaveApprovalsScreen({super.key});

  @override
  ConsumerState<TeacherLeaveApprovalsScreen> createState() =>
      _TeacherLeaveApprovalsScreenState();
}

class _TeacherLeaveApprovalsScreenState
    extends ConsumerState<TeacherLeaveApprovalsScreen> {
  // Simulated pending leave requests for the teacher's class
  final List<_PendingLeave> _pending = [
    _PendingLeave(
      id: 'pl001',
      studentName: 'Arjun Kumar',
      rollNo: '05',
      type: 'Sick Leave',
      fromDate: DateTime.now().add(const Duration(days: 1)),
      toDate: DateTime.now().add(const Duration(days: 2)),
      workingDays: 2,
      reason: 'High fever. Medical certificate attached.',
      parentName: 'Suresh Kumar',
    ),
    _PendingLeave(
      id: 'pl002',
      studentName: 'Preethi Nair',
      rollNo: '12',
      type: 'Casual Leave',
      fromDate: DateTime.now().add(const Duration(days: 3)),
      toDate: DateTime.now().add(const Duration(days: 5)),
      workingDays: 3,
      reason: 'Family function — cousin\'s wedding.',
      parentName: 'Ramesh Nair',
    ),
    _PendingLeave(
      id: 'pl003',
      studentName: 'Kiran Rao',
      rollNo: '08',
      type: 'Half Day',
      fromDate: DateTime.now().add(const Duration(days: 1)),
      toDate: DateTime.now().add(const Duration(days: 1)),
      workingDays: 1,
      reason: 'Dental appointment in the afternoon.',
      parentName: 'Mohan Rao',
    ),
  ];

  final _approvedIds = <String>{};
  final _rejectedIds = <String>{};

  Future<void> _approve(_PendingLeave leave) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _approvedIds.add(leave.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Leave approved for ${leave.studentName}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _reject(_PendingLeave leave) async {
    final ctrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rejection Reason'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Reason for rejection...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isEmpty) return;
              Navigator.pop(ctx, ctrl.text.trim());
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (reason == null || !mounted) return;
    setState(() => _rejectedIds.add(leave.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Leave rejected for ${leave.studentName}'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _pending
        .where(
          (l) => !_approvedIds.contains(l.id) && !_rejectedIds.contains(l.id),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Requests'),
        actions: [
          TextButton(onPressed: () {}, child: const Text('View History')),
        ],
      ),
      body: remaining.isEmpty
          ? const NcEmptyState(
              title: 'No pending leave requests',
              subtitle: 'All student leave applications have been reviewed.',
              icon: Icons.how_to_reg_outlined,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: remaining.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) => _LeaveApprovalCard(
                leave: remaining[i],
                onApprove: () => _approve(remaining[i]),
                onReject: () => _reject(remaining[i]),
              ),
            ),
    );
  }
}

class _LeaveApprovalCard extends StatelessWidget {
  const _LeaveApprovalCard({
    required this.leave,
    required this.onApprove,
    required this.onReject,
  });
  final _PendingLeave leave;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NcAvatar(name: leave.studentName, radius: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(leave.studentName, style: AppTypography.titleSmall),
                    Text(
                      'Roll No. ${leave.rollNo} | Parent: ${leave.parentName}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              NcChip(label: leave.type, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${AppFormatters.shortDate(leave.fromDate)} — ${AppFormatters.shortDate(leave.toDate)}  (${leave.workingDays} days)',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(leave.reason, style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onApprove,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                  ),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Approve'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Reject'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PendingLeave {
  _PendingLeave({
    required this.id,
    required this.studentName,
    required this.rollNo,
    required this.type,
    required this.fromDate,
    required this.toDate,
    required this.workingDays,
    required this.reason,
    required this.parentName,
  });
  final String id;
  final String studentName;
  final String rollNo;
  final String type;
  final DateTime fromDate;
  final DateTime toDate;
  final int workingDays;
  final String reason;
  final String parentName;
}
