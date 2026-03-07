import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';

class WebInventoryAssetsScreen extends ConsumerStatefulWidget {
  const WebInventoryAssetsScreen({super.key});

  @override
  ConsumerState<WebInventoryAssetsScreen> createState() =>
      _WebInventoryAssetsScreenState();
}

class _WebInventoryAssetsScreenState
    extends ConsumerState<WebInventoryAssetsScreen> {
  bool _showDrawer = false;
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _category = 'IT';
  String _condition = 'Good';
  final List<MockAsset> _assets = MockData.assets;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Color _conditionColor(String c) {
    switch (c) {
      case 'Good':
        return AppColors.success;
      case 'Fair':
        return AppColors.warning;
      case 'Needs Repair':
        return AppColors.accent;
      default:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final needsAttention = _assets
        .where(
          (a) => a.condition == 'Needs Repair' || a.condition == 'Condemned',
        )
        .length;
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fixed Asset Registry',
                      style: AppTypography.headlineMedium,
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.bar_chart),
                          label: const Text('Depreciation Report'),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        FilledButton.icon(
                          onPressed: () => setState(() => _showDrawer = true),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Asset'),
                        ),
                      ],
                    ),
                  ],
                ),
                if (needsAttention > 0) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.xs),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '$needsAttention assets need attention.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                NcCard(
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
                                'Asset',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Category',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Brand',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Location',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Condition',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Assigned To',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'QR',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ..._assets.map(
                        (a) => Container(
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
                                  a.name,
                                  style: AppTypography.labelMedium,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: NcChip(
                                  label: a.category,
                                  color: AppColors.primary,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  a.brand,
                                  style: AppTypography.bodySmall,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  a.location,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: NcChip(
                                  label: a.condition,
                                  color: _conditionColor(a.condition),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  a.assignedTo,
                                  style: AppTypography.bodySmall,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                  icon: const Icon(Icons.qr_code, size: 18),
                                  onPressed: () {},
                                  tooltip: 'Download QR',
                                ),
                              ),
                            ],
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

        // Add asset drawer
        if (_showDrawer)
          Container(
            width: 400,
            decoration: const BoxDecoration(
              color: AppColors.card,
              border: Border(left: BorderSide(color: AppColors.divider)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Add Asset', style: AppTypography.headlineSmall),
                        IconButton(
                          onPressed: () => setState(() => _showDrawer = false),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Asset Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: AppValidators.required,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          [
                                'IT',
                                'Furniture',
                                'AV Equipment',
                                'Lab',
                                'Sports',
                                'Electrical',
                                'Vehicles',
                              ]
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => _category = v!),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _brandCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Brand / Model',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _locationCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Location (Room/Lab/Office)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      value: _condition,
                      decoration: const InputDecoration(
                        labelText: 'Condition',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Good', 'Fair', 'Needs Repair', 'Condemned']
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _condition = v!),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _showDrawer = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Asset added!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        },
                        child: const Text('Save Asset'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
