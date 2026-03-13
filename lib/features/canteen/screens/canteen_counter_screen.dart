import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_avatar.dart';
import '../../../core/widgets/nc_card.dart';
import '../providers/canteen_provider.dart';

class CanteenCounterScreen extends ConsumerStatefulWidget {
  const CanteenCounterScreen({super.key});

  @override
  ConsumerState<CanteenCounterScreen> createState() =>
      _CanteenCounterScreenState();
}

class _CanteenCounterScreenState extends ConsumerState<CanteenCounterScreen> {
  final TextEditingController _lookupController = TextEditingController();
  final Map<String, int> _adHocOrder = {};
  final _menuItems = MockData.canteenMenu.take(6).toList();
  final _combos = MockData.canteenCombos;

  int _priceForId(String id) {
    final menuItem = _menuItems.where((m) => m.id == id).firstOrNull;
    if (menuItem != null) return menuItem.pricePaise;
    final combo = _combos.where((c) => c.id == id).firstOrNull;
    if (combo != null) return combo.pricePaise;
    return 0;
  }

  String _nameForId(String id) {
    final menuItem = _menuItems.where((m) => m.id == id).firstOrNull;
    if (menuItem != null) return menuItem.name;
    final combo = _combos.where((c) => c.id == id).firstOrNull;
    if (combo != null) return combo.name;
    return id;
  }

  int get _orderTotal => _adHocOrder.entries.fold(0, (sum, e) {
    return sum + (_priceForId(e.key) * e.value);
  });

  void _lookupPerson() {
    final query = _lookupController.text.trim();
    if (query.isEmpty) return;
    final info = lookupCanteenPerson(query);
    if (info != null) {
      ref.read(canteenStateProvider.notifier).setScannedPerson(info);
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No person found for "$query". Try ID, barcode (BAR-xxx), roll no, or name.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _simulateScan() {
    _lookupController.text = 's01'; // Arjun
    _lookupPerson();
  }

  void _clearPerson() {
    ref.read(canteenStateProvider.notifier).clearScannedPerson();
    _adHocOrder.clear();
    _lookupController.clear();
    setState(() {});
  }

  void _addItem(String id) {
    setState(() => _adHocOrder[id] = (_adHocOrder[id] ?? 0) + 1);
  }

  void _removeItem(String id) {
    setState(() {
      if ((_adHocOrder[id] ?? 0) > 0) {
        _adHocOrder[id] = _adHocOrder[id]! - 1;
        if (_adHocOrder[id] == 0) _adHocOrder.remove(id);
      }
    });
  }

  void _charge() {
    final person = ref.read(canteenStateProvider).scannedPerson;
    if (person == null) return;

    final walletBal = person.walletBalancePaise;
    final walletAfter = walletBal - _orderTotal;

    if (walletAfter < 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Insufficient Balance'),
          content: Text(
            'Insufficient balance (${AppFormatters.formatPaise(-walletAfter)} short). Ask to top up.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final items = _adHocOrder.entries
        .where((e) => e.value > 0)
        .map(
          (e) => MockCanteenOrderItem(
            itemId: e.key,
            name: _nameForId(e.key),
            qty: e.value,
            pricePaise: _priceForId(e.key),
          ),
        )
        .toList();

    if (items.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: Text(
          'Charge ${AppFormatters.formatPaise(_orderTotal)} from ${person.personName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(canteenStateProvider.notifier)
                  .addOrder(person.personId, items, _orderTotal);
              setState(() {
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
    final todayOrders = MockData.canteenOrders
        .where(
          (o) =>
              o.createdAt.year == DateTime.now().year &&
              o.createdAt.month == DateTime.now().month &&
              o.createdAt.day == DateTime.now().day,
        )
        .toList();
    final revenue = todayOrders.fold<int>(0, (s, o) => s + o.totalPaise);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Daily Summary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SummaryRow('Total Orders', '${todayOrders.length}'),
            _SummaryRow('Total Revenue', AppFormatters.formatPaise(revenue)),
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
  void dispose() {
    _lookupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canteenState = ref.watch(canteenStateProvider);
    final person = canteenState.scannedPerson;
    final walletBalance = person?.walletBalancePaise ?? 0;
    final walletAfter = walletBalance - _orderTotal;

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
          // Lookup / Scan area
          if (person == null)
            Expanded(
              flex: 2,
              child: Container(
                color: AppColors.background,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.qr_code_scanner,
                      size: 72,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Scan QR or Enter ID / Barcode',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Person ID, BAR-xxx, roll no, or name',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _lookupController,
                            decoration: const InputDecoration(
                              hintText: 'e.g. s01, BAR-s01, 01, Arjun',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _lookupPerson(),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        FilledButton(
                          onPressed: _lookupPerson,
                          child: const Text('Lookup'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton.icon(
                      onPressed: _simulateScan,
                      icon: const Icon(Icons.touch_app, size: 18),
                      label: const Text('Simulate: Arjun (s01)'),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // Person header
            Container(
              color: AppColors.card,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Row(
                    children: [
                      NcAvatar(name: person.personName, radius: 28),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  person.personName,
                                  style: AppTypography.titleMedium,
                                ),
                                if (person.subscription != null &&
                                    person.subscription!.status ==
                                        'active') ...[
                                  const SizedBox(width: AppSpacing.xs),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      person.subscription!.planName,
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              person.info,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (person.barcode != null)
                              Text(
                                person.barcode!,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
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
                            AppFormatters.formatPaise(walletBalance),
                            style: AppTypography.headlineSmall.copyWith(
                              color: AppColors.teal,
                              fontFamily: 'JetBrainsMono',
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: _clearPerson,
                        icon: const Icon(Icons.close),
                        tooltip: 'Clear & New',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Combos row
            if (_combos.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: _combos.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.xs),
                  itemBuilder: (_, i) {
                    final c = _combos[i];
                    final qty = _adHocOrder[c.id] ?? 0;
                    return SizedBox(
                      width: 120,
                      child: NcCard(
                        color: c.isVeg
                            ? AppColors.success.withValues(alpha: 0.08)
                            : AppColors.error.withValues(alpha: 0.08),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              c.name,
                              style: AppTypography.labelSmall,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              AppFormatters.formatPaise(c.pricePaise),
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.teal,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 16),
                                  onPressed: qty > 0
                                      ? () => _removeItem(c.id)
                                      : null,
                                ),
                                Text('$qty', style: AppTypography.labelMedium),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 16),
                                  onPressed: () => _addItem(c.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Menu grid
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
                              onPressed: () => _addItem(item.id),
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
                                onPressed: () => _removeItem(item.id),
                                icon: const Icon(Icons.remove, size: 16),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              Text('$qty', style: AppTypography.titleSmall),
                              IconButton(
                                onPressed: () => _addItem(item.id),
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
          if (person != null && _orderTotal > 0)
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
                          'Wallet: ${AppFormatters.formatPaise(walletBalance)} → ${AppFormatters.formatPaise(walletAfter)} after',
                          style: AppTypography.bodySmall.copyWith(
                            color: walletAfter < 0
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

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    for (final e in this) return e;
    return null;
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
