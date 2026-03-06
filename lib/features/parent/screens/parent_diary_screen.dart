import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../providers/parent_providers.dart';

class ParentDiaryScreen extends ConsumerWidget {
  const ParentDiaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryAsync = ref.watch(parentDiaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Diary & Homework')),
      backgroundColor: AppColors.background,
      body: diaryAsync.when(
        loading: () =>
            const Padding(padding: EdgeInsets.all(16), child: NcShimmerList()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (entries) {
          // Group by date
          final dates = <DateTime>[];
          for (var d = 6; d >= 0; d--) {
            dates.add(DateTime.now().subtract(Duration(days: d)));
          }

          return Column(
            children: [
              // 7-day date strip
              Container(
                height: 70,
                color: AppColors.card,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  itemCount: dates.length,
                  itemBuilder: (ctx, i) {
                    final d = dates[i];
                    final isSelected = d.isToday;
                    return Container(
                      margin: const EdgeInsets.only(right: AppSpacing.xs),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(AppSpacing.xs),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.divider,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppFormatters.formatShortDate(d),
                            style: AppTypography.labelSmall.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Subject expansion cards
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: entries.length,
                  itemBuilder: (ctx, i) {
                    final e = entries[i];
                    final subjectColor = e.subject.subjectColor;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: NcCard(
                        padding: EdgeInsets.zero,
                        child: Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            leading: Container(
                              width: 4,
                              height: 40,
                              decoration: BoxDecoration(
                                color: subjectColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            title: Text(
                              e.subject,
                              style: AppTypography.labelLarge,
                            ),
                            subtitle: Text(
                              AppFormatters.formatDate(e.date),
                              style: AppTypography.bodySmall,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (e.hasAttachment)
                                  const Icon(
                                    Icons.attach_file,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                if (e.completed)
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.success,
                                    size: 16,
                                  ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.md,
                                  0,
                                  AppSpacing.md,
                                  AppSpacing.md,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(),
                                    _DiarySection(
                                      'Classwork',
                                      e.classwork,
                                      Icons.menu_book,
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    _DiarySection(
                                      'Homework',
                                      e.homework,
                                      Icons.assignment,
                                    ),
                                    if (e.dueDate != null) ...[
                                      const SizedBox(height: AppSpacing.xs),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.event,
                                            size: 14,
                                            color: AppColors.warning,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Due: ${AppFormatters.formatDate(e.dueDate!)}',
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                                  color: AppColors.warning,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DiarySection extends StatelessWidget {
  const _DiarySection(this.title, this.content, this.icon);
  final String title;
  final String content;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              title,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(content, style: AppTypography.bodyMedium),
      ],
    );
  }
}
