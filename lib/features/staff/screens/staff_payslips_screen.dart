import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../providers/staff_providers.dart';

class StaffPayslipsScreen extends ConsumerStatefulWidget {
  const StaffPayslipsScreen({super.key});

  @override
  ConsumerState<StaffPayslipsScreen> createState() =>
      _StaffPayslipsScreenState();
}

class _StaffPayslipsScreenState extends ConsumerState<StaffPayslipsScreen> {
  String _selectedYear = '2026';

  @override
  Widget build(BuildContext context) {
    final payslipsAsync = ref.watch(staffPayslipsProvider);
    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(
              title: const Text('Payslips'),
              actions: [
                DropdownButton<String>(
                  value: _selectedYear,
                  underline: const SizedBox(),
                  items: ['2026', '2025', '2024', '2023']
                      .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedYear = v!),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ),
      body: payslipsAsync.when(
        loading: () => const NcShimmerList(itemCount: 6),
        error: (e, _) => const Center(child: Text('Error loading payslips')),
        data: (payslips) => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: payslips.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (ctx, i) => _PayslipCard(
            payslip: payslips[i],
            onTap: () => _showDetail(ctx, payslips[i]),
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, MockPayslip payslip) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _PayslipDetailScreen(payslip: payslip)),
    );
  }
}

class _PayslipCard extends StatelessWidget {
  const _PayslipCard({required this.payslip, required this.onTap});
  final MockPayslip payslip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: NcCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(payslip.month, style: AppTypography.titleSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Text(
                        'Gross: ',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        AppFormatters.currency(payslip.grossPaise),
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.accent,
                          fontFamily: 'JetBrainsMono',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Net: ',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        AppFormatters.currency(payslip.netPaise),
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.success,
                          fontFamily: 'JetBrainsMono',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                NcStatusChip(
                  label: payslip.status,
                  color: payslip.status == 'Generated'
                      ? AppColors.success
                      : AppColors.warning,
                ),
                const SizedBox(height: AppSpacing.xs),
                if (payslip.status == 'Generated')
                  IconButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Downloading payslip PDF...'),
                      ),
                    ),
                    icon: const Icon(
                      Icons.file_download_outlined,
                      color: AppColors.primary,
                    ),
                    tooltip: 'Download PDF',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PayslipDetailScreen extends StatelessWidget {
  const _PayslipDetailScreen({required this.payslip});
  final MockPayslip payslip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(
              title: Text(payslip.month),
              actions: [
                IconButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloading PDF...')),
                  ),
                  icon: const Icon(Icons.file_download_outlined),
                  tooltip: 'Download PDF',
                ),
              ],
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Earnings', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            NcCard(
              child: Column(
                children: [
                  _PayRow('Basic Salary', payslip.basicPaise, isTotal: false),
                  _PayRow('HRA', payslip.hraPaise, isTotal: false),
                  _PayRow('DA', payslip.daPaise, isTotal: false),
                  _PayRow(
                    'Allowances',
                    payslip.allowancesPaise,
                    isTotal: false,
                  ),
                  const Divider(),
                  _PayRow(
                    'Gross Earnings',
                    payslip.grossPaise,
                    isTotal: true,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Deductions', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            NcCard(
              child: Column(
                children: [
                  _PayRow('PF', payslip.pfDeductionPaise, isTotal: false),
                  _PayRow('ESI', payslip.esiDeductionPaise, isTotal: false),
                  _PayRow('TDS', payslip.tdsDeductionPaise, isTotal: false),
                  const Divider(),
                  _PayRow(
                    'Total Deductions',
                    payslip.totalDeductionsPaise,
                    isTotal: true,
                    color: AppColors.error,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Net Pay',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    AppFormatters.currency(payslip.netPaise),
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.success,
                      fontFamily: 'JetBrainsMono',
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

class _PayRow extends StatelessWidget {
  const _PayRow(
    this.label,
    this.amountPaise, {
    required this.isTotal,
    this.color,
  });
  final String label;
  final int amountPaise;
  final bool isTotal;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTypography.labelMedium
                : AppTypography.bodyMedium,
          ),
          Text(
            AppFormatters.currency(amountPaise),
            style:
                (isTotal ? AppTypography.labelMedium : AppTypography.bodyMedium)
                    .copyWith(fontFamily: 'JetBrainsMono', color: color),
          ),
        ],
      ),
    );
  }
}
