import 'package:flutter/material.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/utils/screen_size.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_card.dart';

class WebMarksEntryScreen extends StatefulWidget {
  const WebMarksEntryScreen({super.key});
  @override
  State<WebMarksEntryScreen> createState() => _WebMarksEntryScreenState();
}

class _WebMarksEntryScreenState extends State<WebMarksEntryScreen> {
  final students = MockData.students
      .where((s) => s.classSection == '8-A')
      .toList();
  final subjects = [
    'Mathematics',
    'Science',
    'English',
    'Social Studies',
    'Kannada',
  ];
  final Map<String, Map<String, int>> marks = {};

  @override
  Widget build(BuildContext context) {
    final isMobile = ScreenSize.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? AppSpacing.sm : AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        DropdownButton<String>(
                          value: '8-A',
                          items: ['8-A', '8-B', '9-A']
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                          onChanged: (_) {},
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        DropdownButton<String>(
                          value: 'Term 1',
                          items: ['Term 1', 'Term 2', 'Term 3']
                              .map(
                                (t) =>
                                    DropdownMenuItem(value: t, child: Text(t)),
                              )
                              .toList(),
                          onChanged: (_) {},
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.upload_file, size: 16),
                            label: Text(isMobile ? 'Import' : 'Import Excel'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: NcPrimaryButton(
                            label: 'Save Marks',
                            icon: Icons.save,
                            onPressed: () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Marks saved!')),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    DropdownButton<String>(
                      value: '8-A',
                      items: ['8-A', '8-B', '9-A']
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (_) {},
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    DropdownButton<String>(
                      value: 'Term 1',
                      items: ['Term 1', 'Term 2', 'Term 3']
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (_) {},
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.upload_file, size: 16),
                      label: const Text('Import Excel'),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    NcPrimaryButton(
                      label: 'Save Marks',
                      icon: Icons.save,
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Marks saved!')),
                          ),
                    ),
                  ],
                ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: NcCard(
                padding: EdgeInsets.zero,
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Sticky-style header
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                          horizontal: AppSpacing.md,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 180,
                              child: Text(
                                'Student',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            ...subjects.map(
                              (s) => SizedBox(
                                width: 120,
                                child: Text(
                                  s,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                'Total',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Rows — dynamic height, no wasted space
                      ...List.generate(students.length, (i) {
                        final s = students[i];
                        int total = 0;
                        final isEven = i.isEven;
                        return Container(
                          color: isEven ? null : AppColors.background,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs + 2,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 180,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: AppColors.primary
                                          .withValues(alpha: 0.15),
                                      child: Text(
                                        s.name.substring(0, 1).toUpperCase(),
                                        style: AppTypography.labelSmall
                                            .copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        s.name,
                                        style: AppTypography.labelSmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...subjects.map((sub) {
                                final mark = marks[s.id]?[sub] ?? 0;
                                total += mark;
                                return SizedBox(
                                  width: 120,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: TextFormField(
                                      initialValue: mark > 0 ? '$mark' : '',
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 10,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: mark > 100
                                            ? AppColors.errorBg
                                            : AppColors.card,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.divider,
                                          ),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (v) {
                                        setState(() {
                                          marks[s.id] ??= {};
                                          marks[s.id]![sub] =
                                              int.tryParse(v) ?? 0;
                                        });
                                      },
                                      style: AppTypography.bodySmall,
                                    ),
                                  ),
                                );
                              }),
                              SizedBox(
                                width: 80,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.08,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$total',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
