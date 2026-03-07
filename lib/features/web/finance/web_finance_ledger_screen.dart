import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_card.dart';

class WebFinanceLedgerScreen extends ConsumerStatefulWidget {
  const WebFinanceLedgerScreen({super.key});

  @override
  ConsumerState<WebFinanceLedgerScreen> createState() =>
      _WebFinanceLedgerScreenState();
}

class _WebFinanceLedgerScreenState extends ConsumerState<WebFinanceLedgerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  final _income = [
    ('Fee Collection', 4850000, 'Mar 1'),
    ('Transport Fee', 120000, 'Mar 3'),
    ('Late Fine', 15000, 'Mar 5'),
    ('Canteen Sales', 45000, 'Mar 6'),
  ];

  final _expenses = [
    ('Staff Salaries', 3200000, 'Mar 1'),
    ('Electricity', 45000, 'Mar 2'),
    ('Maintenance', 28000, 'Mar 4'),
    ('Stationery', 12000, 'Mar 5'),
  ];

  @override
  Widget build(BuildContext context) {
    final totalIncome = _income.fold(0, (sum, e) => sum + e.$2);
    final totalExpense = _expenses.fold(0, (sum, e) => sum + e.$2);
    final profit = totalIncome - totalExpense;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Finance Ledger — March 2026',
                style: AppTypography.headlineMedium,
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download),
                label: const Text('Export'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // P&L summary
          Row(
            children: [
              Expanded(
                child: _PLCard('Total Income', totalIncome, AppColors.success),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _PLCard('Total Expenses', totalExpense, AppColors.error),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _PLCard(
                  'Net Profit / Loss',
                  profit,
                  profit >= 0 ? AppColors.success : AppColors.error,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _PLCard('Petty Cash', 25000, AppColors.primary)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // P&L chart
          NcCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Income vs Expenses (This Month)',
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: totalIncome / 100000,
                              color: AppColors.success,
                              width: 32,
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: totalExpense / 100000,
                              color: AppColors.error,
                              width: 32,
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 2,
                          barRods: [
                            BarChartRodData(
                              toY: profit / 100000,
                              color: profit >= 0
                                  ? AppColors.teal
                                  : AppColors.error,
                              width: 32,
                            ),
                          ],
                        ),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              const labels = ['Income', 'Expenses', 'Net'];
                              final i = v.toInt();
                              if (i < 0 || i >= labels.length)
                                return const SizedBox();
                              return Text(labels[i]);
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) => Text(
                              '₹${v.toInt()}L',
                              style: const TextStyle(fontSize: 10),
                            ),
                            reservedSize: 40,
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Tabs
          TabBar(
            controller: _tabs,
            tabs: const [
              Tab(text: 'Income'),
              Tab(text: 'Expenses'),
              Tab(text: 'P&L Statement'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabs,
              children: [
                _LedgerTable(_income, color: AppColors.success),
                _LedgerTable(_expenses, color: AppColors.error),
                _PLStatement(
                  income: totalIncome,
                  expenses: totalExpense,
                  profit: profit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PLCard extends StatelessWidget {
  const _PLCard(this.label, this.amount, this.color);
  final String label;
  final int amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppFormatters.currency(amount),
            style: AppTypography.titleMedium.copyWith(
              color: color,
              fontFamily: 'JetBrainsMono',
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerTable extends StatelessWidget {
  const _LedgerTable(this.entries, {required this.color});
  final List<(String, int, String)> entries;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          color: AppColors.background,
          child: Row(
            children: const [
              Expanded(
                flex: 4,
                child: Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Amount',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Date',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        ...entries.map(
          (e) => Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(e.$1, style: AppTypography.bodyMedium),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    AppFormatters.currency(e.$2),
                    style: AppTypography.labelMedium.copyWith(
                      color: color,
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    e.$3,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PLStatement extends StatelessWidget {
  const _PLStatement({
    required this.income,
    required this.expenses,
    required this.profit,
  });
  final int income;
  final int expenses;
  final int profit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PLLine('Total Income', income, AppColors.success),
          _PLLine('Total Expenses', expenses, AppColors.error),
          const Divider(),
          _PLLine(
            'Net Profit / Loss',
            profit,
            profit >= 0 ? AppColors.success : AppColors.error,
            isTotal: true,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Profit Margin: ${(profit / income * 100).toStringAsFixed(1)}%',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PLLine extends StatelessWidget {
  const _PLLine(this.label, this.amount, this.color, {this.isTotal = false});
  final String label;
  final int amount;
  final Color color;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTypography.titleSmall
                : AppTypography.bodyMedium,
          ),
          Text(
            AppFormatters.currency(amount),
            style:
                (isTotal ? AppTypography.titleSmall : AppTypography.bodyMedium)
                    .copyWith(color: color, fontFamily: 'JetBrainsMono'),
          ),
        ],
      ),
    );
  }
}
