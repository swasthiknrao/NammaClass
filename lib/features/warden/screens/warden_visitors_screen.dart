import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/shell_layout_scope.dart';

class WardenVisitorsScreen extends StatefulWidget {
  const WardenVisitorsScreen({super.key});

  @override
  State<WardenVisitorsScreen> createState() => _WardenVisitorsScreenState();
}

class _WardenVisitorsScreenState extends State<WardenVisitorsScreen> {
  final List<MockVisitor> _visitors = MockData.visitors;

  Duration _visitDuration(MockVisitor v) {
    final end = v.checkOutTime ?? DateTime.now();
    return end.difference(v.checkInTime);
  }

  List<MockVisitor> get _active =>
      _visitors.where((v) => v.checkOutTime == null).toList();
  List<MockVisitor> get _history =>
      _visitors.where((v) => v.checkOutTime != null).toList();

  void _checkout(MockVisitor v) {
    setState(() => v.checkOutTime = DateTime.now());
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${v.visitorName} checked out.')));
  }

  void _showLogForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _LogVisitorSheet(
        onSubmit: (name, rel, phone, student, idType) {
          setState(() {
            _visitors.insert(
              0,
              MockVisitor(
                id: 'vis_${DateTime.now().millisecondsSinceEpoch}',
                visitorName: name,
                relationship: rel,
                phone: phone,
                studentName: student,
                idType: idType,
                checkInTime: DateTime.now(),
              ),
            );
          });
          Navigator.pop(ctx);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$name logged in.')));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(title: const Text('Visitor Log')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLogForm,
        icon: const Icon(Icons.person_add),
        label: const Text('Log Visitor'),
        backgroundColor: AppColors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active visitors
            NcCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people, color: AppColors.accent),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Currently Inside: ${_active.length} visitors',
                        style: AppTypography.titleSmall,
                      ),
                    ],
                  ),
                  if (_active.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: AppSpacing.sm),
                      child: Text('No visitors inside.'),
                    )
                  else
                    ..._active.map((v) {
                      final duration = _visitDuration(v);
                      final isOverstay = duration.inHours >= 3;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          if (isOverstay)
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber,
                                    color: AppColors.warning,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${v.visitorName} has been inside for ${duration.inHours}h ${duration.inMinutes % 60}m. Please verify.',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              v.visitorName,
                              style: AppTypography.labelMedium,
                            ),
                            subtitle: Text(
                              '${v.relationship} | Visiting: ${v.studentName} | In: ${AppFormatters.time(v.checkInTime)}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            trailing: FilledButton(
                              onPressed: () => _checkout(v),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.error,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Check Out',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // History
            Text("Today's Visitor History", style: AppTypography.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            if (_history.isEmpty)
              const Center(child: Text('No completed visits today.'))
            else
              ..._history.map((v) {
                final duration = _visitDuration(v);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(Icons.person, color: AppColors.textSecondary),
                  ),
                  title: Text(v.visitorName, style: AppTypography.labelMedium),
                  subtitle: Text(
                    '${v.studentName} | ${AppFormatters.time(v.checkInTime)} — ${AppFormatters.time(v.checkOutTime!)} | ${duration.inHours}h ${duration.inMinutes % 60}m',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      v.idType,
                      style: AppTypography.bodySmall.copyWith(fontSize: 10),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _LogVisitorSheet extends StatefulWidget {
  const _LogVisitorSheet({required this.onSubmit});
  final void Function(
    String name,
    String rel,
    String phone,
    String student,
    String idType,
  )
  onSubmit;

  @override
  State<_LogVisitorSheet> createState() => _LogVisitorSheetState();
}

class _LogVisitorSheetState extends State<_LogVisitorSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _relationship = 'Parent';
  String _student = 'Ravi Shankar';
  String _idType = 'Aadhaar';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        top: AppSpacing.lg,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Log Visitor', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Visitor Name',
                border: OutlineInputBorder(),
              ),
              validator: AppValidators.requiredField('Required'),
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              value: _relationship,
              decoration: const InputDecoration(
                labelText: 'Relationship',
                border: OutlineInputBorder(),
              ),
              items: [
                'Parent',
                'Guardian',
                'Sibling',
                'Relative',
                'Friend',
                'Other',
              ].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => setState(() => _relationship = v!),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              validator: AppValidators.phone,
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              value: _student,
              decoration: const InputDecoration(
                labelText: 'Visiting Student',
                border: OutlineInputBorder(),
              ),
              items: [
                'Ravi Shankar',
                'Ajay Reddy',
                'Mohan Das',
                'Sunil Kumar',
              ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _student = v!),
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              value: _idType,
              decoration: const InputDecoration(
                labelText: 'ID Type',
                border: OutlineInputBorder(),
              ),
              items: ['Aadhaar', 'Driving Licence', 'Passport', 'Other']
                  .map((id) => DropdownMenuItem(value: id, child: Text(id)))
                  .toList(),
              onChanged: (v) => setState(() => _idType = v!),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onSubmit(
                      _nameCtrl.text.trim(),
                      _relationship,
                      _phoneCtrl.text.trim(),
                      _student,
                      _idType,
                    );
                  }
                },
                child: const Text('Log Check-In'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
