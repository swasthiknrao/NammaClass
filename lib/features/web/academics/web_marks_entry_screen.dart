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

    return Padding(
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
          Expanded(
            child: NcCard(
              padding: EdgeInsets.zero,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 900,
                  child: Column(
                    children: [
                      // Header
                      Container(
                        color: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                          horizontal: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 180,
                              child: Text(
                                'Student',
                                style: TextStyle(
                                  color: Colors.white,
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
                            const SizedBox(
                              width: 80,
                              child: Text(
                                'Total',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          itemCount: students.length,
                          separatorBuilder: (_, i) => const Divider(height: 1),
                          itemBuilder: (ctx, i) {
                            final s = students[i];
                            int total = 0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 4,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 180,
                                    child: Text(
                                      s.name,
                                      style: AppTypography.labelSmall,
                                      overflow: TextOverflow.ellipsis,
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
                                        child: TextField(
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.all(8),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            fillColor: mark > 100
                                                ? AppColors.errorBg
                                                : null,
                                            filled: mark > 100,
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
                                    child: Text(
                                      '$total',
                                      style: AppTypography.labelMedium.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
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
