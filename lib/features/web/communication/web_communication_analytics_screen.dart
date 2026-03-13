import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';

class WebCommunicationAnalyticsScreen extends ConsumerWidget {
  const WebCommunicationAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Communication Analytics', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.md),

          // KPI row
          Row(
            children: const [
              Expanded(
                child: _KpiCard('Total Notices Sent', '248', Icons.campaign),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(child: _KpiCard('SMS Delivered', '96.4%', Icons.sms)),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _KpiCard(
                  'Push Opened',
                  '71.2%',
                  Icons.notifications_active,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _KpiCard('Avg Acknowledgement', '68.5%', Icons.done_all),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Channel performance chart
          NcCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Channel Performance (Monthly)',
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      barGroups: List.generate(4, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: 90.0 + i * 2,
                              color: AppColors.primary,
                              width: 10,
                            ),
                            BarChartRodData(
                              toY: 65.0 + i * 3,
                              color: AppColors.teal,
                              width: 10,
                            ),
                            BarChartRodData(
                              toY: 70.0 + i * 1,
                              color: AppColors.accent,
                              width: 10,
                            ),
                          ],
                          barsSpace: 3,
                        );
                      }),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              const labels = ['Dec', 'Jan', 'Feb', 'Mar'];
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
                            reservedSize: 36,
                            getTitlesWidget: (v, _) => Text(
                              '${v.toInt()}%',
                              style: const TextStyle(fontSize: 10),
                            ),
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
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _LegendDot(AppColors.primary, 'SMS'),
                    SizedBox(width: AppSpacing.md),
                    _LegendDot(AppColors.teal, 'Push'),
                    SizedBox(width: AppSpacing.md),
                    _LegendDot(AppColors.accent, 'WhatsApp'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Notice engagement table
          NcCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notice Engagement', style: AppTypography.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                _TableHeader(const [
                  'Title',
                  'Sent',
                  'Delivered',
                  'Read',
                  'Acknowledged',
                  '',
                ]),
                ...const [
                  (
                    'Term Exam Schedule — April 2026',
                    '1248',
                    '1230',
                    '1105',
                    '980',
                  ),
                  (
                    'Annual Day Invitation — 20 Mar',
                    '2400',
                    '2389',
                    '1900',
                    '1650',
                  ),
                  ('Fee Due Reminder — Term 3', '1248', '1240', '1080', '1080'),
                ].map(
                  (row) => _NoticeRow(row.$1, row.$2, row.$3, row.$4, row.$5),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Parent engagement
          NcCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Parent Engagement Scores',
                      style: AppTypography.titleMedium,
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.send),
                      label: const Text('Send Re-engagement SMS'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people, color: AppColors.warning),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '15 parents have not opened the app in 30 days.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _TableHeader(const [
                  'Parent',
                  'Children',
                  'App Logins',
                  'Notices Read',
                  'Paid via App',
                  'Score',
                ]),
                ...const [
                  ('Ramesh S.', '1', '24', '45', 'Yes', '88'),
                  ('Priya T.', '2', '8', '20', 'No', '42'),
                  ('Nagesh K.', '1', '2', '5', 'No', '18'),
                ].map((row) {
                  final score = int.tryParse(row.$6) ?? 0;
                  Color scoreColor;
                  if (score >= 70) {
                    scoreColor = AppColors.success;
                  } else if (score >= 40) {
                    scoreColor = AppColors.warning;
                  } else {
                    scoreColor = AppColors.error;
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.divider),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(row.$1, style: AppTypography.labelMedium),
                        ),
                        Expanded(flex: 1, child: Text(row.$2)),
                        Expanded(flex: 2, child: Text(row.$3)),
                        Expanded(flex: 2, child: Text(row.$4)),
                        Expanded(flex: 2, child: Text(row.$5)),
                        Expanded(
                          flex: 1,
                          child: Text(
                            row.$6,
                            style: AppTypography.labelMedium.copyWith(
                              color: scoreColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard(this.label, this.value, this.icon);
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot(this.color, this.label);
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.bodySmall),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader(this.columns);
  final List<String> columns;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      color: AppColors.background,
      child: Row(
        children: columns
            .map(
              (c) => Expanded(
                flex: c.isEmpty ? 1 : 3,
                child: Text(
                  c,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NoticeRow extends StatelessWidget {
  const _NoticeRow(
    this.title,
    this.sent,
    this.delivered,
    this.read,
    this.acked,
  );
  final String title;
  final String sent;
  final String delivered;
  final String read;
  final String acked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(title, style: AppTypography.bodySmall)),
          Expanded(flex: 3, child: Text(sent)),
          Expanded(flex: 3, child: Text(delivered)),
          Expanded(
            flex: 3,
            child: Text(read, style: TextStyle(color: AppColors.teal)),
          ),
          Expanded(
            flex: 3,
            child: Text(acked, style: TextStyle(color: AppColors.success)),
          ),
          Expanded(
            flex: 1,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
              ),
              child: const Text('Detail'),
            ),
          ),
        ],
      ),
    );
  }
}
