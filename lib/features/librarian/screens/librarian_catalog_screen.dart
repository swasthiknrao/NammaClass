import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../providers/library_provider.dart';

enum CatalogSort { title, author, availability }

enum CatalogFormatFilter { all, hardcopy, softcopy }

enum CatalogAvailabilityFilter { all, available, issued }

class LibrarianCatalogScreen extends ConsumerStatefulWidget {
  const LibrarianCatalogScreen({super.key});

  @override
  ConsumerState<LibrarianCatalogScreen> createState() =>
      _LibrarianCatalogScreenState();
}

class _LibrarianCatalogScreenState
    extends ConsumerState<LibrarianCatalogScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  CatalogSort _sort = CatalogSort.title;
  CatalogFormatFilter _formatFilter = CatalogFormatFilter.all;
  CatalogAvailabilityFilter _availabilityFilter = CatalogAvailabilityFilter.all;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<MockBook> _filterAndSort(
    List<MockBook> books,
    List<MockBookIssue> issues,
  ) {
    var list = List<MockBook>.from(books);
    final q = _search.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (b) =>
                b.title.toLowerCase().contains(q) ||
                b.author.toLowerCase().contains(q) ||
                b.category.toLowerCase().contains(q),
          )
          .toList();
    }
    if (_formatFilter != CatalogFormatFilter.all) {
      final fmt = _formatFilter == CatalogFormatFilter.hardcopy
          ? BookFormat.hardcopy
          : BookFormat.softcopy;
      list = list.where((b) => b.format == fmt).toList();
    }
    if (_availabilityFilter != CatalogAvailabilityFilter.all) {
      list = list.where((b) {
        final issued = issuedCountForBook(b.accessionOrId, issues);
        final hasAvailable =
            b.format == BookFormat.softcopy || issued < b.totalCopies;
        if (_availabilityFilter == CatalogAvailabilityFilter.available) {
          return hasAvailable;
        }
        return !hasAvailable || issued > 0;
      }).toList();
    }
    list.sort((a, b) {
      switch (_sort) {
        case CatalogSort.title:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case CatalogSort.author:
          return a.author.toLowerCase().compareTo(b.author.toLowerCase());
        case CatalogSort.availability:
          final ia = issuedCountForBook(a.accessionOrId, issues);
          final ib = issuedCountForBook(b.accessionOrId, issues);
          return ia.compareTo(ib);
      }
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final issues = ref.watch(libraryBookIssuesProvider);
    final filtered = _filterAndSort(MockData.books, issues);
    final totalBooks = MockData.books.length;
    var availableCount = 0;
    var issuedCount = 0;
    for (final b in MockData.books) {
      final issued = issuedCountForBook(b.accessionOrId, issues);
      if (b.format == BookFormat.softcopy || issued < b.totalCopies) {
        availableCount++;
      }
      if (issued > 0) issuedCount++;
    }
    final overdueCount = issues.where((i) => i.isOverdue).length;

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(
              title: const Text('Book Catalog'),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(72),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search by title, author, category…',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                ),
              ),
            ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                _StatChip('Books', '$totalBooks', AppColors.primary),
                _StatChip('Available', '$availableCount', AppColors.teal),
                _StatChip('Issued', '$issuedCount', AppColors.accent),
                _StatChip('Overdue', '$overdueCount', AppColors.error),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              children: [
                DropdownButton<CatalogSort>(
                  value: _sort,
                  isDense: true,
                  items: const [
                    DropdownMenuItem(
                      value: CatalogSort.title,
                      child: Text('Sort: Title'),
                    ),
                    DropdownMenuItem(
                      value: CatalogSort.author,
                      child: Text('Sort: Author'),
                    ),
                    DropdownMenuItem(
                      value: CatalogSort.availability,
                      child: Text('Sort: Issued'),
                    ),
                  ],
                  onChanged: (v) =>
                      setState(() => v != null ? _sort = v : null),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilterChip(
                  label: const Text('Format'),
                  selected: _formatFilter != CatalogFormatFilter.all,
                  onSelected: (_) {
                    setState(() {
                      _formatFilter = _formatFilter == CatalogFormatFilter.all
                          ? CatalogFormatFilter.hardcopy
                          : CatalogFormatFilter.all;
                    });
                  },
                ),
                const SizedBox(width: AppSpacing.xs),
                FilterChip(
                  label: const Text('Availability'),
                  selected:
                      _availabilityFilter != CatalogAvailabilityFilter.all,
                  onSelected: (_) {
                    setState(() {
                      _availabilityFilter =
                          _availabilityFilter == CatalogAvailabilityFilter.all
                          ? CatalogAvailabilityFilter.available
                          : CatalogAvailabilityFilter.all;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final b = filtered[i];
                final issued = issuedCountForBook(b.accessionOrId, issues);
                final avail = b.format == BookFormat.softcopy
                    ? 'Digital'
                    : '${b.totalCopies - issued}/${b.totalCopies}';
                final hasAvailable =
                    b.format == BookFormat.softcopy || issued < b.totalCopies;
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: Icon(
                        b.format == BookFormat.softcopy
                            ? Icons.laptop_mac
                            : Icons.menu_book,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(b.title, style: AppTypography.titleSmall),
                    subtitle: Text(
                      '${b.author}  ·  ${b.category}  ·  ${b.accessionOrId}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (b.format == BookFormat.softcopy)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.teal.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Digital',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.teal,
                              ),
                            ),
                          )
                        else
                          Text(
                            'Hard copy',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          hasAvailable ? 'Avail: $avail' : 'All issued',
                          style: AppTypography.bodySmall.copyWith(
                            color: hasAvailable
                                ? AppColors.teal
                                : AppColors.textSecondary,
                          ),
                        ),
                        if (issued > 0)
                          Text(
                            'Issued: $issued',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.xs),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.titleMedium.copyWith(
                color: color,
                fontFamily: 'JetBrainsMono',
              ),
            ),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
