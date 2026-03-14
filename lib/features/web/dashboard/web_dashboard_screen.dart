import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_async_error.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../shared/widgets/layout/responsive_builder.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../../../features/admin/providers/admin_providers.dart';

class WebDashboardScreen extends ConsumerWidget {
  const WebDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpisAsync = ref.watch(adminDashboardKpisProvider);

    return ResponsiveBuilder(
      builder: (context, breakpoint, isMobile, isTablet, isDesktop) {
        final crossAxisCount = breakpoint == LayoutBreakpoint.xs
            ? 2
            : (breakpoint == LayoutBreakpoint.sm ? 3 : 4);
        final padding = isMobile ? AppSpacing.sm : AppSpacing.lg;
        final childAspectRatio = isMobile ? 2.4 : 3.0;
        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              kpisAsync.when(
                loading: () => GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: childAspectRatio,
                  children: List.generate(8, (_) => const NcShimmerStatCard()),
                ),
                error: (e, _) =>
                    const NcAsyncError(message: 'Unable to load dashboard'),
                data: (kpis) => GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: childAspectRatio,
                  children: [
                    _KpiCard(
                      'Total Students',
                      '${kpis['totalStudents']}',
                      Icons.people_rounded,
                      AppColors.primary,
                      trend: '+5%',
                      trendUp: true,
                    ),
                    _KpiCard(
                      'Present Today',
                      '${kpis['presentToday']}',
                      Icons.check_circle_rounded,
                      AppColors.success,
                      trend: '92%',
                      trendUp: true,
                    ),
                    _KpiCard(
                      'Total Staff',
                      '${kpis['totalStaff']}',
                      Icons.badge_rounded,
                      AppColors.teal,
                    ),
                    _KpiCard(
                      'Attendance %',
                      '${kpis['attendancePercent']}%',
                      Icons.trending_up_rounded,
                      AppColors.primary,
                      trend: '↑ 2%',
                      trendUp: true,
                    ),
                    _KpiCard(
                      'Fees Collected',
                      AppFormatters.formatPaiseCompact(
                        kpis['feesCollectedPaise'] as int,
                      ),
                      Icons.payments_rounded,
                      AppColors.success,
                      trend: '+12%',
                      trendUp: true,
                    ),
                    _KpiCard(
                      'Fees Pending',
                      AppFormatters.formatPaiseCompact(
                        kpis['feesPendingPaise'] as int,
                      ),
                      Icons.pending_rounded,
                      AppColors.error,
                      trend: 'Action',
                      trendUp: false,
                    ),
                    _KpiCard(
                      'New Admissions',
                      '${kpis['newAdmissions']}',
                      Icons.person_add_rounded,
                      AppColors.accent,
                      trend: 'This month',
                    ),
                    _KpiCard(
                      'Pending Approvals',
                      '${kpis['pendingApprovals']}',
                      Icons.approval_rounded,
                      AppColors.warning,
                      trend: 'Review',
                      trendUp: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Charts — stack on mobile, side-by-side on desktop
              isMobile
                  ? Column(
                      children: [
                        _AttendanceTrendCard(),
                        const SizedBox(height: AppSpacing.md),
                        _FeeCollectionCard(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _AttendanceTrendCard()),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(flex: 2, child: _FeeCollectionCard()),
                      ],
                    ),
              const SizedBox(height: AppSpacing.lg),

              // AI alerts + recent activity — stack on mobile
              isMobile
                  ? Column(
                      children: [
                        _AiInsightsCard(),
                        const SizedBox(height: AppSpacing.md),
                        _RecentActivityCard(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _AiInsightsCard()),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: _RecentActivityCard()),
                      ],
                    ),
            ],
          ),
        );
      },
    );
  }
}

class _AttendanceTrendCard extends StatelessWidget {
  const _AttendanceTrendCard();

  @override
  Widget build(BuildContext context) {
    return NcCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Attendance Trend (Last 7 days)',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (v) =>
                      const FlLine(color: AppColors.divider, strokeWidth: 1),
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
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
                    spots: const [
                      FlSpot(0, 92),
                      FlSpot(1, 88),
                      FlSpot(2, 94),
                      FlSpot(3, 91),
                      FlSpot(4, 95),
                      FlSpot(5, 70),
                      FlSpot(6, 85),
                    ],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.1),
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
    );
  }
}

class _FeeCollectionCard extends StatelessWidget {
  const _FeeCollectionCard();

  @override
  Widget build(BuildContext context) {
    return NcCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.payments,
                  color: AppColors.teal,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Fee Collection (Monthly)',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) =>
                      const FlLine(color: AppColors.divider, strokeWidth: 1),
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
    );
  }
}

BarChartGroupData _barGroup(int x, double y) {
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

const _aiInsights = [
  'Class 8-A attendance dropped 12% this week',
  '23 fee defaulters risk this term',
  'Science class showing engagement spike',
  'Transport route 3 is 15 min delayed today',
];

final _activities = [
  ('Arjun Kumar fee payment received', AppColors.success, Icons.payments),
  ('Priya Sharma submitted attendance', AppColors.primary, Icons.how_to_reg),
  ('New admission: Riya Patel (Class 6)', AppColors.accent, Icons.person_add),
  ('Leave approved for Mohan Raj', AppColors.teal, Icons.check_circle),
  ('Notice published: Annual Day', AppColors.primary, Icons.campaign),
];

class _AiInsightsCard extends StatelessWidget {
  const _AiInsightsCard();

  @override
  Widget build(BuildContext context) {
    return NcCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.accent,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'AI Insights',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
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
                  const Icon(Icons.circle, size: 6, color: AppColors.accent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(insight, style: AppTypography.bodySmall),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard();

  @override
  Widget build(BuildContext context) {
    return NcCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.history,
                  color: AppColors.teal,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Recent Activity',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
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
                  Expanded(child: Text(a.$1, style: AppTypography.bodySmall)),
                ],
              ),
            ),
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
    this.trend,
    this.trendUp,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool? trendUp;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color, color.withValues(alpha: 0.5)],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          style: AppTypography.titleMedium.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (trend != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          trend!,
                          style: AppTypography.labelSmall.copyWith(
                            color: trendUp == true
                                ? AppColors.success
                                : trendUp == false
                                ? AppColors.error
                                : color,
                            fontWeight: FontWeight.w600,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    label,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
