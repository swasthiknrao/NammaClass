import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/canteen_provider.dart';

/// Shared food/canteen screen for students, staff, and parents.
/// Shows wallet, menu, combos, subscriptions, order history, top-up.
class FoodCanteenScreen extends ConsumerStatefulWidget {
  const FoodCanteenScreen({super.key});

  @override
  ConsumerState<FoodCanteenScreen> createState() => _FoodCanteenScreenState();
}

class _FoodCanteenScreenState extends ConsumerState<FoodCanteenScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, int> _quantities = {};
  final Map<String, int> _comboQuantities = {};

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

  int _getWalletBalance() {
    final userId = ref.read(currentUserProvider)?.id;
    return walletBalanceForUser(userId);
  }

  List<MockCanteenOrderItem> _buildOrderItems() {
    final items = <MockCanteenOrderItem>[];
    for (final entry in _quantities.entries) {
      if (entry.value > 0) {
        final m = MockData.canteenMenu
            .where((x) => x.id == entry.key)
            .firstOrNull;
        if (m != null) {
          items.add(
            MockCanteenOrderItem(
              itemId: m.id,
              name: m.name,
              qty: entry.value,
              pricePaise: m.pricePaise,
            ),
          );
        }
      }
    }
    for (final entry in _comboQuantities.entries) {
      if (entry.value > 0) {
        final c = MockData.canteenCombos
            .where((x) => x.id == entry.key)
            .firstOrNull;
        if (c != null) {
          items.add(
            MockCanteenOrderItem(
              itemId: c.id,
              name: c.name,
              qty: entry.value,
              pricePaise: c.pricePaise,
            ),
          );
        }
      }
    }
    return items;
  }

  int _getOrderTotal() {
    return _buildOrderItems().fold(0, (s, i) => s + (i.pricePaise * i.qty));
  }

  void _topUp() {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;
    final pid = canonicalPersonId(userId) ?? userId;
    final w = MockData.campusWallets
        .where(
          (x) =>
              x.personId == pid ||
              (pid == 's01' && x.personId == 'usr_student_001'),
        )
        .firstOrNull;
    if (w != null) {
      w.balancePaise += 50000; // mock top-up ₹500
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Top-up of ₹500 successful!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _placeOrder() {
    final items = _buildOrderItems();
    if (items.isEmpty) return;
    final total = _getOrderTotal();
    final userId = ref.read(currentUserProvider)?.id;
    final pid = canonicalPersonId(userId) ?? userId ?? 'unknown';
    final bal = _getWalletBalance();
    if (bal < total) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient balance. Need ${AppFormatters.formatPaise(total - bal)} more. Top up to continue.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    ref.read(canteenStateProvider.notifier).addOrder(pid, items, total);
    setState(() {
      _quantities.clear();
      _comboQuantities.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Order placed! ${AppFormatters.formatPaise(total)} deducted.',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserProvider)?.id;
    final walletBalance = _getWalletBalance();
    final menuAsync = ref.watch(canteenMenuProvider);
    final orders = ordersForPerson(userId);
    final subscription = userId != null
        ? MockData.canteenSubscriptions
              .where(
                (s) =>
                    s.personId == userId ||
                    s.personId == canonicalPersonId(userId),
              )
              .firstOrNull
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Canteen & Food'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Order'),
            Tab(text: 'Combos'),
            Tab(text: 'My Meals'),
            Tab(text: 'Subscription'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Wallet card
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: NcCard(
              gradient: const LinearGradient(
                colors: AppColors.successGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Campus Wallet',
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          AppFormatters.formatPaise(walletBalance),
                          style: AppTypography.displayMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: _topUp,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                    ),
                    child: const Text('Top Up'),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OrderTab(
                  menuAsync: menuAsync,
                  quantities: _quantities,
                  onQuantityChanged: () => setState(() {}),
                  combos: MockData.canteenCombos,
                  comboQuantities: _comboQuantities,
                  onComboQuantityChanged: () => setState(() {}),
                  orderTotal: _getOrderTotal(),
                  walletBalance: walletBalance,
                  onPlaceOrder: _placeOrder,
                ),
                _CombosTab(
                  combos: MockData.canteenCombos,
                  quantities: _comboQuantities,
                  onChanged: () => setState(() {}),
                ),
                _MyMealsTab(orders: orders),
                _SubscriptionTab(
                  subscription: subscription,
                  plans: MockData.canteenSubscriptionPlans,
                ),
              ],
            ),
          ),

          if (_getOrderTotal() > 0)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.card,
              child: SafeArea(
                child: NcPrimaryButton(
                  label:
                      'Pay Online — ${AppFormatters.formatPaise(_getOrderTotal())}',
                  fullWidth: true,
                  icon: Icons.payment,
                  onPressed: _placeOrder,
                ),
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

class _OrderTab extends StatelessWidget {
  const _OrderTab({
    required this.menuAsync,
    required this.quantities,
    required this.onQuantityChanged,
    required this.combos,
    required this.comboQuantities,
    required this.onComboQuantityChanged,
    required this.orderTotal,
    required this.walletBalance,
    required this.onPlaceOrder,
  });

  final AsyncValue<List<MockCanteenItem>> menuAsync;
  final Map<String, int> quantities;
  final VoidCallback onQuantityChanged;
  final List<MockCanteenCombo> combos;
  final Map<String, int> comboQuantities;
  final VoidCallback onComboQuantityChanged;
  final int orderTotal;
  final int walletBalance;
  final VoidCallback onPlaceOrder;

  @override
  Widget build(BuildContext context) {
    return menuAsync.when(
      loading: () =>
          const Padding(padding: EdgeInsets.all(16), child: NcShimmerList()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (menu) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (combos.isNotEmpty) ...[
                Text('Combos', style: AppTypography.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: combos.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (_, i) {
                      final c = combos[i];
                      final qty = comboQuantities[c.id] ?? 0;
                      return SizedBox(
                        width: 140,
                        child: NcCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          color: c.isVeg
                              ? AppColors.success.withValues(alpha: 0.08)
                              : AppColors.error.withValues(alpha: 0.08),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                c.name,
                                style: AppTypography.labelSmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                AppFormatters.formatPaise(c.pricePaise),
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.teal,
                                  fontSize: 12,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: qty > 0
                                        ? () {
                                            comboQuantities[c.id] = qty - 1;
                                            onComboQuantityChanged();
                                          }
                                        : null,
                                    child: Icon(
                                      Icons.remove,
                                      size: 18,
                                      color: qty > 0
                                          ? AppColors.primary
                                          : AppColors.textSecondary.withValues(
                                              alpha: 0.5,
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    child: Text(
                                      '$qty',
                                      style: AppTypography.labelSmall,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      comboQuantities[c.id] = qty + 1;
                                      onComboQuantityChanged();
                                    },
                                    child: const Icon(
                                      Icons.add,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
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
                const SizedBox(height: AppSpacing.lg),
              ],
              Text('Menu', style: AppTypography.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              ...menu.map((item) {
                final qty = quantities[item.id] ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: NcCard(
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item.isVeg
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name, style: AppTypography.labelLarge),
                              Text(
                                AppFormatters.formatPaise(item.pricePaise),
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            if (qty > 0)
                              GestureDetector(
                                onTap: () {
                                  quantities[item.id] = qty - 1;
                                  onQuantityChanged();
                                },
                                child: const CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.error,
                                  child: Icon(
                                    Icons.remove,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            if (qty > 0)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  '$qty',
                                  style: AppTypography.labelLarge,
                                ),
                              ),
                            GestureDetector(
                              onTap: () {
                                quantities[item.id] = qty + 1;
                                onQuantityChanged();
                              },
                              child: const CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.primary,
                                child: Icon(
                                  Icons.add,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _CombosTab extends StatelessWidget {
  const _CombosTab({
    required this.combos,
    required this.quantities,
    required this.onChanged,
  });

  final List<MockCanteenCombo> combos;
  final Map<String, int> quantities;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: combos.length,
      itemBuilder: (_, i) {
        final c = combos[i];
        final qty = quantities[c.id] ?? 0;
        final items = c.itemIds
            .map(
              (id) =>
                  MockData.canteenMenu
                      .where((m) => m.id == id)
                      .firstOrNull
                      ?.name ??
                  id,
            )
            .join(', ');
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: NcCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: c.isVeg
                            ? AppColors.success.withValues(alpha: 0.15)
                            : AppColors.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        c.isVeg ? Icons.eco : Icons.restaurant,
                        color: c.isVeg ? AppColors.success : AppColors.error,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name, style: AppTypography.titleSmall),
                          if (c.description != null)
                            Text(
                              c.description!,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      AppFormatters.formatPaise(c.pricePaise),
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Includes: $items',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: qty > 0
                          ? () {
                              quantities[c.id] = qty - 1;
                              onChanged();
                            }
                          : null,
                    ),
                    Text('$qty', style: AppTypography.titleSmall),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        quantities[c.id] = qty + 1;
                        onChanged();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MyMealsTab extends StatelessWidget {
  const _MyMealsTab({required this.orders});

  final List<MockCanteenOrder> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No orders yet',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: orders.length,
      itemBuilder: (_, i) {
        final o = orders[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: NcCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppFormatters.shortDate(o.createdAt),
                      style: AppTypography.labelMedium,
                    ),
                    Text(
                      AppFormatters.formatPaise(o.totalPaise),
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  o.items.map((i) => '${i.name} x${i.qty}').join(', '),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SubscriptionTab extends StatelessWidget {
  const _SubscriptionTab({required this.subscription, required this.plans});

  final MockCanteenSubscription? subscription;
  final List<MockCanteenSubscriptionPlan> plans;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Subscription', style: AppTypography.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          if (subscription != null)
            NcCard(
              color: subscription!.status == 'active'
                  ? AppColors.success.withValues(alpha: 0.08)
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        subscription!.type == 'veg'
                            ? Icons.eco
                            : Icons.restaurant,
                        color: subscription!.type == 'veg'
                            ? AppColors.success
                            : AppColors.error,
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subscription!.planName,
                              style: AppTypography.labelLarge,
                            ),
                            Text(
                              '${AppFormatters.shortDate(subscription!.startDate)} — ${AppFormatters.shortDate(subscription!.endDate)}',
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
                          color: subscription!.status == 'active'
                              ? AppColors.success.withValues(alpha: 0.2)
                              : AppColors.textSecondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          subscription!.status.toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            color: subscription!.status == 'active'
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            NcCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No active subscription',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Subscribe for veg or non-veg meals and save!',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Text('Available Plans', style: AppTypography.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          ...plans.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: NcCard(
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
                          Text(
                            '${p.durationDays} days',
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
                    const SizedBox(width: AppSpacing.sm),
                    FilledButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Contact canteen to subscribe'),
                          ),
                        );
                      },
                      child: const Text('Subscribe'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
