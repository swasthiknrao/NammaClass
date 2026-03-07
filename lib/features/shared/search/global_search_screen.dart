import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nc_avatar.dart';
import '../../../core/widgets/nc_chip.dart';
import '../../../core/widgets/nc_empty_state.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';
  final List<String> _recentSearches = [
    'Arjun Kumar',
    'Class 8-A',
    'Fee Due',
    'Sports Day',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<_SearchResult> _search(String q) {
    if (q.length < 2) return [];
    final results = <_SearchResult>[];
    final ql = q.toLowerCase();

    // Search students
    for (final s in MockData.students) {
      if (s.name.toLowerCase().contains(ql) ||
          s.rollNo.contains(ql) ||
          s.classSection.toLowerCase().contains(ql)) {
        results.add(
          _SearchResult(
            type: 'Student',
            title: s.name,
            subtitle: '${s.classSection}  ·  Roll ${s.rollNo}',
            icon: Icons.person,
            color: AppColors.primary,
          ),
        );
      }
    }

    // Search staff
    for (final st in MockData.staff) {
      if (st.name.toLowerCase().contains(ql) ||
          st.department.toLowerCase().contains(ql)) {
        results.add(
          _SearchResult(
            type: 'Staff',
            title: st.name,
            subtitle: '${st.role}  ·  ${st.department}',
            icon: Icons.badge,
            color: AppColors.teal,
          ),
        );
      }
    }

    // Search notices
    for (final n in MockData.notices) {
      if (n.title.toLowerCase().contains(ql) ||
          n.body.toLowerCase().contains(ql)) {
        results.add(
          _SearchResult(
            type: 'Notice',
            title: n.title,
            subtitle: n.category,
            icon: Icons.campaign,
            color: AppColors.accent,
          ),
        );
      }
    }

    return results.take(20).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _search(_query);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search students, staff, notices…',
            border: InputBorder.none,
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          style: AppTypography.bodyLarge,
          onChanged: (v) => setState(() => _query = v),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              onPressed: () {
                setState(() => _query = '');
                _ctrl.clear();
              },
              icon: const Icon(Icons.close),
            ),
        ],
      ),
      body: _query.length < 2
          ? _RecentSearches(
              searches: _recentSearches,
              onTap: (s) {
                setState(() => _query = s);
                _ctrl.text = s;
              },
            )
          : results.isEmpty
          ? NcEmptyState(
              title: 'No results for "$_query"',
              subtitle: 'Check spelling or try different keywords.',
              icon: Icons.search_off,
            )
          : _ResultsList(results: results, query: _query),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  const _RecentSearches({required this.searches, required this.onTap});
  final List<String> searches;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          'Recent Searches',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...searches.map(
          (s) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history, color: AppColors.textSecondary),
            title: Text(s, style: AppTypography.bodyLarge),
            onTap: () => onTap(s),
            trailing: const Icon(
              Icons.north_west,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.results, required this.query});
  final List<_SearchResult> results;
  final String query;

  @override
  Widget build(BuildContext context) {
    // Group by type
    final grouped = <String, List<_SearchResult>>{};
    for (final r in results) {
      grouped.putIfAbsent(r.type, () => []).add(r);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: grouped.length * 2 - 1,
      itemBuilder: (_, i) {
        final groupIndex = i ~/ 2;
        if (i.isOdd) return const SizedBox(height: AppSpacing.sm);
        final type = grouped.keys.elementAt(groupIndex);
        final items = grouped[type]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  type,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                NcChip(label: '${items.length}', color: AppColors.primary),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ...items.map(
              (r) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: r.color.withValues(alpha: 0.1),
                  child: Icon(r.icon, color: r.color, size: 20),
                ),
                title: _HighlightText(text: r.title, query: query),
                subtitle: Text(
                  r.subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening ${r.title}...')),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HighlightText extends StatelessWidget {
  const _HighlightText({required this.text, required this.query});
  final String text;
  final String query;

  @override
  Widget build(BuildContext context) {
    final ql = query.toLowerCase();
    final tl = text.toLowerCase();
    final idx = tl.indexOf(ql);
    if (idx < 0) return Text(text, style: AppTypography.bodyLarge);
    return RichText(
      text: TextSpan(
        style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
        children: [
          TextSpan(text: text.substring(0, idx)),
          TextSpan(
            text: text.substring(idx, idx + query.length),
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
          TextSpan(text: text.substring(idx + query.length)),
        ],
      ),
    );
  }
}

class _SearchResult {
  const _SearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
  final String type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}
