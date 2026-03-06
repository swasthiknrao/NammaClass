import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../../../features/admin/providers/admin_providers.dart';

class WebDashboardScreen extends ConsumerWidget {
  const WebDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpisAsync = ref.watch(adminDashboardKpisProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          kpisAsync.when(
            loading: () => GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 2.5,
              children: List.generate(8, (_) => const NcShimmerStatCard()),
            ),
            error: (e, _) => const SizedBox.shrink(),
            data: (kpis) => GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 2.5,
              children: [
                _KpiCard(
                  'Total Students',
                  '${kpis['totalStudents']}',
                  Icons.people,
                  AppColors.primary,
                ),
                _KpiCard(
                  'Present Today',
                  '${kpis['presentToday']}',
                  Icons.check_circle,
                  AppColors.success,
                ),
                _KpiCard(
                  'Total Staff',
                  '${kpis['totalStaff']}',
                  Icons.badge,
                  AppColors.teal,
                ),
                _KpiCard(
                  'Attendance %',
                  '${kpis['attendancePercent']}%',
                  Icons.bar_chart,
                  AppColors.primary,
                ),
                _KpiCard(
                  'Fees Collected',
                  AppFormatters.formatPaiseCompact(
                    kpis['feesCollectedPaise'] as int,
                  ),
                  Icons.payments,
                  AppColors.success,
                ),
                _KpiCard(
                  'Fees Pending',
                  AppFormatters.formatPaiseCompact(
                    kpis['feesPendingPaise'] as int,
                  ),
                  Icons.pending,
                  AppColors.error,
                ),
                _KpiCard(
                  'New Admissions',
                  '${kpis['newAdmissions']}',
                  Icons.person_add,
                  AppColors.accent,
                ),
                _KpiCard(
                  'Pending Approvals',
                  '${kpis['pendingApprovals']}',
                  Icons.approval,
                  AppColors.warning,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Charts row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Attendance trend
              Expanded(
                flex: 3,
                child: NcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attendance Trend (Last 7 days)',
                        style: AppTypography.labelLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        height: 180,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              getDrawingHorizontalLine: (v) => const FlLine(
                                color: AppColors.divider,
                                strokeWidth: 1,
                              ),
                              drawVerticalLine: false,
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (v, m) => Text(
                                    '${v.toInt()}%',
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
                                spots: [
                                  const FlSpot(0, 92),
                                  const FlSpot(1, 88),
                                  const FlSpot(2, 94),
                                  const FlSpot(3, 91),
                                  const FlSpot(4, 95),
                                  const FlSpot(5, 70),
                                  const FlSpot(6, 85),
                                ],
                                isCurved: true,
                                color: AppColors.primary,
                                barWidth: 3,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                              ),
                            ],
                            minY: 60,
                            maxY: 100,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Fee collection bar chart
              Expanded(
                flex: 2,
                child: NcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fee Collection (Monthly)',
                        style: AppTypography.labelLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        height: 180,
                        child: BarChart(
                          BarChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (v) => const FlLine(
                                color: AppColors.divider,
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (v, m) {
                                    const months = [
                                      'Apr',
                                      'May',
                                      'Jun',
                                      'Jul',
                                      'Aug',
                                      'Sep',
                                    ];
                                    return Text(
                                      months[v.toInt()],
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
                            barGroups: [
                              _barGroup(0, 82),
                              _barGroup(1, 78),
                              _barGroup(2, 90),
                              _barGroup(3, 65),
                              _barGroup(4, 88),
                              _barGroup(5, 45),
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
          const SizedBox(height: AppSpacing.lg),

          // AI alerts + recent activity
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI insights
              Expanded(
                child: NcCard(
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: AppColors.accent,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'AI Insights',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ..._aiInsights.map(
                        (insight) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 6,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  insight,
                                  style: AppTypography.bodySmall,
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

              // Recent activity
              Expanded(
                child: NcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recent Activity', style: AppTypography.labelLarge),
                      const SizedBox(height: AppSpacing.sm),
                      ..._activities.map(
                        (a) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: a.$2.withValues(alpha: 0.15),
                                child: Icon(a.$3, color: a.$2, size: 14),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  a.$1,
                                  style: AppTypography.bodySmall,
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

  static BarChartGroupData _barGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primary,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  static final _aiInsights = [
    'Class 8-A attendance dropped 12% this week',
    '23 fee defaulters risk this term',
    'Science class showing engagement spike',
    'Transport route 3 is 15 min delayed today',
  ];

  static final _activities = [
    ('Arjun Kumar fee payment received', AppColors.success, Icons.payments),
    ('Priya Sharma submitted attendance', AppColors.primary, Icons.how_to_reg),
    ('New admission: Riya Patel (Class 6)', AppColors.accent, Icons.person_add),
    ('Leave approved for Mohan Raj', AppColors.teal, Icons.check_circle),
    ('Notice published: Annual Day', AppColors.primary, Icons.campaign),
  ];
}

class _KpiCard extends StatelessWidget {
  const _KpiCard(this.label, this.value, this.icon, this.color);
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: AppTypography.headlineMedium.copyWith(color: color),
                ),
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
