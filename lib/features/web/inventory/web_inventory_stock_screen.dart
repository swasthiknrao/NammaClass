import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';

class WebInventoryStockScreen extends ConsumerStatefulWidget {
  const WebInventoryStockScreen({super.key});

  @override
  ConsumerState<WebInventoryStockScreen> createState() =>
      _WebInventoryStockScreenState();
}

class _WebInventoryStockScreenState
    extends ConsumerState<WebInventoryStockScreen>
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

  final _stock = [
    _StockItem('A4 Paper', 'Stationery', 48, 'Reams', 50, 4200),
    _StockItem('Blue Pen (Box)', 'Stationery', 12, 'Boxes', 10, 850),
    _StockItem('Whiteboard Marker', 'Stationery', 5, 'Boxes', 10, 300),
    _StockItem('Hand Sanitizer (1L)', 'Cleaning', 25, 'Bottles', 20, 1800),
    _StockItem('Sodium Chloride', 'Lab', 2, 'kg', 5, 120),
    _StockItem('Football', 'Sports', 8, 'Nos', 5, 2400),
  ];

  final _pos = [
    _PO('PO-2026-001', 'Sri Traders', 4, 12500, 'Received'),
    _PO('PO-2026-002', 'Lab Supplies Co.', 2, 4800, 'Partial'),
    _PO('PO-2026-003', 'Sports Arena', 6, 15000, 'Draft'),
  ];

  final _vendors = [
    ('Sri Traders', 'Ravi Kumar', 'Stationery, Cleaning', '₹45,000', '★ 4.5'),
    ('Lab Supplies Co.', 'Meena S', 'Lab', '₹12,000', '★ 4.2'),
    ('Sports Arena', 'Ajay P', 'Sports', '₹32,000', '★ 4.8'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Consumable Stock & Purchases',
                style: AppTypography.headlineMedium,
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Create PO'),
              ),
            ],
          ),
        ),
        TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Stock'),
            Tab(text: 'Purchase Orders'),
            Tab(text: 'Vendors'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _StockTable(_stock),
              _POTable(_pos),
              _VendorTable(_vendors),
            ],
          ),
        ),
      ],
    );
  }
}

class _StockItem {
  _StockItem(
    this.name,
    this.category,
    this.qty,
    this.unit,
    this.reorder,
    this.value,
  );
  final String name;
  final String category;
  final int qty;
  final String unit;
  final int reorder;
  final int value;
}

class _PO {
  _PO(this.number, this.vendor, this.items, this.total, this.status);
  final String number;
  final String vendor;
  final int items;
  final int total;
  final String status;
}

class _StockTable extends StatelessWidget {
  const _StockTable(this.items);
  final List<_StockItem> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: NcCard(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              color: AppColors.background,
              child: Row(
                children: const [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Item',
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
                      'Qty',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Reorder',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Value',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Actions',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            ...items.map((item) {
              final isLow = item.qty <= item.reorder;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isLow
                      ? AppColors.warning.withValues(alpha: 0.05)
                      : null,
                  border: const Border(
                    bottom: BorderSide(color: AppColors.divider),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Text(item.name, style: AppTypography.labelMedium),
                          if (isLow) ...[
                            const SizedBox(width: 4),
                            const NcChip(
                              label: 'Low Stock',
                              color: AppColors.warning,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Expanded(flex: 2, child: Text(item.category)),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${item.qty} ${item.unit}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: isLow ? AppColors.warning : null,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Min: ${item.reorder}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        AppFormatters.currency(item.value),
                        style: AppTypography.labelMedium.copyWith(
                          fontFamily: 'JetBrainsMono',
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                            child: const Text('Receive'),
                          ),
                          const SizedBox(width: 4),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                            child: const Text('Issue'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _POTable extends StatelessWidget {
  const _POTable(this.pos);
  final List<_PO> pos;

  Color _statusColor(String s) {
    switch (s) {
      case 'Received':
        return AppColors.success;
      case 'Partial':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: NcCard(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              color: AppColors.background,
              child: Row(
                children: const [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'PO Number',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Vendor',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Items',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Total Value',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Status',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Actions',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            ...pos.map(
              (po) => Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.divider)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        po.number,
                        style: AppTypography.labelMedium.copyWith(
                          fontFamily: 'JetBrainsMono',
                        ),
                      ),
                    ),
                    Expanded(flex: 3, child: Text(po.vendor)),
                    Expanded(flex: 2, child: Text('${po.items} items')),
                    Expanded(
                      flex: 2,
                      child: Text(
                        AppFormatters.currency(po.total),
                        style: AppTypography.labelMedium.copyWith(
                          fontFamily: 'JetBrainsMono',
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: NcChip(
                        label: po.status,
                        color: _statusColor(po.status),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility, size: 18),
                            onPressed: () {},
                            tooltip: 'View',
                          ),
                          IconButton(
                            icon: const Icon(Icons.print, size: 18),
                            onPressed: () {},
                            tooltip: 'Print',
                          ),
                        ],
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
}

class _VendorTable extends StatelessWidget {
  const _VendorTable(this.vendors);
  final List<(String, String, String, String, String)> vendors;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: NcCard(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              color: AppColors.background,
              child: Row(
                children: const [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Vendor',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Contact',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Categories',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Total Purchases',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Rating',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            ...vendors.map(
              (v) => Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.divider)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(v.$1, style: AppTypography.labelMedium),
                    ),
                    Expanded(flex: 2, child: Text(v.$2)),
                    Expanded(
                      flex: 3,
                      child: Text(
                        v.$3,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        v.$4,
                        style: AppTypography.labelMedium.copyWith(
                          fontFamily: 'JetBrainsMono',
                          color: AppColors.teal,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        v.$5,
                        style: const TextStyle(color: AppColors.accent),
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
}
