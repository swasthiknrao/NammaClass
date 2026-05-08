import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';

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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant_menu, size: 24, color: scheme.onPrimary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Canteen manager',
                  style: AppTypography.titleMedium.copyWith(
                    color: scheme.onPrimary,
                  ),
                ),
              ],
            ),
            Text(
              'Menu overview, plans, and today’s sales',
              style: AppTypography.bodySmall.copyWith(
                color: scheme.onPrimary.withValues(alpha: 0.88),
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: scheme.onPrimary,
          unselectedLabelColor: scheme.onPrimary.withValues(alpha: 0.65),
          indicatorColor: scheme.onPrimary,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.grid_view_rounded, size: 18),
                  const SizedBox(width: 6),
                  Text('Menu (${MockData.canteenMenu.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_offer_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text('Combos (${MockData.canteenCombos.length})'),
                ],
              ),
            ),
            const Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.subscriptions_outlined, size: 18),
                  SizedBox(width: 6),
                  Text('Plans'),
                ],
              ),
            ),
            const Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.payments_outlined, size: 18),
                  SizedBox(width: 6),
                  Text('Payments'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _MenuTab(),
          const _CombosTab(),
          const _SubscriptionsTab(),
          _PaymentsTab(todayOrders: todayOrders, todayRevenue: todayRevenue),
        ],
      ),
    );
  }
}

class _MenuTab extends StatelessWidget {
  const _MenuTab();

  @override
  Widget build(BuildContext context) {
    final categories =
        MockData.canteenMenu.map((m) => m.category).toSet().toList()..sort();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: _SectionIntro(
              icon: Icons.inventory_2_outlined,
              title: 'Food & beverages',
              subtitle:
                  '${MockData.canteenMenu.length} items across ${categories.length} categories',
            ),
          ),
        ),
        ...categories.expand((cat) {
          final items = MockData.canteenMenu
              .where((m) => m.category == cat)
              .toList();
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.12),
                            AppColors.teal.withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        _categoryIcon(cat),
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      cat,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${items.length}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  final item = items[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _ManagerMenuItemCard(item: item),
                  );
                }, childCount: items.length),
              ),
            ),
          ];
        }),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
      ],
    );
  }
}

class _ManagerMenuItemCard extends StatelessWidget {
  const _ManagerMenuItemCard({required this.item});

  final MockCanteenItem item;

  @override
  Widget build(BuildContext context) {
    final accent = item.isVeg ? AppColors.success : AppColors.error;
    return Material(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(AppRadius.md),
      color: AppColors.card,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppRadius.md),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: AppTypography.labelLarge),
                          if (item.allergens.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Allergens: ${item.allergens.join(", ")}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppFormatters.formatPaise(item.pricePaise),
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.teal,
                            fontFamily: 'JetBrainsMono',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: item.available
                                ? AppColors.successBg
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.12,
                                  ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.available
                                    ? Icons.check_circle_outline
                                    : Icons.pause_circle_outline,
                                size: 14,
                                color: item.available
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.available ? 'Available' : 'Off menu',
                                style: AppTypography.labelSmall.copyWith(
                                  color: item.available
                                      ? AppColors.success
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

class _CombosTab extends StatelessWidget {
  const _CombosTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: _SectionIntro(
              icon: Icons.celebration_outlined,
              title: 'Combo deals',
              subtitle:
                  'Bundled meals at special prices — synced with the counter',
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, i) {
              final combo = MockData.canteenCombos[i];
              final itemNames = combo.itemIds
                  .map(
                    (id) => MockData.canteenMenu
                        .where((m) => m.id == id)
                        .map((m) => m.name)
                        .firstOrNullIterable,
                  )
                  .whereType<String>()
                  .toList();
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _ManagerComboCard(combo: combo, itemNames: itemNames),
              );
            }, childCount: MockData.canteenCombos.length),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
      ],
    );
  }
}

class _ManagerComboCard extends StatelessWidget {
  const _ManagerComboCard({required this.combo, required this.itemNames});

  final MockCanteenCombo combo;
  final List<String> itemNames;

  @override
  Widget build(BuildContext context) {
    final tint = combo.isVeg
        ? AppColors.success.withValues(alpha: 0.08)
        : AppColors.error.withValues(alpha: 0.08);
    return Material(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(AppRadius.md),
      color: AppColors.card,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [tint, AppColors.card],
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accent.withValues(alpha: 0.2),
                        AppColors.accent.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'COMBO',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  AppFormatters.formatPaise(combo.pricePaise),
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.teal,
                    fontFamily: 'JetBrainsMono',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(combo.name, style: AppTypography.titleSmall),
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
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: itemNames
                    .map(
                      (n) => Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(n, style: AppTypography.labelSmall),
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.06,
                        ),
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 0,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SubscriptionsTab extends StatelessWidget {
  const _SubscriptionsTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: _SectionIntro(
              icon: Icons.card_membership_outlined,
              title: 'Meal plans',
              subtitle: 'Veg & non-veg subscriptions for students and staff',
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'Published plans',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, i) {
              final p = MockData.canteenSubscriptionPlans[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _PlanOfferCard(plan: p),
              );
            }, childCount: MockData.canteenSubscriptionPlans.length),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text(
              'Active subscribers (${MockData.canteenSubscriptions.length})',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, i) {
              final s = MockData.canteenSubscriptions[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _SubscriberRow(subscription: s),
              );
            }, childCount: MockData.canteenSubscriptions.length),
          ),
        ),
      ],
    );
  }
}

