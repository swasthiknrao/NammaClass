import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';

class WebBulkPromotionScreen extends ConsumerStatefulWidget {
  const WebBulkPromotionScreen({super.key});

  @override
  ConsumerState<WebBulkPromotionScreen> createState() =>
      _WebBulkPromotionScreenState();
}

class _WebBulkPromotionScreenState
    extends ConsumerState<WebBulkPromotionScreen> {
  int _step = 0;
  bool _requireFeesClear = true;
  int _attendanceThreshold = 75;
  int _marksThreshold = 35;
  bool _isExecuting = false;
  double _progress = 0;

  final _promotionData = [
    _PromotionRow('Arjun Kumar', '8-A', 'Promote', true),
    _PromotionRow('Preethi Nair', '8-A', 'Promote', true),
    _PromotionRow('Kiran Rao', '8-A', 'Hold', false),
    _PromotionRow('Anjali Singh', '8-B', 'Promote', true),
    _PromotionRow('Ravi Shankar', '9-A', 'Promote', true),
    _PromotionRow('Tejas Patil', '9-B', 'Hold', false),
  ];

  Future<void> _execute() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠ Execute Promotion'),
        content: Text(
          'This will promote ${_promotionData.where((r) => r.action == 'Promote').length} students and hold back ${_promotionData.where((r) => r.action == 'Hold').length} students.\n\nThis action CANNOT be undone. Confirm?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Execute Promotion'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    setState(() => _isExecuting = true);
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      setState(() => _progress = i / 10);
    }
    if (!mounted) return;
    setState(() => _isExecuting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Promotion executed successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bulk Student Promotion', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.md),

          // Step indicator
          Row(
            children: [
              _StepIndicator(1, 'Configure Rules', _step >= 0),
              _StepLine(_step >= 1),
              _StepIndicator(2, 'Review & Adjust', _step >= 1),
              _StepLine(_step >= 2),
              _StepIndicator(3, 'Confirm & Execute', _step >= 2),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          if (_step == 0) ...[
            NcCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step 1 — Configure Promotion Rules',
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attendance Threshold (%)',
                              style: AppTypography.labelMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Slider(
                              value: _attendanceThreshold.toDouble(),
                              min: 50,
                              max: 100,
                              divisions: 10,
                              label: '$_attendanceThreshold%',
                              onChanged: (v) => setState(
                                () => _attendanceThreshold = v.round(),
                              ),
                            ),
                            Text(
                              'Students with <$_attendanceThreshold% attendance will be held back',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xl),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Minimum Marks (%)',
                              style: AppTypography.labelMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Slider(
                              value: _marksThreshold.toDouble(),
                              min: 20,
                              max: 60,
                              divisions: 8,
                              label: '$_marksThreshold%',
                              onChanged: (v) =>
                                  setState(() => _marksThreshold = v.round()),
                            ),
                            Text(
                              'Students scoring <$_marksThreshold% may be held back',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SwitchListTile(
                    value: _requireFeesClear,
                    onChanged: (v) => setState(() => _requireFeesClear = v),
                    title: const Text('Require Fee Clearance'),
                    subtitle: const Text(
                      'Students with outstanding fees cannot be promoted',
                    ),
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () => setState(() => _step = 1),
                      child: const Text('Next: Review Students →'),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_step == 1) ...[
            NcCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step 2 — Review & Adjust',
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'AI recommendations shown. Override individually if needed.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Table header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    color: AppColors.background,
                    child: Row(
                      children: const [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Student',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Class',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'AI Recommendation',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Override',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ..._promotionData.map(
                    (row) => Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.divider),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              row.name,
                              style: AppTypography.bodyMedium,
                            ),
                          ),
                          Expanded(flex: 2, child: Text(row.currentClass)),
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (row.aiRecommend
                                            ? AppColors.success
                                            : AppColors.warning)
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                row.action,
                                style: TextStyle(
                                  color: row.aiRecommend
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: SegmentedButton<String>(
                              selected: {row.action},
                              onSelectionChanged: (v) =>
                                  setState(() => row.action = v.first),
                              segments: const [
                                ButtonSegment(
                                  value: 'Promote',
                                  label: Text(
                                    'Promote',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ),
                                ButtonSegment(
                                  value: 'Hold',
                                  label: Text(
                                    'Hold',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ),
                              ],
                              style: ButtonStyle(
                                visualDensity: VisualDensity.compact,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => setState(() => _step = 0),
                        child: const Text('← Back'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      FilledButton(
                        onPressed: () => setState(() => _step = 2),
                        child: const Text('Next: Confirm →'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            NcCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step 3 — Confirm & Execute',
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_promotionData.where((r) => r.action == 'Promote').length} students will be promoted',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                        Text(
                          '${_promotionData.where((r) => r.action == 'Hold').length} students will be held back',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '⚠ This action is irreversible. Please verify before executing.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isExecuting) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Processing... ${(_progress * 100).round()}%',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    LinearProgressIndicator(
                      value: _progress,
                      color: AppColors.teal,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: _isExecuting
                            ? null
                            : () => setState(() => _step = 1),
                        child: const Text('← Back'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      FilledButton(
                        onPressed: _isExecuting ? null : _execute,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                        ),
                        child: const Text('Execute Promotion'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator(this.number, this.label, this.active);
  final int number;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.divider,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: TextStyle(
              color: active ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: active ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine(this.active);
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: active ? AppColors.primary : AppColors.divider,
      ),
    );
  }
}

class _PromotionRow {
  _PromotionRow(this.name, this.currentClass, this.action, this.aiRecommend);
  final String name;
  final String currentClass;
  String action;
  final bool aiRecommend;
}
