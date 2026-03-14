import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_avatar.dart';
import '../../../core/widgets/nc_shimmer.dart';
import '../../../core/widgets/shell_layout_scope.dart';
import '../providers/parent_providers.dart';

class ParentChatListScreen extends ConsumerWidget {
  const ParentChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadsAsync = ref.watch(parentChatThreadsProvider);

    return Scaffold(
      appBar: ShellLayoutScope.maybeOf(context)?.hasPersistentTopBar == true
          ? null
          : AppBar(title: const Text('Messages')),
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SearchBar(
              hintText: 'Search teachers…',
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
          Expanded(
            child: threadsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: NcShimmerList(),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (threads) => ListView.builder(
                itemCount: threads.length,
                itemBuilder: (ctx, i) {
                  final t = threads[i];
                  return ListTile(
                    onTap: () => context.go('/parent/chat/${t.id}'),
                    leading: badges.Badge(
                      showBadge: t.unreadCount > 0,
                      badgeContent: Text(
                        '${t.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                      badgeStyle: const badges.BadgeStyle(
                        badgeColor: AppColors.accent,
                      ),
                      child: NcAvatar(name: t.teacherName),
                    ),
                    title: Text(
                      t.teacherName,
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: t.unreadCount > 0
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                    subtitle: Text(
                      t.teacherSubject,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppFormatters.timeAgo(t.lastMessageTime),
                          style: AppTypography.labelSmall,
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 100,
                          child: Text(
                            t.lastMessage,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
