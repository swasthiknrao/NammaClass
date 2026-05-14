import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/screen_size.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../l10n/app_localizations.dart';
import '../accountant/accountant_finance_providers.dart';

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

  List<String> _periodChoices(String anchor) {
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

  List<(String, int, String)> _linesToTuples(List<Map<String, dynamic>> lines) {
    return lines.map((e) {
      final label = '${e['label'] ?? ''}';
      final paise = _i(e['amount_paise']);
      final booked = '${e['booked_at'] ?? e['date'] ?? ''}';
      return (label, paise, booked);
    }).toList();
  }

  Future<void> _exportCsv(String period) async {
    final inc = ref.read(ledgerIncomeLinesForPeriodProvider(period));
    final exp = ref.read(ledgerExpenseLinesForPeriodProvider(period));
    final buf = StringBuffer('type,label,amount_paise,booked_at,period\n');
    for (final e in inc) {
      buf.writeln(
        'income,"${e['label']}",${_i(e['amount_paise'])},${e['booked_at'] ?? ''},$period',
      );
    }
    for (final e in exp) {
      buf.writeln(
        'expense,"${e['label']}",${_i(e['amount_paise'])},${e['booked_at'] ?? ''},$period',
      );
    }
    await Clipboard.setData(ClipboardData(text: buf.toString()));
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.accountantLedgerExportSnack)));
  }

  EdgeInsets _pagePadding(BuildContext context) {
    final m = ScreenSize.isMobile(context);
    return EdgeInsets.fromLTRB(
      m ? AppSpacing.sm : AppSpacing.lg,
      m ? AppSpacing.sm : AppSpacing.md,
      m ? AppSpacing.sm : AppSpacing.lg,
      m ? AppSpacing.xl : AppSpacing.lg,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mobile = ScreenSize.isMobile(context);
    final period = ref.watch(accountantFinancePeriodProvider);
    final incomeLines = ref.watch(ledgerIncomeLinesForPeriodProvider(period));
    final expenseLines = ref.watch(ledgerExpenseLinesForPeriodProvider(period));
    final income = _linesToTuples(incomeLines);
    final expenses = _linesToTuples(expenseLines);

    final totalIncome = incomeLines.fold<int>(
      0,
      (s, e) => s + _i(e['amount_paise']),
    );
    final totalExpense = expenseLines.fold<int>(
      0,
      (s, e) => s + _i(e['amount_paise']),
    );
    final profit = totalIncome - totalExpense;
    final petty = _i(MockData.financeSnapshot['petty_cash_paise']);
    final choices = _periodChoices(period);
    final chartH = mobile ? 140.0 : 188.0;
    final pad = _pagePadding(context);

    final tabBar = Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: mobile ? 1 : 0,
      child: TabBar(
        controller: _tabs,
        isScrollable: mobile,
        tabAlignment: mobile ? TabAlignment.start : TabAlignment.fill,
        labelStyle: mobile
            ? AppTypography.labelMedium
            : AppTypography.labelLarge,
        tabs: [
          Tab(text: l10n.accountantTabIncome),
          Tab(text: l10n.accountantTabExpenses),
          Tab(text: l10n.accountantTabPl),
        ],
      ),
    );

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverPadding(
          padding: pad,
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _LedgerHeroStrip(
                mobile: mobile,
                l10n: l10n,
                period: period,
                choices: choices,
                onPeriod: (v) {
                  ref.read(accountantPeriodSelectionProvider.notifier).state =
                      v;
                },
                onExport: () => _exportCsv(period),
              ),
              SizedBox(height: mobile ? AppSpacing.sm : AppSpacing.md),
              _ResponsivePlStrip(
                mobile: mobile,
                l10n: l10n,
                totalIncome: totalIncome,
                totalExpense: totalExpense,
                profit: profit,
                petty: petty,
              ),
              SizedBox(height: mobile ? AppSpacing.sm : AppSpacing.md),
              _LedgerChartCard(
                mobile: mobile,
                l10n: l10n,
                height: chartH,
                totalIncome: totalIncome,
                totalExpense: totalExpense,
                profit: profit,
              ),
            ]),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _LedgerTabBarDelegate(
            height: mobile ? 46 : 48,
            child: tabBar,
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: true,
          child: TabBarView(
            controller: _tabs,
            physics: const BouncingScrollPhysics(),
            children: [
              _LedgerLinesBody(
                mobile: mobile,
                l10n: l10n,
                entries: income,
                color: AppColors.success,
                useCards: mobile,
              ),
              _LedgerLinesBody(
                mobile: mobile,
                l10n: l10n,
                entries: expenses,
                color: AppColors.error,
                useCards: mobile,
              ),
              _PLStatement(
                l10n: l10n,
                income: totalIncome,
                expenses: totalExpense,
                profit: profit,
                petty: petty,
                mobile: mobile,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

int _i(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('$v') ?? 0;
}

class _LedgerTabBarDelegate extends SliverPersistentHeaderDelegate {
  _LedgerTabBarDelegate({required this.height, required this.child});
  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: overlapsContent
              ? Border(
                  bottom: BorderSide(
                    color: AppColors.divider.withValues(alpha: 0.9),
                  ),
                )
              : null,
          boxShadow: overlapsContent
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _LedgerTabBarDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

class _LedgerHeroStrip extends StatelessWidget {
  const _LedgerHeroStrip({
    required this.mobile,
    required this.l10n,
    required this.period,
    required this.choices,
    required this.onPeriod,
    required this.onExport,
  });

  final bool mobile;
  final AppLocalizations l10n;
  final String period;
  final List<String> choices;
  final ValueChanged<String> onPeriod;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(mobile ? 14 : 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: isDark ? 0.85 : 0.92),
              AppColors.teal.withValues(alpha: 0.78),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(mobile ? 12 : 16),
          child: mobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.accountantLedgerTitle,
                            style: AppTypography.headlineSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: onExport,
                          tooltip: l10n.accountantLedgerExport,
                          icon: const Icon(Icons.ios_share_rounded, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            period,
                            style: AppTypography.labelMedium.copyWith(
                              color: Colors.white,
                              fontFamily: 'JetBrainsMono',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              isDense: true,
                              dropdownColor: AppColors.sidebarBg,
                              value: choices.contains(period)
                                  ? period
                                  : choices.first,
                              iconEnabledColor: Colors.white70,
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
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
                    OutlinedButton.icon(
                      onPressed: onExport,
                      icon: const Icon(Icons.download, size: 18),
                      label: Text(l10n.accountantLedgerExport),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        visualDensity: VisualDensity.compact,
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
                            l10n.accountantLedgerTitle,
                            style: AppTypography.headlineSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            period,
                            style: AppTypography.labelMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontFamily: 'JetBrainsMono',
                            ),
                          ),
                        ],
                      ),
                    ),
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
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: onExport,
                      icon: const Icon(Icons.download, size: 18),
                      label: Text(l10n.accountantLedgerExport),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ResponsivePlStrip extends StatelessWidget {
  const _ResponsivePlStrip({
    required this.mobile,
    required this.l10n,
    required this.totalIncome,
    required this.totalExpense,
    required this.profit,
    required this.petty,
  });

  final bool mobile;
  final AppLocalizations l10n;
  final int totalIncome;
  final int totalExpense;
  final int profit;
  final int petty;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _MiniPlTile(l10n.accountantTabIncome, totalIncome, AppColors.success),
      _MiniPlTile(l10n.accountantTabExpenses, totalExpense, AppColors.error),
      _MiniPlTile(
        l10n.accountantTabPl,
        profit,
        profit >= 0 ? AppColors.teal : AppColors.error,
      ),
      _MiniPlTile(l10n.accountantPlPettyCash, petty, AppColors.primary),
    ];

    if (mobile) {
      return GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 2.15,
        children: tiles,
      );
    }

    return Row(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: tiles[i]),
        ],
      ],
    );
  }
}

