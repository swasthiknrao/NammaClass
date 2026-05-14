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

class WardenRoomsScreen extends ConsumerWidget {
  const WardenRoomsScreen({super.key});

  String _nextStatus(String current) {
    switch (current) {
      case 'ready':
        return 'occupied';
      case 'occupied':
        return 'turnover';
      case 'turnover':
        return 'ready';
      default:
        return 'ready';
    }
  }

  String _label(String status, AppLocalizations l10n) {
    switch (status) {
      case 'ready':
        return l10n.wardenRoomStatusReady;
      case 'occupied':
        return l10n.wardenRoomStatusOccupied;
      case 'turnover':
        return l10n.wardenRoomStatusTurnover;
      default:
        return status;
    }
  }

  Color _color(String status) {
    switch (status) {
      case 'ready':
        return AppColors.success;
      case 'occupied':
        return AppColors.primary;
      case 'turnover':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rooms = ref.watch(wardenRoomHousekeepingProvider);

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(
              title: Text(l10n.wardenRoomsTitle),
              backgroundColor: AppColors.deepPurple,
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
            l10n.wardenLodgeRoomBoardSubtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.wardenRoomTapCycle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...rooms.map((room) {
            final roomNo = '${room['room_no']}';
            final status = '${room['status'] ?? 'ready'}';
            final floor = '${room['floor'] ?? '—'}';
            final linen = '${room['linen_due'] ?? ''}';
            final note = '${room['note'] ?? ''}';
            final c = _color(status);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    final next = _nextStatus(status);
                    MockData.patchWardenRoom(roomNo, {'status': next});
                    ref.read(dataSyncProvider.notifier).bump();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: NcCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 4,
                          height: 72,
                          decoration: BoxDecoration(
                            color: c,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Room $roomNo',
                                style: AppTypography.titleSmall,
                              ),
                              Text(
                                l10n.wardenRoomFloor(floor),
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Chip(
                                label: Text(
                                  _label(status, l10n),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                backgroundColor: c.withValues(alpha: 0.15),
                                visualDensity: VisualDensity.compact,
                              ),
                              if (linen.isNotEmpty)
                                Text(
                                  '${l10n.wardenRoomLinen}: $linen',
                                  style: AppTypography.bodySmall,
                                ),
                              if (note.isNotEmpty)
                                Text(
                                  note,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.swap_horiz,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
