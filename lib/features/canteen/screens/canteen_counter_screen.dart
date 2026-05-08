import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/providers/data_sync_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_avatar.dart';
import '../../../core/widgets/nc_card.dart';
import '../providers/canteen_provider.dart';
import 'canteen_counter_catalog_screen.dart';

const double _kPosBreakpoint = 900;

class CanteenCounterScreen extends ConsumerStatefulWidget {
  const CanteenCounterScreen({super.key});

  @override
  ConsumerState<CanteenCounterScreen> createState() =>
      _CanteenCounterScreenState();
}

class _CanteenCounterScreenState extends ConsumerState<CanteenCounterScreen> {
  final TextEditingController _lookupController = TextEditingController();
  final Map<String, int> _adHocOrder = {};
  String? _selectedCategory;

  List<MockCanteenItem> get _saleMenuItems =>
      MockData.canteenMenu.where((m) => m.available).toList();

  List<MockCanteenCombo> get _saleCombos =>
      MockData.canteenCombos.where((c) => c.available).toList();

  List<String> get _categories {
    final set = _saleMenuItems.map((m) => m.category).toSet().toList()..sort();
    return set;
  }

  List<MockCanteenItem> get _filteredMenu {
    final base = _saleMenuItems;
    final cat = _selectedCategory;
    if (cat == null) return base;
    return base.where((m) => m.category == cat).toList();
  }

  int get _cartItemCount => _adHocOrder.values.fold(0, (a, b) => a + b);

  int _priceForId(String id) {
    final menuItem = MockData.canteenMenu.where((m) => m.id == id).firstOrNull;
    if (menuItem != null) return menuItem.pricePaise;
    final combo = MockData.canteenCombos.where((c) => c.id == id).firstOrNull;
    if (combo != null) return combo.pricePaise;
    return 0;
  }

  String _nameForId(String id) {
    final menuItem = MockData.canteenMenu.where((m) => m.id == id).firstOrNull;
    if (menuItem != null) return menuItem.name;
    final combo = MockData.canteenCombos.where((c) => c.id == id).firstOrNull;
    if (combo != null) return combo.name;
    return id;
  }

  int get _orderTotal => _adHocOrder.entries.fold(0, (sum, e) {
    return sum + (_priceForId(e.key) * e.value);
  });

