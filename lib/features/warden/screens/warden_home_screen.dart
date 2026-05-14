import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../l10n/app_localizations.dart';
import '../../../routing/app_routes.dart';
import '../providers/warden_lodge_providers.dart';
import '../widgets/warden_portal_bar_actions.dart';

/// Lodge-style front desk: occupancy, hospitality note, deep links to ops.
class WardenHomeScreen extends ConsumerWidget {
  const WardenHomeScreen({super.key});

  String _greeting(AppLocalizations l10n) {
    final h = DateTime.now().hour;
    if (h < 12) return l10n.wardenLodgeGoodMorning;
    if (h < 17) return l10n.wardenLodgeGoodAfternoon;
    return l10n.wardenLodgeGoodEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final desk = ref.watch(hostelDeskInfoProvider);
    final students = MockData.hostelStudents;
    final visitors = MockData.visitors;
    final outpasses = MockData.hostelOutpasses;
    final activeVisitors = visitors.where((v) => v.checkOutTime == null).length;
    final absentCount = students.where((s) => !s.isPresent).length;
    final presentCount = students.length - absentCount;
    final pendingOutpasses = outpasses
        .where((o) => o.status == 'pending')
        .length;

    final property = desk['property_name']?.toString() ?? 'Hostel';
    final chef = desk['chef_special']?.toString() ?? '';
    final quiet = desk['quiet_hours']?.toString() ?? '';
    final occNote = desk['occupancy_note']?.toString() ?? '';

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(
              title: Text(l10n.wardenLodgeDeskTitle),
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              actions: const [
                WardenPortalBarActions(),
                SizedBox(width: AppSpacing.sm),
              ],
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NcCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.teal.withValues(alpha: 0.25),
                          AppColors.accent.withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.emoji_food_beverage_outlined,
                      size: 36,
                      color: AppColors.teal,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_greeting(l10n)} · ${AppFormatters.shortDate(DateTime.now())}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          l10n.wardenLodgeRollCallHint,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.teal,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.wardenLodgeHospitalityLine,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            NcCard(
              color: AppColors.warning.withValues(alpha: 0.07),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_bar, color: AppColors.warning, size: 22),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        l10n.wardenLodgeSeasonalCard,
                        style: AppTypography.titleSmall,
                      ),
                    ],
                  ),
                  if (chef.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${l10n.wardenLodgeChefSpecialLabel}: $chef',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                  if (quiet.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.wardenLodgeQuietHoursLabel}: $quiet',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (occNote.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.wardenLodgeOccupancyLabel}: $occNote',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(l10n.wardenLodgeOverview, style: AppTypography.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: l10n.present,
                    value: '$presentCount',
                    color: AppColors.success,
                    icon: Icons.check_circle,
                    onTap: () => context.go(AppRoutes.wardenRollcall),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatCard(
                    label: l10n.absent,
                    value: '$absentCount',
                    color: AppColors.error,
                    icon: Icons.cancel,
                    onTap: () => context.go(AppRoutes.wardenRollcall),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: l10n.visitorsTitle,
                    value: '$activeVisitors',
                    color: AppColors.accent,
                    icon: Icons.person_search,
                    onTap: () => context.go(AppRoutes.wardenVisitors),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatCard(
                    label: l10n.outpassTitle,
                    value: '$pendingOutpasses',
                    color: AppColors.warning,
                    icon: Icons.event_busy,
                    onTap: () => context.go(AppRoutes.wardenOutpass),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              l10n.wardenLodgeHouseOps,
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _HospitalityTile(
              icon: Icons.restaurant_menu,
              title: l10n.wardenLodgeMessHall,
              subtitle: l10n.wardenLodgeMessHallSubtitle,
              color: AppColors.accent,
              onTap: () => context.go(AppRoutes.wardenDining),
            ),
            _HospitalityTile(
              icon: Icons.bed_outlined,
              title: l10n.wardenLodgeRoomBoard,
              subtitle: l10n.wardenLodgeRoomBoardSubtitle,
              color: AppColors.deepPurple,
              onTap: () => context.go(AppRoutes.wardenRooms),
            ),
            _HospitalityTile(
              icon: Icons.shield_moon_outlined,
              title: l10n.wardenLodgeNightPatrol,
              subtitle: l10n.wardenLodgeNightPatrolSubtitle,
              color: AppColors.primary,
              onTap: () => context.go(AppRoutes.wardenNightPatrol),
            ),
            _HospitalityTile(
              icon: Icons.sticky_note_2_outlined,
              title: l10n.wardenLodgeConcierge,
              subtitle: l10n.wardenLodgeConciergeSubtitle,
              color: AppColors.teal,
              onTap: () => context.go(AppRoutes.wardenConcierge),
            ),
            const SizedBox(height: AppSpacing.md),
            _HospitalityTile(
              icon: Icons.how_to_reg,
              title: l10n.rollCallTitle,
              subtitle: absentCount > 0
                  ? '$absentCount ${l10n.absent.toLowerCase()} — tap to reconcile'
                  : l10n.present,
              color: AppColors.teal,
              onTap: () => context.go(AppRoutes.wardenRollcall),
            ),
            _HospitalityTile(
              icon: Icons.badge,
              title: l10n.visitorsTitle,
              subtitle: activeVisitors > 0
                  ? '$activeVisitors inside · reception flow'
                  : 'Reception & gate log',
              color: AppColors.accent,
              onTap: () => context.go(AppRoutes.wardenVisitors),
            ),
            _HospitalityTile(
              icon: Icons.event_note,
              title: l10n.outpassTitle,
              subtitle: pendingOutpasses > 0
                  ? '$pendingOutpasses awaiting approval'
                  : 'Leave & return windows',
              color: AppColors.warning,
              onTap: () => context.go(AppRoutes.wardenOutpass),
            ),
            if (absentCount > 0) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                '${l10n.absent} · ${l10n.rollCallTitle}',
                style: AppTypography.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.wardenLodgeAbsentHint,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: AppTypography.headlineSmall.copyWith(
                  color: color,
                  fontFamily: 'JetBrainsMono',
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
        ),
      ),
    );
  }
}

class _HospitalityTile extends StatelessWidget {
  const _HospitalityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: AppTypography.labelLarge),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }
}
