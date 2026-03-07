import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';

class WebEnquiriesScreen extends ConsumerStatefulWidget {
  const WebEnquiriesScreen({super.key});

  @override
  ConsumerState<WebEnquiriesScreen> createState() => _WebEnquiriesScreenState();
}

class _WebEnquiriesScreenState extends ConsumerState<WebEnquiriesScreen> {
  String _search = '';
  bool _showDrawer = false;
  final _formKey = GlobalKey<FormState>();
  final _studentNameCtrl = TextEditingController();
  final _parentNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _classApplying = 'Class 6';
  String _source = 'Walk-in';

  @override
  void dispose() {
    _studentNameCtrl.dispose();
    _parentNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  List<MockAdmissionEnquiry> get _filtered {
    if (_search.length < 2) return MockData.admissionEnquiries;
    final q = _search.toLowerCase();
    return MockData.admissionEnquiries
        .where(
          (e) =>
              e.studentName.toLowerCase().contains(q) ||
              e.phone.contains(q) ||
              e.parentName.toLowerCase().contains(q),
        )
        .toList();
  }

  Color _scoreColor(int score) {
    if (score > 70) return AppColors.success;
    if (score > 40) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admission Enquiries',
                  style: AppTypography.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.md),

                // Toolbar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search by name, phone, email…',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (v) => setState(() => _search = v),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    FilledButton.icon(
                      onPressed: () => setState(() => _showDrawer = true),
                      icon: const Icon(Icons.person_add),
                      label: const Text('New Enquiry'),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Import Excel'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Table
                NcCard(
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
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
                                'Parent / Phone',
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
                              flex: 2,
                              child: Text(
                                'Source',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'AI Score',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Status',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Actions',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      ..._filtered.map((e) {
                        final scoreColor = _scoreColor(e.aiLeadScore);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.studentName,
                                      style: AppTypography.labelMedium,
                                    ),
                                    Text(
                                      AppFormatters.shortDate(e.enquiryDate),
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.parentName,
                                      style: AppTypography.bodySmall,
                                    ),
                                    Text(
                                      e.phone,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(flex: 2, child: Text(e.classApplying)),
                              Expanded(
                                flex: 2,
                                child: NcChip(
                                  label: e.source,
                                  color: AppColors.primary,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Tooltip(
                                  message:
                                      'Based on profile match and engagement',
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: scoreColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${e.aiLeadScore}',
                                      style: TextStyle(
                                        color: scoreColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: NcChip(
                                  label: e.status,
                                  color: AppColors.teal,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.arrow_forward,
                                        size: 18,
                                      ),
                                      tooltip: 'Convert to Application',
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 18),
                                      tooltip: 'Edit',
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.phone,
                                        size: 18,
                                        color: AppColors.teal,
                                      ),
                                      tooltip: 'Call',
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Add enquiry drawer
        if (_showDrawer)
          Container(
            width: 400,
            decoration: const BoxDecoration(
              color: AppColors.card,
              border: Border(left: BorderSide(color: AppColors.divider)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('New Enquiry', style: AppTypography.headlineSmall),
                        IconButton(
                          onPressed: () => setState(() => _showDrawer = false),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _studentNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Student Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: AppValidators.requiredField('Required'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _parentNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Parent Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: AppValidators.requiredField('Required'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                      ),
                      validator: AppValidators.phone,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      value: _classApplying,
                      decoration: const InputDecoration(
                        labelText: 'Class Applying',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          [
                                'Class 1',
                                'Class 2',
                                'Class 3',
                                'Class 6',
                                'Class 9',
                                'Class 11',
                              ]
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => _classApplying = v!),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      value: _source,
                      decoration: const InputDecoration(
                        labelText: 'Source',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Walk-in', 'Online', 'Referral', 'Camp']
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _source = v!),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _showDrawer = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Enquiry added!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        },
                        child: const Text('Save Enquiry'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
