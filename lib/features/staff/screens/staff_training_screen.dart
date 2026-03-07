import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_input.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../providers/staff_providers.dart';

class StaffTrainingScreen extends ConsumerStatefulWidget {
  const StaffTrainingScreen({super.key});

  @override
  ConsumerState<StaffTrainingScreen> createState() =>
      _StaffTrainingScreenState();
}

class _StaffTrainingScreenState extends ConsumerState<StaffTrainingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

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
    final trainingsAsync = ref.watch(staffTrainingsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training & CPD'),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Add Entry'),
          ],
        ),
      ),
      body: trainingsAsync.when(
        loading: () => const NcShimmerList(itemCount: 4),
        error: (e, _) =>
            const Center(child: Text('Error loading training records')),
        data: (trainings) {
          final upcoming = trainings.where((t) => !t.isCompleted).toList();
          final completed = trainings.where((t) => t.isCompleted).toList();
          final totalHours = completed.fold(0, (sum, t) => sum + t.hours);
          return Column(
            children: [
              // CPD progress
              Container(
                margin: const EdgeInsets.all(AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total CPD Hours This Year: $totalHours / 30',
                      style: AppTypography.labelMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    LinearProgressIndicator(
                      value: totalHours / 30,
                      backgroundColor: AppColors.divider,
                      color: AppColors.teal,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _TrainingList(upcoming, isUpcoming: true),
                    _TrainingList(completed, isUpcoming: false),
                    const _AddEntryForm(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TrainingList extends StatelessWidget {
  const _TrainingList(this.trainings, {required this.isUpcoming});
  final List<MockTraining> trainings;
  final bool isUpcoming;

  @override
  Widget build(BuildContext context) {
    if (trainings.isEmpty) {
      return Center(
        child: Text(
          isUpcoming ? 'No upcoming trainings.' : 'No completed trainings.',
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: trainings.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) => NcCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    trainings[i].title,
                    style: AppTypography.titleSmall,
                  ),
                ),
                if (!isUpcoming && trainings[i].certificateUrl != null)
                  OutlinedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Downloading certificate...'),
                      ),
                    ),
                    icon: const Icon(Icons.workspace_premium, size: 14),
                    label: const Text(
                      'Certificate',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              trainings[i].provider,
              style: AppTypography.bodySmall.copyWith(color: AppColors.teal),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  AppFormatters.shortDate(trainings[i].date),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(
                  Icons.schedule,
                  size: 12,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${trainings[i].hours}h',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(
                  Icons.location_on,
                  size: 12,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    trainings[i].venue,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (isUpcoming) ...[
              const SizedBox(height: AppSpacing.xs),
              FilledButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Registration request sent!')),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Register'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddEntryForm extends StatefulWidget {
  const _AddEntryForm();

  @override
  State<_AddEntryForm> createState() => _AddEntryFormState();
}

class _AddEntryFormState extends State<_AddEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _providerCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  int _hours = 4;
  String? _certFile;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _providerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Training Name', style: AppTypography.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            NcTextField(
              controller: _titleCtrl,
              hintText: 'Training title',
              validator: AppValidators.requiredField('Required'),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Provider / Organisation', style: AppTypography.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            NcTextField(
              controller: _providerCtrl,
              hintText: 'Training provider',
              validator: AppValidators.requiredField('Required'),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date', style: AppTypography.labelLarge),
                      const SizedBox(height: AppSpacing.xs),
                      InkWell(
                        onTap: () async {
                          final p = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (p != null) setState(() => _date = p);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.divider),
                            borderRadius: BorderRadius.circular(AppSpacing.xs),
                          ),
                          child: Text(
                            AppFormatters.shortDate(_date),
                            style: AppTypography.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hours', style: AppTypography.labelLarge),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (_hours > 1) setState(() => _hours--);
                            },
                            icon: const Icon(Icons.remove),
                          ),
                          Text('$_hours', style: AppTypography.headlineSmall),
                          IconButton(
                            onPressed: () => setState(() => _hours++),
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Certificate Upload (optional)',
              style: AppTypography.labelLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            if (_certFile != null)
              Chip(
                label: Text(_certFile!),
                onDeleted: () => setState(() => _certFile = null),
              )
            else
              OutlinedButton.icon(
                onPressed: () => setState(() => _certFile = 'certificate.pdf'),
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Certificate'),
              ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Training entry added!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                child: const Text('Submit CPD Entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
