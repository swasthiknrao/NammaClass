import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../features/admin/providers/admin_providers.dart';

class WebPayrollScreen extends ConsumerWidget {
  const WebPayrollScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(adminStaffProvider);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DropdownButton<String>(
                value: 'March 2026',
                items: ['March 2026', 'February 2026', 'January 2026']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (_) {},
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.file_download, size: 16),
                label: const Text('Export Bank File'),
              ),
              const SizedBox(width: AppSpacing.xs),
              NcPrimaryButton(
                label: 'Process Payroll',
                icon: Icons.payment,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: staffAsync.when(
              loading: () => const CircularProgressIndicator.adaptive(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (staff) => NcCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Container(
                      color: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          _H('Name', flex: 3),
                          _H('Role', flex: 2),
                          _H('Basic (CTC)', flex: 2),
                          _H('Allowances', flex: 2),
                          _H('Deductions', flex: 2),
                          _H('Net Pay', flex: 2),
                          _H('Status', flex: 1),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: staff.length,
                        separatorBuilder: (_, i) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final s = staff[i];
                          final basic = (s.salaryCTC * 0.6).round();
                          final allowances = (s.salaryCTC * 0.25).round();
                          final deductions = (s.salaryCTC * 0.12).round();
                          final net = basic + allowances - deductions;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    s.name,
                                    style: AppTypography.labelMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    s.role,
                                    style: AppTypography.bodySmall,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    AppFormatters.formatPaise(basic * 100),
                                    style: AppTypography.bodySmall,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    AppFormatters.formatPaise(allowances * 100),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.success,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    AppFormatters.formatPaise(deductions * 100),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    AppFormatters.formatPaise(net * 100),
                                    style: AppTypography.labelMedium.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Icon(
                                    Icons.check_circle,
                                    color: AppColors.success,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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

class _H extends StatelessWidget {
  const _H(this.label, {this.flex = 1});
  final String label;
  final int flex;
  @override
  Widget build(BuildContext context) => Expanded(
    flex: flex,
    child: Text(
      label,
      style: AppTypography.labelMedium.copyWith(color: Colors.white),
    ),
  );
}
