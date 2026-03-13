import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_avatar.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../core/widgets/nc_shimmer.dart';
import 'package:go_router/go_router.dart';

import '../../../features/admin/providers/staff_notifier.dart';
import '../../../routing/app_routes.dart';

class WebStaffScreen extends ConsumerWidget {
  const WebStaffScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(staffNotifierProvider);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 280,
                child: SearchBar(
                  hintText: 'Search staff…',
                  leading: const Icon(Icons.search),
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 16),
                  ),
                  backgroundColor: const WidgetStatePropertyAll(AppColors.card),
                  elevation: const WidgetStatePropertyAll(0),
                  side: const WidgetStatePropertyAll(
                    BorderSide(color: AppColors.divider),
                  ),
                ),
              ),
              const Spacer(),
              NcPrimaryButton(
                label: 'Add Staff',
                icon: Icons.add,
                onPressed: () => context.push(AppRoutes.webAddStaff),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: staffAsync.when(
              loading: () => const NcShimmerList(itemCount: 6),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (staff) => NcCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Container(
                      color: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          _HeaderCell('Name', flex: 3),
                          _HeaderCell('Role', flex: 2),
                          _HeaderCell('Department', flex: 2),
                          _HeaderCell('Phone', flex: 2),
                          _HeaderCell('Status', flex: 1),
                          _HeaderCell('Actions', flex: 1),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: staff.length,
                        separatorBuilder: (_, i) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final s = staff[i];
                          return Padding(
                            key: ValueKey(s.id),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    children: [
                                      NcAvatar(name: s.name, radius: 14),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          s.name,
                                          style: AppTypography.labelMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    s.role,
                                    style: AppTypography.bodySmall,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    s.department,
                                    style: AppTypography.bodySmall,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    s.phone,
                                    style: AppTypography.bodySmall,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: NcStatusChip(
                                    type: s.status == 'active'
                                        ? NcChipType.active
                                        : NcChipType.inactive,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 16),
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label, {this.flex = 1});
  final String label;
  final int flex;
  @override
  Widget build(BuildContext context) => Expanded(
    flex: flex,
    child: Text(
      label,
      style: AppTypography.labelMedium.copyWith(color: Colors.white),
    ),
  );
}
