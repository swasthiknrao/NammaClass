import 'package:fl_chart/fl_chart.dart';
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

class WebAccountantDashboardScreen extends ConsumerWidget {
  const WebAccountantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const todayCollectionPaise = 12500000; // ₹1.25L
    const pendingTotalPaise = 48500000; // From admin KPIs
    const overduePaise = 8500000;

    final collectionTrend = [42.0, 65.0, 58.0, 72.0, 88.0, 95.0, 79.0];
    final pendingByClass = [
      ('8-A', 1250000),
      ('9-B', 980000),
      ('7-C', 760000),
      ('10-A', 620000),
      ('6-B', 450000),
    ];
    final recentTx = [
      ('Arjun Kumar', 25000, 'Term 1', '10 min ago'),
      ('Priya M', 15000, 'Transport', '25 min ago'),
      ('Suresh R', 35000, 'Term 1 + 2', '1 hr ago'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Finance Dashboard',
                    style: AppTypography.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Overview of fee collection and pending dues',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.webFeeCollect),
                icon: const Icon(Icons.point_of_sale, size: 20),
                label: const Text('Collect Fees'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Hero KPI cards
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth > 900
                  ? 4
                  : (constraints.maxWidth > 600 ? 2 : 1);
              return GridView.count(
                crossAxisCount: count,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 2.0,
                children: [
                  _HeroKpiCard(
                    'Today\'s Collection',
                    AppFormatters.formatPaiseCompact(todayCollectionPaise),
                    Icons.today,
                    AppColors.success,
                  ),
                  _HeroKpiCard(
                    'Total Pending',
                    AppFormatters.formatPaiseCompact(pendingTotalPaise),
                    Icons.pending_actions,
                    AppColors.warning,
                  ),
                  _HeroKpiCard(
                    'Overdue Amount',
                    AppFormatters.formatPaiseCompact(overduePaise),
                    Icons.schedule,
                    AppColors.error,
                  ),
                  _HeroKpiCard(
                    'Students Cleared',
                    '${MockData.students.where((s) => s.feeStatus == 'paid').length}',
                    Icons.check_circle_outline,
                    AppColors.primary,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          // Chart + Quick actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: NcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Collection Trend (Last 7 Days)',
                        style: AppTypography.labelLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (v) => const FlLine(
                                color: AppColors.divider,
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 36,
                                  getTitlesWidget: (v, m) => Text(
                                    '₹${v.toInt()}K',
                                    style: AppTypography.labelSmall,
                                  ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (v, m) {
                                    const days = [
                                      'Mon',
                                      'Tue',
                                      'Wed',
                                      'Thu',
                                      'Fri',
                                      'Sat',
                                      'Sun',
                                    ];
                                    return Text(
                                      days[v.toInt() % 7],
                                      style: AppTypography.labelSmall,
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: collectionTrend
                                    .asMap()
                                    .entries
                                    .map(
                                      (e) => FlSpot(e.key.toDouble(), e.value),
                                    )
                                    .toList(),
                                isCurved: true,
                                color: AppColors.success,
                                barWidth: 3,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppColors.success.withValues(
                                    alpha: 0.15,
                                  ),
                                ),
                              ),
                            ],
                            minY: 0,
                            maxY: 100,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 1,
                child: NcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quick Actions', style: AppTypography.labelLarge),
                      const SizedBox(height: AppSpacing.md),
                      _QuickAction(
                        label: 'Collect Fees',
                        icon: Icons.point_of_sale,
                        onTap: () => context.go(AppRoutes.webFeeCollect),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _QuickAction(
                        label: 'Finance Ledger',
                        icon: Icons.account_balance,
                        onTap: () => context.go(AppRoutes.webFinanceLedger),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _QuickAction(
                        label: 'Print Summary',
                        icon: Icons.print,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Today\'s summary sent to printer'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Pending by class + Recent
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: NcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pending by Class', style: AppTypography.labelLarge),
                      const SizedBox(height: AppSpacing.md),
                      ...pendingByClass.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.xs,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    e.$1,
                                    style: AppTypography.labelMedium.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: (e.$2 / 1250000).clamp(0.0, 1.0),
                                  backgroundColor: AppColors.divider,
                                  valueColor: const AlwaysStoppedAnimation(
                                    AppColors.warning,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                AppFormatters.formatPaiseCompact(e.$2 * 100),
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: NcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Collections',
                            style: AppTypography.labelLarge,
                          ),
                          TextButton(
                            onPressed: () =>
                                context.go(AppRoutes.webFeeCollect),
                            child: const Text('View all'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...recentTx.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.success.withValues(
                                  alpha: 0.15,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: AppColors.success,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(e.$1, style: AppTypography.bodyMedium),
                                    Text(
                                      '${e.$3} · ${e.$4}',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                AppFormatters.formatPaise(e.$2 * 100),
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroKpiCard extends StatelessWidget {
  const _HeroKpiCard(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: AppTypography.headlineMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTypography.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
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
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(label, style: AppTypography.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
