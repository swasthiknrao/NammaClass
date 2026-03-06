import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_card.dart';

class WebFeeStructureScreen extends StatelessWidget {
  const WebFeeStructureScreen({super.key});

  static final _feeHeads = [
    {'name': 'Tuition Fee', 'amount': 1500000, 'type': 'Termly'},
    {'name': 'Lab Fee', 'amount': 150000, 'type': 'Annual'},
    {'name': 'Library Fee', 'amount': 100000, 'type': 'Annual'},
    {'name': 'Sports Fee', 'amount': 200000, 'type': 'Annual'},
    {'name': 'Transport Fee', 'amount': 500000, 'type': 'Monthly'},
    {'name': 'Hostel Fee', 'amount': 1200000, 'type': 'Monthly'},
    {'name': 'Canteen Fee', 'amount': 50000, 'type': 'Monthly'},
    {'name': 'Exam Fee', 'amount': 100000, 'type': 'Annual'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DropdownButton<String>(
                value: '2025-26',
                items: ['2025-26', '2024-25']
                    .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                    .toList(),
                onChanged: (_) {},
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.preview, size: 16),
                label: const Text('Preview Demand Slip'),
              ),
              const SizedBox(width: AppSpacing.xs),
              NcPrimaryButton(
                label: 'Save Structure',
                icon: Icons.save,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: NcCard(
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
                        _HeaderCell('Fee Head', flex: 3),
                        _HeaderCell('Amount (₹)', flex: 2),
                        _HeaderCell('Frequency', flex: 2),
                        _HeaderCell('Due Date', flex: 2),
                        _HeaderCell('Actions', flex: 1),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _feeHeads.length,
                      separatorBuilder: (_, i) => const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        final f = _feeHeads[i];
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
                                  f['name'] as String,
                                  style: AppTypography.labelMedium,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  AppFormatters.formatPaise(f['amount'] as int),
                                  style: AppTypography.bodyMedium,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  f['type'] as String,
                                  style: AppTypography.bodyMedium,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '10th of month',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 16),
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        size: 16,
                                        color: AppColors.error,
                                      ),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: NcSecondaryButton(
                      label: '+ Add Fee Head',
                      icon: Icons.add,
                      onPressed: () {},
                    ),
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

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label, {this.flex = 1});
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
