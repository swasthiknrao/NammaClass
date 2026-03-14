import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_size.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';

class WebReportCardBuilderScreen extends ConsumerStatefulWidget {
  const WebReportCardBuilderScreen({super.key});

  @override
  ConsumerState<WebReportCardBuilderScreen> createState() =>
      _WebReportCardBuilderScreenState();
}

class _WebReportCardBuilderScreenState
    extends ConsumerState<WebReportCardBuilderScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String _selectedTerm = 'Term 1';
  bool _importDone = false;
  bool _isGenerating = false;
  bool _isPublished = false;

  final List<Map<String, String>> _gradeScale = [
    {'from': '90', 'to': '100', 'grade': 'A+'},
    {'from': '80', 'to': '89', 'grade': 'A'},
    {'from': '70', 'to': '79', 'grade': 'B+'},
    {'from': '60', 'to': '69', 'grade': 'B'},
    {'from': '50', 'to': '59', 'grade': 'C'},
    {'from': '35', 'to': '49', 'grade': 'D'},
    {'from': '0', 'to': '34', 'grade': 'F'},
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ScreenSize.isMobile(context);
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? AppSpacing.sm : AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: AppColors.divider.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.grading_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Report Cards', style: AppTypography.headlineSmall),
                    Text(
                      _selectedTerm,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              DropdownButton<String>(
                value: _selectedTerm,
                items: ['Term 1', 'Term 2', 'Annual']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedTerm = v!),
                isExpanded: false,
              ),
            ],
          ),
        ),
        TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(
              icon: Icon(Icons.dashboard_customize, size: 18),
              text: 'Template',
            ),
            Tab(icon: Icon(Icons.publish, size: 18), text: 'Publish'),
            Tab(icon: Icon(Icons.folder_open, size: 18), text: 'Published'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _TemplateTab(gradeScale: _gradeScale),
              _PublishTab(
                selectedTerm: _selectedTerm,
                importDone: _importDone,
                isGenerating: _isGenerating,
                isPublished: _isPublished,
                onImport: () => setState(() => _importDone = true),
                onGenerate: () async {
                  setState(() => _isGenerating = true);
                  await Future.delayed(const Duration(seconds: 2));
                  if (mounted) setState(() => _isGenerating = false);
                },
                onPublish: () => setState(() => _isPublished = true),
              ),
              _PublishedCardsTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _TemplateTab extends StatelessWidget {
  const _TemplateTab({required this.gradeScale});
  final List<Map<String, String>> gradeScale;

  @override
  Widget build(BuildContext context) {
    final isMobile = ScreenSize.isMobile(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? AppSpacing.sm : AppSpacing.lg),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _templateConfigCard(context),
                const SizedBox(height: AppSpacing.md),
                _gradeScaleCard(context),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _templateConfigCard(context)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _gradeScaleCard(context)),
              ],
            ),
    );
  }

  Widget _templateConfigCard(BuildContext context) {
    return NcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Template Configuration', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.md),
          const TextField(
            decoration: InputDecoration(
              labelText: 'School Logo Position',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Include Student Photo'),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Show Attendance %'),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: false,
            onChanged: (_) {},
            title: const Text('Show Rank in Class'),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Co-scholastic Parameters', style: AppTypography.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            children: [
              'Sports',
              'Arts',
              'Discipline',
              'Attendance',
            ].map((p) => Chip(label: Text(p))).toList(),
          ),
        ],
      ),
    );
  }

  Widget _gradeScaleCard(BuildContext context) {
    return NcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Grade Scale', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          ...gradeScale.map(
            (g) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      '${g['from']}–${g['to']}%',
                      style: AppTypography.bodySmall,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      g['grade']!,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PublishTab extends StatelessWidget {
  const _PublishTab({
    required this.selectedTerm,
    required this.importDone,
    required this.isGenerating,
    required this.isPublished,
    required this.onImport,
    required this.onGenerate,
    required this.onPublish,
  });
  final String selectedTerm;
  final bool importDone;
  final bool isGenerating;
  final bool isPublished;
  final VoidCallback onImport;
  final VoidCallback onGenerate;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    final isMobile = ScreenSize.isMobile(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? AppSpacing.sm : AppSpacing.lg),
      child: NcCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Publish Results — $selectedTerm',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Step 1 — Import
            _PublishStep(
              step: 1,
              title: 'Import Marks',
              subtitle:
                  'Upload Excel template with subject-wise marks for all students.',
              done: importDone,
              child: _PublishStepActions(
                items: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Download Template'),
                  ),
                  FilledButton.icon(
                    onPressed: onImport,
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: const Text('Upload Marks Excel'),
                  ),
                  if (importDone)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '1,248 rows imported',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const Divider(),

            // Step 2 — Generate
            _PublishStep(
              step: 2,
              title: 'Generate Report Cards',
              subtitle:
                  'Generate PDF report cards for all students. Background process.',
              done: !isGenerating && importDone,
              child: _PublishStepActions(
                items: [
                  FilledButton.icon(
                    onPressed: importDone && !isGenerating ? onGenerate : null,
                    icon: isGenerating
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(
                      isGenerating
                          ? 'Generating...'
                          : 'Generate All Report Cards',
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Step 3 — Publish
            _PublishStep(
              step: 3,
              title: 'Publish to Parents',
              subtitle:
                  'Make report cards visible on parent app and send push notification.',
              done: isPublished,
              child: FilledButton.icon(
                onPressed: importDone && !isGenerating && !isPublished
                    ? onPublish
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                ),
                icon: const Icon(Icons.send),
                label: Text(isPublished ? 'Published ✓' : 'Publish All'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PublishStepActions extends StatelessWidget {
  const _PublishStepActions({required this.items});
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    final isMobile = ScreenSize.isMobile(context);
    if (isMobile) {
      return Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: items,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          items[i],
        ],
      ],
    );
  }
}

class _PublishStep extends StatelessWidget {
  const _PublishStep({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.child,
  });
  final int step;
  final String title;
  final String subtitle;
  final bool done;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: done ? AppColors.success.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: done
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.divider.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: done ? AppColors.success : AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (done ? AppColors.success : AppColors.primary)
                      .withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '$step',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleSmall),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PublishedCardsTab extends StatelessWidget {
  const _PublishedCardsTab();

  @override
  Widget build(BuildContext context) {
    final isMobile = ScreenSize.isMobile(context);
    final data = [
      ('Term 1 2025-26', '1 Dec 2025', '1248', '1105'),
      ('Annual 2024-25', '15 May 2025', '1203', '1190'),
    ];
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? AppSpacing.sm : AppSpacing.lg),
      child: isMobile
          ? Column(
              children: data
                  .map((row) => _publishedCard(context, row))
                  .toList(),
            )
          : NcCard(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    color: AppColors.background,
                    child: Row(
                      children: const [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Term',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Published',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Views',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Action',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...data.map(
                    (row) => Container(
                      padding: const EdgeInsets.symmetric(
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
                            child: Text(
                              row.$1,
                              style: AppTypography.bodyMedium,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              row.$2,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Expanded(flex: 2, child: Text(row.$3)),
                          Expanded(
                            flex: 2,
                            child: Text(
                              row.$4,
                              style: TextStyle(color: AppColors.teal),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.download, size: 14),
                              label: const Text('All PDFs'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _publishedCard(
    BuildContext context,
    (String, String, String, String) row,
  ) {
    return NcCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(row.$1, style: AppTypography.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Published', style: AppTypography.labelSmall),
                Text(row.$2, style: AppTypography.bodySmall),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: AppTypography.labelSmall),
                Text(row.$3, style: AppTypography.bodySmall),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Views', style: AppTypography.labelSmall),
                Text(
                  row.$4,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Download All PDFs'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
