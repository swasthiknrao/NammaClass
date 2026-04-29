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
            itemBuilder: (ctx, i) =>
                _FeaturedBookCard(book: books[i], allBooks: books),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...books.map(
          (book) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _BookTile(book: book, allBooks: books),
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
          itemBuilder: (ctx, i) => _BookTile(book: books[i], allBooks: books),
        );
      },
    );
  }
}

class _FeaturedBookCard extends StatelessWidget {
  const _FeaturedBookCard({required this.book, required this.allBooks});
  final MockBook book;
  final List<MockBook> allBooks;

  @override
  Widget build(BuildContext context) {
    final tint = book.title.hashCode.isEven
        ? AppColors.primary.withValues(alpha: 0.18)
        : AppColors.teal.withValues(alpha: 0.18);
    return GestureDetector(
      onTap: () => _openBookDetails(context, book: book, allBooks: allBooks),
      child: Container(
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
      ),
    );
  }
}

class _BookTile extends StatelessWidget {
  const _BookTile({required this.book, required this.allBooks});
  final MockBook book;
  final List<MockBook> allBooks;

  @override
  Widget build(BuildContext context) {
    final tint = book.title.hashCode.isEven
        ? AppColors.primary.withValues(alpha: 0.65)
        : AppColors.accent.withValues(alpha: 0.65);

    return GestureDetector(
      onTap: () => _openBookDetails(context, book: book, allBooks: allBooks),
      child: Padding(
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
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.42,
                          ),
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
      ),
    );
  }
}

void _openBookDetails(
  BuildContext context, {
  required MockBook book,
  required List<MockBook> allBooks,
}) {
  final isMobile = MediaQuery.sizeOf(context).width < 700;
  final similarBooks = allBooks
      .where(
        (b) =>
            b.id != book.id &&
            (b.category == book.category || b.author == book.author),
      )
      .take(6)
      .toList();

  if (isMobile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _BookDetailsScreen(
          book: book,
          allBooks: allBooks,
          similarBooks: similarBooks,
        ),
      ),
    );
    return;
  }

  showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 680),
        child: _BookDetailsBody(
          book: book,
          allBooks: allBooks,
          similarBooks: similarBooks,
          isDialog: true,
        ),
      ),
    ),
  );
}

void _openAuthorDetails(
  BuildContext context, {
  required String author,
  required List<MockBook> allBooks,
}) {
  final authored = allBooks.where((b) => b.author == author).toList();
  final isMobile = MediaQuery.sizeOf(context).width < 700;
  if (isMobile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _AuthorDetailsScreen(author: author, books: authored),
      ),
    );
    return;
  }

  showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 600),
        child: _AuthorDetailsBody(
          author: author,
          books: authored,
          isDialog: true,
        ),
      ),
    ),
  );
}

class _BookDetailsScreen extends StatelessWidget {
  const _BookDetailsScreen({
    required this.book,
    required this.allBooks,
    required this.similarBooks,
  });

  final MockBook book;
  final List<MockBook> allBooks;
  final List<MockBook> similarBooks;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Details')),
      body: _BookDetailsBody(
        book: book,
        allBooks: allBooks,
        similarBooks: similarBooks,
        isDialog: false,
      ),
    );
  }
}

class _BookDetailsBody extends StatelessWidget {
  const _BookDetailsBody({
    required this.book,
    required this.allBooks,
    required this.similarBooks,
    required this.isDialog,
  });

  final MockBook book;
  final List<MockBook> allBooks;
  final List<MockBook> similarBooks;
  final bool isDialog;

