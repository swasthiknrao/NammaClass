import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';

/// Notification service state: list of notices with read status.
/// Can later plug into FCM or WebSocket.
class NotificationService extends StateNotifier<List<MockNotice>> {
  NotificationService() : super(List.from(MockData.notices));

  void markAsRead(String id) {
    state = [for (final n in state) n.id == id ? n.copyWith(isRead: true) : n];
  }

  void markAllRead() {
    state = [for (final n in state) n.copyWith(isRead: true)];
  }

  /// Prepends a notice (e.g. admin broadcast demo).
  void prependNotice(MockNotice notice) {
    state = [notice, ...state];
  }

  /// Prepends several notices (e.g. direct messages to many recipients).
  void prependNotices(List<MockNotice> notices) {
    if (notices.isEmpty) return;
    state = [...notices, ...state];
  }
}

final notificationServiceProvider =
    StateNotifierProvider<NotificationService, List<MockNotice>>(
      (ref) => NotificationService(),
    );

final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationServiceProvider).where((n) => !n.isRead).length;
});
