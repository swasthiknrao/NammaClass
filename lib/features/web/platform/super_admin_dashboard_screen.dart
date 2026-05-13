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

/// Super Admin home — KPIs are computed from the persisted college registry + rate card (no random placeholders).
class SuperAdminDashboardScreen extends ConsumerWidget {
  const SuperAdminDashboardScreen({super.key});

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
      error: (e, _) => Center(child: Text('Registry: $e')),
      data: (colleges) {
        final institutions = colleges.length;
        final trackedUsers = colleges.fold<int>(
          0,
          (s, c) => s + c.users.length,
        );
        final mrrSum = colleges.fold<int>(
          0,
          (s, c) => s + estimatedMrrInrPer1kMauBand(c.profile),
        );
        final pending = colleges
            .where((c) => c.status == CollegeProvisioningStatus.pending)
            .length;
        final inProgress = colleges
            .where((c) => c.status == CollegeProvisioningStatus.inProgress)
            .length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSuper ? 'Platform control' : 'Federation hub',
                style: AppTypography.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              if (!isSuper)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.teal.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        'Institution operator view — you keep the full academic web shell '
                        'plus this federation rail. Registry JSON is shared: you can list, '
                        'refresh, and register colleges. Super Admin alone removes rows or '
                        'merges demo seeds.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              Text(
                'Numbers below are read from platform_college_registry.json: '
                'colleges in that file, user rows per college, estimated MRR from '
                'enabled modules (₹ per 1k MAU from assets/config/module_mrr_inr.json), '
                'and provisioning status counts.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final cross = w > 900 ? 4 : (w > 600 ? 2 : 1);
                  return GridView.count(
                    crossAxisCount: cross,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: cross == 4 ? 1.35 : 1.5,
                    children: [
                      _KpiTile(
                        icon: Icons.apartment_outlined,
                        label: 'Colleges',
                        value: '$institutions',
                        subtitle: 'Rows in JSON registry file',
                        color: AppColors.primary,
                      ),
                      _KpiTile(
                        icon: Icons.people_outline,
                        label: 'Tracked users',
                        value: '$trackedUsers',
                        subtitle: 'Sum of roster rows per college',
                        color: AppColors.teal,
                      ),
                      _KpiTile(
                        icon: Icons.currency_rupee_outlined,
                        label: 'Est. MRR (rate sum)',
                        value: currency.format(mrrSum),
                        subtitle: 'Σ module bands; not billing',
                        color: AppColors.success,
                      ),
                      _KpiTile(
                        icon: Icons.hourglass_top_outlined,
                        label: 'Pipeline',
                        value: '${pending + inProgress}',
                        subtitle: '$pending pending · $inProgress in progress',
                        color: AppColors.warning,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  FilledButton.icon(
                    onPressed: () => context.go(AppRoutes.webPlatformColleges),
                    icon: const Icon(Icons.list_alt),
                    label: const Text('College list'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.go(AppRoutes.webPlatformAddCollege),
                    icon: const Icon(Icons.add_business_outlined),
                    label: const Text('Add college'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.go(AppRoutes.webUserManagement),
                    icon: const Icon(Icons.manage_accounts_outlined),
                    label: const Text('Users & roles'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(label, style: AppTypography.labelMedium),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              value,
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
