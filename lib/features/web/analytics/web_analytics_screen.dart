import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';

class WebAnalyticsScreen extends ConsumerWidget {
  const WebAnalyticsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Analytics Deep-Dive', style: AppTypography.headlineLarge),
          const SizedBox(height: AppSpacing.md),
          DefaultTabController(
            length: 4,
            child: Column(
              children: [
                const TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'Attendance'),
                    Tab(text: 'Fees'),
                    Tab(text: 'Academics'),
                    Tab(text: 'Demographics'),
                  ],
                  tabAlignment: TabAlignment.start,
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    children: [
                      // Attendance analytics
                      NcCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monthly Attendance Trend',
                              style: AppTypography.labelLarge,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Expanded(
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    getDrawingHorizontalLine: (v) =>
                                        const FlLine(
                                          color: AppColors.divider,
                                          strokeWidth: 1,
                                        ),
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
                                          const months = [
                                            'Apr',
                                            'May',
                                            'Jun',
                                            'Jul',
                                            'Aug',
                                            'Sep',
                                            'Oct',
                                            'Nov',
                                            'Dec',
                                            'Jan',
                                            'Feb',
                                            'Mar',
                                          ];
                                          return Text(
                                            months[v.toInt() % 12],
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
                                        const FlSpot(0, 95),
                                        const FlSpot(1, 91),
                                        const FlSpot(2, 88),
                                        const FlSpot(3, 93),
                                        const FlSpot(4, 90),
                                        const FlSpot(5, 85),
                                        const FlSpot(6, 87),
                                        const FlSpot(7, 89),
                                        const FlSpot(8, 86),
                                        const FlSpot(9, 92),
                                        const FlSpot(10, 91),
                                        const FlSpot(11, 93),
                                      ],
                                      isCurved: true,
                                      color: AppColors.primary,
                                      barWidth: 3,
                                      dotData: const FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: AppColors.primary.withValues(
                                          alpha: 0.08,
                                        ),
                                      ),
                                    ),
                                  ],
                                  minY: 70,
                                  maxY: 100,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...List.generate(
                        3,
                        (i) => const Center(child: Text('Chart data loading…')),
                      ),
                    ],
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
