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

class ParentComplaintsScreen extends ConsumerWidget {
  const ParentComplaintsScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'Open':
        return AppColors.error;
      case 'In Progress':
        return AppColors.warning;
      case 'Awaiting Response':
        return AppColors.accent;
      case 'Resolved':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'High':
        return AppColors.accent;
      case 'Urgent':
        return AppColors.error;
      case 'Low':
        return AppColors.textSecondary;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complaints = MockData.complaints;
    return Scaffold(
      appBar: AppBar(title: const Text('My Complaints')),
      body: complaints.isEmpty
          ? const NcEmptyState(
              title: 'No complaints raised',
              subtitle: 'Tap below to raise a complaint.',
              icon: Icons.report_outlined,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: complaints.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (ctx, i) => _ComplaintCard(
                complaints[i],
                statusColor: _statusColor(complaints[i].status),
                priorityColor: _priorityColor(complaints[i].priority),
                onTap: () => _showThread(ctx, complaints[i]),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.parentComplaintNew),
        icon: const Icon(Icons.add),
        label: const Text('Raise Complaint'),
        backgroundColor: AppColors.deepPurple,
      ),
    );
  }

  void _showThread(BuildContext context, MockComplaint complaint) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ComplaintThreadScreen(complaint: complaint),
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  const _ComplaintCard(
    this.complaint, {
    required this.statusColor,
    required this.priorityColor,
    required this.onTap,
  });
  final MockComplaint complaint;
  final Color statusColor;
  final Color priorityColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: NcCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '#${complaint.ticketId}',
                  style: AppTypography.labelMedium.copyWith(
                    fontFamily: 'JetBrainsMono',
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                NcChip(label: complaint.category, color: AppColors.primary),
                const Spacer(),
                NcChip(label: complaint.priority, color: priorityColor),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(complaint.subject, style: AppTypography.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              complaint.description,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                NcStatusChip(label: complaint.status, color: statusColor),
                const Spacer(),
                Text(
                  AppFormatters.shortDate(complaint.createdAt),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ComplaintThreadScreen extends StatefulWidget {
  const _ComplaintThreadScreen({required this.complaint});
  final MockComplaint complaint;

  @override
  State<_ComplaintThreadScreen> createState() => _ComplaintThreadScreenState();
}

class _ComplaintThreadScreenState extends State<_ComplaintThreadScreen> {
  final _replyCtrl = TextEditingController();
  final List<MockComplaintResponse> _replies = [];

  @override
  void initState() {
    super.initState();
    _replies.addAll(widget.complaint.responses);
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  void _sendReply() {
    final msg = _replyCtrl.text.trim();
    if (msg.isEmpty) return;
    setState(() {
      _replies.add(
        MockComplaintResponse(
          sender: 'You',
          message: msg,
          timestamp: DateTime.now(),
          isAdmin: false,
        ),
      );
      _replyCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('#${widget.complaint.ticketId}')),
      body: Column(
        children: [
          // Complaint summary
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.complaint.subject, style: AppTypography.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.complaint.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Thread
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: _replies.length,
              itemBuilder: (ctx, i) {
                final r = _replies[i];
                return _MessageBubble(response: r);
              },
            ),
          ),

          // Reply input
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.card,
              border: const Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Type a reply...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    maxLines: 2,
                    maxLength: 500,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton.filled(
                  onPressed: _sendReply,
                  icon: const Icon(Icons.send),
                  color: Colors.white,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.response});
  final MockComplaintResponse response;

  @override
  Widget build(BuildContext context) {
    final isAdmin = response.isAdmin;
    return Align(
      alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.sm),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isAdmin
              ? AppColors.card
              : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isAdmin ? Radius.zero : const Radius.circular(12),
            bottomRight: isAdmin ? const Radius.circular(12) : Radius.zero,
          ),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              response.sender,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(response.message, style: AppTypography.bodySmall),
            const SizedBox(height: 4),
            Text(
              AppFormatters.time(response.timestamp),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
