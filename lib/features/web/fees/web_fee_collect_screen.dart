import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_card.dart';

class WebFeeCollectScreen extends ConsumerStatefulWidget {
  const WebFeeCollectScreen({super.key});

  @override
  ConsumerState<WebFeeCollectScreen> createState() =>
      _WebFeeCollectScreenState();
}

class _WebFeeCollectScreenState extends ConsumerState<WebFeeCollectScreen> {
  MockStudent? _selectedStudent;
  String _paymentMode = 'Cash';
  final Set<String> _selectedInstallments = {};
  final _chequeCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  String _search = '';

  final List<MockFeeInstallment> _installments = MockData.fees;

  int get _totalSelected {
    return _installments
        .where((inst) => _selectedInstallments.contains(inst.id))
        .fold(0, (sum, inst) => sum + inst.amountPaise);
  }

  @override
  void dispose() {
    _chequeCtrl.dispose();
    _refCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  List<MockStudent> get _searchResults {
    if (_search.length < 2) return [];
    final q = _search.toLowerCase();
    return MockData.students
        .where((s) => s.name.toLowerCase().contains(q) || s.rollNo.contains(q))
        .take(5)
        .toList();
  }

  void _collect() {
    if (_selectedStudent == null || _selectedInstallments.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: Text(
          'Collect ${AppFormatters.currency(_totalSelected)} from ${_selectedStudent!.name} via $_paymentMode?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Payment of ${AppFormatters.currency(_totalSelected)} collected! Opening receipt...',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
              setState(() {
                _selectedStudent = null;
                _selectedInstallments.clear();
                _search = '';
              });
            },
            child: const Text('Collect & Print Receipt'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fee Collection Counter',
                style: AppTypography.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '💡 Keyboard shortcut: Ctrl+Enter = submit form',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Student search
              NcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Student Search', style: AppTypography.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText:
                            'Search by name, roll number, admission number…',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => setState(() => _search = v),
                    ),
                    if (_searchResults.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      ..._searchResults.map(
                        (s) => ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(s.name),
                          subtitle: Text(
                            '${s.classSection}  ·  Roll ${s.rollNo}',
                          ),
                          trailing: Text(
                            s.feeStatus,
                            style: TextStyle(
                              color: s.feeStatus == 'paid'
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                          onTap: () => setState(() {
                            _selectedStudent = s;
                            _search = '';
                          }),
                        ),
                      ),
                    ],
                    if (_selectedStudent != null) ...[
                      const Divider(),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            child: Icon(Icons.person),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedStudent!.name,
                                  style: AppTypography.titleMedium,
                                ),
                                Text(
                                  '${_selectedStudent!.classSection}  ·  Roll ${_selectedStudent!.rollNo}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Outstanding',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                AppFormatters.currency(75000),
                                style: AppTypography.headlineSmall.copyWith(
                                  color: AppColors.error,
                                  fontFamily: 'JetBrainsMono',
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () =>
                                setState(() => _selectedStudent = null),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Installments
              if (_selectedStudent != null) ...[
                NcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Installments to Collect',
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ..._installments
                          .where((inst) => inst.status != 'paid')
                          .map(
                            (inst) => CheckboxListTile(
                              value: _selectedInstallments.contains(inst.id),
                              onChanged: (v) {
                                setState(() {
                                  if (v == true) {
                                    _selectedInstallments.add(inst.id);
                                  } else {
                                    _selectedInstallments.remove(inst.id);
                                  }
                                });
                              },
                              title: Text(
                                inst.label,
                                style: AppTypography.bodyMedium,
                              ),
                              subtitle: Text(
                                'Due: ${AppFormatters.shortDate(inst.dueDate)}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              secondary: Text(
                                AppFormatters.currency(inst.amountPaise),
                                style: AppTypography.labelMedium.copyWith(
                                  fontFamily: 'JetBrainsMono',
                                ),
                              ),
                              contentPadding: EdgeInsets.zero,
                              activeColor: AppColors.primary,
                            ),
                          ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Payment mode
                NcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payment Details', style: AppTypography.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      SegmentedButton<String>(
                        selected: {_paymentMode},
                        onSelectionChanged: (v) =>
                            setState(() => _paymentMode = v.first),
                        segments: const [
                          ButtonSegment(value: 'Cash', label: Text('Cash')),
                          ButtonSegment(value: 'Cheque', label: Text('Cheque')),
                          ButtonSegment(value: 'Online', label: Text('Online')),
                          ButtonSegment(value: 'DD', label: Text('DD')),
                        ],
                      ),
                      if (_paymentMode == 'Cheque' || _paymentMode == 'DD') ...[
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _chequeCtrl,
                                decoration: InputDecoration(
                                  labelText: '$_paymentMode Number',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Bank Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (_paymentMode == 'Online') ...[
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: _refCtrl,
                          decoration: const InputDecoration(
                            labelText: 'UTR / Reference Number',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _remarksCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Remarks (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Net payable + action buttons
                NcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Net Payable', style: AppTypography.titleMedium),
                          Text(
                            AppFormatters.currency(_totalSelected),
                            style: AppTypography.displayMedium.copyWith(
                              color: AppColors.primary,
                              fontFamily: 'JetBrainsMono',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          FilledButton.icon(
                            onPressed: _totalSelected > 0 ? _collect : null,
                            icon: const Icon(Icons.print),
                            label: const Text('Collect & Print Receipt'),
                          ),
                          OutlinedButton.icon(
                            onPressed: _totalSelected > 0 ? () {} : null,
                            icon: const Icon(Icons.chat),
                            label: const Text('WhatsApp Receipt'),
                          ),
                          OutlinedButton.icon(
                            onPressed: _totalSelected > 0 ? () {} : null,
                            icon: const Icon(Icons.email_outlined),
                            label: const Text('Email Receipt'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.link),
                            label: const Text('Online Payment Link'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
