import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/screen_size.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../providers/parent_providers.dart';

class ParentFeesScreen extends ConsumerWidget {
  const ParentFeesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feesAsync = ref.watch(parentFeesProvider);
    final isWide =
        ScreenSize.isDesktop(context) || ScreenSize.isTablet(context);

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(title: const Text('Fees & Payment')),
      backgroundColor: Colors.transparent,
      body: feesAsync.when(
        loading: () =>
            const Padding(padding: EdgeInsets.all(16), child: NcShimmerList()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (fees) {
          final totalPaise = fees.fold(0, (sum, f) => sum + f.amountPaise);
          final paidPaise = fees
              .where((f) => f.status == 'paid')
              .fold(0, (sum, f) => sum + f.amountPaise);
          final pendingPaise = totalPaise - paidPaise;
          final hasOverdue = fees.any((f) => f.status == 'overdue');
          final child = ref.watch(parentChildProvider);

          return isWide
              ? _DesktopFeesLayout(
                  child: child,
                  fees: fees,
                  totalPaise: totalPaise,
                  paidPaise: paidPaise,
                  pendingPaise: pendingPaise,
                  hasOverdue: hasOverdue,
                  onPayAll: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment gateway integration coming soon!'),
                    ),
                  ),
                )
              : _MobileFeesLayout(
                  fees: fees,
                  totalPaise: totalPaise,
                  paidPaise: paidPaise,
                  pendingPaise: pendingPaise,
                  hasOverdue: hasOverdue,
                  onPayAll: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment gateway integration coming soon!'),
                    ),
                  ),
                );
        },
      ),
    );
  }
}

// ── Mobile layout ─────────────────────────────────────────────────────────────

class _MobileFeesLayout extends StatelessWidget {
  const _MobileFeesLayout({
    required this.fees,
    required this.totalPaise,
    required this.paidPaise,
    required this.pendingPaise,
    required this.hasOverdue,
    required this.onPayAll,
  });
  final List<MockFeeInstallment> fees;
  final int totalPaise;
  final int paidPaise;
  final int pendingPaise;
  final bool hasOverdue;
  final VoidCallback onPayAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Balance card
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: NcCard(
            gradient: LinearGradient(
              colors: hasOverdue
                  ? [AppColors.error, const Color(0xFFCB4335)]
                  : [AppColors.success, AppColors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Outstanding Balance',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  AppFormatters.formatPaise(pendingPaise),
                  style: AppTypography.displayMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _BalanceStat(
                      'Total',
                      AppFormatters.formatPaise(totalPaise),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    _BalanceStat('Paid', AppFormatters.formatPaise(paidPaise)),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Tab bar — Pending / Paid / All
        DefaultTabController(
          length: 3,
          child: Expanded(
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Pending'),
                    Tab(text: 'Paid'),
                    Tab(text: 'All'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _FeeList(
                        fees: fees.where((f) => f.status != 'paid').toList(),
                      ),
                      _FeeList(
                        fees: fees.where((f) => f.status == 'paid').toList(),
                      ),
                      _FeeList(fees: fees),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Pay all footer
        if (pendingPaise > 0)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: AppColors.card,
            child: NcPrimaryButton(
              label: 'Pay All — ${AppFormatters.formatPaise(pendingPaise)}',
              fullWidth: true,
              onPressed: onPayAll,
            ),
          ),
      ],
    );
  }
}

// ── Desktop layout ─────────────────────────────────────────────────────────────

class _DesktopFeesLayout extends StatelessWidget {
  const _DesktopFeesLayout({
    required this.child,
    required this.fees,
    required this.totalPaise,
    required this.paidPaise,
    required this.pendingPaise,
    required this.hasOverdue,
    required this.onPayAll,
  });
  final MockStudent? child;
  final List<MockFeeInstallment> fees;
  final int totalPaise;
  final int paidPaise;
  final int pendingPaise;
  final bool hasOverdue;
  final VoidCallback onPayAll;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hero + balance inline
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _FeesHeroBanner(
                  childName: child?.name ?? '—',
                  classSection: child?.classSection ?? '—',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 4,
                child: _DesktopBalanceCard(
                  totalPaise: totalPaise,
                  paidPaise: paidPaise,
                  pendingPaise: pendingPaise,
                  hasOverdue: hasOverdue,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Summary + fee list
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FeesSummaryCards(
                      totalPaise: totalPaise,
                      paidPaise: paidPaise,
                      pendingPaise: pendingPaise,
                      fees: fees,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _PaymentMethodsCard(),
                    const SizedBox(height: AppSpacing.md),
                    _QuickTipsCard(),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 5,
                child: _DesktopFeeTabs(
                  fees: fees,
                  pendingPaise: pendingPaise,
                  onPayAll: onPayAll,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _DueReminderBar(fees: fees),
        ],
      ),
    );
  }
}

class _PaymentMethodsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment_rounded, color: AppColors.teal, size: 20),
              const SizedBox(width: 8),
              Text(
                'Pay via',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PayChip(Icons.credit_card, 'UPI'),
              _PayChip(Icons.account_balance, 'Bank'),
              _PayChip(Icons.store, 'Counter'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayChip extends StatelessWidget {
  const _PayChip(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.teal),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: AppColors.teal),
          ),
        ],
      ),
    );
  }
}

