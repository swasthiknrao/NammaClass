import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_card.dart';

class WebLibraryReportsScreen extends ConsumerWidget {
  const WebLibraryReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const mostBorrowed = [
      ('Wings of Fire — APJ Abdul Kalam', 18),
      ('The Alchemist — Paulo Coelho', 15),
      ('Harry Potter Yr 1 — J.K. Rowling', 12),
      ('Maths Std. 10 — NCERT', 11),
      ('Discovery of India — Nehru', 9),
    ];

    const topReaders = [
      ('Arjun Mehta', '10A', 8, 42),
      ('Priya Sharma', '9B', 6, 35),
      ('Riya S.', '8A', 6, 28),
    ];

    const overdue = [
      (
        'Arjun Mehta',
        '10A',
        'Wings of Fire',
        '2026-02-01',
        '2026-03-06',
        33,
        165,
      ),
      (
        'Kavitha B.',
        '7B',
        'Science Digest',
        '2026-02-14',
        '2026-03-06',
        20,
        100,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Library Analytics & Reports',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.md),

          // KPI row
          Row(
            children: const [
              Expanded(
                child: _KpiCard(
                  'Books Issued',
                  '148',
                  Icons.book,
                  AppColors.primary,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _KpiCard(
                  'Books Returned',
                  '131',
                  Icons.assignment_return,
                  AppColors.teal,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _KpiCard(
                  'Overdue Count',
                  '17',
                  Icons.access_time,
                  AppColors.warning,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _KpiCard(
                  'Fines Collected',
                  '₹850',
                  Icons.currency_rupee,
                  AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Most borrowed books
              Expanded(
                child: NcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Most Borrowed Books',
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            barGroups: mostBorrowed
                                .asMap()
                                .entries
                                .map(
                                  (e) => BarChartGroupData(
                                    x: e.key,
                                    barRods: [
                                      BarChartRodData(
                                        toY: e.value.$2.toDouble(),
                                        color: AppColors.primary,
                                        width: 20,
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (v, _) => Text(
                                    'B${v.toInt() + 1}',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 28,
                                  getTitlesWidget: (v, _) => Text(
                                    '${v.toInt()}',
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
                      ...mostBorrowed.asMap().entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                alignment: Alignment.center,
                                child: Text(
                                  'B${e.key + 1}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  e.value.$1,
                                  style: AppTypography.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${e.value.$2}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.teal,
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

              // Inventory stats
              Expanded(
                child: NcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inventory Report',
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ...[
                        ('Total Titles', '2,450', AppColors.primary),
                        ('Total Copies', '6,800', AppColors.teal),
                        ('Issued', '148', AppColors.warning),
                        ('Available', '6,652', AppColors.success),
                        ('Withdrawn', '48', AppColors.textSecondary),
                      ].map(
                        (s) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(s.$1, style: AppTypography.bodyMedium),
                              Text(
                                s.$2,
                                style: AppTypography.titleSmall.copyWith(
                                  color: s.$3,
                                  fontFamily: 'JetBrainsMono',
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
          const SizedBox(height: AppSpacing.md),

          // Top readers
          NcCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Most Active Readers (This Month)',
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  color: AppColors.background,
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Student',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Class',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'This Month',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'This Year',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                ...topReaders.map(
                  (r) => Container(
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
                          child: Text(r.$1, style: AppTypography.labelMedium),
                        ),
                        Expanded(flex: 2, child: Text(r.$2)),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${r.$3} books',
                            style: TextStyle(color: AppColors.teal),
                          ),
                        ),
                        Expanded(flex: 2, child: Text('${r.$4} books')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Overdue report
          NcCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Overdue Report', style: AppTypography.titleMedium),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.send, size: 16),
                      label: const Text('Send Reminders'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  color: AppColors.background,
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Student',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Book',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Issue Date',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Days Overdue',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Fine ₹',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Action',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                ...overdue.map(
                  (row) => Container(
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
                          child: Text(
                            '${row.$1} (${row.$2})',
                            style: AppTypography.labelMedium,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(row.$3, style: AppTypography.bodySmall),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            row.$4,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${row.$6} days',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            AppFormatters.currency(row.$7),
                            style: AppTypography.labelMedium.copyWith(
                              fontFamily: 'JetBrainsMono',
                              color: AppColors.error,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text('Remind'),
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
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTypography.headlineSmall.copyWith(color: color),
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
