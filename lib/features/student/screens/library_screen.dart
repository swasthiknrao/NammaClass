import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../core/widgets/nc_empty_state.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../providers/student_providers.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MockBook> _filterBooks(List<MockBook> books) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return books;
    return books.where((b) {
      return b.title.toLowerCase().contains(q) ||
          b.author.toLowerCase().contains(q) ||
          b.category.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(studentBooksProvider);

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(title: const Text('Library')),
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.12),
                  AppColors.teal.withValues(alpha: 0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.divider.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_library_rounded),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Discover Great Books',
                        style: AppTypography.titleMedium,
                      ),
                      Text(
                        'Search, reserve, and manage your reading.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          booksAsync.when(
            loading: () => const Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: NcShimmerList(),
              ),
            ),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (books) {
              final filtered = _filterBooks(books);
              return Expanded(
                child: DefaultTabController(
                  length: 4,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: SearchBar(
                          controller: _searchController,
                          hintText: 'Search books, authors…',
                          leading: const Icon(Icons.search),
                          trailing: _query.isEmpty
                              ? null
                              : [
                                  IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _query = '');
                                    },
                                    icon: const Icon(Icons.close),
                                  ),
                                ],
                          onChanged: (v) => setState(() => _query = v),
                          padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 16),
                          ),
                          backgroundColor: const WidgetStatePropertyAll(
                            AppColors.card,
                          ),
                          elevation: const WidgetStatePropertyAll(0),
                          side: WidgetStatePropertyAll(
                            BorderSide(
                              color: AppColors.divider.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const TabBar(
                        isScrollable: true,
                        tabs: [
                          Tab(text: 'Search'),
                          Tab(text: 'My Books'),
                          Tab(text: 'E-Library'),
                          Tab(text: 'History'),
                        ],
                        tabAlignment: TabAlignment.start,
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _BookGrid(books: filtered),

                            _BookGrid(
                              books: filtered
                                  .where((b) => !b.available)
                                  .toList(),
                            ),

                            const NcEmptyState(
                              title: 'E-Library',
                              body: 'Digital books and resources coming soon!',
                              illustration: NcIllustration.general,
                            ),

                            ListView.builder(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              itemCount: filtered.length < 5
                                  ? filtered.length
                                  : 5,
                              itemBuilder: (ctx, i) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.xs,
                                ),
                                child: NcCard(
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.history,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              filtered[i].title,
                                              style: AppTypography.labelMedium,
                                            ),
                                            Text(
                                              'Returned 5 days ago',
                                              style: AppTypography.bodySmall
                                                  .copyWith(
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      NcChip(label: filtered[i].category),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _BookGrid extends StatelessWidget {
  const _BookGrid({required this.books});
  final List<MockBook> books;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return const NcEmptyState(
        title: 'No Books Found',
        body: 'Try searching with different keywords.',
        illustration: NcIllustration.noData,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return _BookListMobile(books: books);
        }
        return _BookGridDesktop(books: books);
      },
    );
  }
}

class _BookListMobile extends StatelessWidget {
  const _BookListMobile({required this.books});
  final List<MockBook> books;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        SizedBox(
          height: 166,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: books.length < 8 ? books.length : 8,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (ctx, i) => _FeaturedBookCard(book: books[i]),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...books.map(
          (book) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _BookTile(book: book),
          ),
        ),
      ],
    );
  }
}

class _BookGridDesktop extends StatelessWidget {
  const _BookGridDesktop({required this.books});
  final List<MockBook> books;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1500
            ? 4
            : width >= 1100
            ? 3
            : 2;

        return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 2.45,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
          ),
          itemCount: books.length,
          itemBuilder: (ctx, i) => _BookTile(book: books[i]),
        );
      },
    );
  }
}

class _FeaturedBookCard extends StatelessWidget {
  const _FeaturedBookCard({required this.book});
  final MockBook book;

  @override
  Widget build(BuildContext context) {
    final tint = book.title.hashCode.isEven
        ? AppColors.primary.withValues(alpha: 0.18)
        : AppColors.teal.withValues(alpha: 0.18);
    return Container(
      width: 240,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book_rounded, size: 30),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  book.title,
                  style: AppTypography.labelLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'By ${book.author}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                NcChip(label: book.category),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookTile extends StatelessWidget {
  const _BookTile({required this.book});
  final MockBook book;

  @override
  Widget build(BuildContext context) {
    final tint = book.title.hashCode.isEven
        ? AppColors.primary.withValues(alpha: 0.65)
        : AppColors.accent.withValues(alpha: 0.65);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          NcCard(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(86, 16, 14, 16),
              child: SizedBox(
                height: 58,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: AppTypography.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withValues(alpha: 0.42),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    const SizedBox(height: 6),
                    FractionallySizedBox(
                      widthFactor: 0.65,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.28,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 14,
            top: -18,
            child: Container(
              width: 80,
              height: 114,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.menu_book_rounded, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}
