import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_avatar.dart';
import '../../../core/widgets/nc_card.dart';

class CanteenCounterScreen extends ConsumerStatefulWidget {
  const CanteenCounterScreen({super.key});

  @override
  ConsumerState<CanteenCounterScreen> createState() =>
      _CanteenCounterScreenState();
}

class _CanteenCounterScreenState extends ConsumerState<CanteenCounterScreen> {
  bool _studentScanned = false;
  final Map<String, int> _adHocOrder = {};
  final int _walletBalance = 12000; // paise

  final _menuItems = MockData.canteenMenu.take(6).toList();

  int get _orderTotal => _adHocOrder.entries.fold(0, (sum, e) {
    final item = _menuItems.firstWhere((m) => m.id == e.key);
    return sum + (item.pricePaise * e.value);
  });

  int get _walletAfter => _walletBalance - _orderTotal;

  void _simulateScan() {
    setState(() => _studentScanned = true);
  }

  void _addItem(MockCanteenItem item) {
    setState(() => _adHocOrder[item.id] = (_adHocOrder[item.id] ?? 0) + 1);
  }

  void _removeItem(MockCanteenItem item) {
    setState(() {
      if ((_adHocOrder[item.id] ?? 0) > 0) {
        _adHocOrder[item.id] = _adHocOrder[item.id]! - 1;
      }
    });
  }

  void _charge() {
    if (_walletAfter < 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Insufficient Balance'),
          content: Text(
            'Insufficient balance (${AppFormatters.formatPaise(-_walletAfter)} short). Ask parent to top up.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Charge Partial'),
            ),
          ],
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: Text(
          'Charge ${AppFormatters.formatPaise(_orderTotal)} from wallet?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _studentScanned = false;
                _adHocOrder.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Payment of ${AppFormatters.formatPaise(_orderTotal)} deducted!',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showDailySummary() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Daily Summary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SummaryRow('Total Orders', '47'),
            _SummaryRow('Total Revenue', AppFormatters.formatPaise(234500)),
            _SummaryRow('Most Ordered', 'Idli Sambhar (12)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canteen Counter'),
        actions: [
          IconButton(
            onPressed: _showDailySummary,
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Daily Summary',
          ),
        ],
      ),
      body: Column(
        children: [
          // Scan area
          if (!_studentScanned)
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: _simulateScan,
                child: Container(
                  color: AppColors.background,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.qr_code_scanner,
                          size: 80,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Scan Student QR Card',
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Tap to simulate scan',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else ...[
            // Student result
            Container(
              color: AppColors.card,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Row(
                    children: [
                      const NcAvatar(name: 'Arjun Kumar', radius: 28),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Arjun Kumar',
                              style: AppTypography.titleMedium,
                            ),
                            Text(
                              'Class 8-A',
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
                            'Wallet Balance',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            AppFormatters.formatPaise(_walletBalance),
                            style: AppTypography.headlineSmall.copyWith(
                              color: AppColors.teal,
                              fontFamily: 'JetBrainsMono',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Pre-order section
                  const SizedBox(height: AppSpacing.sm),
                  NcCard(
                    color: AppColors.success.withValues(alpha: 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Pre-Order',
                          style: AppTypography.labelMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            const Icon(
                              Icons.lunch_dining,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Idli Sambhar x2 — ₹40',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _charge,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.success,
                            ),
                            child: const Text('Deliver & Charge ₹40'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Ad-hoc menu
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.sm),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: AppSpacing.xs,
                  mainAxisSpacing: AppSpacing.xs,
                ),
                itemCount: _menuItems.length,
                itemBuilder: (_, i) {
                  final item = _menuItems[i];
                  final qty = _adHocOrder[item.id] ?? 0;
                  return NcCard(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.name,
                          style: AppTypography.labelSmall,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                        Text(
                          AppFormatters.formatPaise(item.pricePaise),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.teal,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        if (qty == 0)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _addItem(item),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                              ),
                              child: const Icon(Icons.add, size: 16),
                            ),
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () => _removeItem(item),
                                icon: const Icon(Icons.remove, size: 16),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              Text('$qty', style: AppTypography.titleSmall),
                              IconButton(
                                onPressed: () => _addItem(item),
                                icon: const Icon(Icons.add, size: 16),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],

          // Order total footer
          if (_studentScanned && _orderTotal > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              color: AppColors.card,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total: ${AppFormatters.formatPaise(_orderTotal)}',
                          style: AppTypography.titleSmall.copyWith(
                            fontFamily: 'JetBrainsMono',
                          ),
                        ),
                        Text(
                          'Wallet: ${AppFormatters.formatPaise(_walletBalance)} → ${AppFormatters.formatPaise(_walletAfter)} after',
                          style: AppTypography.bodySmall.copyWith(
                            color: _walletAfter < 0
                                ? AppColors.error
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: _charge,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                    ),
                    child: Text(
                      'Charge ${AppFormatters.formatPaise(_orderTotal)}',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium),
          Text(
            value,
            style: AppTypography.labelMedium.copyWith(
              fontFamily: 'JetBrainsMono',
            ),
          ),
        ],
      ),
    );
  }
}
