import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';

class WebApplicationDetailScreen extends ConsumerStatefulWidget {
  const WebApplicationDetailScreen({super.key, required this.applicationId});
  final String applicationId;

  @override
  ConsumerState<WebApplicationDetailScreen> createState() =>
      _WebApplicationDetailScreenState();
}

class _WebApplicationDetailScreenState
    extends ConsumerState<WebApplicationDetailScreen> {
  String _decision = '';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Row(
            children: [
              TextButton(onPressed: () {}, child: const Text('Admissions')),
              const Icon(Icons.chevron_right, size: 16),
              TextButton(onPressed: () {}, child: const Text('Applications')),
              const Icon(Icons.chevron_right, size: 16),
              Text(
                'APP-2026-${widget.applicationId.isEmpty ? '0042' : widget.applicationId}',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left — application details
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    // Application header
                    NcCard(
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 32,
                            backgroundColor: AppColors.primary,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sneha Patil',
                                  style: AppTypography.headlineMedium,
                                ),
                                Text(
                                  'Applying for Class 6  ·  APP-2026-0042',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  'Applied on: 4 Mar 2026',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          NcStatusChip(
                            label: 'Under Review',
                            color: AppColors.warning,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Personal details
                    _SectionCard('Personal Details', [
                      _InfoRow('Date of Birth', '15 Aug 2014'),
                      _InfoRow('Gender', 'Female'),
                      _InfoRow('Blood Group', 'B+'),
                      _InfoRow(
                        'Previous School',
                        'Little Flower School, Udupi',
                      ),
                      _InfoRow('Category', 'General'),
                    ]),
                    const SizedBox(height: AppSpacing.md),

                    // Parent details
                    _SectionCard('Parent / Guardian', [
                      _InfoRow('Father', 'Sunil Patil'),
                      _InfoRow('Mother', 'Meena Patil'),
                      _InfoRow('Phone', '+91 9876501234'),
                      _InfoRow('Email', 'sunil.patil@gmail.com'),
                      _InfoRow('Occupation', 'Business'),
                    ]),
                    const SizedBox(height: AppSpacing.md),

                    // Documents
                    NcCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Documents', style: AppTypography.titleMedium),
                          const SizedBox(height: AppSpacing.sm),
                          ...[
                            ('Birth Certificate', true),
                            ('Aadhaar Card', true),
                            ('Transfer Certificate', false),
                            ('Mark Sheet', true),
                            ('Passport Photo', true),
                          ].map(
                            (doc) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                doc.$2 ? Icons.check_circle : Icons.pending,
                                color: doc.$2
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                              title: Text(
                                doc.$1,
                                style: AppTypography.bodyMedium,
                              ),
                              trailing: doc.$2
                                  ? TextButton(
                                      onPressed: () {},
                                      child: const Text('Verify'),
                                    )
                                  : TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.warning,
                                      ),
                                      onPressed: () {},
                                      child: const Text('Request'),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Test result
                    NcCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Entrance Test Result',
                            style: AppTypography.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: '78',
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Marks (out of 100)',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              const Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Interviewer',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Right — action panel + timeline
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    // Admission decision
                    NcCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admission Decision',
                            style: AppTypography.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          SegmentedButton<String>(
                            selected: {_decision},
                            onSelectionChanged: (v) =>
                                setState(() => _decision = v.first),
                            emptySelectionAllowed: true,
                            segments: const [
                              ButtonSegment(
                                value: 'admit',
                                label: Text('Admit'),
                                icon: Icon(Icons.check),
                              ),
                              ButtonSegment(
                                value: 'waitlist',
                                label: Text('Waitlist'),
                                icon: Icon(Icons.hourglass_empty),
                              ),
                              ButtonSegment(
                                value: 'reject',
                                label: Text('Reject'),
                                icon: Icon(Icons.close),
                              ),
                            ],
                          ),
                          if (_decision == 'admit') ...[
                            const SizedBox(height: AppSpacing.sm),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Admission letter generated!',
                                        ),
                                        backgroundColor: AppColors.success,
                                      ),
                                    ),
                                icon: const Icon(Icons.description),
                                label: const Text('Generate Admission Letter'),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Student record created!',
                                        ),
                                        backgroundColor: AppColors.teal,
                                      ),
                                    ),
                                icon: const Icon(Icons.person_add),
                                label: const Text('Convert to Student'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.teal,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Schedule interview
                    NcCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Schedule Interview',
                            style: AppTypography.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          const TextField(
                            decoration: InputDecoration(
                              labelText: 'Interview Date & Time',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.event),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          const TextField(
                            decoration: InputDecoration(
                              labelText: 'Interviewer',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {},
                              child: const Text('Schedule'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Application timeline
                    NcCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Application Timeline',
                            style: AppTypography.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ...[
                            ('Enquiry Received', true, '1 Mar 2026'),
                            ('Application Submitted', true, '3 Mar 2026'),
                            ('Documents Received', true, '4 Mar 2026'),
                            ('Test Scheduled', true, '8 Mar 2026'),
                            ('Interview', false, 'Pending'),
                            ('Final Decision', false, 'Pending'),
                          ].map(
                            (step) => _TimelineStep(
                              title: step.$1,
                              done: step.$2,
                              date: step.$3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard(this.title, this.rows);
  final String title;
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return NcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          ...rows,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.title,
    required this.done,
    required this.date,
  });
  final String title;
  final bool done;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: done ? AppColors.success : AppColors.divider,
                shape: BoxShape.circle,
              ),
              child: done
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            if (title != 'Final Decision')
              Container(width: 2, height: 24, color: AppColors.divider),
          ],
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelMedium.copyWith(
                    color: done
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                Text(
                  date,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
