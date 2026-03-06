import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_avatar.dart';
import '../../../core/widgets/nc_bottom_sheet.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../providers/teacher_providers.dart';

class MyStudentsScreen extends ConsumerWidget {
  const MyStudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(teacherStudentsProvider);

    final classes = ['8-A', '8-B', '9-A', '9-B', '10-A'];

    return Scaffold(
      appBar: AppBar(title: const Text('My Students')),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SearchBar(
              hintText: 'Search students…',
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
          studentsAsync.when(
            loading: () => const Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: NcShimmerList(),
              ),
            ),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (students) => Expanded(
              child: DefaultTabController(
                length: classes.length,
                child: Column(
                  children: [
                    TabBar(
                      isScrollable: true,
                      tabs: classes.map((c) => Tab(text: c)).toList(),
                      tabAlignment: TabAlignment.start,
                    ),
                    Expanded(
                      child: TabBarView(
                        children: classes.map((cls) {
                          final filtered = students
                              .where((s) => s.classSection == cls)
                              .toList();
                          return ListView.builder(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            itemCount: filtered.length,
                            itemBuilder: (ctx, i) {
                              final s = filtered[i];
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.xs,
                                ),
                                child: ListTile(
                                  tileColor: AppColors.card,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.sm,
                                    ),
                                  ),
                                  leading: NcAvatar(name: s.name, radius: 20),
                                  title: Text(
                                    s.name,
                                    style: AppTypography.labelLarge,
                                  ),
                                  subtitle: Text(
                                    'Roll: ${s.rollNo}',
                                    style: AppTypography.bodySmall,
                                  ),
                                  trailing: NcStatusChip(
                                    type: s.attendancePercent >= 0.85
                                        ? NcChipType.present
                                        : NcChipType.absent,
                                    label:
                                        '${(s.attendancePercent * 100).round()}%',
                                  ),
                                  onTap: () {
                                    NcBottomSheet.show(
                                      context,
                                      title: s.name,
                                      initialChildSize: 0.5,
                                      child: Padding(
                                        padding: const EdgeInsets.all(
                                          AppSpacing.md,
                                        ),
                                        child: Column(
                                          children: [
                                            NcAvatar(name: s.name, radius: 36),
                                            const SizedBox(
                                              height: AppSpacing.md,
                                            ),
                                            _InfoRow('Class', s.classSection),
                                            _InfoRow('Roll No', s.rollNo),
                                            _InfoRow(
                                              'Attendance',
                                              '${(s.attendancePercent * 100).round()}%',
                                            ),
                                            _InfoRow(
                                              'Fee Status',
                                              s.feeStatus.toUpperCase(),
                                            ),
                                            if (s.parentName != null)
                                              _InfoRow('Parent', s.parentName!),
                                            if (s.parentPhone != null) ...[
                                              _InfoRow(
                                                'Parent Phone',
                                                s.parentPhone!,
                                              ),
                                              const SizedBox(
                                                height: AppSpacing.md,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: OutlinedButton.icon(
                                                      onPressed: () {},
                                                      icon: const Icon(
                                                        Icons.call,
                                                        size: 16,
                                                      ),
                                                      label: const Text(
                                                        'Call Parent',
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: AppSpacing.sm,
                                                  ),
                                                  Expanded(
                                                    child: ElevatedButton.icon(
                                                      onPressed: () {},
                                                      icon: const Icon(
                                                        Icons.chat,
                                                        size: 16,
                                                      ),
                                                      label: const Text(
                                                        'Message',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        }).toList(),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(value, style: AppTypography.labelMedium),
        ],
      ),
    );
  }
}
