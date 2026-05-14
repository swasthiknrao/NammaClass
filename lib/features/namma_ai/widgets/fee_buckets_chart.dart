import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Inline chart when tool results include `buckets` (fee aging demo).
class NammaAiFeeBucketsChart extends StatelessWidget {
  const NammaAiFeeBucketsChart({super.key, required this.buckets});

  final List<Map<String, dynamic>> buckets;

  @override
  Widget build(BuildContext context) {
    if (buckets.isEmpty) return const SizedBox.shrink();
    final amounts = buckets
        .map((b) => (b['amount_inr'] as num?)?.toDouble() ?? 0)
        .toList();
    final maxY = amounts.fold<double>(0, (a, b) => a > b ? a : b);
    final cap = maxY <= 0 ? 1.0 : maxY * 1.15;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: SizedBox(
        height: 140,
        child: BarChart(
          BarChartData(
            maxY: cap,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (v, m) => Text(
                    '${(v / 1000).round()}k',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, m) {
                    final idx = v.toInt();
                    if (idx < 0 || idx >= buckets.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${buckets[idx]['label']}',
                        style: AppTypography.labelSmall,
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < buckets.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: (buckets[i]['amount_inr'] as num?)?.toDouble() ?? 0,
                      width: 18,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                      color: AppColors.primary,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