class _MiniPlTile extends StatelessWidget {
  const _MiniPlTile(this.label, this.amountPaise, this.color);
  final String label;
  final int amountPaise;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.85)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              AppFormatters.formatPaise(amountPaise),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.titleSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontFamily: 'JetBrainsMono',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LedgerChartCard extends StatelessWidget {
  const _LedgerChartCard({
    required this.mobile,
    required this.l10n,
    required this.height,
    required this.totalIncome,
    required this.totalExpense,
    required this.profit,
  });

  final bool mobile;
  final AppLocalizations l10n;
  final double height;
  final int totalIncome;
  final int totalExpense;
  final int profit;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      padding: EdgeInsets.fromLTRB(
        mobile ? 10 : 14,
        mobile ? 8 : 12,
        mobile ? 10 : 14,
        mobile ? 8 : 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.accountantLedgerIncomeVsExpense,
            style: mobile ? AppTypography.labelLarge : AppTypography.titleSmall,
          ),
          SizedBox(height: mobile ? 6 : 10),
          SizedBox(
            height: height,
            child: BarChart(
              BarChartData(
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: (totalIncome / 100000.0).clamp(0.0, 9999.0),
                        color: AppColors.success,
                        width: mobile ? 22 : 28,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: (totalExpense / 100000.0).clamp(0.0, 9999.0),
                        color: AppColors.error,
                        width: mobile ? 22 : 28,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: (profit / 100000.0).clamp(-9999.0, 9999.0),
                        color: profit >= 0 ? AppColors.teal : AppColors.error,
                        width: mobile ? 22 : 28,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final labels = [
                          l10n.accountantTabIncome,
                          l10n.accountantTabExpenses,
                          'Net',
                        ];
                        final i = v.toInt();
                        if (i < 0 || i >= labels.length)
                          return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            labels[i],
                            style: TextStyle(
                              fontSize: mobile ? 10 : 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: mobile ? 30 : 40,
                      getTitlesWidget: (v, _) => Text(
                        '₹${v.toInt()}L',
                        style: TextStyle(fontSize: mobile ? 9 : 10),
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
        ],
      ),
    );
  }
}

class _LedgerLinesBody extends StatelessWidget {
  const _LedgerLinesBody({
    required this.mobile,
    required this.l10n,
    required this.entries,
    required this.color,
    required this.useCards,
  });

  final bool mobile;
  final AppLocalizations l10n;
  final List<(String, int, String)> entries;
  final Color color;
  final bool useCards;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            AppLocalizations.of(context).noDataFound,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    if (useCards) {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final e = entries[i];
          return _LedgerEntryCard(
            label: e.$1,
            paise: e.$2,
            date: e.$3,
            color: color,
          );
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _TableHeaderRow(l10n: l10n),
        ...entries.map(
          (e) => _TableDataRow(
            label: e.$1,
            paise: e.$2,
            date: e.$3,
            color: color,
            compact: mobile,
          ),
        ),
      ],
    );
  }
}

