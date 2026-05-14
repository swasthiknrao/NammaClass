import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/screen_size.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../domain/entities/nc_feature.dart';
import '../../../domain/entities/tenant_profile.dart';
import '../../../l10n/app_localizations.dart';
import '../../../routing/app_routes.dart';
import '../../tenant/providers/tenant_provider.dart';
import 'accountant_finance_providers.dart';

class WebAccountantDashboardScreen extends ConsumerWidget {
  const WebAccountantDashboardScreen({super.key});

  static List<String> _periodChoices(String anchor) {
    final parts = anchor.split('-');
    final y = int.tryParse(parts[0]) ?? DateTime.now().year;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '1') ?? 1;
    final out = <String>[];
    var yy = y;
    var mm = m;
    for (var i = 0; i < 6; i++) {
      out.add(
        '${yy.toString().padLeft(4, '0')}-${mm.toString().padLeft(2, '0')}',
      );
      mm -= 1;
      if (mm < 1) {
        mm = 12;
        yy -= 1;
      }
    }
    return out;
  }

  static EdgeInsets _pagePadding(BuildContext context) {
    final m = ScreenSize.isMobile(context);
    return EdgeInsets.fromLTRB(
      m ? AppSpacing.sm : AppSpacing.lg,
      m ? AppSpacing.sm : AppSpacing.lg,
      m ? AppSpacing.sm : AppSpacing.lg,
      m ? AppSpacing.xl : AppSpacing.lg,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mobile = ScreenSize.isMobile(context);
    final tablet = ScreenSize.isTablet(context);
    final tenant = ref.watch(tenantProfileProvider);
    final period = ref.watch(accountantFinancePeriodProvider);
    final feesRoll = ref.watch(accountantFeesRollupProvider);
    final trendPaise = ref.watch(collectionTrendPaiseProvider);
    final trend = normalizeTrendToHundred(trendPaise);
    final pendingByClass = ref.watch(financePendingByClassProvider);
    final events = ref.watch(financeCollectionEventsProvider);
    final exceptions = ref.watch(financeExceptionsProvider);
    final expenseLines = ref.watch(ledgerExpenseLinesForPeriodProvider(period));
    final payrollLiab = ref.watch(payrollLiabilityForPeriodProvider(period));
    final pf = _i(MockData.financeSnapshot['pf_employer_month_paise']);
    final esi = _i(MockData.financeSnapshot['esi_employer_month_paise']);
    final today = _i(MockData.financeSnapshot['today_collection_paise']);
    final cleared = MockData.students
        .where((s) => s.feeStatus == 'paid')
        .length;
    final mtdSpend = expenseLines.fold<int>(
      0,
      (s, e) => s + _i(e['amount_paise']),
    );
    final maxClass = pendingByClass.fold<int>(
      0,
      (s, e) => s > _i(e['amount_paise']) ? s : _i(e['amount_paise']),
    );
    final nonZeroMax = maxClass > 0 ? maxClass : 1;
    final choices = _periodChoices(period);
    final atFmt = DateFormat('MMM d · h:mm a');

    final kpis = <({String label, String value, IconData icon, Color color})>[
      (
        label: l10n.accountantTodaysCollection,
        value: AppFormatters.formatPaiseCompact(today),
        icon: Icons.today_rounded,
        color: AppColors.success,
      ),
      (
        label: l10n.accountantTotalPending,
        value: AppFormatters.formatPaiseCompact(feesRoll.pending),
        icon: Icons.pending_actions_rounded,
        color: AppColors.warning,
      ),
      (
        label: l10n.accountantOverdueAmount,
        value: AppFormatters.formatPaiseCompact(feesRoll.overdue),
        icon: Icons.schedule_rounded,
        color: AppColors.error,
      ),
      (
        label: l10n.accountantPayrollLiability,
        value: AppFormatters.formatPaiseCompact(payrollLiab),
        icon: Icons.payments_outlined,
        color: AppColors.primary,
      ),
      (
        label: l10n.accountantExpenseBurnMtd,
        value: AppFormatters.formatPaiseCompact(mtdSpend),
        icon: Icons.local_fire_department_outlined,
        color: AppColors.accent,
      ),
      (
        label: l10n.accountantStudentsCleared,
        value: '$cleared',
        icon: Icons.check_circle_outline_rounded,
        color: AppColors.teal,
      ),
    ];

    final chartH = mobile ? 132.0 : 168.0;

    return SingleChildScrollView(
      padding: _pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroBar(
            mobile: mobile,
            l10n: l10n,
            period: period,
            choices: choices,
            onPeriod: (v) {
              ref.read(accountantPeriodSelectionProvider.notifier).state = v;
            },
            onCollect: () => context.go(AppRoutes.webFeeCollect),
          ),
          SizedBox(height: mobile ? AppSpacing.sm : AppSpacing.md),
          Text(
            l10n.accountantFinanceSubtitle,
            style: (mobile ? AppTypography.bodySmall : AppTypography.bodyMedium)
                .copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: mobile ? AppSpacing.sm : AppSpacing.md),
          _CompactKpiRail(mobile: mobile, tablet: tablet, kpis: kpis),
          SizedBox(height: mobile ? AppSpacing.md : AppSpacing.lg),
          mobile || tablet
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ChartCard(l10n: l10n, trend: trend, height: chartH),
                    SizedBox(height: AppSpacing.sm),
                    _QuickLinksPanel(
                      mobile: true,
                      l10n: l10n,
                      tenant: tenant,
                      parentContext: context,
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _ChartCard(
                        l10n: l10n,
                        trend: trend,
                        height: chartH + 32,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: _QuickLinksPanel(
                        mobile: false,
                        l10n: l10n,
                        tenant: tenant,
                        parentContext: context,
                      ),
                    ),
                  ],
                ),
          SizedBox(height: mobile ? AppSpacing.md : AppSpacing.lg),
          mobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PayrollStrip(
                      mobile: true,
                      l10n: l10n,
                      pf: pf,
                      esi: esi,
                      payrollLiab: payrollLiab,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _ExceptionsPanel(l10n: l10n, exceptions: exceptions),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _PayrollStrip(
                        mobile: false,
                        l10n: l10n,
                        pf: pf,
                        esi: esi,
                        payrollLiab: payrollLiab,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _ExceptionsPanel(
                        l10n: l10n,
                        exceptions: exceptions,
                      ),
                    ),
                  ],
                ),
          SizedBox(height: mobile ? AppSpacing.md : AppSpacing.lg),
          mobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PendingPanel(
                      l10n: l10n,
                      pendingByClass: pendingByClass,
                      nonZeroMax: nonZeroMax,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _RecentPanel(
                      l10n: l10n,
                      events: events,
                      atFmt: atFmt,
                      onViewAll: () => context.go(AppRoutes.webFeeCollect),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _PendingPanel(
                        l10n: l10n,
                        pendingByClass: pendingByClass,
                        nonZeroMax: nonZeroMax,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _RecentPanel(
                        l10n: l10n,
                        events: events,
                        atFmt: atFmt,
                        onViewAll: () => context.go(AppRoutes.webFeeCollect),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  static Color _sevColor(String s) {
    if (s.toLowerCase() == 'high') return AppColors.error;
    return AppColors.warning;
  }

  static int _i(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? 0;
  }
}

// ── Hero (slim, stacks on phone) ───────────────────────────────────────────

class _HeroBar extends StatelessWidget {
  const _HeroBar({
    required this.mobile,
    required this.l10n,
    required this.period,
    required this.choices,
    required this.onPeriod,
    required this.onCollect,
  });

  final bool mobile;
  final AppLocalizations l10n;
  final String period;
  final List<String> choices;
  final ValueChanged<String> onPeriod;
  final VoidCallback onCollect;

  @override
  Widget build(BuildContext context) {
    final pad = mobile ? AppSpacing.sm : AppSpacing.md;
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(mobile ? 12 : 14),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.teal.withValues(alpha: 0.92),
              AppColors.purple.withValues(alpha: 0.82),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: mobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.accountantFinanceTitle,
                      style: AppTypography.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          l10n.accountantPeriodLabel,
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              isDense: true,
                              dropdownColor: AppColors.sidebarBg,
                              value: choices.contains(period)
                                  ? period
                                  : choices.first,
                              style: AppTypography.labelMedium.copyWith(
                                color: Colors.white,
                                fontFamily: 'JetBrainsMono',
                              ),
                              items: choices
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(
                                        p,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'JetBrainsMono',
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) onPeriod(v);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: FilledButton.icon(
                        onPressed: onCollect,
                        icon: const Icon(Icons.point_of_sale, size: 18),
                        label: Text(
                          l10n.accountantCollectFeesCta,
                          style: AppTypography.labelLarge,
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.teal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.accountantFinanceTitle,
                            style: AppTypography.headlineSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                l10n.accountantPeriodLabel,
                                style: AppTypography.labelMedium.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(width: 8),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  dropdownColor: AppColors.sidebarBg,
                                  value: choices.contains(period)
                                      ? period
                                      : choices.first,
                                  style: AppTypography.titleSmall.copyWith(
                                    color: Colors.white,
                                    fontFamily: 'JetBrainsMono',
                                  ),
                                  items: choices
                                      .map(
                                        (p) => DropdownMenuItem(
                                          value: p,
                                          child: Text(
                                            p,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'JetBrainsMono',
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) onPeriod(v);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: onCollect,
                      icon: const Icon(Icons.point_of_sale, size: 20),
                      label: Text(l10n.accountantCollectFeesCta),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.teal,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Compact KPIs: horizontal thumb-strip on phone, tight wrap on desktop ───

class _CompactKpiRail extends StatelessWidget {
  const _CompactKpiRail({
    required this.mobile,
    required this.tablet,
    required this.kpis,
  });

  final bool mobile;
  final bool tablet;
  final List<({String label, String value, IconData icon, Color color})> kpis;

  @override
  Widget build(BuildContext context) {
    final tiles = List.generate(kpis.length, (i) {
      final k = kpis[i];
      return _CompactMetricPill(
            label: k.label,
            value: k.value,
            icon: k.icon,
            color: k.color,
          )
          .animate()
          .fadeIn(duration: 220.ms, delay: (20 * i).ms)
          .slideX(begin: 0.04, curve: Curves.easeOutCubic);
    });

    if (mobile) {
      return SizedBox(
        height: 76,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          itemCount: tiles.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) => SizedBox(width: 148, child: tiles[i]),
        ),
      );
    }

    if (tablet) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tiles
            .map(
              (w) => SizedBox(
                width: (MediaQuery.sizeOf(context).width - 16 - 8) / 2,
                child: w,
              ),
            )
            .toList(),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: tiles.map((w) => SizedBox(width: 168, child: w)).toList(),
    );
  }
}

class _CompactMetricPill extends StatelessWidget {
  const _CompactMetricPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: isDark ? 0.35 : 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleSmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'JetBrainsMono',
                      height: 1.1,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.15,
                    ),
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

// ── Chart (dense) ───────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.l10n,
    required this.trend,
    required this.height,
  });

  final AppLocalizations l10n;
  final List<double> trend;
  final double height;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.accountantCollectionTrend,
            style: AppTypography.labelMedium,
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: height,
            child: trend.isEmpty
                ? Center(
                    child: Text(
                      l10n.noDataFound,
                      style: AppTypography.bodySmall,
                    ),
                  )
                : LineChart(
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
                            reservedSize: 28,
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
                              const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
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
                          spots: trend
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value))
                              .toList(),
                          isCurved: true,
                          color: AppColors.success,
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.success.withValues(alpha: 0.08),
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
    );
  }
}

// ── Quick links: chips on mobile, slim list on desktop ──────────────────────

class _QuickLinksPanel extends StatelessWidget {
  const _QuickLinksPanel({
    required this.mobile,
    required this.l10n,
    required this.tenant,
    required this.parentContext,
  });

  final bool mobile;
  final AppLocalizations l10n;
  final TenantProfile tenant;
  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    final items = <({IconData icon, String label, VoidCallback onTap})>[
      (
        icon: Icons.account_balance_rounded,
        label: l10n.accountantLinkLedger,
        onTap: () => GoRouter.of(parentContext).go(AppRoutes.webFinanceLedger),
      ),
      if (tenant.hasFeature(NcFeature.hrPayroll))
        (
          icon: Icons.payments_outlined,
          label: l10n.accountantLinkPayroll,
          onTap: () =>
              GoRouter.of(parentContext).go(AppRoutes.webAccountantPayroll),
        ),
      (
        icon: Icons.receipt_long_outlined,
        label: l10n.accountantLinkExpenses,
        onTap: () =>
            GoRouter.of(parentContext).go(AppRoutes.webAccountantExpenses),
      ),
      (
        icon: Icons.fact_check_outlined,
        label: l10n.accountantLinkMonthClose,
        onTap: () =>
            GoRouter.of(parentContext).go(AppRoutes.webAccountantReports),
      ),
    ];

    if (mobile) {
      return NcCard(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.accountantQuickLinks, style: AppTypography.labelMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...items.map(
                  (e) => ActionChip(
                    avatar: Icon(e.icon, size: 16, color: AppColors.primary),
                    label: Text(e.label, style: AppTypography.labelSmall),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onPressed: e.onTap,
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.print, size: 16),
                  label: Text(
                    l10n.accountantPrintSummary,
                    style: AppTypography.labelSmall,
                  ),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onPressed: () {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      SnackBar(content: Text(l10n.accountantPrintSummarySnack)),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      );
    }

    return NcCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.accountantQuickLinks, style: AppTypography.labelMedium),
          const SizedBox(height: 8),
          for (final e in items) ...[
            _QuickRow(icon: e.icon, label: e.label, onTap: e.onTap),
            const SizedBox(height: 4),
          ],
          _QuickRow(
            icon: Icons.print,
            label: l10n.accountantPrintSummary,
            onTap: () {
              ScaffoldMessenger.of(parentContext).showSnackBar(
                SnackBar(content: Text(l10n.accountantPrintSummarySnack)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickRow extends StatelessWidget {
  const _QuickRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: AppTypography.bodySmall)),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Payroll strip (compact) ─────────────────────────────────────────────────

class _PayrollStrip extends StatelessWidget {
  const _PayrollStrip({
    required this.mobile,
    required this.l10n,
    required this.pf,
    required this.esi,
    required this.payrollLiab,
  });

  final bool mobile;
  final AppLocalizations l10n;
  final int pf;
  final int esi;
  final int payrollLiab;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 10 : 12,
        vertical: mobile ? 8 : 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.accountantPayrollSnapshot,
            style: AppTypography.labelMedium,
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _TinyStat(
                l10n.accountantPfEmployerChip,
                AppFormatters.formatPaiseCompact(pf),
              ),
              _TinyStat(
                l10n.accountantEsiEmployerChip,
                AppFormatters.formatPaiseCompact(esi),
              ),
              _TinyStat(
                l10n.accountantPayrollLiability,
                AppFormatters.formatPaiseCompact(payrollLiab),
                emphasize: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TinyStat extends StatelessWidget {
  const _TinyStat(this.title, this.value, {this.emphasize = false});

  final String title;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RichText(
        text: TextSpan(
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
          children: [
            TextSpan(text: '$title · '),
            TextSpan(
              text: value,
              style: TextStyle(
                color: emphasize ? AppColors.primary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontFamily: 'JetBrainsMono',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Exceptions (tight) ────────────────────────────────────────────────────────

class _ExceptionsPanel extends StatelessWidget {
  const _ExceptionsPanel({required this.l10n, required this.exceptions});

  final AppLocalizations l10n;
  final List<Map<String, dynamic>> exceptions;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.accountantExceptionsTitle,
            style: AppTypography.labelMedium,
          ),
          const SizedBox(height: 4),
          ...exceptions.map(
            (ex) => Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: WebAccountantDashboardScreen._sevColor(
                      '${ex['severity']}',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${ex['title']}',
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${ex['detail']}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
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

// ── Pending + recent (compact rows) ─────────────────────────────────────────

class _PendingPanel extends StatelessWidget {
  const _PendingPanel({
    required this.l10n,
    required this.pendingByClass,
    required this.nonZeroMax,
  });

  final AppLocalizations l10n;
  final List<Map<String, dynamic>> pendingByClass;
  final int nonZeroMax;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.accountantPendingByClass, style: AppTypography.labelMedium),
          const SizedBox(height: 6),
          ...pendingByClass.map((row) {
            final cls = '${row['class_section'] ?? row['class'] ?? ''}';
            final amt = WebAccountantDashboardScreen._i(row['amount_paise']);
            if (amt <= 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    child: Text(
                      cls,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        value: (amt / nonZeroMax).clamp(0.0, 1.0),
                        backgroundColor: AppColors.divider,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.warning,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    AppFormatters.formatPaiseCompact(amt),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.warning,
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _RecentPanel extends StatelessWidget {
  const _RecentPanel({
    required this.l10n,
    required this.events,
    required this.atFmt,
    required this.onViewAll,
  });

  final AppLocalizations l10n;
  final List<Map<String, dynamic>> events;
  final DateFormat atFmt;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.accountantRecentCollections,
                style: AppTypography.labelMedium,
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: onViewAll,
                child: Text(
                  l10n.accountantViewAll,
                  style: AppTypography.labelSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...events.map((e) {
            final name = '${e['student_name'] ?? ''}';
            final amt = WebAccountantDashboardScreen._i(e['amount_paise']);
            final label = '${e['label'] ?? ''}';
            final at = DateTime.tryParse('${e['at'] ?? ''}');
            final tail = at != null ? atFmt.format(at) : '';
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.south_west_rounded,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: AppTypography.bodySmall),
                        Text(
                          '$label · $tail',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    AppFormatters.formatPaise(amt),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.success,
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
