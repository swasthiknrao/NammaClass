import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../core/widgets/nc_empty_state.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../providers/parent_providers.dart';

class ParentNoticesScreen extends ConsumerWidget {
  const ParentNoticesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(parentNoticesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notices')),
      backgroundColor: Colors.transparent,
      body: noticesAsync.when(
        loading: () =>
            const Padding(padding: EdgeInsets.all(16), child: NcShimmerList()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (notices) {
          if (notices.isEmpty) {
            return const NcEmptyState(
              title: 'No Notices',
              body: 'You have no new notices.',
              illustration: NcIllustration.noNotifications,
            );
          }

          // Group by category
          final categories = notices.map((n) => n.category).toSet().toList();

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: notices.length + categories.length,
            itemBuilder: (ctx, i) {
              // This is a simplified list; in production use sticky_headers
              final notice =
                  notices[i < notices.length ? i : notices.length - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: NcCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!notice.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(
                            top: 6,
                            right: AppSpacing.xs,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        )
                      else
                        const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    notice.title,
                                    style: AppTypography.labelLarge.copyWith(
                                      fontWeight: notice.isRead
                                          ? FontWeight.w400
                                          : FontWeight.w700,
                                    ),
                                  ),
                                ),
                                NcChip(label: notice.category),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notice.body,
                              style: AppTypography.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  AppFormatters.timeAgo(notice.date),
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (notice.hasAttachment) ...[
                                  const SizedBox(width: AppSpacing.xs),
                                  const Icon(
                                    Icons.attach_file,
                                    size: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  const Text(
                                    ' Attachment',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
