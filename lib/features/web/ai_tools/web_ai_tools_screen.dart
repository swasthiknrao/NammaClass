import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_card.dart';

class WebAiToolsScreen extends StatelessWidget {
  const WebAiToolsScreen({super.key});

  static final _tools = [
    (
      'AI Notice Drafter',
      'Generate notices in seconds using AI',
      Icons.edit_note,
      AppColors.primary,
    ),
    (
      'Fee Defaulter Prediction',
      'Predict students likely to default on fees',
      Icons.warning_amber,
      AppColors.error,
    ),
    (
      'Attendance Insights',
      'Analyse attendance patterns and alerts',
      Icons.bar_chart,
      AppColors.teal,
    ),
    (
      'Report Card Generator',
      'Auto-generate report cards with analysis',
      Icons.grade,
      AppColors.accent,
    ),
    (
      'Timetable Optimizer',
      'AI-optimized conflict-free timetables',
      Icons.table_chart,
      AppColors.primary,
    ),
    (
      'Parent Communication',
      'Smart notifications & message suggestions',
      Icons.chat,
      AppColors.success,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.accent, size: 28),
              const SizedBox(width: AppSpacing.sm),
              Text('AI Tools Hub', style: AppTypography.headlineLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'NammaClass AI-powered features',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 2,
            children: _tools
                .map(
                  (t) => NcCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: t.$4.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(t.$3, color: t.$4, size: 28),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(t.$1, style: AppTypography.labelLarge),
                              Text(
                                t.$2,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              SizedBox(
                                height: 28,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: t.$4,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    minimumSize: Size.zero,
                                    textStyle: AppTypography.labelSmall,
                                  ),
                                  child: const Text('Try Now'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          // AI Notice Drafter expanded
          NcCard(
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.4),
              width: 1.5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text(
                      'AI Notice Drafter',
                      style: AppTypography.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'What is the notice about?',
                    hintText:
                        'e.g. Annual Day on March 20th at school auditorium',
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    NcPrimaryButton(
                      label: 'Generate Draft',
                      icon: Icons.auto_awesome,
                      color: AppColors.accent,
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
