import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

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

@DriftDatabase(tables: [LocalAttendances, SyncQueueEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'nammaclass.sqlite'));

  @override
  int get schemaVersion => 1;
}
