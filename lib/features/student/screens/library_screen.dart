import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../core/widgets/nc_empty_state.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../providers/student_providers.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(studentBooksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SearchBar(
              hintText: 'Search books, authors…',
              leading: const Icon(Icons.search),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16),
              ),
              backgroundColor: const WidgetStatePropertyAll(AppColors.card),
              elevation: const WidgetStatePropertyAll(0),
              side: const WidgetStatePropertyAll(
                BorderSide(color: AppColors.divider),
              ),
            ),
          ),

          // Tab bar
          booksAsync.when(
            loading: () => const Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: NcShimmerList(),
              ),
            ),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (books) => Expanded(
              child: DefaultTabController(
                length: 4,
                child: Column(
                  children: [
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
                          // All books
                          _BookGrid(books: books),

                          // My books (issued)
                          _BookGrid(
                            books: books.where((b) => !b.available).toList(),
                          ),

                          // E-Library placeholder
                          const NcEmptyState(
                            title: 'E-Library',
                            body: 'Digital books and resources coming soon!',
                            illustration: NcIllustration.general,
                          ),

                          // History placeholder
                          ListView.builder(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            itemCount: 5,
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
                                            books[i].title,
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
                                    NcChip(label: books[i].category),
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
            ),
          ),
        ],
      ),
    );
  }
}

class _BookGrid extends StatelessWidget {
  const _BookGrid({required this.books});
  final List books;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return const NcEmptyState(
        title: 'No Books Found',
        body: 'Try searching with different keywords.',
        illustration: NcIllustration.noData,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: books.length,
      itemBuilder: (ctx, i) {
        final book = books[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: NcCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 64,
                  decoration: BoxDecoration(
                    color: book.title.hashCode.isNegative
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.teal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.book,
                    color: AppColors.primary.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: AppTypography.labelLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        book.author,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Row(children: [NcChip(label: book.category)]),
                    ],
                  ),
                ),
                Column(
                  children: [
                    NcChip(
                      label: book.available ? 'Available' : 'Issued',
                      selected: book.available as bool,
                    ),
                    if (book.available as bool) ...[
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 28,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            minimumSize: Size.zero,
                            textStyle: AppTypography.labelSmall,
                          ),
                          child: const Text('Reserve'),
                        ),
                      ),
                    ],
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