  bool get _isWalkInSale {
    final p = ref.read(canteenStateProvider).scannedPerson;
    return p == null || p.personId == kCanteenWalkInPersonId;
  }

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
            'No person found for "$query". Try ID, roll no, or name.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _simulateLookup() {
    _lookupController.text = 's01';
    _lookupPerson();
  }

  void _setGuestCash() {
    ref
        .read(canteenStateProvider.notifier)
        .setScannedPerson(canteenWalkInGuest());
    setState(() {});
  }

  void _clearCustomer() {
    ref.read(canteenStateProvider.notifier).clearScannedPerson();
    _lookupController.clear();
    _adHocOrder.clear();
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

  void _clearLine(String id) {
    setState(() => _adHocOrder.remove(id));
  }

  void _charge() {
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

    final person = ref.read(canteenStateProvider).scannedPerson;
    final walkIn = person == null || person.personId == kCanteenWalkInPersonId;
    final personId = person?.personId ?? kCanteenWalkInPersonId;

    if (!walkIn) {
      final walletAfter = person.walletBalancePaise - _orderTotal;
      if (walletAfter < 0) {
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Insufficient balance'),
            content: Text(
              'Short by ${AppFormatters.formatPaise(-walletAfter)}. Ask customer to top up or use Guest (cash).',
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
    }

    final title = walkIn ? 'Record cash sale' : 'Charge wallet';
    final body = walkIn
        ? 'Record ${AppFormatters.formatPaise(_orderTotal)} as cash at counter?'
        : 'Charge ${AppFormatters.formatPaise(_orderTotal)} from ${person.personName}\'s wallet?';

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
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
                  .addOrder(personId, items, _orderTotal);
              setState(() => _adHocOrder.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    walkIn
                        ? 'Cash sale ${AppFormatters.formatPaise(_orderTotal)} recorded.'
                        : 'Wallet charged ${AppFormatters.formatPaise(_orderTotal)}.',
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

  void _openCatalog() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (ctx) => const CanteenCounterCatalogScreen(),
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

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Daily summary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SummaryRow('Total orders', '${todayOrders.length}'),
            _SummaryRow('Total revenue', AppFormatters.formatPaise(revenue)),
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

  void _openCartSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.58,
          minChildSize: 0.35,
          maxChildSize: 0.94,
          expand: false,
          builder: (_, scrollController) {
            return _TicketPanel(
              scrollController: scrollController,
              person: ref.watch(canteenStateProvider).scannedPerson,
              orderEntries: _adHocOrder.entries
                  .where((e) => e.value > 0)
                  .toList(),
              orderTotal: _orderTotal,
              isWalkInSale: _isWalkInSale,
              priceForId: _priceForId,
              nameForId: _nameForId,
              onRemoveOne: _removeItem,
              onClearLine: _clearLine,
              onPay: () {
                Navigator.pop(ctx);
                _charge();
              },
              onClearCustomer: _clearCustomer,
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _lookupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(dataSyncProvider);
    final canteenState = ref.watch(canteenStateProvider);
    final person = canteenState.scannedPerson;
    final walletBalance = person?.walletBalancePaise ?? 0;
    final walletAfter = walletBalance - _orderTotal;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _kPosBreakpoint;

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 64,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
            actionsIconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                    AppColors.teal,
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.point_of_sale,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Canteen counter',
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Point of sale · pick items & pay',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: _openCatalog,
                icon: const Icon(Icons.storefront_outlined),
                tooltip: 'Kitchen & menu',
              ),
              IconButton(
                onPressed: _showDailySummary,
                icon: const Icon(Icons.insights_outlined),
                tooltip: 'Daily summary',
              ),
            ],
          ),
          floatingActionButton: !wide && _cartItemCount > 0
              ? FloatingActionButton.extended(
                  onPressed: _openCartSheet,
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  icon: Badge(
                    backgroundColor: AppColors.primary,
                    label: Text(
                      '$_cartItemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Icon(Icons.receipt_long),
                  ),
                  label: Text(AppFormatters.formatPaise(_orderTotal)),
                )
              : null,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.teal.withValues(alpha: 0.07),
                  AppColors.background,
                  AppColors.background,
                ],
                stops: const [0.0, 0.22, 1.0],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CustomerStrip(
                  controller: _lookupController,
                  person: person,
                  onLookup: _lookupPerson,
                  onGuestCash: _setGuestCash,
                  onClear: _clearCustomer,
                  onSimulate: _simulateLookup,
                ),
                Expanded(
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 58,
                              child: _MenuPane(
                                categories: _categories,
                                selectedCategory: _selectedCategory,
                                onCategorySelected: (c) {
                                  setState(() => _selectedCategory = c);
                                },
                                combos: _saleCombos,
                                menuItems: _filteredMenu,
                                adHocOrder: _adHocOrder,
                                onAdd: _addItem,
                                onRemove: _removeItem,
                              ),
                            ),
                            VerticalDivider(
                              width: 1,
                              thickness: 1,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.15,
                              ),
                            ),
                            Expanded(
                              flex: 42,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerRight,
                                    end: Alignment.centerLeft,
                                    colors: [
                                      AppColors.card,
                                      AppColors.primary.withValues(alpha: 0.04),
                                      AppColors.teal.withValues(alpha: 0.06),
                                    ],
                                    stops: const [0.0, 0.55, 1.0],
                                  ),
                                ),
                                child: _TicketPanel(
                                  person: person,
                                  orderEntries: _adHocOrder.entries
                                      .where((e) => e.value > 0)
                                      .toList(),
                                  orderTotal: _orderTotal,
                                  walletBalance: walletBalance,
                                  walletAfter: walletAfter,
                                  isWalkInSale: _isWalkInSale,
                                  priceForId: _priceForId,
                                  nameForId: _nameForId,
                                  onRemoveOne: _removeItem,
                                  onClearLine: _clearLine,
                                  onPay: _charge,
                                  onClearCustomer: _clearCustomer,
                                ),
                              ),
                            ),
                          ],
                        )
                      : _MenuPane(
                          categories: _categories,
                          selectedCategory: _selectedCategory,
                          onCategorySelected: (c) {
                            setState(() => _selectedCategory = c);
                          },
                          combos: _saleCombos,
                          menuItems: _filteredMenu,
                          adHocOrder: _adHocOrder,
                          onAdd: _addItem,
                          onRemove: _removeItem,
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

class _CustomerStrip extends StatelessWidget {
  const _CustomerStrip({
    required this.controller,
    required this.person,
    required this.onLookup,
    required this.onGuestCash,
    required this.onClear,
    required this.onSimulate,
  });

  final TextEditingController controller;
  final CanteenPersonInfo? person;
  final VoidCallback onLookup;
  final VoidCallback onGuestCash;
  final VoidCallback onClear;
  final VoidCallback onSimulate;

  @override
  Widget build(BuildContext context) {
    final isGuest =
        person != null && person!.personId == kCanteenWalkInPersonId;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: AppColors.teal.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.12),
                        AppColors.teal.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.person_search_rounded,
                    size: 22,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Find account or guest checkout',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onSimulate,
                  icon: const Icon(Icons.bolt_outlined, size: 18),
                  label: const Text('Demo'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'ID, roll no, or name',
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    onSubmitted: (_) => onLookup(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton(onPressed: onLookup, child: const Text('Find')),
                const SizedBox(width: AppSpacing.sm),
                FilterChip(
                  label: const Text('Guest (cash)'),
                  selected: isGuest,
                  onSelected: (_) => onGuestCash(),
                  selectedColor: AppColors.accent.withValues(alpha: 0.22),
                  checkmarkColor: AppColors.accent,
                  avatar: Icon(
                    Icons.payments_rounded,
                    size: 18,
                    color: isGuest ? AppColors.accent : AppColors.primary,
                  ),
                ),
                if (person != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  IconButton(
                    onPressed: onClear,
                    tooltip: 'Clear customer & cart',
                    icon: const Icon(Icons.close),
                  ),
                ],
              ],
            ),
            if (person != null &&
                person!.personId != kCanteenWalkInPersonId) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  NcAvatar(name: person!.personName, radius: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person!.personName,
                          style: AppTypography.labelLarge,
                        ),
                        Text(
                          '${person!.info} · Wallet ${AppFormatters.formatPaise(person!.walletBalancePaise)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (person!.subscription != null &&
                      person!.subscription!.status == 'active')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        person!.subscription!.planName,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CounterMenuBanner extends StatelessWidget {
  const _CounterMenuBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.teal.withValues(alpha: 0.06),
            AppColors.card,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
        boxShadow: [AppColors.shadowSm],
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
            child: Icon(
              Icons.restaurant_menu,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today’s menu',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Categories below · add items to the ticket on the right',
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

class _MenuPane extends StatelessWidget {
  const _MenuPane({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.combos,
    required this.menuItems,
    required this.adHocOrder,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> categories;
  final String? selectedCategory;
  final void Function(String?) onCategorySelected;
  final List<MockCanteenCombo> combos;
  final List<MockCanteenItem> menuItems;
  final Map<String, int> adHocOrder;
  final void Function(String id) onAdd;
  final void Function(String id) onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _CounterMenuBanner()),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 46,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: ChoiceChip(
                      label: const Text('All'),
                      selected: selectedCategory == null,
                      onSelected: (_) => onCategorySelected(null),
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: selectedCategory == null
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: selectedCategory == null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  ...categories.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.xs),
                      child: ChoiceChip(
                        avatar: Icon(_categoryIcon(c), size: 18),
                        label: Text(c),
                        selected: selectedCategory == c,
                        onSelected: (_) => onCategorySelected(c),
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: selectedCategory == c
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontWeight: selectedCategory == c
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (combos.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_offer_outlined,
                      size: 20,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      "Today's specials",
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (combos.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 118,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  itemCount: combos.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (_, i) {
                    final c = combos[i];
                    final qty = adHocOrder[c.id] ?? 0;
                    return _ComboCard(
                      combo: c,
                      qty: qty,
                      onAdd: () => onAdd(c.id),
                      onRemove: () => onRemove(c.id),
                    );
                  },
                ),
              ),
            ),
          if (menuItems.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'No items in this category. Use the menu icon in the app bar to add items.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.82,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                ),
                delegate: SliverChildBuilderDelegate((context, i) {
                  final item = menuItems[i];
                  final qty = adHocOrder[item.id] ?? 0;
                  return _MenuTileCard(
                    item: item,
                    qty: qty,
                    onAdd: () => onAdd(item.id),
                    onRemove: () => onRemove(item.id),
                  );
                }, childCount: menuItems.length),
              ),
            ),
        ],
      ),
    );
  }
}