  @override
  Widget build(BuildContext context) {
    final tint = book.title.hashCode.isEven
        ? AppColors.primary.withValues(alpha: 0.65)
        : AppColors.accent.withValues(alpha: 0.65);
    final formatText = book.format == BookFormat.hardcopy
        ? 'Hardcover'
        : 'E-Book';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3EDEA),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 420,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: Container(
                          height: 250,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3EDEA),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                              bottom: Radius.circular(24),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.primary.withValues(
                                  alpha: 0.25,
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: () => _openAuthorDetails(
                                    context,
                                    author: book.author,
                                    allBooks: allBooks,
                                  ),
                                  child: Center(
                                    child: Text(
                                      book.author.characters.first,
                                      style: AppTypography.labelMedium,
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.tune_rounded,
                                color: AppColors.primary.withValues(
                                  alpha: 0.75,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        top: 74,
                        child: Container(
                          width: 145,
                          height: 206,
                          decoration: BoxDecoration(
                            color: tint,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.22),
                                blurRadius: 14,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.menu_book_rounded, size: 50),
                        ),
                      ),
                      Positioned(
                        left: 180,
                        right: 18,
                        top: 104,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.headlineSmall.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () => _openAuthorDetails(
                                context,
                                author: book.author,
                                allBooks: allBooks,
                              ),
                              child: Text(
                                '${book.author} • $formatText',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: Color(0xFFF4B400),
                                ),
                                const SizedBox(width: 4),
                                Text('4.9', style: AppTypography.labelLarge),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                FilledButton(
                                  onPressed: book.available ? () {} : null,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFFC6469),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(80, 32),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                  ),
                                  child: const Text('Borrow'),
                                ),
                                OutlinedButton(
                                  onPressed: () => _openAuthorDetails(
                                    context,
                                    author: book.author,
                                    allBooks: allBooks,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(36, 32),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Icon(
                                    Icons.bookmark_border_rounded,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 182,
                          padding: const EdgeInsets.fromLTRB(22, 34, 22, 14),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFC6469),
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(24),
                            ),
                          ),
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Hardcover',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Accession ${book.accessionOrId}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Publisher',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'NammaClass Library Edition',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Language',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'English',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 22,
                        bottom: 168,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F3EF),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            'Book Details',
                            style: AppTypography.titleMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      NcChip(label: book.category),
                      NcChip(
                        label: book.available ? 'Available' : 'Issued',
                        selected: book.available,
                      ),
                      NcChip(label: formatText),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Similar Books', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          if (similarBooks.isEmpty)
            const NcEmptyState(
              title: 'No Similar Books',
              body: 'Try other genres to discover more titles.',
              illustration: NcIllustration.general,
            )
          else
            SizedBox(
              height: 128,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: similarBooks.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final b = similarBooks[index];
                  final similarTint = b.title.hashCode.isEven
                      ? AppColors.primary.withValues(alpha: 0.24)
                      : AppColors.accent.withValues(alpha: 0.24);
                  return GestureDetector(
                    onTap: () =>
                        _openBookDetails(context, book: b, allBooks: allBooks),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 62,
                          height: 82,
                          decoration: BoxDecoration(
                            color: similarTint,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.menu_book_rounded, size: 22),
                        ),
                        const SizedBox(height: 2),
                        SizedBox(
                          width: 62,
                          child: Text(
                            b.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall,
                          ),
                        ),
                      ],
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

class _AuthorDetailsScreen extends StatelessWidget {
  const _AuthorDetailsScreen({required this.author, required this.books});

  final String author;
  final List<MockBook> books;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Author Profile')),
      body: _AuthorDetailsBody(author: author, books: books, isDialog: false),
    );
  }
}

class _AuthorDetailsBody extends StatelessWidget {
  const _AuthorDetailsBody({
    required this.author,
    required this.books,
    required this.isDialog,
  });

  final String author;
  final List<MockBook> books;
  final bool isDialog;

  @override
  Widget build(BuildContext context) {
    final featured = books.take(2).toList();
    final coral = const Color(0xFFFC6469);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Spacer(),
              Text(
                'Profile',
                style: AppTypography.headlineSmall.copyWith(color: coral),
              ),
              const Spacer(),
              Icon(Icons.tune_rounded, color: coral.withValues(alpha: 0.9)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    author.characters.first,
                    style: AppTypography.headlineSmall,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      style: AppTypography.titleMedium.copyWith(color: coral),
                    ),
                    Text(
                      'Member since 2.9 Years',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 7,
              horizontal: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: coral,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              '${books.length} Books in your Pocket',
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: coral,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Running Plan',
                  style: AppTypography.titleMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F3EF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 62,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '12',
                              style: AppTypography.titleMedium.copyWith(
                                color: coral,
                              ),
                            ),
                            Text(
                              'Month',
                              style: AppTypography.bodySmall.copyWith(
                                color: coral,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$120',
                              style: AppTypography.titleMedium.copyWith(
                                color: coral,
                              ),
                            ),
                            Text(
                              'Enjoy twelve months all books reading',
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
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatPill(label: 'Months Left', value: '3'),
                    _StatPill(label: 'Books Read', value: '47'),
                    _StatPill(label: 'Total Saved', value: '\$1024'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFFF3EDEA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Books',
                  style: AppTypography.titleMedium.copyWith(color: coral),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...featured.map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 70,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.titleMedium.copyWith(
                                    color: coral,
                                  ),
                                ),
                                Text(
                                  '1 month left',
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
                  ),
                ),
              ],
            ),
          ),
          if (isDialog) const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(color: Colors.white),
        ),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}
