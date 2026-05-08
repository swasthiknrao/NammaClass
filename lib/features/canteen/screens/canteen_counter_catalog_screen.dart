import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/providers/data_sync_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';

int? _parseRupeesToPaise(String raw) {
  final t = raw.trim().replaceAll(',', '');
  if (t.isEmpty) return null;
  final v = double.tryParse(t);
  if (v == null) return null;
  return (v * 100).round();
}

String _rupeesFieldFromPaise(int paise) {
  if (paise % 100 == 0) return (paise ~/ 100).toString();
  return (paise / 100).toStringAsFixed(2);
}

const _menuCategories = ['Breakfast', 'Lunch', 'Snacks', 'Beverages', 'Other'];

/// Counter staff: add/edit menu items, set prices, build combos.
class CanteenCounterCatalogScreen extends ConsumerStatefulWidget {
  const CanteenCounterCatalogScreen({super.key});

  @override
  ConsumerState<CanteenCounterCatalogScreen> createState() =>
      _CanteenCounterCatalogScreenState();
}

class _CanteenCounterCatalogScreenState
    extends ConsumerState<CanteenCounterCatalogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _bump() {
    ref.read(dataSyncProvider.notifier).bump();
    setState(() {});
  }

  void _stripItemFromCombos(String itemId) {
    for (var i = 0; i < MockData.canteenCombos.length; i++) {
      final c = MockData.canteenCombos[i];
      if (!c.itemIds.contains(itemId)) continue;
      MockData.canteenCombos[i] = c.copyWith(
        itemIds: c.itemIds.where((id) => id != itemId).toList(),
      );
    }
  }

  Future<void> _confirmDeleteItem(MockCanteenItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove item?'),
        content: Text(
          '"${item.name}" will disappear from the counter and be removed from combos that include it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    _stripItemFromCombos(item.id);
    MockData.canteenMenu.removeWhere((m) => m.id == item.id);
    _bump();
  }

  Future<void> _confirmDeleteCombo(MockCanteenCombo combo) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove combo?'),
        content: Text('"${combo.name}" will no longer appear at the counter.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    MockData.canteenCombos.removeWhere((c) => c.id == combo.id);
    _bump();
  }

  Future<void> _showMenuItemDialog({MockCanteenItem? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final priceCtrl = TextEditingController(
      text: existing != null ? _rupeesFieldFromPaise(existing.pricePaise) : '',
    );
    var category = existing?.category ?? 'Snacks';
    if (!_menuCategories.contains(category)) category = 'Other';
    var isVeg = existing?.isVeg ?? true;
    var available = existing?.available ?? true;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(existing == null ? 'Add menu item' : 'Edit menu item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: category,
                      isExpanded: true,
                      items: _menuCategories
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setLocal(() => category = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Price (₹)',
                    border: OutlineInputBorder(),
                    hintText: 'e.g. 50 or 49.50',
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile(
                  title: const Text('Vegetarian'),
                  value: isVeg,
                  onChanged: (v) => setLocal(() => isVeg = v),
                ),
                SwitchListTile(
                  title: const Text('Sold at counter today'),
                  value: available,
                  onChanged: (v) => setLocal(() => available = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final paise = _parseRupeesToPaise(priceCtrl.text);
                if (name.isEmpty || paise == null || paise < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter a name and valid price in ₹.'),
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx, true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (saved != true || !context.mounted) {
      nameCtrl.dispose();
      priceCtrl.dispose();
      return;
    }

    final name = nameCtrl.text.trim();
    final paise = _parseRupeesToPaise(priceCtrl.text)!;
    nameCtrl.dispose();
    priceCtrl.dispose();

    if (existing == null) {
      final id = 'c_${DateTime.now().millisecondsSinceEpoch}';
      MockData.canteenMenu.add(
        MockCanteenItem(
          id: id,
          name: name,
          category: category,
          pricePaise: paise,
          isVeg: isVeg,
          available: available,
        ),
      );
    } else {
      final i = MockData.canteenMenu.indexWhere((m) => m.id == existing.id);
      if (i >= 0) {
        MockData.canteenMenu[i] = existing.copyWith(
          name: name,
          category: category,
          pricePaise: paise,
          isVeg: isVeg,
          available: available,
        );
      }
    }
    _bump();
  }

  Future<void> _showComboDialog({MockCanteenCombo? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final priceCtrl = TextEditingController(
      text: existing != null ? _rupeesFieldFromPaise(existing.pricePaise) : '',
    );
    var isVeg = existing?.isVeg ?? true;
    var available = existing?.available ?? true;
    final selected = <String>{if (existing != null) ...existing.itemIds};

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(existing == null ? 'New combo' : 'Edit combo'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Combo name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Combo price (₹)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SwitchListTile(
                    title: const Text('Vegetarian'),
                    value: isVeg,
                    onChanged: (v) => setLocal(() => isVeg = v),
                  ),
                  SwitchListTile(
                    title: const Text('Available at counter'),
                    value: available,
                    onChanged: (v) => setLocal(() => available = v),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Includes', style: AppTypography.labelMedium),
                  const SizedBox(height: AppSpacing.xs),
                  ...MockData.canteenMenu.map(
                    (m) => CheckboxListTile(
                      dense: true,
                      value: selected.contains(m.id),
                      title: Text(
                        m.name,
                        style: AppTypography.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        AppFormatters.formatPaise(m.pricePaise),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.teal,
                        ),
                      ),
                      onChanged: (v) {
                        setLocal(() {
                          if (v == true) {
                            selected.add(m.id);
                          } else {
                            selected.remove(m.id);
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (selected.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pick at least one menu item.'),
                    ),
                  );
                  return;
                }
                final name = nameCtrl.text.trim();
                final paise = _parseRupeesToPaise(priceCtrl.text);
                if (name.isEmpty || paise == null || paise < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter a name and valid combo price in ₹.'),
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx, true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (saved != true || !context.mounted) {
      nameCtrl.dispose();
      descCtrl.dispose();
      priceCtrl.dispose();
      return;
    }

    final name = nameCtrl.text.trim();
    final desc = descCtrl.text.trim();
    final paise = _parseRupeesToPaise(priceCtrl.text)!;
    nameCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();

    final ids = selected.toList();
    if (existing == null) {
      final id = 'combo_${DateTime.now().millisecondsSinceEpoch}';
      MockData.canteenCombos.add(
        MockCanteenCombo(
          id: id,
          name: name,
          itemIds: ids,
          pricePaise: paise,
          description: desc.isEmpty ? null : desc,
          isVeg: isVeg,
          available: available,
        ),
      );
    } else {
      final i = MockData.canteenCombos.indexWhere((c) => c.id == existing.id);
      if (i >= 0) {
        MockData.canteenCombos[i] = existing.copyWith(
          name: name,
          itemIds: ids,
          pricePaise: paise,
          description: desc.isEmpty ? null : desc,
          clearDescription: desc.isEmpty,
          isVeg: isVeg,
          available: available,
        );
      }
    }
    _bump();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
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
                  Icons.storefront_rounded,
                  size: 24,
                  color: Colors.white,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Kitchen & menu',
                  style: AppTypography.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              'Prices, items, and combo deals',
              style: AppTypography.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.65),
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.restaurant_rounded, size: 18),
                  const SizedBox(width: 6),
                  Text('Items (${MockData.canteenMenu.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_offer_rounded, size: 18),
                  const SizedBox(width: 6),
                  Text('Combos (${MockData.canteenCombos.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabs.index == 0) {
            _showMenuItemDialog();
          } else {
            _showComboDialog();
          }
        },
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded),
        label: Text(_tabs.index == 0 ? 'Add item' : 'Add combo'),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: MockData.canteenMenu.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _CatalogIntroCard(
                    icon: Icons.edit_note_rounded,
                    title: 'Edit your live menu',
                    subtitle:
                        'Changes apply on the counter and student app after save.',
                  ),
                );
              }
              final item = MockData.canteenMenu[i - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Material(
                  elevation: 2,
                  shadowColor: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  color: AppColors.card,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      side: BorderSide(
                        color: AppColors.teal.withValues(alpha: 0.12),
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: item.isVeg
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.error.withValues(alpha: 0.15),
                      child: Icon(
                        _catalogCategoryIcon(item.category),
                        color: item.isVeg ? AppColors.success : AppColors.error,
                        size: 22,
                      ),
                    ),
                    title: Text(item.name, style: AppTypography.labelLarge),
                    subtitle: Text(
                      '${item.category} · ${item.available ? "On counter" : "Hidden"}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppFormatters.formatPaise(item.pricePaise),
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.teal,
                            fontFamily: 'JetBrainsMono',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _showMenuItemDialog(existing: item),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: AppColors.error.withValues(alpha: 0.85),
                          ),
                          onPressed: () => _confirmDeleteItem(item),
                        ),
                      ],
                    ),
                    onTap: () => _showMenuItemDialog(existing: item),
                  ),
                ),
              );
            },
          ),
          ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: MockData.canteenCombos.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _CatalogIntroCard(
                    icon: Icons.auto_awesome,
                    title: 'Bundle & save',
                    subtitle:
                        'Combos appear in “Today’s specials” on the counter.',
                  ),
                );
              }
              final combo = MockData.canteenCombos[i - 1];
              final names = combo.itemIds
                  .map(
                    (id) => MockData.canteenMenu
                        .where((m) => m.id == id)
                        .map((m) => m.name)
                        .firstOrNull,
                  )
                  .whereType<String>()
                  .join(', ');
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Material(
                  elevation: 2,
                  shadowColor: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  color: AppColors.card,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      side: BorderSide(
                        color: AppColors.accent.withValues(alpha: 0.28),
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accent.withValues(alpha: 0.18),
                      child: Icon(
                        Icons.local_offer,
                        color: AppColors.accent,
                        size: 22,
                      ),
                    ),
                    title: Text(combo.name, style: AppTypography.labelLarge),
                    subtitle: Text(
                      '${combo.itemIds.length} items${names.isNotEmpty ? ": $names" : ""}\n'
                      '${combo.available ? "Available" : "Hidden"}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppFormatters.formatPaise(combo.pricePaise),
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.teal,
                            fontFamily: 'JetBrainsMono',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _showComboDialog(existing: combo),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: AppColors.error.withValues(alpha: 0.85),
                          ),
                          onPressed: () => _confirmDeleteCombo(combo),
                        ),
                      ],
                    ),
                    onTap: () => _showComboDialog(existing: combo),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CatalogIntroCard extends StatelessWidget {
  const _CatalogIntroCard({
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.teal.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
        boxShadow: [AppColors.shadowSm],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [AppColors.shadowSm],
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleSmall),
                const SizedBox(height: 4),
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

IconData _catalogCategoryIcon(String category) {
  switch (category) {
    case 'Breakfast':
      return Icons.free_breakfast;
    case 'Lunch':
      return Icons.lunch_dining;
    case 'Snacks':
      return Icons.fastfood;
    case 'Beverages':
      return Icons.local_cafe;
    default:
      return Icons.restaurant;
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
