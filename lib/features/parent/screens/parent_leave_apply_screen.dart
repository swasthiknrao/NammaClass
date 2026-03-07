import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_input.dart';
import '../../../routing/app_routes.dart';

class ParentLeaveApplyScreen extends ConsumerStatefulWidget {
  const ParentLeaveApplyScreen({super.key});

  @override
  ConsumerState<ParentLeaveApplyScreen> createState() =>
      _ParentLeaveApplyScreenState();
}

class _ParentLeaveApplyScreenState
    extends ConsumerState<ParentLeaveApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  String _leaveType = 'Casual Leave';
  DateTime _fromDate = DateTime.now().add(const Duration(days: 1));
  DateTime _toDate = DateTime.now().add(const Duration(days: 1));
  final _reasonCtrl = TextEditingController();
  String? _attachedFileName;
  bool _isSubmitting = false;

  static const _leaveTypes = ['Casual Leave', 'Sick Leave', 'Half Day'];

  int get _workingDays {
    int count = 0;
    for (
      var d = _fromDate;
      !d.isAfter(_toDate);
      d = d.add(const Duration(days: 1))
    ) {
      if (d.weekday != DateTime.sunday) count++;
    }
    return count;
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(
            ctx,
          ).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _fromDate = picked;
        if (_toDate.isBefore(_fromDate)) _toDate = _fromDate;
      } else {
        if (!picked.isBefore(_fromDate)) _toDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Leave Application'),
        content: Text(
          'Submit leave for Riya from ${AppFormatters.shortDate(_fromDate)} to ${AppFormatters.shortDate(_toDate)} ($_workingDays working days)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Leave application submitted successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
    context.go(AppRoutes.parentLeaveStatus);
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apply Leave')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leave Balance Card
              NcCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '8',
                            style: AppTypography.headlineLarge.copyWith(
                              color: AppColors.teal,
                            ),
                          ),
                          Text(
                            'CL Remaining',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppColors.divider),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '5',
                            style: AppTypography.headlineLarge.copyWith(
                              color: AppColors.teal,
                            ),
                          ),
                          Text(
                            'SL Remaining',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppColors.divider),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '12',
                            style: AppTypography.headlineLarge.copyWith(
                              color: AppColors.teal,
                            ),
                          ),
                          Text(
                            'Days Available',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Leave type
              Text('Leave Type', style: AppTypography.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              NcDropdown<String>(
                value: _leaveType,
                items: _leaveTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _leaveType = v!),
                validator: (v) => v == null ? 'Select leave type' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              // Date range
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('From Date', style: AppTypography.labelLarge),
                        const SizedBox(height: AppSpacing.xs),
                        InkWell(
                          onTap: () => _pickDate(isFrom: true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.divider),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.xs,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  AppFormatters.shortDate(_fromDate),
                                  style: AppTypography.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('To Date', style: AppTypography.labelLarge),
                        const SizedBox(height: AppSpacing.xs),
                        InkWell(
                          onTap: () => _pickDate(isFrom: false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.divider),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.xs,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  AppFormatters.shortDate(_toDate),
                                  style: AppTypography.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '$_workingDays working day${_workingDays == 1 ? '' : 's'}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.teal),
              ),
              const SizedBox(height: AppSpacing.md),

              // Reason
              Text('Reason', style: AppTypography.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              NcTextField(
                controller: _reasonCtrl,
                hintText: 'Reason for leave...',
                maxLines: 4,
                maxLength: 300,
                validator: AppValidators.combine([
                  AppValidators.requiredField('Reason is required'),
                  AppValidators.minLength(10, 'At least 10 characters'),
                ]),
              ),
              const SizedBox(height: AppSpacing.md),

              // Attach document
              Text(
                'Attach Document (optional)',
                style: AppTypography.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              if (_attachedFileName != null)
                Chip(
                  label: Text(_attachedFileName!),
                  onDeleted: () => setState(() => _attachedFileName = null),
                  deleteIconColor: AppColors.error,
                )
              else
                OutlinedButton.icon(
                  onPressed: () =>
                      setState(() => _attachedFileName = 'medical_cert.pdf'),
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Attach Medical Certificate (optional)'),
                ),
              const SizedBox(height: AppSpacing.xl),

              NcPrimaryButton(
                label: _isSubmitting
                    ? 'Submitting…'
                    : 'Submit Leave Application',
                onPressed: _isSubmitting ? null : _submit,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
