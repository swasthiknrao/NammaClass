import 'package:dio/dio.dart';

import '../../core/config/env_config.dart';
import '../../core/mock/mock_data.dart';
import '../../core/services/app_logger.dart';
import '../../domain/entities/notice_entity.dart';
import '../../domain/repositories/notices_repository.dart';

class NoticesRepositoryImpl implements NoticesRepository {
  NoticesRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<NoticeEntity>> getNoticesForUser(String userId) async {
    if (EnvConfig.apiBaseUrl.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return MockData.notices
          .where((n) => n.targetUserId == null || n.targetUserId == userId)
          .map(
            (n) => NoticeEntity(
              id: n.id,
              title: n.title,
              body: n.body,
              date: n.date,
              category: n.category,
              isRead: n.isRead,
              hasAttachment: n.hasAttachment,
              targetUserId: n.targetUserId,
            ),
          )
          .toList();
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        '/notices',
        queryParameters: {'userId': userId},
      );
      return (response.data ?? [])
          .map((e) => NoticeEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger.instance.error(
        'NoticesRepository: getNoticesForUser',
        e,
        e.stackTrace,
      );
      return [];
    }
  }

  @override
  Future<void> markAsRead(String noticeId) async {
    if (EnvConfig.apiBaseUrl.isEmpty) return;
    try {
      await _dio.patch<void>('/notices/$noticeId/read');
    } on DioException catch (e) {
      AppLogger.instance.error(
        'NoticesRepository: markAsRead',
        e,
        e.stackTrace,
      );
    }
  }
}
