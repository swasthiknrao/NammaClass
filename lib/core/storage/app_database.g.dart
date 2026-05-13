// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalAttendancesTable extends LocalAttendances
    with TableInfo<$LocalAttendancesTable, LocalAttendanceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAttendancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classSectionMeta = const VerificationMeta(
    'classSection',
  );
  @override
  late final GeneratedColumn<String> classSection = GeneratedColumn<String>(
    'class_section',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusCodeMeta = const VerificationMeta(
    'statusCode',
  );
  @override
  late final GeneratedColumn<String> statusCode = GeneratedColumn<String>(
    'status_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientUuidMeta = const VerificationMeta(
    'clientUuid',
  );
  @override
  late final GeneratedColumn<String> clientUuid = GeneratedColumn<String>(
    'client_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    studentId,
    classSection,
    date,
    statusCode,
    clientUuid,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_attendances';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAttendanceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('class_section')) {
      context.handle(
        _classSectionMeta,
        classSection.isAcceptableOrUnknown(
          data['class_section']!,
          _classSectionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_classSectionMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('status_code')) {
      context.handle(
        _statusCodeMeta,
        statusCode.isAcceptableOrUnknown(data['status_code']!, _statusCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_statusCodeMeta);
    }
    if (data.containsKey('client_uuid')) {
      context.handle(
        _clientUuidMeta,
        clientUuid.isAcceptableOrUnknown(data['client_uuid']!, _clientUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_clientUuidMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAttendanceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAttendanceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      classSection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_section'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      statusCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_code'],
      )!,
      clientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_uuid'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $LocalAttendancesTable createAlias(String alias) {
    return $LocalAttendancesTable(attachedDatabase, alias);
  }
}

class LocalAttendanceRow extends DataClass
    implements Insertable<LocalAttendanceRow> {
  final String id;
  final String tenantId;
  final String studentId;
  final String classSection;
  final DateTime date;
  final String statusCode;
  final String clientUuid;
  final bool synced;
  const LocalAttendanceRow({
    required this.id,
    required this.tenantId,
    required this.studentId,
    required this.classSection,
    required this.date,
    required this.statusCode,
    required this.clientUuid,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['student_id'] = Variable<String>(studentId);
    map['class_section'] = Variable<String>(classSection);
    map['date'] = Variable<DateTime>(date);
    map['status_code'] = Variable<String>(statusCode);
    map['client_uuid'] = Variable<String>(clientUuid);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  LocalAttendancesCompanion toCompanion(bool nullToAbsent) {
    return LocalAttendancesCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      studentId: Value(studentId),
      classSection: Value(classSection),
      date: Value(date),
      statusCode: Value(statusCode),
      clientUuid: Value(clientUuid),
      synced: Value(synced),
    );
  }

  factory LocalAttendanceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAttendanceRow(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      classSection: serializer.fromJson<String>(json['classSection']),
      date: serializer.fromJson<DateTime>(json['date']),
      statusCode: serializer.fromJson<String>(json['statusCode']),
      clientUuid: serializer.fromJson<String>(json['clientUuid']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'studentId': serializer.toJson<String>(studentId),
      'classSection': serializer.toJson<String>(classSection),
      'date': serializer.toJson<DateTime>(date),
      'statusCode': serializer.toJson<String>(statusCode),
      'clientUuid': serializer.toJson<String>(clientUuid),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  LocalAttendanceRow copyWith({
    String? id,
    String? tenantId,
    String? studentId,
    String? classSection,
    DateTime? date,
    String? statusCode,
    String? clientUuid,
    bool? synced,
  }) => LocalAttendanceRow(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    studentId: studentId ?? this.studentId,
    classSection: classSection ?? this.classSection,
    date: date ?? this.date,
    statusCode: statusCode ?? this.statusCode,
    clientUuid: clientUuid ?? this.clientUuid,
    synced: synced ?? this.synced,
  );
  LocalAttendanceRow copyWithCompanion(LocalAttendancesCompanion data) {
    return LocalAttendanceRow(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      classSection: data.classSection.present
          ? data.classSection.value
          : this.classSection,
      date: data.date.present ? data.date.value : this.date,
      statusCode: data.statusCode.present
          ? data.statusCode.value
          : this.statusCode,
      clientUuid: data.clientUuid.present
          ? data.clientUuid.value
          : this.clientUuid,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAttendanceRow(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('studentId: $studentId, ')
          ..write('classSection: $classSection, ')
          ..write('date: $date, ')
          ..write('statusCode: $statusCode, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    studentId,
    classSection,
    date,
    statusCode,
    clientUuid,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAttendanceRow &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.studentId == this.studentId &&
          other.classSection == this.classSection &&
          other.date == this.date &&
          other.statusCode == this.statusCode &&
          other.clientUuid == this.clientUuid &&
          other.synced == this.synced);
}

class LocalAttendancesCompanion extends UpdateCompanion<LocalAttendanceRow> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> studentId;
  final Value<String> classSection;
  final Value<DateTime> date;
  final Value<String> statusCode;
  final Value<String> clientUuid;
  final Value<bool> synced;
  final Value<int> rowid;
  const LocalAttendancesCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.classSection = const Value.absent(),
    this.date = const Value.absent(),
    this.statusCode = const Value.absent(),
    this.clientUuid = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAttendancesCompanion.insert({
    required String id,
    required String tenantId,
    required String studentId,
    required String classSection,
    required DateTime date,
    required String statusCode,
    required String clientUuid,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       studentId = Value(studentId),
       classSection = Value(classSection),
       date = Value(date),
       statusCode = Value(statusCode),
       clientUuid = Value(clientUuid);
  static Insertable<LocalAttendanceRow> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? studentId,
    Expression<String>? classSection,
    Expression<DateTime>? date,
    Expression<String>? statusCode,
    Expression<String>? clientUuid,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (studentId != null) 'student_id': studentId,
      if (classSection != null) 'class_section': classSection,
      if (date != null) 'date': date,
      if (statusCode != null) 'status_code': statusCode,
      if (clientUuid != null) 'client_uuid': clientUuid,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAttendancesCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? studentId,
    Value<String>? classSection,
    Value<DateTime>? date,
    Value<String>? statusCode,
    Value<String>? clientUuid,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return LocalAttendancesCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      studentId: studentId ?? this.studentId,
      classSection: classSection ?? this.classSection,
      date: date ?? this.date,
      statusCode: statusCode ?? this.statusCode,
      clientUuid: clientUuid ?? this.clientUuid,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (classSection.present) {
      map['class_section'] = Variable<String>(classSection.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (statusCode.present) {
      map['status_code'] = Variable<String>(statusCode.value);
    }
    if (clientUuid.present) {
      map['client_uuid'] = Variable<String>(clientUuid.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAttendancesCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('studentId: $studentId, ')
          ..write('classSection: $classSection, ')
          ..write('date: $date, ')
          ..write('statusCode: $statusCode, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueEntriesTable extends SyncQueueEntries
    with TableInfo<$SyncQueueEntriesTable, SyncQueueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    operation,
    payload,
    status,
    retryCount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncQueueEntriesTable createAlias(String alias) {
    return $SyncQueueEntriesTable(attachedDatabase, alias);
  }
}

class SyncQueueRow extends DataClass implements Insertable<SyncQueueRow> {
  final int id;
  final String operation;
  final String payload;
  final String status;
  final int retryCount;
  final DateTime createdAt;
  const SyncQueueRow({
    required this.id,
    required this.operation,
    required this.payload,
    required this.status,
    required this.retryCount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncQueueEntriesCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueEntriesCompanion(
      id: Value(id),
      operation: Value(operation),
      payload: Value(payload),
      status: Value(status),
      retryCount: Value(retryCount),
      createdAt: Value(createdAt),
    );
  }

  factory SyncQueueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueRow(
      id: serializer.fromJson<int>(json['id']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncQueueRow copyWith({
    int? id,
    String? operation,
    String? payload,
    String? status,
    int? retryCount,
    DateTime? createdAt,
  }) => SyncQueueRow(
    id: id ?? this.id,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncQueueRow copyWithCompanion(SyncQueueEntriesCompanion data) {
    return SyncQueueRow(
      id: data.id.present ? data.id.value : this.id,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueRow(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, operation, payload, status, retryCount, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueRow &&
          other.id == this.id &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.createdAt == this.createdAt);
}

class SyncQueueEntriesCompanion extends UpdateCompanion<SyncQueueRow> {
  final Value<int> id;
  final Value<String> operation;
  final Value<String> payload;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<DateTime> createdAt;
  const SyncQueueEntriesCompanion({
    this.id = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncQueueEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String operation,
    required String payload,
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : operation = Value(operation),
       payload = Value(payload);
  static Insertable<SyncQueueRow> custom({
    Expression<int>? id,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncQueueEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? operation,
    Value<String>? payload,
    Value<String>? status,
    Value<int>? retryCount,
    Value<DateTime>? createdAt,
  }) {
    return SyncQueueEntriesCompanion(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntriesCompanion(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $LocalNoticesTable extends LocalNotices
    with TableInfo<$LocalNoticesTable, LocalNoticeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalNoticesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hasAttachmentMeta = const VerificationMeta(
    'hasAttachment',
  );
  @override
  late final GeneratedColumn<bool> hasAttachment = GeneratedColumn<bool>(
    'has_attachment',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_attachment" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _targetUserIdMeta = const VerificationMeta(
    'targetUserId',
  );
  @override
  late final GeneratedColumn<String> targetUserId = GeneratedColumn<String>(
    'target_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    title,
    body,
    date,
    category,
    isRead,
    hasAttachment,
    targetUserId,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_notices';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalNoticeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('has_attachment')) {
      context.handle(
        _hasAttachmentMeta,
        hasAttachment.isAcceptableOrUnknown(
          data['has_attachment']!,
          _hasAttachmentMeta,
        ),
      );
    }
    if (data.containsKey('target_user_id')) {
      context.handle(
        _targetUserIdMeta,
        targetUserId.isAcceptableOrUnknown(
          data['target_user_id']!,
          _targetUserIdMeta,
        ),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalNoticeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalNoticeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      hasAttachment: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_attachment'],
      )!,
      targetUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_user_id'],
      ),
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $LocalNoticesTable createAlias(String alias) {
    return $LocalNoticesTable(attachedDatabase, alias);
  }
}

class LocalNoticeRow extends DataClass implements Insertable<LocalNoticeRow> {
  final String id;
  final String tenantId;
  final String title;
  final String body;
  final DateTime date;
  final String category;
  final bool isRead;
  final bool hasAttachment;
  final String? targetUserId;
  final DateTime cachedAt;
  const LocalNoticeRow({
    required this.id,
    required this.tenantId,
    required this.title,
    required this.body,
    required this.date,
    required this.category,
    required this.isRead,
    required this.hasAttachment,
    this.targetUserId,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['date'] = Variable<DateTime>(date);
    map['category'] = Variable<String>(category);
    map['is_read'] = Variable<bool>(isRead);
    map['has_attachment'] = Variable<bool>(hasAttachment);
    if (!nullToAbsent || targetUserId != null) {
      map['target_user_id'] = Variable<String>(targetUserId);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  LocalNoticesCompanion toCompanion(bool nullToAbsent) {
    return LocalNoticesCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      title: Value(title),
      body: Value(body),
      date: Value(date),
      category: Value(category),
      isRead: Value(isRead),
      hasAttachment: Value(hasAttachment),
      targetUserId: targetUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetUserId),
      cachedAt: Value(cachedAt),
    );
  }

  factory LocalNoticeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalNoticeRow(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      date: serializer.fromJson<DateTime>(json['date']),
      category: serializer.fromJson<String>(json['category']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      hasAttachment: serializer.fromJson<bool>(json['hasAttachment']),
      targetUserId: serializer.fromJson<String?>(json['targetUserId']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'date': serializer.toJson<DateTime>(date),
      'category': serializer.toJson<String>(category),
      'isRead': serializer.toJson<bool>(isRead),
      'hasAttachment': serializer.toJson<bool>(hasAttachment),
      'targetUserId': serializer.toJson<String?>(targetUserId),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  LocalNoticeRow copyWith({
    String? id,
    String? tenantId,
    String? title,
    String? body,
    DateTime? date,
    String? category,
    bool? isRead,
    bool? hasAttachment,
    Value<String?> targetUserId = const Value.absent(),
    DateTime? cachedAt,
  }) => LocalNoticeRow(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    title: title ?? this.title,
    body: body ?? this.body,
    date: date ?? this.date,
    category: category ?? this.category,
    isRead: isRead ?? this.isRead,
    hasAttachment: hasAttachment ?? this.hasAttachment,
    targetUserId: targetUserId.present ? targetUserId.value : this.targetUserId,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  LocalNoticeRow copyWithCompanion(LocalNoticesCompanion data) {
    return LocalNoticeRow(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      date: data.date.present ? data.date.value : this.date,
      category: data.category.present ? data.category.value : this.category,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      hasAttachment: data.hasAttachment.present
          ? data.hasAttachment.value
          : this.hasAttachment,
      targetUserId: data.targetUserId.present
          ? data.targetUserId.value
          : this.targetUserId,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalNoticeRow(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('date: $date, ')
          ..write('category: $category, ')
          ..write('isRead: $isRead, ')
          ..write('hasAttachment: $hasAttachment, ')
          ..write('targetUserId: $targetUserId, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    title,
    body,
    date,
    category,
    isRead,
    hasAttachment,
    targetUserId,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalNoticeRow &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.title == this.title &&
          other.body == this.body &&
          other.date == this.date &&
          other.category == this.category &&
          other.isRead == this.isRead &&
          other.hasAttachment == this.hasAttachment &&
          other.targetUserId == this.targetUserId &&
          other.cachedAt == this.cachedAt);
}

class LocalNoticesCompanion extends UpdateCompanion<LocalNoticeRow> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> title;
  final Value<String> body;
  final Value<DateTime> date;
  final Value<String> category;
  final Value<bool> isRead;
  final Value<bool> hasAttachment;
  final Value<String?> targetUserId;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const LocalNoticesCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.date = const Value.absent(),
    this.category = const Value.absent(),
    this.isRead = const Value.absent(),
    this.hasAttachment = const Value.absent(),
    this.targetUserId = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalNoticesCompanion.insert({
    required String id,
    required String tenantId,
    required String title,
    required String body,
    required DateTime date,
    required String category,
    this.isRead = const Value.absent(),
    this.hasAttachment = const Value.absent(),
    this.targetUserId = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       title = Value(title),
       body = Value(body),
       date = Value(date),
       category = Value(category);
  static Insertable<LocalNoticeRow> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? title,
    Expression<String>? body,
    Expression<DateTime>? date,
    Expression<String>? category,
    Expression<bool>? isRead,
    Expression<bool>? hasAttachment,
    Expression<String>? targetUserId,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (date != null) 'date': date,
      if (category != null) 'category': category,
      if (isRead != null) 'is_read': isRead,
      if (hasAttachment != null) 'has_attachment': hasAttachment,
      if (targetUserId != null) 'target_user_id': targetUserId,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalNoticesCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? title,
    Value<String>? body,
    Value<DateTime>? date,
    Value<String>? category,
    Value<bool>? isRead,
    Value<bool>? hasAttachment,
    Value<String?>? targetUserId,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return LocalNoticesCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      title: title ?? this.title,
      body: body ?? this.body,
      date: date ?? this.date,
      category: category ?? this.category,
      isRead: isRead ?? this.isRead,
      hasAttachment: hasAttachment ?? this.hasAttachment,
      targetUserId: targetUserId ?? this.targetUserId,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (hasAttachment.present) {
      map['has_attachment'] = Variable<bool>(hasAttachment.value);
    }
    if (targetUserId.present) {
      map['target_user_id'] = Variable<String>(targetUserId.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalNoticesCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('date: $date, ')
          ..write('category: $category, ')
          ..write('isRead: $isRead, ')
          ..write('hasAttachment: $hasAttachment, ')
          ..write('targetUserId: $targetUserId, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalDiaryEntriesTable extends LocalDiaryEntries
    with TableInfo<$LocalDiaryEntriesTable, LocalDiaryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalDiaryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectMeta = const VerificationMeta(
    'subject',
  );
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
    'subject',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classworkMeta = const VerificationMeta(
    'classwork',
  );
  @override
  late final GeneratedColumn<String> classwork = GeneratedColumn<String>(
    'classwork',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _homeworkMeta = const VerificationMeta(
    'homework',
  );
  @override
  late final GeneratedColumn<String> homework = GeneratedColumn<String>(
    'homework',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classSectionMeta = const VerificationMeta(
    'classSection',
  );
  @override
  late final GeneratedColumn<String> classSection = GeneratedColumn<String>(
    'class_section',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teacherNameMeta = const VerificationMeta(
    'teacherName',
  );
  @override
  late final GeneratedColumn<String> teacherName = GeneratedColumn<String>(
    'teacher_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    date,
    subject,
    classwork,
    homework,
    classSection,
    teacherName,
    completed,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_diary_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalDiaryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('subject')) {
      context.handle(
        _subjectMeta,
        subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectMeta);
    }
    if (data.containsKey('classwork')) {
      context.handle(
        _classworkMeta,
        classwork.isAcceptableOrUnknown(data['classwork']!, _classworkMeta),
      );
    } else if (isInserting) {
      context.missing(_classworkMeta);
    }
    if (data.containsKey('homework')) {
      context.handle(
        _homeworkMeta,
        homework.isAcceptableOrUnknown(data['homework']!, _homeworkMeta),
      );
    } else if (isInserting) {
      context.missing(_homeworkMeta);
    }
    if (data.containsKey('class_section')) {
      context.handle(
        _classSectionMeta,
        classSection.isAcceptableOrUnknown(
          data['class_section']!,
          _classSectionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_classSectionMeta);
    }
    if (data.containsKey('teacher_name')) {
      context.handle(
        _teacherNameMeta,
        teacherName.isAcceptableOrUnknown(
          data['teacher_name']!,
          _teacherNameMeta,
        ),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalDiaryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalDiaryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      subject: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject'],
      )!,
      classwork: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}classwork'],
      )!,
      homework: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}homework'],
      )!,
      classSection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_section'],
      )!,
      teacherName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher_name'],
      ),
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $LocalDiaryEntriesTable createAlias(String alias) {
    return $LocalDiaryEntriesTable(attachedDatabase, alias);
  }
}

class LocalDiaryRow extends DataClass implements Insertable<LocalDiaryRow> {
  final String id;
  final String tenantId;
  final DateTime date;
  final String subject;
  final String classwork;
  final String homework;
  final String classSection;
  final String? teacherName;
  final bool completed;
  final DateTime cachedAt;
  const LocalDiaryRow({
    required this.id,
    required this.tenantId,
    required this.date,
    required this.subject,
    required this.classwork,
    required this.homework,
    required this.classSection,
    this.teacherName,
    required this.completed,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['date'] = Variable<DateTime>(date);
    map['subject'] = Variable<String>(subject);
    map['classwork'] = Variable<String>(classwork);
    map['homework'] = Variable<String>(homework);
    map['class_section'] = Variable<String>(classSection);
    if (!nullToAbsent || teacherName != null) {
      map['teacher_name'] = Variable<String>(teacherName);
    }
    map['completed'] = Variable<bool>(completed);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  LocalDiaryEntriesCompanion toCompanion(bool nullToAbsent) {
    return LocalDiaryEntriesCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      date: Value(date),
      subject: Value(subject),
      classwork: Value(classwork),
      homework: Value(homework),
      classSection: Value(classSection),
      teacherName: teacherName == null && nullToAbsent
          ? const Value.absent()
          : Value(teacherName),
      completed: Value(completed),
      cachedAt: Value(cachedAt),
    );
  }

  factory LocalDiaryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalDiaryRow(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      date: serializer.fromJson<DateTime>(json['date']),
      subject: serializer.fromJson<String>(json['subject']),
      classwork: serializer.fromJson<String>(json['classwork']),
      homework: serializer.fromJson<String>(json['homework']),
      classSection: serializer.fromJson<String>(json['classSection']),
      teacherName: serializer.fromJson<String?>(json['teacherName']),
      completed: serializer.fromJson<bool>(json['completed']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'date': serializer.toJson<DateTime>(date),
      'subject': serializer.toJson<String>(subject),
      'classwork': serializer.toJson<String>(classwork),
      'homework': serializer.toJson<String>(homework),
      'classSection': serializer.toJson<String>(classSection),
      'teacherName': serializer.toJson<String?>(teacherName),
      'completed': serializer.toJson<bool>(completed),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  LocalDiaryRow copyWith({
    String? id,
    String? tenantId,
    DateTime? date,
    String? subject,
    String? classwork,
    String? homework,
    String? classSection,
    Value<String?> teacherName = const Value.absent(),
    bool? completed,
    DateTime? cachedAt,
  }) => LocalDiaryRow(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    date: date ?? this.date,
    subject: subject ?? this.subject,
    classwork: classwork ?? this.classwork,
    homework: homework ?? this.homework,
    classSection: classSection ?? this.classSection,
    teacherName: teacherName.present ? teacherName.value : this.teacherName,
    completed: completed ?? this.completed,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  LocalDiaryRow copyWithCompanion(LocalDiaryEntriesCompanion data) {
    return LocalDiaryRow(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      date: data.date.present ? data.date.value : this.date,
      subject: data.subject.present ? data.subject.value : this.subject,
      classwork: data.classwork.present ? data.classwork.value : this.classwork,
      homework: data.homework.present ? data.homework.value : this.homework,
      classSection: data.classSection.present
          ? data.classSection.value
          : this.classSection,
      teacherName: data.teacherName.present
          ? data.teacherName.value
          : this.teacherName,
      completed: data.completed.present ? data.completed.value : this.completed,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalDiaryRow(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('date: $date, ')
          ..write('subject: $subject, ')
          ..write('classwork: $classwork, ')
          ..write('homework: $homework, ')
          ..write('classSection: $classSection, ')
          ..write('teacherName: $teacherName, ')
          ..write('completed: $completed, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    date,
    subject,
    classwork,
    homework,
    classSection,
    teacherName,
    completed,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalDiaryRow &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.date == this.date &&
          other.subject == this.subject &&
          other.classwork == this.classwork &&
          other.homework == this.homework &&
          other.classSection == this.classSection &&
          other.teacherName == this.teacherName &&
          other.completed == this.completed &&
          other.cachedAt == this.cachedAt);
}

class LocalDiaryEntriesCompanion extends UpdateCompanion<LocalDiaryRow> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<DateTime> date;
  final Value<String> subject;
  final Value<String> classwork;
  final Value<String> homework;
  final Value<String> classSection;
  final Value<String?> teacherName;
  final Value<bool> completed;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const LocalDiaryEntriesCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.date = const Value.absent(),
    this.subject = const Value.absent(),
    this.classwork = const Value.absent(),
    this.homework = const Value.absent(),
    this.classSection = const Value.absent(),
    this.teacherName = const Value.absent(),
    this.completed = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalDiaryEntriesCompanion.insert({
    required String id,
    required String tenantId,
    required DateTime date,
    required String subject,
    required String classwork,
    required String homework,
    required String classSection,
    this.teacherName = const Value.absent(),
    this.completed = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       date = Value(date),
       subject = Value(subject),
       classwork = Value(classwork),
       homework = Value(homework),
       classSection = Value(classSection);
  static Insertable<LocalDiaryRow> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<DateTime>? date,
    Expression<String>? subject,
    Expression<String>? classwork,
    Expression<String>? homework,
    Expression<String>? classSection,
    Expression<String>? teacherName,
    Expression<bool>? completed,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (date != null) 'date': date,
      if (subject != null) 'subject': subject,
      if (classwork != null) 'classwork': classwork,
      if (homework != null) 'homework': homework,
      if (classSection != null) 'class_section': classSection,
      if (teacherName != null) 'teacher_name': teacherName,
      if (completed != null) 'completed': completed,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalDiaryEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<DateTime>? date,
    Value<String>? subject,
    Value<String>? classwork,
    Value<String>? homework,
    Value<String>? classSection,
    Value<String?>? teacherName,
    Value<bool>? completed,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return LocalDiaryEntriesCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      date: date ?? this.date,
      subject: subject ?? this.subject,
      classwork: classwork ?? this.classwork,
      homework: homework ?? this.homework,
      classSection: classSection ?? this.classSection,
      teacherName: teacherName ?? this.teacherName,
      completed: completed ?? this.completed,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (classwork.present) {
      map['classwork'] = Variable<String>(classwork.value);
    }
    if (homework.present) {
      map['homework'] = Variable<String>(homework.value);
    }
    if (classSection.present) {
      map['class_section'] = Variable<String>(classSection.value);
    }
    if (teacherName.present) {
      map['teacher_name'] = Variable<String>(teacherName.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalDiaryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('date: $date, ')
          ..write('subject: $subject, ')
          ..write('classwork: $classwork, ')
          ..write('homework: $homework, ')
          ..write('classSection: $classSection, ')
          ..write('teacherName: $teacherName, ')
          ..write('completed: $completed, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalCanteenOrdersTable extends LocalCanteenOrders
    with TableInfo<$LocalCanteenOrdersTable, LocalCanteenOrderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCanteenOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _clientUuidMeta = const VerificationMeta(
    'clientUuid',
  );
  @override
  late final GeneratedColumn<String> clientUuid = GeneratedColumn<String>(
    'client_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemsJsonMeta = const VerificationMeta(
    'itemsJson',
  );
  @override
  late final GeneratedColumn<String> itemsJson = GeneratedColumn<String>(
    'items_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalPaiseMeta = const VerificationMeta(
    'totalPaise',
  );
  @override
  late final GeneratedColumn<int> totalPaise = GeneratedColumn<int>(
    'total_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentModeMeta = const VerificationMeta(
    'paymentMode',
  );
  @override
  late final GeneratedColumn<String> paymentMode = GeneratedColumn<String>(
    'payment_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _orderedAtMeta = const VerificationMeta(
    'orderedAt',
  );
  @override
  late final GeneratedColumn<DateTime> orderedAt = GeneratedColumn<DateTime>(
    'ordered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientUuid,
    userId,
    itemsJson,
    totalPaise,
    paymentMode,
    status,
    orderedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_canteen_orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCanteenOrderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('client_uuid')) {
      context.handle(
        _clientUuidMeta,
        clientUuid.isAcceptableOrUnknown(data['client_uuid']!, _clientUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_clientUuidMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('items_json')) {
      context.handle(
        _itemsJsonMeta,
        itemsJson.isAcceptableOrUnknown(data['items_json']!, _itemsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_itemsJsonMeta);
    }
    if (data.containsKey('total_paise')) {
      context.handle(
        _totalPaiseMeta,
        totalPaise.isAcceptableOrUnknown(data['total_paise']!, _totalPaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_totalPaiseMeta);
    }
    if (data.containsKey('payment_mode')) {
      context.handle(
        _paymentModeMeta,
        paymentMode.isAcceptableOrUnknown(
          data['payment_mode']!,
          _paymentModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentModeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('ordered_at')) {
      context.handle(
        _orderedAtMeta,
        orderedAt.isAcceptableOrUnknown(data['ordered_at']!, _orderedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCanteenOrderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCanteenOrderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_uuid'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      itemsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}items_json'],
      )!,
      totalPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_paise'],
      )!,
      paymentMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_mode'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      orderedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ordered_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $LocalCanteenOrdersTable createAlias(String alias) {
    return $LocalCanteenOrdersTable(attachedDatabase, alias);
  }
}

class LocalCanteenOrderRow extends DataClass
    implements Insertable<LocalCanteenOrderRow> {
  final int id;
  final String clientUuid;
  final String userId;

  /// JSON-encoded list of OrderLineItem
  final String itemsJson;
  final int totalPaise;
  final String paymentMode;
  final String status;
  final DateTime orderedAt;
  final bool synced;
  const LocalCanteenOrderRow({
    required this.id,
    required this.clientUuid,
    required this.userId,
    required this.itemsJson,
    required this.totalPaise,
    required this.paymentMode,
    required this.status,
    required this.orderedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['client_uuid'] = Variable<String>(clientUuid);
    map['user_id'] = Variable<String>(userId);
    map['items_json'] = Variable<String>(itemsJson);
    map['total_paise'] = Variable<int>(totalPaise);
    map['payment_mode'] = Variable<String>(paymentMode);
    map['status'] = Variable<String>(status);
    map['ordered_at'] = Variable<DateTime>(orderedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  LocalCanteenOrdersCompanion toCompanion(bool nullToAbsent) {
    return LocalCanteenOrdersCompanion(
      id: Value(id),
      clientUuid: Value(clientUuid),
      userId: Value(userId),
      itemsJson: Value(itemsJson),
      totalPaise: Value(totalPaise),
      paymentMode: Value(paymentMode),
      status: Value(status),
      orderedAt: Value(orderedAt),
      synced: Value(synced),
    );
  }

  factory LocalCanteenOrderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCanteenOrderRow(
      id: serializer.fromJson<int>(json['id']),
      clientUuid: serializer.fromJson<String>(json['clientUuid']),
      userId: serializer.fromJson<String>(json['userId']),
      itemsJson: serializer.fromJson<String>(json['itemsJson']),
      totalPaise: serializer.fromJson<int>(json['totalPaise']),
      paymentMode: serializer.fromJson<String>(json['paymentMode']),
      status: serializer.fromJson<String>(json['status']),
      orderedAt: serializer.fromJson<DateTime>(json['orderedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clientUuid': serializer.toJson<String>(clientUuid),
      'userId': serializer.toJson<String>(userId),
      'itemsJson': serializer.toJson<String>(itemsJson),
      'totalPaise': serializer.toJson<int>(totalPaise),
      'paymentMode': serializer.toJson<String>(paymentMode),
      'status': serializer.toJson<String>(status),
      'orderedAt': serializer.toJson<DateTime>(orderedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  LocalCanteenOrderRow copyWith({
    int? id,
    String? clientUuid,
    String? userId,
    String? itemsJson,
    int? totalPaise,
    String? paymentMode,
    String? status,
    DateTime? orderedAt,
    bool? synced,
  }) => LocalCanteenOrderRow(
    id: id ?? this.id,
    clientUuid: clientUuid ?? this.clientUuid,
    userId: userId ?? this.userId,
    itemsJson: itemsJson ?? this.itemsJson,
    totalPaise: totalPaise ?? this.totalPaise,
    paymentMode: paymentMode ?? this.paymentMode,
    status: status ?? this.status,
    orderedAt: orderedAt ?? this.orderedAt,
    synced: synced ?? this.synced,
  );
  LocalCanteenOrderRow copyWithCompanion(LocalCanteenOrdersCompanion data) {
    return LocalCanteenOrderRow(
      id: data.id.present ? data.id.value : this.id,
      clientUuid: data.clientUuid.present
          ? data.clientUuid.value
          : this.clientUuid,
      userId: data.userId.present ? data.userId.value : this.userId,
      itemsJson: data.itemsJson.present ? data.itemsJson.value : this.itemsJson,
      totalPaise: data.totalPaise.present
          ? data.totalPaise.value
          : this.totalPaise,
      paymentMode: data.paymentMode.present
          ? data.paymentMode.value
          : this.paymentMode,
      status: data.status.present ? data.status.value : this.status,
      orderedAt: data.orderedAt.present ? data.orderedAt.value : this.orderedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCanteenOrderRow(')
          ..write('id: $id, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('userId: $userId, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('totalPaise: $totalPaise, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('status: $status, ')
          ..write('orderedAt: $orderedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientUuid,
    userId,
    itemsJson,
    totalPaise,
    paymentMode,
    status,
    orderedAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCanteenOrderRow &&
          other.id == this.id &&
          other.clientUuid == this.clientUuid &&
          other.userId == this.userId &&
          other.itemsJson == this.itemsJson &&
          other.totalPaise == this.totalPaise &&
          other.paymentMode == this.paymentMode &&
          other.status == this.status &&
          other.orderedAt == this.orderedAt &&
          other.synced == this.synced);
}

class LocalCanteenOrdersCompanion
    extends UpdateCompanion<LocalCanteenOrderRow> {
  final Value<int> id;
  final Value<String> clientUuid;
  final Value<String> userId;
  final Value<String> itemsJson;
  final Value<int> totalPaise;
  final Value<String> paymentMode;
  final Value<String> status;
  final Value<DateTime> orderedAt;
  final Value<bool> synced;
  const LocalCanteenOrdersCompanion({
    this.id = const Value.absent(),
    this.clientUuid = const Value.absent(),
    this.userId = const Value.absent(),
    this.itemsJson = const Value.absent(),
    this.totalPaise = const Value.absent(),
    this.paymentMode = const Value.absent(),
    this.status = const Value.absent(),
    this.orderedAt = const Value.absent(),
    this.synced = const Value.absent(),
  });
  LocalCanteenOrdersCompanion.insert({
    this.id = const Value.absent(),
    required String clientUuid,
    required String userId,
    required String itemsJson,
    required int totalPaise,
    required String paymentMode,
    this.status = const Value.absent(),
    this.orderedAt = const Value.absent(),
    this.synced = const Value.absent(),
  }) : clientUuid = Value(clientUuid),
       userId = Value(userId),
       itemsJson = Value(itemsJson),
       totalPaise = Value(totalPaise),
       paymentMode = Value(paymentMode);
  static Insertable<LocalCanteenOrderRow> custom({
    Expression<int>? id,
    Expression<String>? clientUuid,
    Expression<String>? userId,
    Expression<String>? itemsJson,
    Expression<int>? totalPaise,
    Expression<String>? paymentMode,
    Expression<String>? status,
    Expression<DateTime>? orderedAt,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientUuid != null) 'client_uuid': clientUuid,
      if (userId != null) 'user_id': userId,
      if (itemsJson != null) 'items_json': itemsJson,
      if (totalPaise != null) 'total_paise': totalPaise,
      if (paymentMode != null) 'payment_mode': paymentMode,
      if (status != null) 'status': status,
      if (orderedAt != null) 'ordered_at': orderedAt,
      if (synced != null) 'synced': synced,
    });
  }

  LocalCanteenOrdersCompanion copyWith({
    Value<int>? id,
    Value<String>? clientUuid,
    Value<String>? userId,
    Value<String>? itemsJson,
    Value<int>? totalPaise,
    Value<String>? paymentMode,
    Value<String>? status,
    Value<DateTime>? orderedAt,
    Value<bool>? synced,
  }) {
    return LocalCanteenOrdersCompanion(
      id: id ?? this.id,
      clientUuid: clientUuid ?? this.clientUuid,
      userId: userId ?? this.userId,
      itemsJson: itemsJson ?? this.itemsJson,
      totalPaise: totalPaise ?? this.totalPaise,
      paymentMode: paymentMode ?? this.paymentMode,
      status: status ?? this.status,
      orderedAt: orderedAt ?? this.orderedAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clientUuid.present) {
      map['client_uuid'] = Variable<String>(clientUuid.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (itemsJson.present) {
      map['items_json'] = Variable<String>(itemsJson.value);
    }
    if (totalPaise.present) {
      map['total_paise'] = Variable<int>(totalPaise.value);
    }
    if (paymentMode.present) {
      map['payment_mode'] = Variable<String>(paymentMode.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (orderedAt.present) {
      map['ordered_at'] = Variable<DateTime>(orderedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCanteenOrdersCompanion(')
          ..write('id: $id, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('userId: $userId, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('totalPaise: $totalPaise, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('status: $status, ')
          ..write('orderedAt: $orderedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $LocalChatMessagesTable extends LocalChatMessages
    with TableInfo<$LocalChatMessagesTable, LocalChatMessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _threadIdMeta = const VerificationMeta(
    'threadId',
  );
  @override
  late final GeneratedColumn<String> threadId = GeneratedColumn<String>(
    'thread_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderNameMeta = const VerificationMeta(
    'senderName',
  );
  @override
  late final GeneratedColumn<String> senderName = GeneratedColumn<String>(
    'sender_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageTextMeta = const VerificationMeta(
    'messageText',
  );
  @override
  late final GeneratedColumn<String> messageText = GeneratedColumn<String>(
    'message_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _pendingSyncMeta = const VerificationMeta(
    'pendingSync',
  );
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
    'pending_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    threadId,
    senderId,
    senderName,
    messageText,
    timestamp,
    isRead,
    pendingSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalChatMessageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('thread_id')) {
      context.handle(
        _threadIdMeta,
        threadId.isAcceptableOrUnknown(data['thread_id']!, _threadIdMeta),
      );
    } else if (isInserting) {
      context.missing(_threadIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('sender_name')) {
      context.handle(
        _senderNameMeta,
        senderName.isAcceptableOrUnknown(data['sender_name']!, _senderNameMeta),
      );
    } else if (isInserting) {
      context.missing(_senderNameMeta);
    }
    if (data.containsKey('message_text')) {
      context.handle(
        _messageTextMeta,
        messageText.isAcceptableOrUnknown(
          data['message_text']!,
          _messageTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_messageTextMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
        _pendingSyncMeta,
        pendingSync.isAcceptableOrUnknown(
          data['pending_sync']!,
          _pendingSyncMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalChatMessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalChatMessageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      threadId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thread_id'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      )!,
      senderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_name'],
      )!,
      messageText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_text'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      pendingSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_sync'],
      )!,
    );
  }

  @override
  $LocalChatMessagesTable createAlias(String alias) {
    return $LocalChatMessagesTable(attachedDatabase, alias);
  }
}

class LocalChatMessageRow extends DataClass
    implements Insertable<LocalChatMessageRow> {
  final String id;
  final String threadId;
  final String senderId;
  final String senderName;

  /// Message body — named 'messageText' to avoid collision with Drift's text() builder.
  final String messageText;
  final DateTime timestamp;
  final bool isRead;
  final bool pendingSync;
  const LocalChatMessageRow({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.senderName,
    required this.messageText,
    required this.timestamp,
    required this.isRead,
    required this.pendingSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['thread_id'] = Variable<String>(threadId);
    map['sender_id'] = Variable<String>(senderId);
    map['sender_name'] = Variable<String>(senderName);
    map['message_text'] = Variable<String>(messageText);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['is_read'] = Variable<bool>(isRead);
    map['pending_sync'] = Variable<bool>(pendingSync);
    return map;
  }

  LocalChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return LocalChatMessagesCompanion(
      id: Value(id),
      threadId: Value(threadId),
      senderId: Value(senderId),
      senderName: Value(senderName),
      messageText: Value(messageText),
      timestamp: Value(timestamp),
      isRead: Value(isRead),
      pendingSync: Value(pendingSync),
    );
  }

  factory LocalChatMessageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalChatMessageRow(
      id: serializer.fromJson<String>(json['id']),
      threadId: serializer.fromJson<String>(json['threadId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      senderName: serializer.fromJson<String>(json['senderName']),
      messageText: serializer.fromJson<String>(json['messageText']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'threadId': serializer.toJson<String>(threadId),
      'senderId': serializer.toJson<String>(senderId),
      'senderName': serializer.toJson<String>(senderName),
      'messageText': serializer.toJson<String>(messageText),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'isRead': serializer.toJson<bool>(isRead),
      'pendingSync': serializer.toJson<bool>(pendingSync),
    };
  }

  LocalChatMessageRow copyWith({
    String? id,
    String? threadId,
    String? senderId,
    String? senderName,
    String? messageText,
    DateTime? timestamp,
    bool? isRead,
    bool? pendingSync,
  }) => LocalChatMessageRow(
    id: id ?? this.id,
    threadId: threadId ?? this.threadId,
    senderId: senderId ?? this.senderId,
    senderName: senderName ?? this.senderName,
    messageText: messageText ?? this.messageText,
    timestamp: timestamp ?? this.timestamp,
    isRead: isRead ?? this.isRead,
    pendingSync: pendingSync ?? this.pendingSync,
  );
  LocalChatMessageRow copyWithCompanion(LocalChatMessagesCompanion data) {
    return LocalChatMessageRow(
      id: data.id.present ? data.id.value : this.id,
      threadId: data.threadId.present ? data.threadId.value : this.threadId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      senderName: data.senderName.present
          ? data.senderName.value
          : this.senderName,
      messageText: data.messageText.present
          ? data.messageText.value
          : this.messageText,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      pendingSync: data.pendingSync.present
          ? data.pendingSync.value
          : this.pendingSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalChatMessageRow(')
          ..write('id: $id, ')
          ..write('threadId: $threadId, ')
          ..write('senderId: $senderId, ')
          ..write('senderName: $senderName, ')
          ..write('messageText: $messageText, ')
          ..write('timestamp: $timestamp, ')
          ..write('isRead: $isRead, ')
          ..write('pendingSync: $pendingSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    threadId,
    senderId,
    senderName,
    messageText,
    timestamp,
    isRead,
    pendingSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalChatMessageRow &&
          other.id == this.id &&
          other.threadId == this.threadId &&
          other.senderId == this.senderId &&
          other.senderName == this.senderName &&
          other.messageText == this.messageText &&
          other.timestamp == this.timestamp &&
          other.isRead == this.isRead &&
          other.pendingSync == this.pendingSync);
}

class LocalChatMessagesCompanion extends UpdateCompanion<LocalChatMessageRow> {
  final Value<String> id;
  final Value<String> threadId;
  final Value<String> senderId;
  final Value<String> senderName;
  final Value<String> messageText;
  final Value<DateTime> timestamp;
  final Value<bool> isRead;
  final Value<bool> pendingSync;
  final Value<int> rowid;
  const LocalChatMessagesCompanion({
    this.id = const Value.absent(),
    this.threadId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.senderName = const Value.absent(),
    this.messageText = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.isRead = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalChatMessagesCompanion.insert({
    required String id,
    required String threadId,
    required String senderId,
    required String senderName,
    required String messageText,
    required DateTime timestamp,
    this.isRead = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       threadId = Value(threadId),
       senderId = Value(senderId),
       senderName = Value(senderName),
       messageText = Value(messageText),
       timestamp = Value(timestamp);
  static Insertable<LocalChatMessageRow> custom({
    Expression<String>? id,
    Expression<String>? threadId,
    Expression<String>? senderId,
    Expression<String>? senderName,
    Expression<String>? messageText,
    Expression<DateTime>? timestamp,
    Expression<bool>? isRead,
    Expression<bool>? pendingSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (threadId != null) 'thread_id': threadId,
      if (senderId != null) 'sender_id': senderId,
      if (senderName != null) 'sender_name': senderName,
      if (messageText != null) 'message_text': messageText,
      if (timestamp != null) 'timestamp': timestamp,
      if (isRead != null) 'is_read': isRead,
      if (pendingSync != null) 'pending_sync': pendingSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalChatMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? threadId,
    Value<String>? senderId,
    Value<String>? senderName,
    Value<String>? messageText,
    Value<DateTime>? timestamp,
    Value<bool>? isRead,
    Value<bool>? pendingSync,
    Value<int>? rowid,
  }) {
    return LocalChatMessagesCompanion(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      messageText: messageText ?? this.messageText,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      pendingSync: pendingSync ?? this.pendingSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (threadId.present) {
      map['thread_id'] = Variable<String>(threadId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (senderName.present) {
      map['sender_name'] = Variable<String>(senderName.value);
    }
    if (messageText.present) {
      map['message_text'] = Variable<String>(messageText.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('threadId: $threadId, ')
          ..write('senderId: $senderId, ')
          ..write('senderName: $senderName, ')
          ..write('messageText: $messageText, ')
          ..write('timestamp: $timestamp, ')
          ..write('isRead: $isRead, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalAttendancesTable localAttendances = $LocalAttendancesTable(
    this,
  );
  late final $SyncQueueEntriesTable syncQueueEntries = $SyncQueueEntriesTable(
    this,
  );
  late final $LocalNoticesTable localNotices = $LocalNoticesTable(this);
  late final $LocalDiaryEntriesTable localDiaryEntries =
      $LocalDiaryEntriesTable(this);
  late final $LocalCanteenOrdersTable localCanteenOrders =
      $LocalCanteenOrdersTable(this);
  late final $LocalChatMessagesTable localChatMessages =
      $LocalChatMessagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localAttendances,
    syncQueueEntries,
    localNotices,
    localDiaryEntries,
    localCanteenOrders,
    localChatMessages,
  ];
}

typedef $$LocalAttendancesTableCreateCompanionBuilder =
    LocalAttendancesCompanion Function({
      required String id,
      required String tenantId,
      required String studentId,
      required String classSection,
      required DateTime date,
      required String statusCode,
      required String clientUuid,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$LocalAttendancesTableUpdateCompanionBuilder =
    LocalAttendancesCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> studentId,
      Value<String> classSection,
      Value<DateTime> date,
      Value<String> statusCode,
      Value<String> clientUuid,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$LocalAttendancesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAttendancesTable> {
  $$LocalAttendancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classSection => $composableBuilder(
    column: $table.classSection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAttendancesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAttendancesTable> {
  $$LocalAttendancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classSection => $composableBuilder(
    column: $table.classSection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAttendancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAttendancesTable> {
  $$LocalAttendancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get classSection => $composableBuilder(
    column: $table.classSection,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$LocalAttendancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAttendancesTable,
          LocalAttendanceRow,
          $$LocalAttendancesTableFilterComposer,
          $$LocalAttendancesTableOrderingComposer,
          $$LocalAttendancesTableAnnotationComposer,
          $$LocalAttendancesTableCreateCompanionBuilder,
          $$LocalAttendancesTableUpdateCompanionBuilder,
          (
            LocalAttendanceRow,
            BaseReferences<
              _$AppDatabase,
              $LocalAttendancesTable,
              LocalAttendanceRow
            >,
          ),
          LocalAttendanceRow,
          PrefetchHooks Function()
        > {
  $$LocalAttendancesTableTableManager(
    _$AppDatabase db,
    $LocalAttendancesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAttendancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAttendancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAttendancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> classSection = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> statusCode = const Value.absent(),
                Value<String> clientUuid = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAttendancesCompanion(
                id: id,
                tenantId: tenantId,
                studentId: studentId,
                classSection: classSection,
                date: date,
                statusCode: statusCode,
                clientUuid: clientUuid,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String studentId,
                required String classSection,
                required DateTime date,
                required String statusCode,
                required String clientUuid,
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAttendancesCompanion.insert(
                id: id,
                tenantId: tenantId,
                studentId: studentId,
                classSection: classSection,
                date: date,
                statusCode: statusCode,
                clientUuid: clientUuid,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAttendancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAttendancesTable,
      LocalAttendanceRow,
      $$LocalAttendancesTableFilterComposer,
      $$LocalAttendancesTableOrderingComposer,
      $$LocalAttendancesTableAnnotationComposer,
      $$LocalAttendancesTableCreateCompanionBuilder,
      $$LocalAttendancesTableUpdateCompanionBuilder,
      (
        LocalAttendanceRow,
        BaseReferences<
          _$AppDatabase,
          $LocalAttendancesTable,
          LocalAttendanceRow
        >,
      ),
      LocalAttendanceRow,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueEntriesTableCreateCompanionBuilder =
    SyncQueueEntriesCompanion Function({
      Value<int> id,
      required String operation,
      required String payload,
      Value<String> status,
      Value<int> retryCount,
      Value<DateTime> createdAt,
    });
typedef $$SyncQueueEntriesTableUpdateCompanionBuilder =
    SyncQueueEntriesCompanion Function({
      Value<int> id,
      Value<String> operation,
      Value<String> payload,
      Value<String> status,
      Value<int> retryCount,
      Value<DateTime> createdAt,
    });

class $$SyncQueueEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncQueueEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueEntriesTable,
          SyncQueueRow,
          $$SyncQueueEntriesTableFilterComposer,
          $$SyncQueueEntriesTableOrderingComposer,
          $$SyncQueueEntriesTableAnnotationComposer,
          $$SyncQueueEntriesTableCreateCompanionBuilder,
          $$SyncQueueEntriesTableUpdateCompanionBuilder,
          (
            SyncQueueRow,
            BaseReferences<_$AppDatabase, $SyncQueueEntriesTable, SyncQueueRow>,
          ),
          SyncQueueRow,
          PrefetchHooks Function()
        > {
  $$SyncQueueEntriesTableTableManager(
    _$AppDatabase db,
    $SyncQueueEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncQueueEntriesCompanion(
                id: id,
                operation: operation,
                payload: payload,
                status: status,
                retryCount: retryCount,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String operation,
                required String payload,
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncQueueEntriesCompanion.insert(
                id: id,
                operation: operation,
                payload: payload,
                status: status,
                retryCount: retryCount,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueEntriesTable,
      SyncQueueRow,
      $$SyncQueueEntriesTableFilterComposer,
      $$SyncQueueEntriesTableOrderingComposer,
      $$SyncQueueEntriesTableAnnotationComposer,
      $$SyncQueueEntriesTableCreateCompanionBuilder,
      $$SyncQueueEntriesTableUpdateCompanionBuilder,
      (
        SyncQueueRow,
        BaseReferences<_$AppDatabase, $SyncQueueEntriesTable, SyncQueueRow>,
      ),
      SyncQueueRow,
      PrefetchHooks Function()
    >;
typedef $$LocalNoticesTableCreateCompanionBuilder =
    LocalNoticesCompanion Function({
      required String id,
      required String tenantId,
      required String title,
      required String body,
      required DateTime date,
      required String category,
      Value<bool> isRead,
      Value<bool> hasAttachment,
      Value<String?> targetUserId,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });
typedef $$LocalNoticesTableUpdateCompanionBuilder =
    LocalNoticesCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> title,
      Value<String> body,
      Value<DateTime> date,
      Value<String> category,
      Value<bool> isRead,
      Value<bool> hasAttachment,
      Value<String?> targetUserId,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$LocalNoticesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalNoticesTable> {
  $$LocalNoticesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasAttachment => $composableBuilder(
    column: $table.hasAttachment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetUserId => $composableBuilder(
    column: $table.targetUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalNoticesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalNoticesTable> {
  $$LocalNoticesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasAttachment => $composableBuilder(
    column: $table.hasAttachment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetUserId => $composableBuilder(
    column: $table.targetUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalNoticesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalNoticesTable> {
  $$LocalNoticesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<bool> get hasAttachment => $composableBuilder(
    column: $table.hasAttachment,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetUserId => $composableBuilder(
    column: $table.targetUserId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$LocalNoticesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalNoticesTable,
          LocalNoticeRow,
          $$LocalNoticesTableFilterComposer,
          $$LocalNoticesTableOrderingComposer,
          $$LocalNoticesTableAnnotationComposer,
          $$LocalNoticesTableCreateCompanionBuilder,
          $$LocalNoticesTableUpdateCompanionBuilder,
          (
            LocalNoticeRow,
            BaseReferences<_$AppDatabase, $LocalNoticesTable, LocalNoticeRow>,
          ),
          LocalNoticeRow,
          PrefetchHooks Function()
        > {
  $$LocalNoticesTableTableManager(_$AppDatabase db, $LocalNoticesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalNoticesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalNoticesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalNoticesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<bool> hasAttachment = const Value.absent(),
                Value<String?> targetUserId = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalNoticesCompanion(
                id: id,
                tenantId: tenantId,
                title: title,
                body: body,
                date: date,
                category: category,
                isRead: isRead,
                hasAttachment: hasAttachment,
                targetUserId: targetUserId,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String title,
                required String body,
                required DateTime date,
                required String category,
                Value<bool> isRead = const Value.absent(),
                Value<bool> hasAttachment = const Value.absent(),
                Value<String?> targetUserId = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalNoticesCompanion.insert(
                id: id,
                tenantId: tenantId,
                title: title,
                body: body,
                date: date,
                category: category,
                isRead: isRead,
                hasAttachment: hasAttachment,
                targetUserId: targetUserId,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalNoticesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalNoticesTable,
      LocalNoticeRow,
      $$LocalNoticesTableFilterComposer,
      $$LocalNoticesTableOrderingComposer,
      $$LocalNoticesTableAnnotationComposer,
      $$LocalNoticesTableCreateCompanionBuilder,
      $$LocalNoticesTableUpdateCompanionBuilder,
      (
        LocalNoticeRow,
        BaseReferences<_$AppDatabase, $LocalNoticesTable, LocalNoticeRow>,
      ),
      LocalNoticeRow,
      PrefetchHooks Function()
    >;
typedef $$LocalDiaryEntriesTableCreateCompanionBuilder =
    LocalDiaryEntriesCompanion Function({
      required String id,
      required String tenantId,
      required DateTime date,
      required String subject,
      required String classwork,
      required String homework,
      required String classSection,
      Value<String?> teacherName,
      Value<bool> completed,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });
typedef $$LocalDiaryEntriesTableUpdateCompanionBuilder =
    LocalDiaryEntriesCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<DateTime> date,
      Value<String> subject,
      Value<String> classwork,
      Value<String> homework,
      Value<String> classSection,
      Value<String?> teacherName,
      Value<bool> completed,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$LocalDiaryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalDiaryEntriesTable> {
  $$LocalDiaryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classwork => $composableBuilder(
    column: $table.classwork,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homework => $composableBuilder(
    column: $table.homework,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classSection => $composableBuilder(
    column: $table.classSection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacherName => $composableBuilder(
    column: $table.teacherName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalDiaryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalDiaryEntriesTable> {
  $$LocalDiaryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classwork => $composableBuilder(
    column: $table.classwork,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homework => $composableBuilder(
    column: $table.homework,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classSection => $composableBuilder(
    column: $table.classSection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacherName => $composableBuilder(
    column: $table.teacherName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalDiaryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalDiaryEntriesTable> {
  $$LocalDiaryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get classwork =>
      $composableBuilder(column: $table.classwork, builder: (column) => column);

  GeneratedColumn<String> get homework =>
      $composableBuilder(column: $table.homework, builder: (column) => column);

  GeneratedColumn<String> get classSection => $composableBuilder(
    column: $table.classSection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get teacherName => $composableBuilder(
    column: $table.teacherName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$LocalDiaryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalDiaryEntriesTable,
          LocalDiaryRow,
          $$LocalDiaryEntriesTableFilterComposer,
          $$LocalDiaryEntriesTableOrderingComposer,
          $$LocalDiaryEntriesTableAnnotationComposer,
          $$LocalDiaryEntriesTableCreateCompanionBuilder,
          $$LocalDiaryEntriesTableUpdateCompanionBuilder,
          (
            LocalDiaryRow,
            BaseReferences<
              _$AppDatabase,
              $LocalDiaryEntriesTable,
              LocalDiaryRow
            >,
          ),
          LocalDiaryRow,
          PrefetchHooks Function()
        > {
  $$LocalDiaryEntriesTableTableManager(
    _$AppDatabase db,
    $LocalDiaryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalDiaryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalDiaryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalDiaryEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> subject = const Value.absent(),
                Value<String> classwork = const Value.absent(),
                Value<String> homework = const Value.absent(),
                Value<String> classSection = const Value.absent(),
                Value<String?> teacherName = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalDiaryEntriesCompanion(
                id: id,
                tenantId: tenantId,
                date: date,
                subject: subject,
                classwork: classwork,
                homework: homework,
                classSection: classSection,
                teacherName: teacherName,
                completed: completed,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required DateTime date,
                required String subject,
                required String classwork,
                required String homework,
                required String classSection,
                Value<String?> teacherName = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalDiaryEntriesCompanion.insert(
                id: id,
                tenantId: tenantId,
                date: date,
                subject: subject,
                classwork: classwork,
                homework: homework,
                classSection: classSection,
                teacherName: teacherName,
                completed: completed,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalDiaryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalDiaryEntriesTable,
      LocalDiaryRow,
      $$LocalDiaryEntriesTableFilterComposer,
      $$LocalDiaryEntriesTableOrderingComposer,
      $$LocalDiaryEntriesTableAnnotationComposer,
      $$LocalDiaryEntriesTableCreateCompanionBuilder,
      $$LocalDiaryEntriesTableUpdateCompanionBuilder,
      (
        LocalDiaryRow,
        BaseReferences<_$AppDatabase, $LocalDiaryEntriesTable, LocalDiaryRow>,
      ),
      LocalDiaryRow,
      PrefetchHooks Function()
    >;
typedef $$LocalCanteenOrdersTableCreateCompanionBuilder =
    LocalCanteenOrdersCompanion Function({
      Value<int> id,
      required String clientUuid,
      required String userId,
      required String itemsJson,
      required int totalPaise,
      required String paymentMode,
      Value<String> status,
      Value<DateTime> orderedAt,
      Value<bool> synced,
    });
typedef $$LocalCanteenOrdersTableUpdateCompanionBuilder =
    LocalCanteenOrdersCompanion Function({
      Value<int> id,
      Value<String> clientUuid,
      Value<String> userId,
      Value<String> itemsJson,
      Value<int> totalPaise,
      Value<String> paymentMode,
      Value<String> status,
      Value<DateTime> orderedAt,
      Value<bool> synced,
    });

class $$LocalCanteenOrdersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCanteenOrdersTable> {
  $$LocalCanteenOrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemsJson => $composableBuilder(
    column: $table.itemsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPaise => $composableBuilder(
    column: $table.totalPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get orderedAt => $composableBuilder(
    column: $table.orderedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalCanteenOrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCanteenOrdersTable> {
  $$LocalCanteenOrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemsJson => $composableBuilder(
    column: $table.itemsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPaise => $composableBuilder(
    column: $table.totalPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get orderedAt => $composableBuilder(
    column: $table.orderedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalCanteenOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCanteenOrdersTable> {
  $$LocalCanteenOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get itemsJson =>
      $composableBuilder(column: $table.itemsJson, builder: (column) => column);

  GeneratedColumn<int> get totalPaise => $composableBuilder(
    column: $table.totalPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get orderedAt =>
      $composableBuilder(column: $table.orderedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$LocalCanteenOrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalCanteenOrdersTable,
          LocalCanteenOrderRow,
          $$LocalCanteenOrdersTableFilterComposer,
          $$LocalCanteenOrdersTableOrderingComposer,
          $$LocalCanteenOrdersTableAnnotationComposer,
          $$LocalCanteenOrdersTableCreateCompanionBuilder,
          $$LocalCanteenOrdersTableUpdateCompanionBuilder,
          (
            LocalCanteenOrderRow,
            BaseReferences<
              _$AppDatabase,
              $LocalCanteenOrdersTable,
              LocalCanteenOrderRow
            >,
          ),
          LocalCanteenOrderRow,
          PrefetchHooks Function()
        > {
  $$LocalCanteenOrdersTableTableManager(
    _$AppDatabase db,
    $LocalCanteenOrdersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCanteenOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCanteenOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCanteenOrdersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> clientUuid = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> itemsJson = const Value.absent(),
                Value<int> totalPaise = const Value.absent(),
                Value<String> paymentMode = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> orderedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => LocalCanteenOrdersCompanion(
                id: id,
                clientUuid: clientUuid,
                userId: userId,
                itemsJson: itemsJson,
                totalPaise: totalPaise,
                paymentMode: paymentMode,
                status: status,
                orderedAt: orderedAt,
                synced: synced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String clientUuid,
                required String userId,
                required String itemsJson,
                required int totalPaise,
                required String paymentMode,
                Value<String> status = const Value.absent(),
                Value<DateTime> orderedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => LocalCanteenOrdersCompanion.insert(
                id: id,
                clientUuid: clientUuid,
                userId: userId,
                itemsJson: itemsJson,
                totalPaise: totalPaise,
                paymentMode: paymentMode,
                status: status,
                orderedAt: orderedAt,
                synced: synced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalCanteenOrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalCanteenOrdersTable,
      LocalCanteenOrderRow,
      $$LocalCanteenOrdersTableFilterComposer,
      $$LocalCanteenOrdersTableOrderingComposer,
      $$LocalCanteenOrdersTableAnnotationComposer,
      $$LocalCanteenOrdersTableCreateCompanionBuilder,
      $$LocalCanteenOrdersTableUpdateCompanionBuilder,
      (
        LocalCanteenOrderRow,
        BaseReferences<
          _$AppDatabase,
          $LocalCanteenOrdersTable,
          LocalCanteenOrderRow
        >,
      ),
      LocalCanteenOrderRow,
      PrefetchHooks Function()
    >;
typedef $$LocalChatMessagesTableCreateCompanionBuilder =
    LocalChatMessagesCompanion Function({
      required String id,
      required String threadId,
      required String senderId,
      required String senderName,
      required String messageText,
      required DateTime timestamp,
      Value<bool> isRead,
      Value<bool> pendingSync,
      Value<int> rowid,
    });
typedef $$LocalChatMessagesTableUpdateCompanionBuilder =
    LocalChatMessagesCompanion Function({
      Value<String> id,
      Value<String> threadId,
      Value<String> senderId,
      Value<String> senderName,
      Value<String> messageText,
      Value<DateTime> timestamp,
      Value<bool> isRead,
      Value<bool> pendingSync,
      Value<int> rowid,
    });

class $$LocalChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalChatMessagesTable> {
  $$LocalChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get threadId => $composableBuilder(
    column: $table.threadId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageText => $composableBuilder(
    column: $table.messageText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalChatMessagesTable> {
  $$LocalChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get threadId => $composableBuilder(
    column: $table.threadId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageText => $composableBuilder(
    column: $table.messageText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalChatMessagesTable> {
  $$LocalChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get threadId =>
      $composableBuilder(column: $table.threadId, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get messageText => $composableBuilder(
    column: $table.messageText,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => column,
  );
}

class $$LocalChatMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalChatMessagesTable,
          LocalChatMessageRow,
          $$LocalChatMessagesTableFilterComposer,
          $$LocalChatMessagesTableOrderingComposer,
          $$LocalChatMessagesTableAnnotationComposer,
          $$LocalChatMessagesTableCreateCompanionBuilder,
          $$LocalChatMessagesTableUpdateCompanionBuilder,
          (
            LocalChatMessageRow,
            BaseReferences<
              _$AppDatabase,
              $LocalChatMessagesTable,
              LocalChatMessageRow
            >,
          ),
          LocalChatMessageRow,
          PrefetchHooks Function()
        > {
  $$LocalChatMessagesTableTableManager(
    _$AppDatabase db,
    $LocalChatMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalChatMessagesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> threadId = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<String> senderName = const Value.absent(),
                Value<String> messageText = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalChatMessagesCompanion(
                id: id,
                threadId: threadId,
                senderId: senderId,
                senderName: senderName,
                messageText: messageText,
                timestamp: timestamp,
                isRead: isRead,
                pendingSync: pendingSync,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String threadId,
                required String senderId,
                required String senderName,
                required String messageText,
                required DateTime timestamp,
                Value<bool> isRead = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalChatMessagesCompanion.insert(
                id: id,
                threadId: threadId,
                senderId: senderId,
                senderName: senderName,
                messageText: messageText,
                timestamp: timestamp,
                isRead: isRead,
                pendingSync: pendingSync,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalChatMessagesTable,
      LocalChatMessageRow,
      $$LocalChatMessagesTableFilterComposer,
      $$LocalChatMessagesTableOrderingComposer,
      $$LocalChatMessagesTableAnnotationComposer,
      $$LocalChatMessagesTableCreateCompanionBuilder,
      $$LocalChatMessagesTableUpdateCompanionBuilder,
      (
        LocalChatMessageRow,
        BaseReferences<
          _$AppDatabase,
          $LocalChatMessagesTable,
          LocalChatMessageRow
        >,
      ),
      LocalChatMessageRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalAttendancesTableTableManager get localAttendances =>
      $$LocalAttendancesTableTableManager(_db, _db.localAttendances);
  $$SyncQueueEntriesTableTableManager get syncQueueEntries =>
      $$SyncQueueEntriesTableTableManager(_db, _db.syncQueueEntries);
  $$LocalNoticesTableTableManager get localNotices =>
      $$LocalNoticesTableTableManager(_db, _db.localNotices);
  $$LocalDiaryEntriesTableTableManager get localDiaryEntries =>
      $$LocalDiaryEntriesTableTableManager(_db, _db.localDiaryEntries);
  $$LocalCanteenOrdersTableTableManager get localCanteenOrders =>
      $$LocalCanteenOrdersTableTableManager(_db, _db.localCanteenOrders);
  $$LocalChatMessagesTableTableManager get localChatMessages =>
      $$LocalChatMessagesTableTableManager(_db, _db.localChatMessages);
}
