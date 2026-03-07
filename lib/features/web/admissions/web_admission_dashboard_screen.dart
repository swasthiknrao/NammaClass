import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';

class WebAdmissionDashboardScreen extends ConsumerWidget {
  const WebAdmissionDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Year selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Admission Dashboard — 2026–27',
                style: AppTypography.headlineMedium,
              ),
              DropdownButton<String>(
                value: '2026-27',
                items: const [
                  DropdownMenuItem(value: '2026-27', child: Text('2026-27')),
                  DropdownMenuItem(value: '2025-26', child: Text('2025-26')),
                ],
                onChanged: (_) {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // KPI cards
          Row(
            children: const [
              Expanded(
                child: _KpiCard(
                  'Total Enquiries',
                  '142',
                  Icons.person_add_outlined,
                  AppColors.primary,
                  '+18 vs last year',
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _KpiCard(
                  'Applications',
                  '86',
                  Icons.assignment_outlined,
                  AppColors.teal,
                  '+12 vs last year',
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _KpiCard(
                  'Interviews Scheduled',
                  '34',
                  Icons.event_outlined,
                  AppColors.accent,
                  '+5 vs last year',
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _KpiCard(
                  'Admissions Confirmed',
                  '28',
                  Icons.how_to_reg_outlined,
                  AppColors.success,
                  '+8 vs last year',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Funnel chart + recent enquiries
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admission funnel
              Expanded(
                flex: 6,
                child: NcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admission Funnel',
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            barGroups: [
                              _barGroup(0, 142, AppColors.primary),
                              _barGroup(1, 98, AppColors.teal),
                              _barGroup(2, 86, AppColors.accent),
                              _barGroup(3, 56, AppColors.warning),
                              _barGroup(4, 34, AppColors.deepPurple),
                              _barGroup(5, 28, AppColors.success),
                            ],
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (v, _) {
                                    const labels = [
                                      'Enquiry',
                                      'Visit',
                                      'Applied',
                                      'Test',
                                      'Interview',
                                      'Admitted',
                                    ];
                                    final i = v.toInt();
                                    if (i < 0 || i >= labels.length)
                                      return const SizedBox();
                                    return Text(
                                      labels[i],
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                  reservedSize: 28,
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
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
              ),
              const SizedBox(width: AppSpacing.md),

              // Class-wise seats
              Expanded(
                flex: 4,
                child: NcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Class-wise Seats',
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...[
                        ('Class 1', 40, 12, AppColors.success),
                        ('Class 6', 60, 55, AppColors.warning),
                        ('Class 9', 50, 50, AppColors.error),
                        ('Class 11', 80, 28, AppColors.success),
                      ].map((row) {
                        final pct = row.$3 / row.$2;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(row.$1, style: AppTypography.bodySmall),
                                  Text(
                                    '${row.$3}/${row.$2}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: row.$4,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              LinearProgressIndicator(
                                value: pct,
                                backgroundColor: AppColors.divider,
                                color: row.$4,
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Recent enquiries
          NcCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Enquiries', style: AppTypography.titleMedium),
                    TextButton(onPressed: () {}, child: const Text('View All')),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ...MockData.admissionEnquiries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            e.studentName,
                            style: AppTypography.bodyMedium,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            e.classApplying,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: NcChip(
                            label: e.source,
                            color: AppColors.primary,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (e.aiLeadScore > 70
                                          ? AppColors.success
                                          : e.aiLeadScore > 40
                                          ? AppColors.warning
                                          : AppColors.error)
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Score: ${e.aiLeadScore}',
                              style: TextStyle(
                                fontSize: 11,
                                color: e.aiLeadScore > 70
                                    ? AppColors.success
                                    : e.aiLeadScore > 40
                                    ? AppColors.warning
                                    : AppColors.error,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: NcChip(
                            label: e.status,
                            color: e.status == 'Converted'
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 24,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard(this.label, this.value, this.icon, this.color, this.delta);
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String delta;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color),
              Text(delta, style: TextStyle(color: color, fontSize: 11)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.displayMedium.copyWith(
              color: color,
              fontFamily: 'JetBrainsMono',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
