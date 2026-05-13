import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';

/// Notification service state: list of notices with read status.
/// Can later plug into FCM or WebSocket.
class NotificationService extends StateNotifier<List<MockNotice>> {
  NotificationService() : super(List.from(MockData.notices));

  void markAsRead(String id) {
    state = [
      for (final n in state)
        n.id == id
            ? MockNotice(
                id: n.id,
                title: n.title,
                body: n.body,
                date: n.date,
                category: n.category,
                isRead: true,
                hasAttachment: n.hasAttachment,
                targetUserId: n.targetUserId,
              )
            : n,
    ];
  }

  void markAllRead() {
    state = [
      for (final n in state)
        MockNotice(
          id: n.id,
          title: n.title,
          body: n.body,
          date: n.date,
          category: n.category,
          isRead: true,
          hasAttachment: n.hasAttachment,
          targetUserId: n.targetUserId,
        ),
    ];
  }

  /// Prepends a notice (e.g. admin broadcast demo).
  void prependNotice(MockNotice notice) {
    state = [notice, ...state];
  }
}

final notificationServiceProvider =
    StateNotifierProvider<NotificationService, List<MockNotice>>(
      (ref) => NotificationService(),
    );

final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationServiceProvider).where((n) => !n.isRead).length;
});
