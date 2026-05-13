import '../entities/chat_entity.dart';

/// Contract for fetching chat threads and messages.
abstract class ChatRepository {
  /// Returns all chat threads for [userId].
  Future<List<ChatThread>> getThreads(String userId);

  /// Returns messages for [threadId], newest first.
  Future<List<ChatMessage>> getMessages(String threadId);

  /// Sends a [message] — queued for offline delivery if no connectivity.
  Future<ChatMessage> sendMessage(ChatMessage message);

  /// Marks all messages in [threadId] as read.
  Future<void> markThreadRead(String threadId);
}
