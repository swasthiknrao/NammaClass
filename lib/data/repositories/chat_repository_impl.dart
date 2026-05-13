import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/env_config.dart';
import '../../core/mock/mock_data.dart';
import '../../core/services/app_logger.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<ChatThread>> getThreads(String userId) async {
    if (EnvConfig.apiBaseUrl.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return MockData.chatThreads
          .map(
            (t) => ChatThread(
              id: t.id,
              participantName: t.teacherName,
              participantRole: 'teacher',
              lastMessage: t.lastMessage,
              lastMessageTime: t.lastMessageTime,
              unreadCount: t.unreadCount,
              subject: t.teacherSubject,
            ),
          )
          .toList();
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        '/chat/threads',
        queryParameters: {'userId': userId},
      );
      return (response.data ?? [])
          .map((e) => ChatThread.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger.instance.error('ChatRepository: getThreads', e, e.stackTrace);
      return [];
    }
  }

  @override
  Future<List<ChatMessage>> getMessages(String threadId) async {
    if (EnvConfig.apiBaseUrl.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return MockData.messages
          .map(
            (m) => ChatMessage(
              id: m.id,
              threadId: threadId,
              senderId: m.senderId,
              senderName: m.senderId,
              text: m.text,
              timestamp: m.timestamp,
              isRead: m.isRead,
            ),
          )
          .toList();
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        '/chat/threads/$threadId/messages',
      );
      return (response.data ?? [])
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger.instance.error('ChatRepository: getMessages', e, e.stackTrace);
      return [];
    }
  }

  @override
  Future<ChatMessage> sendMessage(ChatMessage message) async {
    final id = message.id.isEmpty ? const Uuid().v4() : message.id;
    final payload = message.toJson();

    if (EnvConfig.apiBaseUrl.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      return ChatMessage.fromJson({...payload, 'id': id});
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/chat/threads/${message.threadId}/messages',
        data: payload,
      );
      return ChatMessage.fromJson(response.data!);
    } on DioException catch (e) {
      AppLogger.instance.error('ChatRepository: sendMessage', e, e.stackTrace);
      return ChatMessage.fromJson({...payload, 'id': id});
    }
  }

  @override
  Future<void> markThreadRead(String threadId) async {
    if (EnvConfig.apiBaseUrl.isEmpty) return;
    try {
      await _dio.patch<void>('/chat/threads/$threadId/read');
    } on DioException catch (e) {
      AppLogger.instance.error(
        'ChatRepository: markThreadRead',
        e,
        e.stackTrace,
      );
    }
  }
}
