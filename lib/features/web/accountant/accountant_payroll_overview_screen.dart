import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../admin/providers/admin_providers.dart';
import 'accountant_finance_providers.dart';

/// Accountant-facing payroll hub: staff roster + payslip status (read-heavy demo).
class AccountantPayrollOverviewScreen extends ConsumerWidget {
  const AccountantPayrollOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final period = ref.watch(accountantFinancePeriodProvider);
    final staffAsync = ref.watch(adminStaffProvider);
    final liability = ref.watch(payrollLiabilityForPeriodProvider(period));
    final pf = _intDyn(MockData.financeSnapshot['pf_employer_month_paise']);
    final esi = _intDyn(MockData.financeSnapshot['esi_employer_month_paise']);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.accountantPayrollScreenTitle,
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.accountantPayrollScreenSubtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _ChipMetric(
                l10n.accountantPayrollLiability,
                AppFormatters.formatPaiseCompact(liability),
              ),
              _ChipMetric(
                l10n.accountantPfEmployerChip,
                AppFormatters.formatPaiseCompact(pf),
              ),
              _ChipMetric(
                l10n.accountantEsiEmployerChip,
                AppFormatters.formatPaiseCompact(esi),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                period,
                style: AppTypography.titleSmall.copyWith(
                  fontFamily: 'JetBrainsMono',
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => _exportPayrollBankFile(context, period, l10n),
                icon: const Icon(Icons.file_download, size: 18),
                label: Text(l10n.accountantExportBankFile),
              ),
              const SizedBox(width: AppSpacing.sm),
              NcPrimaryButton(
                label: 'Process payroll',
                icon: Icons.payment,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.accountantProcessPayrollSnack)),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: staffAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator.adaptive()),
              error: (e, _) => Center(child: Text('$e')),
              data: (staff) {
                return NcCard(
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
                          children: const [
                            _H('Name', flex: 3),
                            _H('Role', flex: 2),
                            _H('Basic', flex: 2),
                            _H('Allow.', flex: 2),
                            _H('Ded.', flex: 2),
                            _H('Net', flex: 2),
                            _H('Status', flex: 2),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          itemCount: staff.length,
                          separatorBuilder: (_, i) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final s = staff[i];
                            MockPayslip? slip;
                            for (final p in MockData.payslips) {
                              if (p.month == period && p.employeeId == s.id) {
                                slip = p;
                                break;
                              }
                            }
                            final basic = (s.salaryCTC * 0.6).round();
                            final allowances = (s.salaryCTC * 0.25).round();
                            final deductions = (s.salaryCTC * 0.12).round();
                            final fallbackNetPaise =
                                (basic + allowances - deductions) * 100;
                            final netPaise = slip?.netPaise ?? fallbackNetPaise;
                            final status = slip?.status ?? '—';
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
                                      AppFormatters.formatPaise(
                                        allowances * 100,
                                      ),
                                      style: AppTypography.bodySmall,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      AppFormatters.formatPaise(
                                        deductions * 100,
                                      ),
                                      style: AppTypography.bodySmall,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      AppFormatters.formatPaise(netPaise),
                                      style: AppTypography.labelMedium,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      status,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: status.toLowerCase() == 'pending'
                                            ? AppColors.warning
                                            : AppColors.textSecondary,
                                      ),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _exportPayrollBankFile(
  BuildContext context,
  String period,
  AppLocalizations l10n,
) async {
  final buf = StringBuffer('employee_id,net_paise,month\n');
  for (final p in MockData.payslips) {
    if (p.month != period) continue;
    buf.writeln('${p.employeeId ?? p.id},${p.netPaise},$period');
  }
  await Clipboard.setData(ClipboardData(text: buf.toString()));
  if (!context.mounted) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(l10n.accountantBankFileSnack)));
}

int _intDyn(dynamic v, [int d = 0]) {
  if (v == null) return d;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('$v') ?? d;
}

class _H extends StatelessWidget {
  const _H(this.t, {this.flex = 1});
  final String t;
  final int flex;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        t,
        style: AppTypography.labelSmall.copyWith(color: Colors.white),
      ),
    );
  }
}

class _ChipMetric extends StatelessWidget {
  const _ChipMetric(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(Icons.savings_outlined, size: 18, color: AppColors.primary),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTypography.labelSmall),
          Text(value, style: AppTypography.titleSmall),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
    );
  }
}
