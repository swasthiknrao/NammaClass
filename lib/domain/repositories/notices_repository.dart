import '../entities/notice_entity.dart';

/// Contract for fetching, caching, and marking school notices.
abstract class NoticesRepository {
  /// Returns notices relevant to [userId] (global + targeted).
  /// Implementations must cache results to Drift for offline access.
  Future<List<NoticeEntity>> getNoticesForUser(String userId);

  /// Marks a notice as read on the backend.
  Future<void> markAsRead(String noticeId);
}
