import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_button.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../features/student/providers/student_providers.dart';

class WebLibraryScreen extends ConsumerWidget {
  const WebLibraryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(studentBooksProvider);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 280,
                child: SearchBar(
                  hintText: 'Search books…',
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
              const Spacer(),
              NcPrimaryButton(
                label: 'Add Book',
                icon: Icons.add,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: booksAsync.when(
              loading: () => const CircularProgressIndicator.adaptive(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (books) => NcCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Container(
                      color: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          _H('Title', flex: 4),
                          _H('Author', flex: 3),
                          _H('Category', flex: 2),
                          _H('Status', flex: 1),
                          _H('Actions', flex: 1),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: books.length,
                        separatorBuilder: (_, i) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final b = books[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    b.title,
                                    style: AppTypography.labelMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    b.author,
                                    style: AppTypography.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: NcChip(label: b.category),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: NcChip(
                                    label: b.available ? 'Available' : 'Issued',
                                    selected: b.available,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      b.available ? 'Issue' : 'Return',
                                    ),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _H extends StatelessWidget {
  const _H(this.label, {this.flex = 1});
  final String label;
  final int flex;
  @override
  Widget build(BuildContext context) => Expanded(
    flex: flex,
    child: Text(
      label,
      style: AppTypography.labelMedium.copyWith(color: Colors.white),
    ),
  );
}