class _LedgerEntryCard extends StatelessWidget {
  const _LedgerEntryCard({
    required this.label,
    required this.paise,
    required this.date,
    required this.color,
  });

  final String label;
  final int paise;
  final String date;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.45),
        ),
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.06), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.receipt_long_rounded, size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  AppFormatters.formatPaise(paise),
                  style: AppTypography.labelLarge.copyWith(
                    color: color,
                    fontFamily: 'JetBrainsMono',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              date,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontFamily: 'JetBrainsMono',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              l10n.ledgerColDescription,
              style: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              l10n.ledgerColAmount,
              textAlign: TextAlign.end,
              style: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 72,
            child: Text(
              l10n.ledgerColDate,
              style: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableDataRow extends StatelessWidget {
  const _TableDataRow({
    required this.label,
    required this.paise,
    required this.date,
    required this.color,
    required this.compact,
  });

  final String label;
  final int paise;
  final String date;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: compact ? 8 : 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: compact
                  ? AppTypography.bodySmall
                  : AppTypography.bodyMedium,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              AppFormatters.formatPaise(paise),
              textAlign: TextAlign.end,
              style: AppTypography.labelSmall.copyWith(
                color: color,
                fontFamily: 'JetBrainsMono',
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 72,
            child: Text(
              date,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontFamily: 'JetBrainsMono',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PLStatement extends StatelessWidget {
  const _PLStatement({
    required this.l10n,
    required this.income,
    required this.expenses,
    required this.profit,
    required this.petty,
    required this.mobile,
  });

  final AppLocalizations l10n;
  final int income;
  final int expenses;
  final int profit;
  final int petty;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final marginPct = income > 0 ? (profit / income * 100) : 0.0;
    return ListView(
      padding: EdgeInsets.fromLTRB(mobile ? 12 : 16, 8, mobile ? 12 : 16, 24),
      children: [
        _PLLine(
          l10n.accountantTabIncome,
          income,
          AppColors.success,
          mobile: mobile,
        ),
        _PLLine(
          l10n.accountantTabExpenses,
          expenses,
          AppColors.error,
          mobile: mobile,
        ),
        const Divider(height: 20),
        _PLLine(
          l10n.accountantTabPl,
          profit,
          profit >= 0 ? AppColors.success : AppColors.error,
          isTotal: true,
          mobile: mobile,
        ),
        const SizedBox(height: 8),
        _PLLine(
          l10n.accountantPlPettyCash,
          petty,
          AppColors.primary,
          mobile: mobile,
        ),
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              '${l10n.accountantPlMargin}: ${marginPct.toStringAsFixed(1)}%',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PLLine extends StatelessWidget {
  const _PLLine(
    this.label,
    this.amountPaise,
    this.color, {
    this.isTotal = false,
    required this.mobile,
  });

  final String label;
  final int amountPaise;
  final Color color;
  final bool isTotal;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: isTotal
                  ? (mobile
                        ? AppTypography.titleSmall
                        : AppTypography.titleMedium)
                  : AppTypography.bodyMedium,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            AppFormatters.formatPaise(amountPaise),
            style:
                (isTotal
                        ? (mobile
                              ? AppTypography.titleSmall
                              : AppTypography.titleMedium)
                        : AppTypography.bodyMedium)
                    .copyWith(color: color, fontFamily: 'JetBrainsMono'),
          ),
        ],
      ),
    );
  }
}
