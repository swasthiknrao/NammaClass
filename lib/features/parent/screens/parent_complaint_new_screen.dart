import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_input.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../routing/app_routes.dart';

class ParentComplaintNewScreen extends ConsumerStatefulWidget {
  const ParentComplaintNewScreen({super.key});

  @override
  ConsumerState<ParentComplaintNewScreen> createState() =>
      _ParentComplaintNewScreenState();
}

class _ParentComplaintNewScreenState
    extends ConsumerState<ParentComplaintNewScreen> {
  final _formKey = GlobalKey<FormState>();
  String _category = 'Transport';
  String _priority = 'Medium';
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isAnonymous = false;
  final List<String> _attachments = [];
  bool _isSubmitting = false;

  static const _categories = [
    'Academics',
    'Staff Behaviour',
    'Transport',
    'Infrastructure',
    'Canteen',
    'Fee Issue',
    'Safety',
    'Other',
  ];

  static const _priorities = ['Low', 'Medium', 'High', 'Urgent'];

  Color _priorityColor(String p) {
    switch (p) {
      case 'Low':
        return AppColors.textSecondary;
      case 'High':
        return AppColors.accent;
      case 'Urgent':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Complaint'),
        content: Text(
          'Submit ${_priority.toLowerCase()} priority complaint about $_category?',
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
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Complaint Submitted!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Ticket ID: #NC-2026-0043',
              style: AppTypography.headlineSmall.copyWith(
                fontFamily: 'JetBrainsMono',
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'We will respond within 3 working days.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Back to Home'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (context.mounted) context.go(AppRoutes.parentComplaints);
            },
            child: const Text('Track Complaint'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(title: const Text('Raise Complaint')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category
              Text('Complaint Type', style: AppTypography.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              NcDropdown<String>(
                value: _category,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
                validator: (v) => v == null ? 'Select category' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              // Subject
              Text('Subject', style: AppTypography.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              NcTextField(
                controller: _subjectCtrl,
                hintText: 'Short title for the complaint',
                maxLength: 100,
                validator: AppValidators.combine([
                  AppValidators.requiredField('Subject is required'),
                  AppValidators.minLength(5, 'At least 5 characters'),
                ]),
              ),
              const SizedBox(height: AppSpacing.md),

              // Description
              Text('Description', style: AppTypography.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              NcTextField(
                controller: _descCtrl,
                hintText: 'Detailed description of the issue...',
                maxLines: 5,
                maxLength: 1000,
                validator: AppValidators.combine([
                  AppValidators.requiredField('Description is required'),
                  AppValidators.minLength(20, 'At least 20 characters'),
                ]),
              ),
              const SizedBox(height: AppSpacing.md),

              // Priority
              Text('Priority', style: AppTypography.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                children: _priorities.map((p) {
                  final selected = _priority == p;
                  return ChoiceChip(
                    label: Text(p),
                    selected: selected,
                    onSelected: (_) => setState(() => _priority = p),
                    selectedColor: _priorityColor(p).withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: selected
                          ? _priorityColor(p)
                          : AppColors.textSecondary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    side: BorderSide(
                      color: selected ? _priorityColor(p) : AppColors.divider,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),

              // Attach evidence
              Text(
                'Attach Evidence (optional)',
                style: AppTypography.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                children: [
                  ..._attachments.map(
                    (f) => Chip(
                      label: Text(f),
                      onDeleted: () => setState(() => _attachments.remove(f)),
                      deleteIconColor: AppColors.error,
                    ),
                  ),
                  if (_attachments.length < 3)
                    ActionChip(
                      avatar: const Icon(Icons.attach_file, size: 16),
                      label: const Text('Add File'),
                      onPressed: () => setState(
                        () => _attachments.add(
                          'evidence_${_attachments.length + 1}.jpg',
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Anonymous toggle
              SwitchListTile.adaptive(
                value: _isAnonymous,
                onChanged: (v) => setState(() => _isAnonymous = v),
                title: const Text('Submit Anonymously'),
                subtitle: Text(
                  'Anonymous complaints may take longer to resolve.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: AppSpacing.xl),

              NcPrimaryButton(
                label: _isSubmitting ? 'Submitting…' : 'Submit Complaint',
                onPressed: _isSubmitting ? null : _submit,
                isFullWidth: true,
                color: AppColors.deepPurple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
