import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_card.dart';

class DiaryEntryScreen extends ConsumerStatefulWidget {
  const DiaryEntryScreen({super.key});

  @override
  ConsumerState<DiaryEntryScreen> createState() => _DiaryEntryScreenState();
}

class _DiaryEntryScreenState extends ConsumerState<DiaryEntryScreen> {
  final Map<String, TextEditingController> _cwControllers = {};
  final Map<String, TextEditingController> _hwControllers = {};
  DateTime _selectedDate = DateTime.now();

  final _subjects = [
    'Mathematics',
    'Science',
    'English',
    'Social Studies',
    'Kannada',
    'Computer Science',
  ];

  @override
  void initState() {
    super.initState();
    for (final s in _subjects) {
      _cwControllers[s] = TextEditingController();
      _hwControllers[s] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _cwControllers.values) {
      c.dispose();
    }
    for (final c in _hwControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diary & Homework Entry')),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 7-day date strip
          Container(
            height: 70,
            color: AppColors.card,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              itemCount: 7,
              itemBuilder: (ctx, i) {
                final d = DateTime.now().subtract(Duration(days: 6 - i));
                final isSelected =
                    _selectedDate.day == d.day &&
                    _selectedDate.month == d.month;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = d),
                  child: Container(
                    margin: const EdgeInsets.only(right: AppSpacing.xs),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(AppSpacing.xs),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.divider,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppFormatters.formatShortDate(d),
                          style: AppTypography.labelSmall.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Subject cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _subjects.length,
              itemBuilder: (ctx, i) {
                final subject = _subjects[i];
                final color = subject.subjectColor;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: NcCard(
                    padding: EdgeInsets.zero,
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: Container(
                          width: 4,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        title: Text(subject, style: AppTypography.labelLarge),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.md,
                              0,
                              AppSpacing.md,
                              AppSpacing.md,
                            ),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _cwControllers[subject],
                                  decoration: const InputDecoration(
                                    labelText: 'Classwork',
                                    hintText: 'What was covered today…',
                                    prefixIcon: Icon(Icons.menu_book),
                                  ),
                                  maxLines: 2,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                TextField(
                                  controller: _hwControllers[subject],
                                  decoration: const InputDecoration(
                                    labelText: 'Homework',
                                    hintText: 'Assignment for students…',
                                    prefixIcon: Icon(Icons.assignment),
                                  ),
                                  maxLines: 2,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.attach_file,
                                        size: 16,
                                      ),
                                      label: const Text('Attach'),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '$subject diary saved!',
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.save, size: 16),
                                      label: const Text('Save'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