class _ComboCard extends StatelessWidget {
  const _ComboCard({
    required this.combo,
    required this.qty,
    required this.onAdd,
    required this.onRemove,
  });

  final MockCanteenCombo combo;
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 172,
      child: NcCard(
        color: combo.isVeg
            ? AppColors.success.withValues(alpha: 0.07)
            : AppColors.error.withValues(alpha: 0.07),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.35),
          width: 1,
        ),
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'COMBO',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Expanded(
              child: Text(
                combo.name,
                style: AppTypography.labelMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              AppFormatters.formatPaise(combo.pricePaise),
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.teal,
                fontFamily: 'JetBrainsMono',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 22),
                  onPressed: qty > 0 ? onRemove : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
                Text('$qty', style: AppTypography.titleSmall),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 22),
                  onPressed: onAdd,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTileCard extends StatelessWidget {
  const _MenuTileCard({
    required this.item,
    required this.qty,
    required this.onAdd,
    required this.onRemove,
  });

  final MockCanteenItem item;
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final gradBegin = item.isVeg
        ? AppColors.success.withValues(alpha: 0.12)
        : AppColors.error.withValues(alpha: 0.1);
    final gradEnd = AppColors.card;

    return Material(
      elevation: 3,
      shadowColor: AppColors.primary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gradBegin, gradEnd],
          ),
          border: Border.all(color: AppColors.teal.withValues(alpha: 0.12)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    _categoryIcon(item.category),
                    size: 20,
                    color: AppColors.primary.withValues(alpha: 0.85),
                  ),
                  const Spacer(),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item.isVeg ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Expanded(
                child: Text(
                  item.name,
                  style: AppTypography.labelMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                AppFormatters.formatPaise(item.pricePaise),
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.teal,
                  fontFamily: 'JetBrainsMono',
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              if (qty == 0)
                FilledButton.tonal(
                  onPressed: onAdd,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(36),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.add, size: 20),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: onRemove,
                      icon: const Icon(Icons.remove, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text('$qty', style: AppTypography.titleMedium),
                    ),
                    IconButton(
                      onPressed: onAdd,
                      icon: const Icon(Icons.add, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketPanel extends StatelessWidget {
  const _TicketPanel({
    this.scrollController,
    required this.person,
    required this.orderEntries,
    required this.orderTotal,
    this.walletBalance = 0,
    this.walletAfter = 0,
    required this.isWalkInSale,
    required this.priceForId,
    required this.nameForId,
    required this.onRemoveOne,
    required this.onClearLine,
    required this.onPay,
    required this.onClearCustomer,
  });

  final ScrollController? scrollController;
  final CanteenPersonInfo? person;
  final List<MapEntry<String, int>> orderEntries;
  final int orderTotal;
  final int walletBalance;
  final int walletAfter;
  final bool isWalkInSale;
  final int Function(String id) priceForId;
  final String Function(String id) nameForId;
  final void Function(String id) onRemoveOne;
  final void Function(String id) onClearLine;
  final VoidCallback onPay;
  final VoidCallback onClearCustomer;

  @override
  Widget build(BuildContext context) {
    final listView = ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Row(
          children: [
            Icon(
              Icons.receipt_long,
              color: AppColors.primary.withValues(alpha: 0.9),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Order ticket',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (person == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              'Cash sale — no wallet. Or find a customer / Guest (cash).',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else if (person!.personId == kCanteenWalkInPersonId)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: AppColors.accent.withValues(alpha: 0.2),
              child: Icon(Icons.payments_outlined, color: AppColors.accent),
            ),
            title: Text(person!.personName, style: AppTypography.labelLarge),
            subtitle: Text(
              person!.info,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: NcAvatar(name: person!.personName, radius: 22),
            title: Text(person!.personName, style: AppTypography.labelLarge),
            subtitle: Text(
              'Wallet ${AppFormatters.formatPaise(walletBalance)}'
              '${orderTotal > 0 ? ' → ${AppFormatters.formatPaise(walletAfter)} after' : ''}',
              style: AppTypography.bodySmall.copyWith(
                color: walletAfter < 0 && orderTotal > 0
                    ? AppColors.error
                    : AppColors.textSecondary,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 20),
              tooltip: 'Clear customer',
              onPressed: onClearCustomer,
            ),
          ),
        const Divider(),
        if (orderEntries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: Text(
                'No items yet.\nAdd from the menu.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ...orderEntries.map((e) {
            final line = priceForId(e.key) * e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Material(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nameForId(e.key),
                              style: AppTypography.labelMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${AppFormatters.formatPaise(priceForId(e.key))} × ${e.value}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontFamily: 'JetBrainsMono',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        AppFormatters.formatPaise(line),
                        style: AppTypography.labelLarge.copyWith(
                          fontFamily: 'JetBrainsMono',
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: () => onRemoveOne(e.key),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: AppColors.error.withValues(alpha: 0.8),
                            ),
                            onPressed: () => onClearLine(e.key),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: listView),
        if (orderTotal > 0)
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.18),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
              border: Border(
                top: BorderSide(
                  color: AppColors.accent.withValues(alpha: 0.55),
                  width: 3,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        AppFormatters.formatPaise(orderTotal),
                        style: AppTypography.titleMedium.copyWith(
                          fontFamily: 'JetBrainsMono',
                          color: AppColors.teal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (!isWalkInSale && person != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Deducted from wallet after payment.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton(
                    onPressed: onPay,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                      shadowColor: AppColors.accent.withValues(alpha: 0.45),
                    ),
                    child: Text(
                      isWalkInSale
                          ? 'Record cash ${AppFormatters.formatPaise(orderTotal)}'
                          : 'Charge wallet ${AppFormatters.formatPaise(orderTotal)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
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

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    for (final e in this) {
      return e;
    }
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
