import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/config/tenant_policy_loader.dart';
import '../../../../core/platform/platform_revenue_estimate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/nc_feature.dart';
import '../../../../domain/entities/registered_college.dart';
import '../../../../routing/app_routes.dart';
import '../../auth/providers/auth_provider.dart';
import '../../tenant/providers/tenant_provider.dart';
import 'platform_college_registry_provider.dart';
import 'widgets/live_theme_preview_card.dart';

class PlatformCollegeDetailScreen extends ConsumerWidget {
  const PlatformCollegeDetailScreen({super.key, required this.tenantId});

  final String tenantId;

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
      data: (list) {
        RegisteredCollege? college;
        try {
          college = list.firstWhere((c) => c.tenantId == tenantId);
        } catch (_) {
          college = null;
        }
        if (college == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('College not found in registry.'),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton(
                  onPressed: () => context.go(AppRoutes.webPlatformColleges),
                  child: const Text('Back to list'),
                ),
              ],
            ),
          );
        }

        final p = college.profile;
        final modulesOn = NcFeature.values
            .where(p.hasFeature)
            .toList(growable: false);
        final subFeatures = _moduleSubFeaturesFromIntake(p.intake);
        final mrr = estimatedMrrInrPer1kMauBand(p);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go(AppRoutes.webPlatformColleges),
                  ),
                  Expanded(
                    child: Text(
                      p.institutionName.isEmpty ? tenantId : p.institutionName,
                      style: AppTypography.headlineMedium,
                    ),
                  ),
                ],
              ),
              Text(
                tenantId,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      ref.read(tenantProvider.notifier).applyLocalProfile(p);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Active tenant switched (session). Web shell uses this profile until you reload or switch again.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Use as active tenant'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.push(AppRoutes.webPlatformAddCollege),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Add / duplicate flow'),
                  ),
                  if (isSuper)
                    OutlinedButton.icon(
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Remove from JSON store?'),
                            content: Text(
                              'Deletes tenant "$tenantId" from platform_college_registry.json. '
                              'This cannot be undone from the app.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Remove'),
                              ),
                            ],
                          ),
                        );
                        if (ok != true || !context.mounted) return;
                        await ref
                            .read(platformCollegeRegistryProvider.notifier)
                            .removeCollege(tenantId);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Removed $tenantId from registry JSON.',
                            ),
                          ),
                        );
                        context.go(AppRoutes.webPlatformColleges);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Remove from registry'),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Summary', style: AppTypography.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${college.users.length} users tracked · ${modulesOn.length} modules on · est. rate sum ${currency.format(mrr)} / 1k MAU band',
                style: AppTypography.bodyMedium,
              ),
              ..._collegeProfileBlocks(p.intake),
              const SizedBox(height: AppSpacing.lg),
              Text('Theme (live preview)', style: AppTypography.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              LiveThemePreviewCard(profile: p, height: 220),
              const SizedBox(height: AppSpacing.lg),
              Text('Enabled modules', style: AppTypography.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: modulesOn.map((f) {
                  final catalog = TenantPolicyLoader.moduleCatalogForFeature(f);
                  return Tooltip(
                    message: f.key,
                    child: Chip(
                      label: Text(
                        catalog.title,
                        style: const TextStyle(fontSize: 11),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }).toList(),
              ),
              if (subFeatures.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Configured sub-features',
                  style: AppTypography.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: subFeatures.entries.expand((entry) {
                    return entry.value.map(
                      (id) => Chip(
                        label: Text('${entry.key}: ${_titleFromKey(id)}'),
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Text('Users', style: AppTypography.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              if (college.users.isEmpty)
                Text(
                  'No users stored for this college. Add rows when you register staff in the registry (or wire an API later).',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                )
              else
                Card(
                  child: Column(
                    children: college.users.map((u) {
                      return ListTile(
                        dense: true,
                        title: Text(u.name),
                        subtitle: Text('${u.role} · ${u.email}'),
                        trailing: Text(
                          u.status,
                          style: AppTypography.labelSmall,
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Map<String, List<String>> _moduleSubFeaturesFromIntake(
    Map<String, dynamic>? intake,
  ) {
    final raw = intake?['module_sub_features'];
    if (raw is! Map) return {};
    final out = <String, List<String>>{};
    for (final entry in raw.entries) {
      final value = entry.value;
      if (value is! List) continue;
      out[entry.key.toString()] = value.map((e) => e.toString()).toList();
    }
    return out;
  }

  String _titleFromKey(String key) {
    return key
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}

/// Rows from [TenantProfile.intake] `college_profile` (same shape as Add college).
List<Widget> _collegeProfileBlocks(Map<String, dynamic>? intake) {
  final raw = intake?['college_profile'];
  if (raw is! Map) return <Widget>[];
  final map = Map<String, dynamic>.from(raw);
  final rows = <Widget>[];
  final sorted = map.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
  for (final e in sorted) {
    final display = e.value?.toString().trim() ?? '';
    if (display.isEmpty) continue;
    rows.add(
      Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 200,
              child: Text(
                e.key.replaceAll('_', ' '),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(child: Text(display, style: AppTypography.bodySmall)),
          ],
        ),
      ),
    );
  }
  if (rows.isEmpty) return <Widget>[];
  return [
    const SizedBox(height: AppSpacing.lg),
    Text('Campus dossier (JSON)', style: AppTypography.titleSmall),
    const SizedBox(height: AppSpacing.xs),
    Text(
      'From profile.intake.college_profile in platform_college_registry.json',
      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
    ),
    const SizedBox(height: AppSpacing.sm),
    Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        ),
      ),
    ),
  ];
}
