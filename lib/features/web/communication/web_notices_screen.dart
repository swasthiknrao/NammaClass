import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../features/admin/providers/admin_providers.dart';

class WebNoticesScreen extends ConsumerWidget {
  const WebNoticesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(adminNoticesProvider);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Notices', style: AppTypography.headlineMedium),
                    const Spacer(),
                    NcPrimaryButton(
                      label: 'Compose',
                      icon: Icons.add,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: noticesAsync.when(
                    loading: () => const CircularProgressIndicator.adaptive(),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (notices) => ListView.separated(
                      itemCount: notices.length,
                      separatorBuilder: (_, i) => const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        final n = notices[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              if (!n.isRead)
                                Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: const BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              else
                                const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n.title,
                                      style: AppTypography.labelLarge,
                                    ),
                                    Text(
                                      n.body,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              NcChip(label: n.category),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                AppFormatters.timeAgo(n.date),
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert, size: 18),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Compose panel
          SizedBox(
            width: 360,
            child: NcCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Draft Notice', style: AppTypography.headlineSmall),
                  const SizedBox(height: AppSpacing.md),
                  const TextField(
                    decoration: InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const TextField(
                    decoration: InputDecoration(labelText: 'Message'),
                    maxLines: 6,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.auto_awesome, size: 16),
                    label: const Text('AI Draft'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  NcPrimaryButton(
                    label: 'Publish Notice',
                    fullWidth: true,
                    onPressed: () {},
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
