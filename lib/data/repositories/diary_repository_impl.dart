import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/env_config.dart';
import '../../core/mock/mock_data.dart';
import '../../core/services/app_logger.dart';
import '../../domain/entities/diary_entity.dart';
import '../../domain/repositories/diary_repository.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  DiaryRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<DiaryEntry>> getEntries({
    required String classSection,
    required DateTime from,
    required DateTime to,
  }) async {
    if (EnvConfig.apiBaseUrl.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return MockData.diary
          .where((e) => !e.date.isBefore(from) && !e.date.isAfter(to))
          .map(
            (e) => DiaryEntry(
              id: '${e.date.millisecondsSinceEpoch}_${e.subject}',
              date: e.date,
              subject: e.subject,
              classwork: e.classwork,
              homework: e.homework,
              classSection: classSection,
              dueDate: e.dueDate,
              hasAttachment: e.hasAttachment,
              completed: e.completed,
            ),
          )
          .toList();
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        '/diary',
        queryParameters: {
          'classSection': classSection,
          'from': from.toIso8601String(),
          'to': to.toIso8601String(),
        },
      );
      return (response.data ?? [])
          .map((e) => DiaryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger.instance.error('DiaryRepository: getEntries', e, e.stackTrace);
      return [];
    }
  }

  @override
  Future<DiaryEntry> saveEntry(DiaryEntry entry) async {
    final id = entry.id.isEmpty ? const Uuid().v4() : entry.id;
    final payload = entry.toJson();

    if (EnvConfig.apiBaseUrl.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return DiaryEntry.fromJson({...payload, 'id': id});
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/diary',
        data: payload,
      );
      return DiaryEntry.fromJson(response.data!);
    } on DioException catch (e) {
      AppLogger.instance.error('DiaryRepository: saveEntry', e, e.stackTrace);
      return DiaryEntry.fromJson({...payload, 'id': id});
    }
  }

  @override
  Future<void> markHomeworkComplete(String entryId) async {
    if (EnvConfig.apiBaseUrl.isEmpty) return;
    try {
      await _dio.patch<void>('/diary/$entryId/complete');
    } on DioException catch (e) {
      AppLogger.instance.error(
        'DiaryRepository: markHomeworkComplete',
        e,
        e.stackTrace,
      );
    }
  }
}
