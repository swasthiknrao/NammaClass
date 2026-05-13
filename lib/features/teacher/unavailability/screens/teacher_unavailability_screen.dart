import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_input.dart';
import '../../../../core/widgets/shell_layout_scope.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../admin/timetable/providers/timetable_notifier.dart';
import '../providers/unavailability_notifier.dart';

class TeacherUnavailabilityScreen extends ConsumerStatefulWidget {
  const TeacherUnavailabilityScreen({super.key});

  @override
  ConsumerState<TeacherUnavailabilityScreen> createState() =>
      _TeacherUnavailabilityScreenState();
}

class _TeacherUnavailabilityScreenState
    extends ConsumerState<TeacherUnavailabilityScreen> {
  DateTime _date = DateTime.now();
  final _reason = TextEditingController();
  final Set<String> _periods = {};
  bool _sending = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    if (_periods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one period')),
      );
      return;
    }
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 150));
    ref
        .read(unavailabilityNotifierProvider.notifier)
        .submit(
          staffId: user.id,
          staffName: user.name,
          date: _date,
          periodLabels: _periods.toList()..sort(),
          reason: _reason.text,
        );
    setState(() {
      _sending = false;
      _periods.clear();
      _reason.clear();
    });
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Request submitted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final periodDefs = ref.watch(timetableNotifierProvider).periods;
    final mine = ref
        .watch(unavailabilityNotifierProvider)
        .where((e) => e.staffId == (user?.id ?? ''));

    final periodChips = periodDefs
        .map((p) => '${p.label} (${p.startLabel}–${p.endLabel})')
        .toList();

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(title: const Text('Mark unavailable')),
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Notify admin when you cannot take scheduled periods.',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            NcCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date', style: AppTypography.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(
                      '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Periods', style: AppTypography.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: periodChips.map((label) {
                      final sel = _periods.contains(label);
                      return FilterChip(
                        label: Text(label, style: AppTypography.labelSmall),
                        selected: sel,
                        onSelected: (v) {
                          setState(() {
                            if (v) {
                              _periods.add(label);
                            } else {
                              _periods.remove(label);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  NcTextField(
                    controller: _reason,
                    label: 'Reason',
                    maxLines: 3,
                    minLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  NcPrimaryButton(
                    label: 'Submit request',
                    loading: _sending,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('My requests', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            if (mine.isEmpty)
              Text('No requests yet.', style: AppTypography.bodySmall)
            else
              ...mine.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: NcCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${r.date.year}-${r.date.month.toString().padLeft(2, '0')}-${r.date.day.toString().padLeft(2, '0')}',
                          style: AppTypography.titleSmall,
                        ),
                        Text(
                          r.periodLabels.join(', '),
                          style: AppTypography.bodySmall,
                        ),
                        Text(r.reason, style: AppTypography.bodyMedium),
                        const SizedBox(height: 4),
                        Text(r.status.name, style: AppTypography.labelSmall),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
