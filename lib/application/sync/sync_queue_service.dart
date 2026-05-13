import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../../core/config/env_config.dart';
import '../../core/services/app_logger.dart';
import '../../core/storage/app_database.dart';

/// Operation type constants used in [SyncQueueEntries.operation].
class SyncOperation {
  SyncOperation._();

  static const String markAttendance = 'mark_attendance';
  static const String postDiary = 'post_diary';
  static const String sendChat = 'send_chat';
  static const String canteenOrder = 'canteen_order';
}

/// Processes offline-queued write operations with exponential backoff.
///
/// When [EnvConfig.apiBaseUrl] is empty the service is a no-op — all writes
/// remain queued in [SyncQueueEntries] until the API URL is configured.
///
/// Call [processPending] from a connectivity-change listener or an app-foreground
/// lifecycle hook to drain the queue whenever the device comes back online.
class SyncQueueService {
  SyncQueueService(this._db, this._dio);

  final AppDatabase _db;
  final Dio _dio;

  static const int _maxRetries = 5;

  /// Enqueues a new write operation.  [operation] must be one of [SyncOperation.*].
  Future<void> enqueue({
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    await _db
        .into(_db.syncQueueEntries)
        .insert(
          SyncQueueEntriesCompanion.insert(
            operation: operation,
            payload: jsonEncode(payload),
          ),
        );
  }

  /// Processes all pending / failed entries in FIFO order.
  ///
  /// Each entry is retried with exponential backoff (1s, 2s, 4s, 8s, 16s).
  /// Entries exceeding [_maxRetries] are left in the queue with status 'failed'
  /// for manual investigation.
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

      try {
        final map = jsonDecode(row.payload) as Map<String, dynamic>;
        await _dispatch(row.operation, map);
        await (_db.delete(
          _db.syncQueueEntries,
        )..where((t) => t.id.equals(row.id))).go();
      } on DioException catch (e) {
        AppLogger.instance.error(
          'SyncQueueService: failed op=${row.operation} id=${row.id}',
          e,
          e.stackTrace,
        );
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

  /// Routes each operation to the appropriate API endpoint.
  Future<void> _dispatch(String operation, Map<String, dynamic> payload) async {
    switch (operation) {
      case SyncOperation.markAttendance:
        await _dio.post<void>('/attendance/batch', data: payload);

      case SyncOperation.postDiary:
        // payload: diary entry JSON matching DiaryEntry.toJson()
        if (payload.containsKey('id') && (payload['id'] as String).isNotEmpty) {
          await _dio.put<void>('/diary/${payload['id']}', data: payload);
        } else {
          await _dio.post<void>('/diary', data: payload);
        }

      case SyncOperation.sendChat:
        // payload: chat message JSON matching ChatMessage.toJson()
        final threadId = payload['thread_id'] as String?;
        if (threadId == null || threadId.isEmpty) {
          AppLogger.instance.warn(
            'SyncQueueService: sendChat missing thread_id',
          );
          return;
        }
        await _dio.post<void>(
          '/chat/threads/$threadId/messages',
          data: payload,
        );
        // Mark the local chat message as synced
        final messageId = payload['id'] as String?;
        if (messageId != null) {
          await (_db.update(
            _db.localChatMessages,
          )..where((m) => m.id.equals(messageId))).write(
            const LocalChatMessagesCompanion(pendingSync: Value(false)),
          );
        }

      case SyncOperation.canteenOrder:
        // payload: order JSON matching CanteenOrder.toJson()
        await _dio.post<void>('/canteen/order', data: payload);
        // Mark the local canteen order as synced by clientUuid
        final clientUuid = payload['id'] as String?;
        if (clientUuid != null) {
          await (_db.update(_db.localCanteenOrders)
                ..where((o) => o.clientUuid.equals(clientUuid)))
              .write(const LocalCanteenOrdersCompanion(synced: Value(true)));
        }

      default:
        AppLogger.instance.warn(
          'SyncQueueService: unknown operation "$operation" — skipped',
        );
    }
  }
}
