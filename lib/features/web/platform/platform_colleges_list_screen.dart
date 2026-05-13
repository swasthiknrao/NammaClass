import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/platform/platform_revenue_estimate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/registered_college.dart';
import '../../../../routing/app_routes.dart';
import '../../auth/providers/auth_provider.dart';
import 'platform_college_registry_provider.dart';

class PlatformCollegesListScreen extends ConsumerWidget {
  const PlatformCollegesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reg = ref.watch(platformCollegeRegistryProvider);
    final role = ref.watch(userRoleProvider);
    final isSuper = role == UserRole.superAdmin;
    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return reg.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (colleges) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Text('Colleges', style: AppTypography.headlineMedium),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Reload from platform_college_registry.json',
                    onPressed: () async {
                      await ref
                          .read(platformCollegeRegistryProvider.notifier)
                          .reloadFromDisk();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'College store refreshed from JSON on disk.',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.storage_outlined),
                  ),
                  if (isSuper)
                    IconButton(
                      tooltip:
                          'Append demo colleges (nc_seed_*) to JSON if not present',
                      onPressed: () async {
                        await ref
                            .read(platformCollegeRegistryProvider.notifier)
                            .mergeSeedCollegesIfAbsent();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Sample colleges merged into registry JSON (skipped duplicates).',
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.auto_stories_outlined),
                    ),
                  FilledButton.icon(
                    onPressed: () =>
                        context.push(AppRoutes.webPlatformAddCollege),
                    icon: const Icon(Icons.add_business_outlined),
                    label: const Text('Add college'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(
                'Single store: platform_college_registry.json — list, add, and '
                'reload for everyone. Removing rows or merging demo seeds is '
                'limited to Super Admin until PostgreSQL ships.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: colleges.isEmpty
                  ? Center(
                      child: Text(
                        'No colleges in registry yet.',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref
                          .read(platformCollegeRegistryProvider.notifier)
                          .reloadFromDisk(),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: colleges.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, i) {
                          final c = colleges[i];
                          final mrr = estimatedMrrInrPer1kMauBand(c.profile);
                          return Card(
                            child: InkWell(
                              onTap: () => context.push(
                                '/web/platform/colleges/${Uri.encodeComponent(c.tenantId)}',
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Color(
                                        c.profile.primaryColorValue,
                                      ),
                                      child: Text(
                                        c.profile.institutionName.isNotEmpty
                                            ? c.profile.institutionName[0]
                                                  .toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c.profile.institutionName.isEmpty
                                                ? '(unnamed)'
                                                : c.profile.institutionName,
                                            style: AppTypography.titleSmall,
                                          ),
                                          Text(
                                            c.tenantId,
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _StatusChip(status: c.status),
                                    const SizedBox(width: AppSpacing.sm),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${c.users.length} users · ${c.enabledModuleCount} modules',
                                          style: AppTypography.labelSmall,
                                        ),
                                        Text(
                                          currency.format(mrr),
                                          style: AppTypography.labelMedium,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final CollegeProvisioningStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      CollegeProvisioningStatus.live => ('Live', AppColors.success),
      CollegeProvisioningStatus.pending => ('Pending', AppColors.warning),
      CollegeProvisioningStatus.inProgress => (
        'In progress',
        AppColors.primary,
      ),
    };
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
      backgroundColor: color.withValues(alpha: 0.15),
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