class _QuickTipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: AppColors.warning,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Tip',
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Pay before due date to avoid late fees. Receipts are sent to your registered email.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _DueReminderBar extends StatelessWidget {
  const _DueReminderBar({required this.fees});
  final List<MockFeeInstallment> fees;

  @override
  Widget build(BuildContext context) {
    final pending = fees.where((f) => f.status != 'paid').toList()
      ..sort((a, b) {
        if (a.status == 'overdue' && b.status != 'overdue') return -1;
        if (a.status != 'overdue' && b.status == 'overdue') return 1;
        return a.dueDate.compareTo(b.dueDate);
      });
    final next = pending.isNotEmpty ? pending.first : null;
    if (next == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            'Next due: ${next.label} — ${AppFormatters.formatPaise(next.amountPaise)} • ${AppFormatters.formatDate(next.dueDate)}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeesHeroBanner extends StatelessWidget {
  const _FeesHeroBanner({required this.childName, required this.classSection});
  final String childName;
  final String classSection;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.9),
            AppColors.teal,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fees & Payment',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  '$childName • $classSection',
                  style: AppTypography.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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

class _DesktopBalanceCard extends StatelessWidget {
  const _DesktopBalanceCard({
    required this.totalPaise,
    required this.paidPaise,
    required this.pendingPaise,
    required this.hasOverdue,
  });
  final int totalPaise;
  final int paidPaise;
  final int pendingPaise;
  final bool hasOverdue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasOverdue
              ? [AppColors.error, const Color(0xFFCB4335)]
              : [AppColors.success, AppColors.teal],
        ),
        boxShadow: [
          BoxShadow(
            color: (hasOverdue ? AppColors.error : AppColors.success)
                .withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Outstanding Balance',
            style: AppTypography.labelLarge.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppFormatters.formatPaise(pendingPaise),
            style: AppTypography.headlineLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _BalanceStat('Total', AppFormatters.formatPaise(totalPaise)),
              const SizedBox(width: AppSpacing.xl),
              _BalanceStat('Paid', AppFormatters.formatPaise(paidPaise)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeesSummaryCards extends StatelessWidget {
  const _FeesSummaryCards({
    required this.totalPaise,
    required this.paidPaise,
    required this.pendingPaise,
    required this.fees,
  });
  final int totalPaise;
  final int paidPaise;
  final int pendingPaise;
  final List<MockFeeInstallment> fees;

  @override
  Widget build(BuildContext context) {
    final paidCount = fees.where((f) => f.status == 'paid').length;
    final pendingCount = fees.where((f) => f.status != 'paid').length;

    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            icon: Icons.check_circle_rounded,
            label: '$paidCount Paid',
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _SummaryTile(
            icon: Icons.schedule_rounded,
            label: '$pendingCount Pending',
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopFeeTabs extends StatelessWidget {
  const _DesktopFeeTabs({
    required this.fees,
    required this.pendingPaise,
    required this.onPayAll,
  });
  final List<MockFeeInstallment> fees;
  final int pendingPaise;
  final VoidCallback onPayAll;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBar(
              labelColor: AppColors.primary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'Paid'),
                Tab(text: 'All'),
              ],
            ),
            SizedBox(
              height: 320,
              child: TabBarView(
                children: [
                  _FeeList(
                    fees: fees.where((f) => f.status != 'paid').toList(),
                  ),
                  _FeeList(
                    fees: fees.where((f) => f.status == 'paid').toList(),
                  ),
                  _FeeList(fees: fees),
                ],
              ),
            ),
            if (pendingPaise > 0) ...[
              const SizedBox(height: AppSpacing.md),
              NcPrimaryButton(
                label: 'Pay All — ${AppFormatters.formatPaise(pendingPaise)}',
                fullWidth: true,
                onPressed: onPayAll,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  const _BalanceStat(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: Colors.white70),
        ),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}

class _FeeList extends StatelessWidget {
  const _FeeList({required this.fees});
  final List fees;

  @override
  Widget build(BuildContext context) {
    if (fees.isEmpty) {
      return const Center(child: Text('No records'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: fees.length,
      itemBuilder: (ctx, i) {
        final fee = fees[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: NcCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fee.label, style: AppTypography.labelLarge),
                      Text(
                        'Due: ${AppFormatters.formatDate(fee.dueDate)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (fee.paidDate != null)
                        Text(
                          'Paid: ${AppFormatters.formatDate(fee.paidDate!)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppFormatters.formatPaise(fee.amountPaise as int),
                      style: AppTypography.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    NcStatusChip(type: _chipType(fee.status as String)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  NcChipType _chipType(String status) {
    switch (status) {
      case 'paid':
        return NcChipType.paid;
      case 'overdue':
        return NcChipType.overdue;
      default:
        return NcChipType.pending;
    }
  }
}
