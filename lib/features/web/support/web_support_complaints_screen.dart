import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../core/widgets/nc_empty_state.dart';

class WebSupportComplaintsScreen extends ConsumerStatefulWidget {
  const WebSupportComplaintsScreen({super.key});

  @override
  ConsumerState<WebSupportComplaintsScreen> createState() =>
      _WebSupportComplaintsScreenState();
}

class _WebSupportComplaintsScreenState
    extends ConsumerState<WebSupportComplaintsScreen> {
  String _statusFilter = 'all';

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
  Widget build(BuildContext context) {
    final complaints = MockData.complaints;

    final filtered = complaints.where((c) {
      if (_statusFilter == 'all') return true;
      return c.status.toLowerCase().replaceAll(' ', '_') == _statusFilter;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Complaints', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'View and respond to parent complaints',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Filter
          NcCard(
            child: Row(
              children: [
                Text('Status:', style: AppTypography.labelMedium),
                const SizedBox(width: AppSpacing.sm),
                DropdownButton<String>(
                  value: _statusFilter,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'open', child: Text('Open')),
                    DropdownMenuItem(
                      value: 'in_progress',
                      child: Text('In Progress'),
                    ),
                    DropdownMenuItem(
                      value: 'awaiting_response',
                      child: Text('Awaiting Response'),
                    ),
                    DropdownMenuItem(
                      value: 'resolved',
                      child: Text('Resolved'),
                    ),
                    DropdownMenuItem(value: 'closed', child: Text('Closed')),
                  ],
                  onChanged: (v) => setState(() => _statusFilter = v ?? 'all'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          filtered.isEmpty
              ? const NcEmptyState(
                  title: 'No complaints found',
                  subtitle: 'Try adjusting the status filter.',
                  icon: Icons.report_outlined,
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, i) => _ComplaintCard(
                    complaint: filtered[i],
                    statusColor: _statusColor(filtered[i].status),
                    priorityColor: _priorityColor(filtered[i].priority),
                    onTap: () => _showThread(context, filtered[i]),
                  ),
                ),
        ],
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
  const _ComplaintCard({
    required this.complaint,
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
                    fontFamily: 'monospace',
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
          sender: 'Support',
          message: msg,
          timestamp: DateTime.now(),
          isAdmin: true,
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
