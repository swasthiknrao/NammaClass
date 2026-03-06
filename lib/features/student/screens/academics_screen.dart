import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../providers/student_providers.dart';

class AcademicsScreen extends ConsumerWidget {
  const AcademicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeworkAsync = ref.watch(studentHomeworkProvider);
    final timetableAsync = ref.watch(studentTimetableProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Academics')),
      backgroundColor: AppColors.background,
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Homework', icon: Icon(Icons.assignment, size: 16)),
                Tab(text: 'Timetable', icon: Icon(Icons.table_chart, size: 16)),
                Tab(text: 'Report Cards', icon: Icon(Icons.grade, size: 16)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Homework tab
                  homeworkAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16),
                      child: NcShimmerList(),
                    ),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (entries) => ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: entries.length,
                      itemBuilder: (ctx, i) {
                        final e = entries[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: NcCard(
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: e.subject.subjectColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.subject,
                                        style: AppTypography.labelLarge,
                                      ),
                                      Text(
                                        e.homework,
                                        style: AppTypography.bodySmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (e.dueDate != null)
                                        Text(
                                          'Due: ${AppFormatters.formatDate(e.dueDate!)}',
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                color: AppColors.warning,
                                              ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (e.completed)
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.success,
                                  )
                                else
                                  const Icon(
                                    Icons.radio_button_unchecked,
                                    color: AppColors.textSecondary,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Timetable tab
                  timetableAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16),
                      child: NcShimmerList(),
                    ),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (timetable) {
                      final days = [
                        'Monday',
                        'Tuesday',
                        'Wednesday',
                        'Thursday',
                        'Friday',
                      ];
                      return ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: days.length,
                        itemBuilder: (ctx, di) {
                          final day = days[di];
                          final periods = timetable[day] ?? [];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.xs,
                                ),
                                child: Text(
                                  day,
                                  style: AppTypography.headlineSmall,
                                ),
                              ),
                              ...periods.map(
                                (p) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.xs,
                                  ),
                                  child: NcCard(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.xs,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: p.subject.subjectColor,
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Text(
                                            p.subject,
                                            style: AppTypography.labelMedium,
                                          ),
                                        ),
                                        Text(
                                          '${p.startTime} – ${p.endTime}',
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  // Report Cards tab (placeholder)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.grade,
                          size: 64,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Report Cards',
                          style: AppTypography.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Term 1, 2 & 3 report cards',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ...[
                          'Term 1 — Apr-Jun 2025',
                          'Term 2 — Jul-Sep 2025',
                          'Term 3 — Oct-Dec 2025',
                        ].map(
                          (t) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                              left: AppSpacing.lg,
                              right: AppSpacing.lg,
                            ),
                            child: NcCard(
                              onTap: () {},
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.picture_as_pdf,
                                    color: AppColors.error,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      t,
                                      style: AppTypography.labelMedium,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.download,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
