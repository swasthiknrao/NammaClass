import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/nc_empty_state.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notices = MockData.notices;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Mark all read',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: notices.isEmpty
          ? const NcEmptyState(
              title: 'No Notifications',
              body: 'You\'re all caught up!',
              illustration: NcIllustration.noNotifications,
            )
          : ListView.builder(
              itemCount: notices.length,
              itemBuilder: (ctx, i) {
                final n = notices[i];
                return Dismissible(
                  key: Key(n.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Notification dismissed'),
                        action: SnackBarAction(label: 'Undo', onPressed: () {}),
                      ),
                    );
                  },
                  background: Container(
                    color: AppColors.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    tileColor: n.isRead
                        ? AppColors.card
                        : AppColors.primary.withValues(alpha: 0.04),
                    leading: CircleAvatar(
                      backgroundColor: _categoryColor(
                        n.category,
                      ).withValues(alpha: 0.15),
                      child: Icon(
                        _categoryIcon(n.category),
                        color: _categoryColor(n.category),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      n.title,
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: n.isRead
                            ? FontWeight.w400
                            : FontWeight.w700,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        if (!n.isRead)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Text(
                          AppFormatters.timeAgo(n.date),
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                    trailing: Text(
                      n.category,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Finance':
        return AppColors.error;
      case 'Academic':
        return AppColors.primary;
      case 'Events':
        return AppColors.accent;
      case 'Holiday':
        return AppColors.success;
      case 'Library':
        return AppColors.teal;
      default:
        return AppColors.primary;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Finance':
        return Icons.payments;
      case 'Academic':
        return Icons.school;
      case 'Events':
        return Icons.event;
      case 'Holiday':
        return Icons.celebration;
      case 'Library':
        return Icons.local_library;
      default:
        return Icons.notifications;
    }
  }
}
