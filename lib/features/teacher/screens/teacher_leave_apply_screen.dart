import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_input.dart';
import '../../../core/widgets/shell_layout_scope.dart';

class TeacherLeaveApplyScreen extends ConsumerStatefulWidget {
  const TeacherLeaveApplyScreen({super.key});

  @override
  ConsumerState<TeacherLeaveApplyScreen> createState() =>
      _TeacherLeaveApplyScreenState();
}

class _TeacherLeaveApplyScreenState
    extends ConsumerState<TeacherLeaveApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  String _leaveType = 'Casual Leave';
  DateTime _fromDate = DateTime.now().add(const Duration(days: 1));
  DateTime _toDate = DateTime.now().add(const Duration(days: 1));
  final _reasonCtrl = TextEditingController();
  final _coverageCtrl = TextEditingController();
  String? _substituteTeacher;
  String? _attachedFileName;
  bool _isSubmitting = false;

  static const _leaveTypes = [
    'Casual Leave',
    'Sick Leave',
    'Earned Leave',
    'Half Day (AM)',
    'Half Day (PM)',
    'On-Duty',
  ];
  static const _substituteTeachers = [
    'Mr. Rajan Kumar',
    'Ms. Deepa Nair',
    'Mr. Anand Shetty',
    'Ms. Kavitha Rao',
  ];

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
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Leave application submitted for approval.'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _coverageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(title: const Text('Apply Leave')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leave balance
              NcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Leave Balance', style: AppTypography.titleSmall),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: const [
                        _BalanceBadge('CL', '6/12'),
                        _BalanceBadge('SL', '8/12'),
                        _BalanceBadge('EL', '15/30'),
                        _BalanceBadge('OD', 'Unlimited'),
                      ],
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
              if (_leaveType == 'On-Duty') ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'On-Duty leave does not deduct from your leave balance.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.teal,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),

              // Date range
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('From', style: AppTypography.labelLarge),
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
                        Text('To', style: AppTypography.labelLarge),
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
                maxLength: 400,
                validator: AppValidators.combine([
                  AppValidators.requiredField('Reason is required'),
                  AppValidators.minLength(10, 'At least 10 characters'),
                ]),
              ),
              const SizedBox(height: AppSpacing.md),

              // Substitute teacher
              Text(
                'Suggest Substitute Teacher (optional)',
                style: AppTypography.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              NcDropdown<String>(
                value: _substituteTeacher,
                hint: 'Select substitute teacher',
                items: _substituteTeachers
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _substituteTeacher = v),
              ),
              const SizedBox(height: AppSpacing.md),

              // Class coverage note
              Text(
                'Class Coverage Note (optional)',
                style: AppTypography.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              NcTextField(
                controller: _coverageCtrl,
                hintText:
                    'Instructions for substitute: Continue Chapter 7 of Maths...',
                maxLines: 3,
                maxLength: 300,
              ),
              const SizedBox(height: AppSpacing.md),

              // Attach doc
              Text(
                'Attach Supporting Document (optional)',
                style: AppTypography.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              if (_attachedFileName != null)
                Chip(
                  label: Text(_attachedFileName!),
                  onDeleted: () => setState(() => _attachedFileName = null),
                )
              else
                OutlinedButton.icon(
                  onPressed: () =>
                      setState(() => _attachedFileName = 'supporting_doc.pdf'),
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Attach Document'),
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

class _BalanceBadge extends StatelessWidget {
  const _BalanceBadge(this.type, this.value);
  final String type;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            type,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTypography.labelMedium.copyWith(color: AppColors.teal),
          ),
        ],
      ),
    );
  }
}
