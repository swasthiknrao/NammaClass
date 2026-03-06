import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_avatar.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../providers/admin_providers.dart';

class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(adminStudentsProvider);
    final staffAsync = ref.watch(adminStaffProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('People')),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SearchBar(
              hintText: 'Search people…',
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
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Students'),
                      Tab(text: 'Staff'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Students
                        studentsAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.all(16),
                            child: NcShimmerList(),
                          ),
                          error: (e, _) => Center(child: Text('Error: $e')),
                          data: (students) => ListView.builder(
                            itemCount: students.length,
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            itemBuilder: (ctx, i) {
                              final s = students[i];
                              return ListTile(
                                tileColor: i % 2 == 0
                                    ? AppColors.card
                                    : AppColors.background,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.xs,
                                  ),
                                ),
                                leading: NcAvatar(name: s.name, radius: 18),
                                title: Text(
                                  s.name,
                                  style: AppTypography.labelMedium,
                                ),
                                subtitle: Text(
                                  '${s.classSection} • Roll: ${s.rollNo}',
                                  style: AppTypography.bodySmall,
                                ),
                                trailing: NcChip(
                                  label: s.feeStatus,
                                  selected: s.feeStatus == 'paid',
                                ),
                              );
                            },
                          ),
                        ),

                        // Staff
                        staffAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.all(16),
                            child: NcShimmerList(),
                          ),
                          error: (e, _) => Center(child: Text('Error: $e')),
                          data: (staff) => ListView.builder(
                            itemCount: staff.length,
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            itemBuilder: (ctx, i) {
                              final s = staff[i];
                              return ListTile(
                                tileColor: i % 2 == 0
                                    ? AppColors.card
                                    : AppColors.background,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.xs,
                                  ),
                                ),
                                leading: NcAvatar(name: s.name, radius: 18),
                                title: Text(
                                  s.name,
                                  style: AppTypography.labelMedium,
                                ),
                                subtitle: Text(
                                  '${s.role} • ${s.department}',
                                  style: AppTypography.bodySmall,
                                ),
                                trailing: NcChip(
                                  label: s.status,
                                  selected: s.status == 'active',
                                ),
                              );
                            },
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
