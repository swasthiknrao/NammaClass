import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/providers/data_sync_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/warden_lodge_providers.dart';
import '../widgets/warden_portal_bar_actions.dart';

class WardenDiningScreen extends ConsumerWidget {
  const WardenDiningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rounds = ref.watch(wardenDiningRoundsProvider);

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(
              title: Text(l10n.wardenDiningTitle),
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              actions: const [
                WardenPortalBarActions(),
                SizedBox(width: AppSpacing.sm),
              ],
            ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            l10n.wardenLodgeMessHallSubtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...rounds.map((r) {
            final id = '${r['id']}';
            final expected = (r['expected'] as num?)?.toInt() ?? 0;
            var served = (r['served'] as num?)?.toInt() ?? 0;
            final status = '${r['status'] ?? '—'}';
            final note = '${r['chef_note'] ?? ''}';
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: NcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.restaurant, color: AppColors.accent),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            '${r['meal']}',
                            style: AppTypography.titleSmall,
                          ),
                        ),
                        Chip(
                          label: Text(
                            status,
                            style: const TextStyle(fontSize: 11),
                          ),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: AppColors.teal.withValues(
                            alpha: 0.12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.wardenDiningWindow}: ${r['window']}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${l10n.wardenDiningServed}: $served / ${l10n.wardenDiningExpected}: $expected',
                      style: AppTypography.labelMedium,
                    ),
                    if (note.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${l10n.wardenDiningChefNote}: $note',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    FilledButton.tonalIcon(
                      onPressed: served >= expected
                          ? null
                          : () {
                              served++;
                              MockData.patchWardenDiningRound(id, {
                                'served': served,
                                'status': served >= expected
                                    ? 'Closed'
                                    : 'In service',
                              });
                              ref.read(dataSyncProvider.notifier).bump();
                              if (context.mounted && served >= expected) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.wardenDiningRoundComplete,
                                    ),
                                  ),
                                );
                              }
                            },
                      icon: const Icon(Icons.room_service_outlined, size: 20),
                      label: Text(l10n.wardenDiningPortionServed),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
