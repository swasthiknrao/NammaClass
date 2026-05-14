import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/providers/data_sync_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../l10n/app_localizations.dart';
import 'accountant_finance_providers.dart';

class WebAccountantMonthCloseScreen extends ConsumerWidget {
  const WebAccountantMonthCloseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final period = ref.watch(accountantFinancePeriodProvider);
    final items = ref.watch(financeMonthCloseItemsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.accountantMonthCloseTitle,
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.accountantMonthCloseSubtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.accountantMonthCloseChecklist,
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          NcCard(
            child: Column(
              children: items.map((row) {
                final id = '${row['id'] ?? ''}';
                final label = '${row['label'] ?? ''}';
                final done = row['done'] == true || row['done'] == 1;
                return CheckboxListTile(
                  value: done,
                  onChanged: (v) {
                    MockData.patchFinanceMonthCloseItem(id, v ?? false);
                    ref.read(dataSyncProvider.notifier).bump();
                  },
                  title: Text(label, style: AppTypography.bodyMedium),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.accountantExportPdfSnack(period)),
                    ),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Text(l10n.accountantExportPdfPlaceholder),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                    const ClipboardData(text: 'Tally_Voucher_Preset_May2026'),
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.accountantExportTallySnack)),
                  );
                },
                icon: const Icon(Icons.table_chart_outlined),
                label: Text(l10n.accountantExportTallyPreset),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
