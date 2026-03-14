import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_card.dart';
import '../../../core/widgets/nc_empty_state.dart';

class WebSupportKnowledgeBaseScreen extends ConsumerStatefulWidget {
  const WebSupportKnowledgeBaseScreen({super.key});

  @override
  ConsumerState<WebSupportKnowledgeBaseScreen> createState() =>
      _WebSupportKnowledgeBaseScreenState();
}

class _WebSupportKnowledgeBaseScreenState
    extends ConsumerState<WebSupportKnowledgeBaseScreen> {
  String _search = '';
  String? _selectedArticleId;

  @override
  Widget build(BuildContext context) {
    final articles = MockData.kbArticles;

    final filtered = articles.where((a) {
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      return a.title.toLowerCase().contains(q) ||
          a.category.toLowerCase().contains(q) ||
          a.excerpt.toLowerCase().contains(q);
    }).toList();

    MockKbArticle? selectedArticle;
    if (_selectedArticleId != null) {
      for (final a in articles) {
        if (a.id == _selectedArticleId) {
          selectedArticle = a;
          break;
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Knowledge Base', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Self-service help articles for parents and staff',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Search
          NcCard(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search articles...',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Article list
              Expanded(
                flex: selectedArticle != null ? 1 : 1,
                child: filtered.isEmpty
                    ? const NcEmptyState(
                        title: 'No articles found',
                        subtitle: 'Try a different search term.',
                        icon: Icons.menu_book_outlined,
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (_, i) {
                          final a = filtered[i];
                          final isSelected = a.id == _selectedArticleId;
                          return _ArticleListItem(
                            article: a,
                            isSelected: isSelected,
                            onTap: () =>
                                setState(() => _selectedArticleId = a.id),
                          );
                        },
                      ),
              ),
              if (selectedArticle != null) ...[
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  flex: 2,
                  child: NcCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                selectedArticle.title,
                                style: AppTypography.titleMedium,
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  setState(() => _selectedArticleId = null),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.xxl),
                          ),
                          child: Text(
                            selectedArticle.category,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          selectedArticle.excerpt,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Divider(),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          selectedArticle.body,
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ArticleListItem extends StatelessWidget {
  const _ArticleListItem({
    required this.article,
    required this.isSelected,
    required this.onTap,
  });
  final MockKbArticle article;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: NcCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          color: Colors.transparent,
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 1)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.title,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                article.category,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