class _PlanOfferCard extends StatelessWidget {
  const _PlanOfferCard({required this.plan});

  final MockCanteenSubscriptionPlan plan;

  @override
  Widget build(BuildContext context) {
    final veg = plan.type == 'veg';
    final iconBg = veg
        ? AppColors.success.withValues(alpha: 0.15)
        : AppColors.error.withValues(alpha: 0.15);
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(AppRadius.md),
      color: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                veg ? Icons.eco : Icons.restaurant,
                color: veg ? AppColors.success : AppColors.error,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.name, style: AppTypography.labelLarge),
                  if (plan.description != null)
                    Text(
                      plan.description!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  Text(
                    '${plan.durationDays} days · Student & staff',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              AppFormatters.formatPaise(plan.pricePaise),
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.teal,
                fontFamily: 'JetBrainsMono',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriberRow extends StatelessWidget {
  const _SubscriberRow({required this.subscription});

  final MockCanteenSubscription subscription;

  @override
  Widget build(BuildContext context) {
    final active = subscription.status == 'active';
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(AppRadius.md),
      color: AppColors.card,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: Text(
            subscription.personName.isNotEmpty
                ? subscription.personName[0].toUpperCase()
                : '?',
            style: AppTypography.titleSmall.copyWith(color: AppColors.primary),
          ),
        ),
        title: Text(subscription.personName, style: AppTypography.labelLarge),
        subtitle: Text(
          '${subscription.planName} · ${subscription.type}\n'
          '${AppFormatters.shortDate(subscription.startDate)} — ${AppFormatters.shortDate(subscription.endDate)}',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? AppColors.successBg
                : AppColors.textSecondary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            subscription.status.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: active ? AppColors.success : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
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
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: _SectionIntro(
              icon: Icons.analytics_outlined,
              title: 'Today at a glance',
              subtitle: 'Orders and revenue from all counters',
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: _KpiTile(
                    gradient: [
                      AppColors.primary.withValues(alpha: 0.85),
                      AppColors.teal.withValues(alpha: 0.75),
                    ],
                    icon: Icons.receipt_long,
                    label: 'Orders today',
                    value: '${todayOrders.length}',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _KpiTile(
                    gradient: [
                      AppColors.success.withValues(alpha: 0.9),
                      AppColors.teal.withValues(alpha: 0.65),
                    ],
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Revenue today',
                    value: AppFormatters.formatPaise(todayRevenue),
                    valueIsMoney: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  size: 20,
                  color: AppColors.primary.withValues(alpha: 0.8),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Recent activity',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (todayOrders.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.coffee_outlined,
                      size: 56,
                      color: AppColors.textSecondary.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No orders yet today',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Sales from the counter will show up here.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, i) {
                final o = todayOrders[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _PaymentOrderRow(order: o),
                );
              }, childCount: todayOrders.length > 15 ? 15 : todayOrders.length),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
      ],
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.gradient,
    required this.icon,
    required this.label,
    required this.value,
    this.valueIsMoney = false,
  });

  final List<Color> gradient;
  final IconData icon;
  final String label;
  final String value;
  final bool valueIsMoney;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      shadowColor: gradient.first.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.95), size: 26),
            const SizedBox(height: AppSpacing.md),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style:
                  (valueIsMoney
                          ? AppTypography.headlineSmall
                          : AppTypography.headlineMedium)
                      .copyWith(
                        color: Colors.white,
                        fontFamily: 'JetBrainsMono',
                        fontWeight: FontWeight.w600,
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentOrderRow extends StatelessWidget {
  const _PaymentOrderRow({required this.order});

  final MockCanteenOrder order;

  @override
  Widget build(BuildContext context) {
    final paid = order.paymentStatus == 'paid';
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(AppRadius.md),
      color: AppColors.card,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.teal.withValues(alpha: 0.12),
          child: Icon(Icons.restaurant, color: AppColors.teal, size: 22),
        ),
        title: Text(order.personName, style: AppTypography.labelLarge),
        subtitle: Text(
          '${order.items.map((i) => '${i.name} ×${i.qty}').join(', ')}\n'
          '${AppFormatters.timeAgo(order.createdAt)}',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppFormatters.formatPaise(order.totalPaise),
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.teal,
                fontFamily: 'JetBrainsMono',
              ),
            ),
            Icon(
              paid ? Icons.check_circle : Icons.pending_outlined,
              size: 18,
              color: paid ? AppColors.success : AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionIntro extends StatelessWidget {
  const _SectionIntro({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.teal.withValues(alpha: 0.05),
            AppColors.background,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [AppColors.shadowSm],
            ),
            child: Icon(icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleSmall),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
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

IconData _categoryIcon(String category) {
  switch (category) {
    case 'Breakfast':
      return Icons.free_breakfast;
    case 'Lunch':
      return Icons.lunch_dining;
    case 'Snacks':
      return Icons.fastfood_outlined;
    case 'Beverages':
      return Icons.local_cafe_outlined;
    default:
      return Icons.restaurant_menu_outlined;
  }
}

extension _FirstOrNullIterable<E> on Iterable<E> {
  E? get firstOrNullIterable {
    for (final e in this) {
      return e;
    }
    return null;
  }
}
