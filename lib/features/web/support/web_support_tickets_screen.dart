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

class WebSupportTicketsScreen extends ConsumerStatefulWidget {
  const WebSupportTicketsScreen({super.key});

  @override
  ConsumerState<WebSupportTicketsScreen> createState() =>
      _WebSupportTicketsScreenState();
}

class _WebSupportTicketsScreenState
    extends ConsumerState<WebSupportTicketsScreen> {
  String _statusFilter = 'all';
  String _priorityFilter = 'all';
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final tickets = MockData.supportTickets;

    final filtered = tickets.where((t) {
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        if (!t.subject.toLowerCase().contains(q) &&
            !t.id.toLowerCase().contains(q) &&
            !t.category.toLowerCase().contains(q)) {
          return false;
        }
      }
      if (_statusFilter != 'all' && t.status != _statusFilter) return false;
      if (_priorityFilter != 'all' && t.priority != _priorityFilter) {
        return false;
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Support Tickets', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Manage and resolve support tickets',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Filters
          NcCard(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by subject, ID, or category...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                      ),
                    ),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                DropdownButton<String>(
                  value: _statusFilter,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All status')),
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
                const SizedBox(width: AppSpacing.sm),
                DropdownButton<String>(
                  value: _priorityFilter,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All priority')),
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                    DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                  ],
                  onChanged: (v) =>
                      setState(() => _priorityFilter = v ?? 'all'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          filtered.isEmpty
              ? const NcEmptyState(
                  title: 'No tickets found',
                  subtitle: 'Try adjusting your filters.',
                  icon: Icons.inbox_outlined,
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, i) => _TicketCard(
                    ticket: filtered[i],
                    onReply: () => _showReplyDialog(context, filtered[i]),
                    onAssign: () => _showAssignDialog(context, filtered[i]),
                  ),
                ),
        ],
      ),
    );
  }

  void _showReplyDialog(BuildContext context, MockSupportTicket ticket) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reply to ${ticket.id}'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: 'Type your reply...',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reply sent for ${ticket.id}'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Send Reply'),
          ),
        ],
      ),
    );
  }

  void _showAssignDialog(BuildContext context, MockSupportTicket ticket) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Assign ${ticket.id}'),
        content: const Text(
          'Assign to team member (demo: assigns to Kiran Shetty)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${ticket.id} assigned to Kiran Shetty'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.ticket,
    required this.onReply,
    required this.onAssign,
  });
  final MockSupportTicket ticket;
  final VoidCallback onReply;
  final VoidCallback onAssign;

  Color _statusColor(String status) {
    switch (status) {
      case 'open':
        return AppColors.error;
      case 'in_progress':
        return AppColors.warning;
      case 'awaiting_response':
        return AppColors.accent;
      case 'resolved':
        return AppColors.success;
      case 'closed':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'urgent':
        return AppColors.error;
      case 'high':
        return AppColors.accent;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                ticket.id,
                style: AppTypography.labelMedium.copyWith(
                  fontFamily: 'monospace',
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              NcChip(label: ticket.category, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              NcChip(
                label: ticket.priority,
                color: _priorityColor(ticket.priority),
              ),
              const Spacer(),
              NcStatusChip(
                label: ticket.status.replaceAll('_', ' '),
                color: _statusColor(ticket.status),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppFormatters.timeAgo(ticket.createdAt),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(ticket.subject, style: AppTypography.titleSmall),
          if (ticket.description != null && ticket.description!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              ticket.description!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (ticket.assignee != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Assigned to: ${ticket.assignee}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              TextButton.icon(
                onPressed: onReply,
                icon: const Icon(Icons.reply, size: 18),
                label: const Text('Reply'),
              ),
              TextButton.icon(
                onPressed: onAssign,
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Assign'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
