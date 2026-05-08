import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../../core/config/env_config.dart';
import '../../core/storage/app_database.dart';

/// Retries queued writes with exponential backoff delays (1s, 2s, 4s, 8s).
class SyncQueueService {
  SyncQueueService(this._db, this._dio);

  final AppDatabase _db;
  final Dio _dio;

  static const int _maxRetries = 5;

  Future<void> processPending() async {
    if (EnvConfig.apiBaseUrl.isEmpty) return;

    final rows = await _db.select(_db.syncQueueEntries).get();
    final pending = rows
        .where(
          (r) =>
              (r.status == 'pending' || r.status == 'failed') &&
              r.retryCount < _maxRetries,
        )
        .toList();

    for (final row in pending) {
      final delayMs = 1000 * (1 << row.retryCount.clamp(0, 4));
      await Future<void>.delayed(Duration(milliseconds: delayMs));

      if (row.operation != 'mark_attendance') continue;

      try {
        final map = jsonDecode(row.payload) as Map<String, dynamic>;
        await _dio.post<Map<String, dynamic>>('/attendance/batch', data: map);
        await (_db.delete(
          _db.syncQueueEntries,
        )..where((t) => t.id.equals(row.id))).go();
      } on DioException {
        await (_db.update(
          _db.syncQueueEntries,
        )..where((t) => t.id.equals(row.id))).write(
          SyncQueueEntriesCompanion(
            retryCount: Value(row.retryCount + 1),
            status: const Value('failed'),
          ),
        );
      }
    }
  }
}
