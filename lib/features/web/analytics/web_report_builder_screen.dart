import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';

class WebReportBuilderScreen extends ConsumerStatefulWidget {
  const WebReportBuilderScreen({super.key});

  @override
  ConsumerState<WebReportBuilderScreen> createState() =>
      _WebReportBuilderScreenState();
}

class _WebReportBuilderScreenState
    extends ConsumerState<WebReportBuilderScreen> {
  String _source = 'Students';
  final List<String> _selectedFields = [];
  final _conditions = <_Condition>[];
  String _sortBy = '';
  String _groupBy = 'None';
  String _reportName = '';
  bool _hasRun = false;

  static const _sources = [
    'Students',
    'Attendance',
    'Fees',
    'Staff',
    'Library',
    'Transport',
    'Hostel',
    'Inventory',
  ];

  static const _fieldsBySource = {
    'Students': [
      'Student Name',
      'Class',
      'Section',
      'Roll No',
      'DOB',
      'Parent Phone',
      'Fee Status',
      'Attendance %',
    ],
    'Attendance': [
      'Student Name',
      'Class',
      'Date',
      'Status',
      'Period',
      'Subject',
      'Month',
      'Year',
    ],
    'Fees': [
      'Student Name',
      'Class',
      'Installment',
      'Amount',
      'Due Date',
      'Paid Date',
      'Status',
      'Payment Mode',
    ],
    'Staff': [
      'Staff Name',
      'Department',
      'Designation',
      'Join Date',
      'Status',
      'Gross Salary',
      'Net Salary',
    ],
  };

  static const _operators = ['=', '!=', '>', '<', '>=', '<=', 'contains', 'in'];

  List<String> get _availableFields =>
      _fieldsBySource[_source] ?? ['Name', 'ID', 'Date', 'Status'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left panel — sources & fields
        Container(
          width: 260,
          decoration: const BoxDecoration(
            color: AppColors.card,
            border: Border(right: BorderSide(color: AppColors.divider)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Data Source', style: AppTypography.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                DropdownButtonFormField<String>(
                  value: _source,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: _sources
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _source = v!;
                    _selectedFields.clear();
                  }),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Available Fields', style: AppTypography.titleSmall),
                Text(
                  'Drag to canvas or tap to add',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                ..._availableFields.map(
                  (f) => ListTile(
                    dense: true,
                    leading: Icon(
                      _selectedFields.contains(f)
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 18,
                      color: _selectedFields.contains(f)
                          ? AppColors.primary
                          : null,
                    ),
                    title: Text(f, style: AppTypography.bodySmall),
                    onTap: () => setState(() {
                      if (_selectedFields.contains(f)) {
                        _selectedFields.remove(f);
                      } else {
                        _selectedFields.add(f);
                      }
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Centre — report canvas
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Report Name...',
                          border: InputBorder.none,
                        ),
                        style: AppTypography.headlineSmall,
                        onChanged: (v) => _reportName = v,
                      ),
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.save),
                          label: const Text('Save Template'),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        FilledButton.icon(
                          onPressed: () => setState(() => _hasRun = true),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Run Report'),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.download),
                          label: const Text('Export'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Selected columns
                NcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Report Columns', style: AppTypography.titleSmall),
                      const SizedBox(height: AppSpacing.xs),
                      if (_selectedFields.isEmpty)
                        Text(
                          'Select fields from left panel to add columns',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        )
                      else
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: _selectedFields
                              .map(
                                (f) => Chip(
                                  label: Text(
                                    f,
                                    style: AppTypography.bodySmall,
                                  ),
                                  onDeleted: () =>
                                      setState(() => _selectedFields.remove(f)),
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Filters
                NcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Filters', style: AppTypography.titleSmall),
                          TextButton.icon(
                            onPressed: () =>
                                setState(() => _conditions.add(_Condition())),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Condition'),
                          ),
                        ],
                      ),
                      ..._conditions.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final cond = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: DropdownButtonFormField<String>(
                                  value: cond.field.isEmpty ? null : cond.field,
                                  hint: const Text('Field'),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  items: _availableFields
                                      .map(
                                        (f) => DropdownMenuItem(
                                          value: f,
                                          child: Text(f),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => cond.field = v ?? ''),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  value: cond.operator.isEmpty
                                      ? null
                                      : cond.operator,
                                  hint: const Text('Op'),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  items: _operators
                                      .map(
                                        (o) => DropdownMenuItem(
                                          value: o,
                                          child: Text(o),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => cond.operator = v ?? ''),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    hintText: 'Value',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  onChanged: (v) =>
                                      setState(() => cond.value = v),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 18,
                                  color: AppColors.error,
                                ),
                                onPressed: () =>
                                    setState(() => _conditions.removeAt(idx)),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Sort & Group
                Row(
                  children: [
                    Expanded(
                      child: NcCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sort By', style: AppTypography.titleSmall),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _sortBy.isEmpty ? null : _sortBy,
                              hint: const Text('Select column'),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              items: _selectedFields
                                  .map(
                                    (f) => DropdownMenuItem(
                                      value: f,
                                      child: Text(f),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _sortBy = v ?? ''),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: NcCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Group By', style: AppTypography.titleSmall),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _groupBy,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              items: ['None', ..._selectedFields]
                                  .map(
                                    (f) => DropdownMenuItem(
                                      value: f,
                                      child: Text(f),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _groupBy = v ?? 'None'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Result preview
                if (_hasRun)
                  NcCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _reportName.isEmpty
                                  ? 'Result Preview (Showing 5 rows)'
                                  : '$_reportName — Result Preview (Showing 5 rows)',
                              style: AppTypography.titleSmall,
                            ),
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.picture_as_pdf,
                                    size: 16,
                                  ),
                                  label: const Text('PDF'),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.table_chart, size: 16),
                                  label: const Text('Excel'),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.schedule, size: 16),
                                  label: const Text('Schedule'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        if (_selectedFields.isEmpty)
                          const Text('No columns selected. Please add fields.')
                        else
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: _selectedFields
                                  .map(
                                    (f) => DataColumn(
                                      label: Text(
                                        f,
                                        style: AppTypography.labelSmall,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              rows: List.generate(
                                5,
                                (i) => DataRow(
                                  cells: _selectedFields
                                      .map(
                                        (f) => DataCell(
                                          Text(
                                            'Sample ${i + 1}',
                                            style: AppTypography.bodySmall,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                      ],
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

class _Condition {
  String field = '';
  String operator = '';
  String value = '';
}
