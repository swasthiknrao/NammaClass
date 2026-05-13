import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// ── Table definitions ──────────────────────────────────────────────────────

@DataClassName('LocalAttendanceRow')
class LocalAttendances extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get studentId => text()();
  TextColumn get classSection => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get statusCode => text()();
  TextColumn get clientUuid => text()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

@DataClassName('SyncQueueRow')
class SyncQueueEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Cached notice records for offline viewing.
@DataClassName('LocalNoticeRow')
class LocalNotices extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get category => text()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  BoolColumn get hasAttachment =>
      boolean().withDefault(const Constant(false))();
  TextColumn get targetUserId => text().nullable()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

/// Cached diary entries for offline viewing.
@DataClassName('LocalDiaryRow')
class LocalDiaryEntries extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get subject => text()();
  TextColumn get classwork => text()();
  TextColumn get homework => text()();
  TextColumn get classSection => text()();
  TextColumn get teacherName => text().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

/// Pending canteen orders queued while offline.
@DataClassName('LocalCanteenOrderRow')
class LocalCanteenOrders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get clientUuid => text()();
  TextColumn get userId => text()();

  /// JSON-encoded list of OrderLineItem
  TextColumn get itemsJson => text()();
  IntColumn get totalPaise => integer()();
  TextColumn get paymentMode => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get orderedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

/// Last N messages per chat thread for offline reading.
@DataClassName('LocalChatMessageRow')
class LocalChatMessages extends Table {
  TextColumn get id => text()();
  TextColumn get threadId => text()();
  TextColumn get senderId => text()();
  TextColumn get senderName => text()();

  /// Message body — named 'messageText' to avoid collision with Drift's text() builder.
  TextColumn get messageText => text()();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get isRead => boolean().withDefault(const Constant(true))();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

// ── Database class ─────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [
    LocalAttendances,
    SyncQueueEntries,
    LocalNotices,
    LocalDiaryEntries,
    LocalCanteenOrders,
    LocalChatMessages,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'nammaclass.sqlite'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // v1 → v2: add notice, diary, canteen order, chat message tables
        await m.createTable(localNotices);
        await m.createTable(localDiaryEntries);
        await m.createTable(localCanteenOrders);
        await m.createTable(localChatMessages);
      }
    },
  );

  // ── Notice helpers ─────────────────────────────────────────────────────────

  Future<void> upsertNotice(LocalNoticeRow row) =>
      into(localNotices).insertOnConflictUpdate(row);

  Future<List<LocalNoticeRow>> getNoticesForUser(
    String tenantId,
    String userId,
  ) =>
      (select(localNotices)
            ..where(
              (n) =>
                  n.tenantId.equals(tenantId) &
                  (n.targetUserId.isNull() | n.targetUserId.equals(userId)),
            )
            ..orderBy([(n) => OrderingTerm.desc(n.date)]))
          .get();

  // ── Diary helpers ──────────────────────────────────────────────────────────

  Future<void> upsertDiaryEntry(LocalDiaryRow row) =>
      into(localDiaryEntries).insertOnConflictUpdate(row);

  Future<List<LocalDiaryRow>> getDiaryEntries({
    required String tenantId,
    required String classSection,
    required DateTime from,
    required DateTime to,
  }) =>
      (select(localDiaryEntries)
            ..where(
              (e) =>
                  e.tenantId.equals(tenantId) &
                  e.classSection.equals(classSection) &
                  e.date.isBiggerOrEqualValue(from) &
                  e.date.isSmallerOrEqualValue(to),
            )
            ..orderBy([(e) => OrderingTerm.desc(e.date)]))
          .get();

  // ── Canteen order helpers ──────────────────────────────────────────────────

  Future<int> queueCanteenOrder(LocalCanteenOrdersCompanion row) =>
      into(localCanteenOrders).insert(row);

  Future<List<LocalCanteenOrderRow>> getPendingOrders() =>
      (select(localCanteenOrders)..where((o) => o.synced.equals(false))).get();

  Future<void> markOrderSynced(int rowId) =>
      (update(localCanteenOrders)..where((o) => o.id.equals(rowId))).write(
        const LocalCanteenOrdersCompanion(synced: Value(true)),
      );

  // ── Chat message helpers ───────────────────────────────────────────────────

  Future<void> upsertChatMessage(LocalChatMessageRow row) =>
      into(localChatMessages).insertOnConflictUpdate(row);

  Future<List<LocalChatMessageRow>> getThreadMessages(String threadId) =>
      (select(localChatMessages)
            ..where((m) => m.threadId.equals(threadId))
            ..orderBy([(m) => OrderingTerm.desc(m.timestamp)])
            ..limit(100))
          .get();

  Future<List<LocalChatMessageRow>> getPendingChatMessages() => (select(
    localChatMessages,
  )..where((m) => m.pendingSync.equals(true))).get();
}
