import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/providers/data_sync_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../providers/admin_providers.dart';

/// Principal-only: view learners and **edit guardian contact** fields (not full SIS).
class PrincipalStudentContactsScreen extends ConsumerStatefulWidget {
  const PrincipalStudentContactsScreen({super.key});

  @override
  ConsumerState<PrincipalStudentContactsScreen> createState() =>
      _PrincipalStudentContactsScreenState();
}

class _PrincipalStudentContactsScreenState
    extends ConsumerState<PrincipalStudentContactsScreen> {
  final Map<String, TextEditingController> _phoneCtrls = {};
  final Map<String, TextEditingController> _parentCtrls = {};
  final Set<String> _dirty = {};

  @override
  void dispose() {
    for (final c in _phoneCtrls.values) {
      c.dispose();
    }
    for (final c in _parentCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _phoneFor(MockStudent s) {
    return _phoneCtrls.putIfAbsent(
      s.id,
      () => TextEditingController(text: s.parentPhone ?? ''),
    );
  }

  TextEditingController _parentFor(MockStudent s) {
    return _parentCtrls.putIfAbsent(
      s.id,
      () => TextEditingController(text: s.parentName ?? ''),
    );
  }

  void _save(MockStudent original) {
    final phone = _phoneFor(original).text.trim();
    final parent = _parentFor(original).text.trim();
    final updated = original.copyWith(
      parentPhone: phone.isEmpty ? null : phone,
      parentName: parent.isEmpty ? null : parent,
    );
    MockData.upsertStudent(updated);
    ref.read(dataSyncProvider.notifier).bump();
    setState(() => _dirty.remove(original.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updated contacts for ${original.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(adminStudentsProvider);

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(title: const Text('Student & guardian contacts')),
      backgroundColor: Colors.transparent,
      body: studentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (students) {
          final sorted = [...students]
            ..sort((a, b) => a.classSection.compareTo(b.classSection));
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              NcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Principal authority',
                      style: AppTypography.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'You can adjust guardian names and phone numbers for outreach '
                      '(fee reminders, safety, PTM). Academic records and roster HR '
                      'stay with the school admin team.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...sorted.map((s) {
                final phoneCtrl = _phoneFor(s);
                final parentCtrl = _parentFor(s);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: NcCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                s.name,
                                style: AppTypography.titleSmall,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                s.classSection,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Roll ${s.rollNo}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: parentCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Guardian name',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (_) => setState(() => _dirty.add(s.id)),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Guardian phone',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (_) => setState(() => _dirty.add(s.id)),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: _dirty.contains(s.id)
                                ? () => _save(s)
                                : null,
                            icon: const Icon(Icons.save_outlined, size: 18),
                            label: const Text('Save row'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
