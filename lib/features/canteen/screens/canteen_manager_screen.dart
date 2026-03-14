import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/shell_layout_scope.dart';

/// Canteen manager — menu, combos, subscriptions, online payments.
class CanteenManagerScreen extends ConsumerStatefulWidget {
  const CanteenManagerScreen({super.key});

  @override
  ConsumerState<CanteenManagerScreen> createState() =>
      _CanteenManagerScreenState();
}

class _CanteenManagerScreenState extends ConsumerState<CanteenManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayOrders = MockData.canteenOrders
        .where(
          (o) =>
              o.createdAt.year == DateTime.now().year &&
              o.createdAt.month == DateTime.now().month &&
              o.createdAt.day == DateTime.now().day,
        )
        .toList();
    final todayRevenue = todayOrders.fold<int>(0, (s, o) => s + o.totalPaise);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Canteen Manager'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'Menu (${MockData.canteenMenu.length})'),
            Tab(text: 'Combos (${MockData.canteenCombos.length})'),
            Tab(text: 'Subscriptions'),
            const Tab(text: 'Payments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MenuTab(),
          _CombosTab(),
          _SubscriptionsTab(),
          _PaymentsTab(todayOrders: todayOrders, todayRevenue: todayRevenue),
        ],
      ),
    );
  }
}

class _MenuTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categories = MockData.canteenMenu
        .map((m) => m.category)
        .toSet()
        .toList();
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: categories.length,
      itemBuilder: (_, i) {
        final cat = categories[i];
        final items = MockData.canteenMenu
            .where((m) => m.category == cat)
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cat,
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ...items.map(
              (item) => NcCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: item.isVeg ? AppColors.success : AppColors.error,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: AppTypography.labelLarge),
                          if (item.allergens.isNotEmpty)
                            Text(
                              'Allergens: ${item.allergens.join(", ")}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.warning,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      AppFormatters.formatPaise(item.pricePaise),
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.teal,
                      ),
                    ),
                    Text(
                      item.available ? 'Available' : 'Unavailable',
                      style: AppTypography.labelSmall.copyWith(
                        color: item.available
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        );
      },
    );
  }
}

class _CombosTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: MockData.canteenCombos.length,
      itemBuilder: (_, i) {
        final combo = MockData.canteenCombos[i];
        final itemNames = combo.itemIds
            .map(
              (id) => MockData.canteenMenu
                  .where((m) => m.id == id)
                  .map((m) => m.name)
                  .firstOrNull,
            )
            .whereType<String>()
            .toList();
        return NcCard(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'COMBO',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(combo.name, style: AppTypography.titleSmall),
                  ),
                  Text(
                    AppFormatters.formatPaise(combo.pricePaise),
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
              if (combo.description != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  combo.description!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (itemNames.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Includes: ${itemNames.join(", ")}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SubscriptionsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Plans (Veg / Non-Veg)', style: AppTypography.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          ...MockData.canteenSubscriptionPlans.map(
            (p) => NcCard(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: p.type == 'veg'
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      p.type == 'veg' ? Icons.eco : Icons.restaurant,
                      color: p.type == 'veg'
                          ? AppColors.success
                          : AppColors.error,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, style: AppTypography.labelLarge),
                        if (p.description != null)
                          Text(
                            p.description!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        Text(
                          '${p.durationDays} days · Student & Staff',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    AppFormatters.formatPaise(p.pricePaise),
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Active Subscriptions (${MockData.canteenSubscriptions.length})',
            style: AppTypography.titleSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...MockData.canteenSubscriptions.map(
            (s) => NcCard(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.personName, style: AppTypography.labelLarge),
                        Text(
                          '${s.planName} · ${s.type}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${AppFormatters.shortDate(s.startDate)} — ${AppFormatters.shortDate(s.endDate)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: s.status == 'active'
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.textSecondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      s.status.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: s.status == 'active'
                            ? AppColors.success
                            : AppColors.textSecondary,
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

class _PaymentsTab extends StatelessWidget {
  const _PaymentsTab({required this.todayOrders, required this.todayRevenue});
  final List<MockCanteenOrder> todayOrders;
  final int todayRevenue;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: NcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Orders",
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${todayOrders.length}',
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.primary,
                          fontFamily: 'JetBrainsMono',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: NcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Revenue",
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        AppFormatters.formatPaise(todayRevenue),
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.success,
                          fontFamily: 'JetBrainsMono',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Recent Online Payments', style: AppTypography.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          if (todayOrders.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Text('No orders today yet'),
              ),
            )
          else
            ...todayOrders
                .take(15)
                .map(
                  (o) => NcCard(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                o.personName,
                                style: AppTypography.labelLarge,
                              ),
                              Text(
                                o.items
                                    .map((i) => '${i.name} x${i.qty}')
                                    .join(', '),
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                AppFormatters.timeAgo(o.createdAt),
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          AppFormatters.formatPaise(o.totalPaise),
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.teal,
                            fontFamily: 'JetBrainsMono',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Icon(
                          o.paymentStatus == 'paid'
                              ? Icons.check_circle
                              : Icons.pending,
                          color: o.paymentStatus == 'paid'
                              ? AppColors.success
                              : AppColors.warning,
                          size: 20,
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
