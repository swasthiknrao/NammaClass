import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../providers/parent_providers.dart';

class CanteenScreen extends ConsumerStatefulWidget {
  const CanteenScreen({super.key});

  @override
  ConsumerState<CanteenScreen> createState() => _CanteenScreenState();
}

class _CanteenScreenState extends ConsumerState<CanteenScreen> {
  final Map<String, int> _quantities = {};
  final double _walletBalance = 350.0;

  @override
  Widget build(BuildContext context) {
    final menuAsync = ref.watch(parentCanteenMenuProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Canteen & Campus Wallet')),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Wallet balance card
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
                          AppFormatters.formatRupees(_walletBalance),
                          style: AppTypography.displayMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {},
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

          // Menu list
          Expanded(
            child: menuAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: NcShimmerList(),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (menu) {
                final categories = menu.map((m) => m.category).toSet().toList();
                return DefaultTabController(
                  length: categories.length,
                  child: Column(
                    children: [
                      TabBar(
                        isScrollable: true,
                        tabs: categories.map((c) => Tab(text: c)).toList(),
                        tabAlignment: TabAlignment.start,
                      ),
                      Expanded(
                        child: TabBarView(
                          children: categories.map((cat) {
                            final items = menu
                                .where((m) => m.category == cat)
                                .toList();
                            return ListView.builder(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              itemCount: items.length,
                              itemBuilder: (ctx, i) {
                                final item = items[i];
                                final qty = _quantities[item.id] ?? 0;
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.sm,
                                  ),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name,
                                                style: AppTypography.labelLarge,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    AppFormatters.formatPaise(
                                                      item.pricePaise,
                                                    ),
                                                    style: AppTypography
                                                        .labelMedium
                                                        .copyWith(
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                  ),
                                                  ...item.allergens.map(
                                                    (a) => Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            left: 4,
                                                          ),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 4,
                                                              vertical: 1,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: AppColors
                                                              .warningBg,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                4,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          a,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 9,
                                                                color: AppColors
                                                                    .warning,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Quantity stepper
                                        Row(
                                          children: [
                                            if (qty > 0) ...[
                                              GestureDetector(
                                                onTap: () => setState(
                                                  () => _quantities[item.id] =
                                                      qty - 1,
                                                ),
                                                child: const CircleAvatar(
                                                  radius: 14,
                                                  backgroundColor:
                                                      AppColors.error,
                                                  child: Icon(
                                                    Icons.remove,
                                                    size: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                    ),
                                                child: Text(
                                                  '$qty',
                                                  style:
                                                      AppTypography.labelLarge,
                                                ),
                                              ),
                                            ],
                                            GestureDetector(
                                              onTap: () => setState(
                                                () => _quantities[item.id] =
                                                    qty + 1,
                                              ),
                                              child: const CircleAvatar(
                                                radius: 14,
                                                backgroundColor:
                                                    AppColors.primary,
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
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Pre-order footer
          if (_quantities.values.any((q) => q > 0))
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.card,
              child: NcPrimaryButton(
                label:
                    'Pre-Order (${_quantities.values.fold(0, (a, b) => a + b)} items)',
                fullWidth: true,
                icon: Icons.shopping_cart,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order placed successfully!')),
                  );
                  setState(() => _quantities.clear());
                },
              ),
            ),
        ],
      ),
    );
  }
}
