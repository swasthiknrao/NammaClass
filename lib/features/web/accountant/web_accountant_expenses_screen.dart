import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../l10n/app_localizations.dart';
import 'accountant_finance_providers.dart';

class WebAccountantExpensesScreen extends ConsumerWidget {
  const WebAccountantExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pipeline = ref.watch(expensePipelineProvider);
    final budget = ref.watch(financeBudgetVsActualProvider);

    final pipeChildren = <Widget>[_PipeHeader(l10n)];
    for (final e in pipeline) {
      pipeChildren.add(const Divider(height: 1));
      final vendor = '${e['vendor'] ?? ''}';
      final amt = _i(e['amount_paise']);
      final st = '${e['status'] ?? ''}';
      final due = '${e['due_date'] ?? ''}';
      pipeChildren.add(
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(vendor, style: AppTypography.bodyMedium),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  AppFormatters.formatPaise(amt),
                  style: AppTypography.labelMedium,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(st, style: AppTypography.bodySmall),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  due,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontFamily: 'JetBrainsMono',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.accountantExpensesTitle,
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.accountantExpensesSubtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.accountantExpenseBurnTitle,
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          ...budget.map((row) {
            final cat = '${row['category'] ?? ''}';
            final cap = _i(row['budget_paise']);
            final act = _i(row['actual_paise']);
            final r = cap > 0 ? (act / cap).clamp(0.0, 1.0) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: NcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(cat, style: AppTypography.titleSmall),
                        Text(
                          '${AppFormatters.formatPaiseCompact(act)} / ${AppFormatters.formatPaiseCompact(cap)}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontFamily: 'JetBrainsMono',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: r,
                        minHeight: 10,
                        backgroundColor: AppColors.divider,
                        valueColor: AlwaysStoppedAnimation(
                          r > 0.92 ? AppColors.warning : AppColors.teal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.accountantPayablesPipelineTitle,
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          NcCard(
            padding: EdgeInsets.zero,
            child: Column(children: pipeChildren),
          ),
        ],
      ),
    );
  }
}

class _PipeHeader extends StatelessWidget {
  const _PipeHeader(this.l10n);
  final AppLocalizations l10n;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              l10n.accountantPipelineVendor,
              style: AppTypography.labelLarge,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              l10n.accountantPipelineAmount,
              style: AppTypography.labelLarge,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              l10n.accountantPipelineStatus,
              style: AppTypography.labelLarge,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              l10n.accountantPipelineDue,
              style: AppTypography.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}

int _i(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('$v') ?? 0;
}
