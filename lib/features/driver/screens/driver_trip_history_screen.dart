import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/driver_provider.dart';
import '../widgets/driver_portal_bar_actions.dart';

class DriverTripHistoryScreen extends ConsumerWidget {
  const DriverTripHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rows = ref.watch(driverTripHistoryProvider);

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(
              title: Text(l10n.driverTripHistoryTitle),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              actions: const [
                DriverPortalBarActions(),
                SizedBox(width: AppSpacing.sm),
              ],
            ),
      body: rows.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  l10n.driverTripLogEmpty,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: rows.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
              itemBuilder: (_, i) {
                final r = rows[i];
                return NcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${r['route'] ?? '—'} · ${r['shift'] ?? '—'}',
                        style: AppTypography.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${r['date'] ?? ''}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.driverTripHistoryCounts(
                          (r['boarded'] as num?)?.toInt() ?? 0,
                          (r['total'] as num?)?.toInt() ?? 0,
                        ),
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.teal,
                        ),
                      ),
                      if ((r['status']?.toString().isNotEmpty ?? false))
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            r['status'].toString(),
                            style: AppTypography.bodySmall,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
