import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../routing/app_routes.dart';

class WebSupportDashboardScreen extends ConsumerWidget {
  const WebSupportDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tickets = MockData.supportTickets;
    final complaints = MockData.complaints;

    final openTickets = tickets.where((t) => t.status == 'open').length;
    final inProgressTickets = tickets
        .where((t) => t.status == 'in_progress')
        .length;
    final resolvedToday = tickets
        .where((t) => t.status == 'resolved' && _isToday(t.createdAt))
        .length;
    final openComplaints = complaints
        .where((c) => c.status != 'Resolved' && c.status != 'Closed')
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header — minimal, dynamic
          _HeaderSection(),
          const SizedBox(height: AppSpacing.xl),

          // KPI strip — horizontal scroll on narrow, no overflow
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              return SingleChildScrollView(
                scrollDirection: isNarrow ? Axis.horizontal : Axis.vertical,
                child: isNarrow
                    ? IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _KpiCard(
                              'Open',
                              '$openTickets',
                              Icons.inbox_outlined,
                              AppColors.error,
                              compact: true,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _KpiCard(
                              'Progress',
                              '$inProgressTickets',
                              Icons.sync_outlined,
                              AppColors.warning,
                              compact: true,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _KpiCard(
                              'Resolved',
                              '$resolvedToday',
                              Icons.check_circle_outline,
                              AppColors.success,
                              compact: true,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _KpiCard(
                              'Complaints',
                              '$openComplaints',
                              Icons.report_problem_outlined,
                              AppColors.accent,
                              compact: true,
                            ),
                          ],
                        ),
                      )
                    : Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        children: [
                          _KpiCard(
                            'Open Tickets',
                            '$openTickets',
                            Icons.inbox_outlined,
                            AppColors.error,
                          ),
                          _KpiCard(
                            'In Progress',
                            '$inProgressTickets',
                            Icons.sync_outlined,
                            AppColors.warning,
                          ),
                          _KpiCard(
                            'Resolved Today',
                            '$resolvedToday',
                            Icons.check_circle_outline,
                            AppColors.success,
                          ),
                          _KpiCard(
                            'Open Complaints',
                            '$openComplaints',
                            Icons.report_problem_outlined,
                            AppColors.accent,
                          ),
                        ],
                      ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),

          // Content — responsive row/column
          LayoutBuilder(
            builder: (context, constraints) {
              final useColumn = constraints.maxWidth < 700;
              return useColumn
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _QuickActionsCard(
                          onViewTickets: () =>
                              context.go(AppRoutes.webSupportTickets),
                          onComplaints: () =>
                              context.go(AppRoutes.webSupportComplaints),
                          onKb: () =>
                              context.go(AppRoutes.webSupportKnowledgeBase),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _RecentTicketsCard(tickets: tickets),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _QuickActionsCard(
                            onViewTickets: () =>
                                context.go(AppRoutes.webSupportTickets),
                            onComplaints: () =>
                                context.go(AppRoutes.webSupportComplaints),
                            onKb: () =>
                                context.go(AppRoutes.webSupportKnowledgeBase),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          flex: 3,
                          child: _RecentTicketsCard(tickets: tickets),
                        ),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }

  static bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }
}

class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.06),
            AppColors.teal.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Icon(
                  Icons.support_agent_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Support Dashboard',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Track tickets and complaints at a glance',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard(
    this.label,
    this.value,
    this.icon,
    this.color, {
    this.compact = false,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.md : AppSpacing.lg,
        vertical: compact ? AppSpacing.sm : AppSpacing.md,
      ),
      child: compact
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  value,
                  style: AppTypography.titleMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    label,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(icon, color: color, size: 18),
                    ),
                    const Spacer(),
                    Text(
                      value,
                      style: AppTypography.headlineSmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({
    required this.onViewTickets,
    required this.onComplaints,
    required this.onKb,
  });
  final VoidCallback onViewTickets;
  final VoidCallback onComplaints;
  final VoidCallback onKb;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _QuickActionChip(
                label: 'Tickets',
                icon: Icons.confirmation_number_outlined,
                onTap: onViewTickets,
              ),
              _QuickActionChip(
                label: 'Complaints',
                icon: Icons.report_outlined,
                onTap: onComplaints,
              ),
              _QuickActionChip(
                label: 'KB',
                icon: Icons.menu_book_outlined,
                onTap: onKb,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentTicketsCard extends StatelessWidget {
  const _RecentTicketsCard({required this.tickets});
  final List<MockSupportTicket> tickets;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Tickets',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.webSupportTickets),
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          tickets.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Center(
                    child: Text(
                      'No tickets yet',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tickets.take(5).length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final t = tickets[i];
                    return _TicketRow(ticket: t);
                  },
                ),
        ],
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({required this.ticket});
  final MockSupportTicket ticket;

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
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(AppRoutes.webSupportTickets),
      borderRadius: BorderRadius.circular(AppSpacing.xs),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ticket.subject,
                    style: AppTypography.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${ticket.id} · ${ticket.category}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              fit: FlexFit.loose,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor(ticket.status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.xxl),
                ),
                child: Text(
                  ticket.status.replaceAll('_', ' '),
                  style: AppTypography.labelSmall.copyWith(
                    color: _statusColor(ticket.status),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                AppFormatters.timeAgo(ticket.createdAt),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
