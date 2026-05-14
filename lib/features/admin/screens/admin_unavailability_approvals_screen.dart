import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/demo_permissions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/shell_layout_scope.dart';
import '../../../../domain/entities/unavailability_request_entry.dart';
import '../../auth/providers/auth_provider.dart';
import '../../teacher/unavailability/providers/unavailability_notifier.dart';

class AdminUnavailabilityApprovalsScreen extends ConsumerWidget {
  const AdminUnavailabilityApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canAct = ref
        .watch(demoPermissionsProvider)
        .contains(DemoPermission.coverApprove);
    final list = ref.watch(unavailabilityNotifierProvider);
    final pending = list
        .where((e) => e.status == UnavailabilityStatus.pending)
        .toList();

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(title: const Text('Cover requests')),
      backgroundColor: Colors.transparent,
      body: pending.isEmpty
          ? const Center(child: Text('No pending requests'))
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: pending.length,
              itemBuilder: (ctx, i) {
                final r = pending[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: NcCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.staffName, style: AppTypography.titleSmall),
                        Text(
                          '${r.date.year}-${r.date.month.toString().padLeft(2, '0')}-${r.date.day.toString().padLeft(2, '0')}',
                          style: AppTypography.bodySmall,
                        ),
                        Text(
                          r.periodLabels.join(', '),
                          style: AppTypography.labelMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(r.reason, style: AppTypography.bodyMedium),
                        const SizedBox(height: AppSpacing.md),
                        if (canAct)
                          Row(
                            children: [
                              Expanded(
                                child: NcSecondaryButton(
                                  label: 'Reject',
                                  onPressed: () {
                                    ref
                                        .read(
                                          unavailabilityNotifierProvider
                                              .notifier,
                                        )
                                        .setStatus(
                                          r.id,
                                          UnavailabilityStatus.rejected,
                                        );
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: NcPrimaryButton(
                                  label: 'Approve',
                                  onPressed: () {
                                    ref
                                        .read(
                                          unavailabilityNotifierProvider
                                              .notifier,
                                        )
                                        .setStatus(
                                          r.id,
                                          UnavailabilityStatus.approved,
                                        );
                                  },
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            'Demo account lacks the cover:approve claim — '
                            'no actions shown.',
                            style: AppTypography.bodySmall.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
