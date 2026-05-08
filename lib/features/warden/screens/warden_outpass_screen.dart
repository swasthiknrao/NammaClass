import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/launch_utils.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../providers/warden_provider.dart';

/// Outpass / leave requests — approve, reject, track.
class WardenOutpassScreen extends ConsumerStatefulWidget {
  const WardenOutpassScreen({super.key});

  @override
  ConsumerState<WardenOutpassScreen> createState() =>
      _WardenOutpassScreenState();
}

class _WardenOutpassScreenState extends ConsumerState<WardenOutpassScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _approve(MockHostelOutpass op) {
    setState(() {
      op.status = 'approved';
      op.approvedBy = 'Warden';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Outpass approved'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _reject(MockHostelOutpass op) {
    setState(() => op.status = 'rejected');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Outpass rejected')));
  }

  @override
  Widget build(BuildContext context) {
    final outpasses = ref.watch(wardenOutpassesProvider);
    final pending = outpasses.where((o) => o.status == 'pending').toList();
    final other = outpasses.where((o) => o.status != 'pending').toList();

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(
              title: const Text('Outpass & Leave'),
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'Pending (${pending.length})'),
                  const Tab(text: 'History'),
                ],
              ),
            ),
      body: TabBarView(
        controller: _tabController,
        children: [
          pending.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 48,
                        color: AppColors.success.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'No pending requests',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: pending.length,
                  itemBuilder: (_, i) {
                    final op = pending[i];
                    final student = getHostelStudentByName(op.studentName);
                    return _OutpassCard(
                      op: op,
                      student: student,
                      onApprove: () => _approve(op),
                      onReject: () => _reject(op),
                      showActions: true,
                    );
                  },
                ),
          other.isEmpty
              ? Center(
                  child: Text(
                    'No completed requests',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: other.length,
                  itemBuilder: (_, i) {
                    final op = other[i];
                    final student = getHostelStudentByName(op.studentName);
                    return _OutpassCard(
                      op: op,
                      student: student,
                      showActions: false,
                    );
                  },
                ),
        ],
      ),
    );
  }
}

class _OutpassCard extends StatelessWidget {
  const _OutpassCard({
    required this.op,
    this.student,
    required this.showActions,
    this.onApprove,
    this.onReject,
  });
  final MockHostelOutpass op;
  final MockHostelStudent? student;
  final bool showActions;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final isApproved = op.status == 'approved';

    return NcCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.event_busy,
                  color: AppColors.teal,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(op.studentName, style: AppTypography.titleSmall),
                    Text(
                      '${op.reason}  ·  ${AppFormatters.shortDate(op.fromDate)} — ${AppFormatters.shortDate(op.toDate)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (showActions) ...[
                TextButton(
                  onPressed: onReject,
                  child: Text(
                    'Reject',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
                FilledButton(
                  onPressed: onApprove,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                  ),
                  child: const Text('Approve'),
                ),
              ] else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isApproved
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    op.status.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      color: isApproved ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (student != null) ...[
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Parent: ${student!.parentName ?? "—"}  ·  ${student!.parentPhone ?? "—"}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (student!.parentPhone != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.phone, size: 18),
                    onPressed: () => launchTel(
                      context,
                      phone: student!.parentPhone!,
                      fallbackSnackBar: 'Cannot call',
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.success.withValues(
                        alpha: 0.15,
                      ),
                      padding: const EdgeInsets.all(6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
