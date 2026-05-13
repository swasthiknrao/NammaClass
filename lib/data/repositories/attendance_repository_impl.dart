import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/env_config.dart';
import '../../core/models/result.dart';
import '../../core/providers/app_root_container.dart';
import '../../core/storage/app_database.dart';
import '../../core/mock/mock_data.dart';
import '../../domain/constants/demo_tenant.dart';
import '../../domain/entities/attendance_entities.dart';
import '../../domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl({required AppDatabase db, required Dio dio})
    : _db = db,
      _dio = dio;

  final AppDatabase _db;
  final Dio _dio;
  final Uuid _uuid = const Uuid();

  @override
  Future<Result<List<AttendanceDayEntity>>> getAttendanceDays() async {
    final list = MockData.attendance
        .map(
          (d) => AttendanceDayEntity(
            tenantId: kDemoTenantId,
            date: d.date,
            status: d.status,
            periods: List<String>.from(d.periods),
          ),
        )
        .toList();
    return ResultSuccess(list);
  }

  @override
  Future<Result<bool>> submitClassAttendance({
    required String tenantId,
    required String classSection,
    required DateTime date,
    required String teacherUserId,
    required Map<String, String> recordsByStudentId,
  }) async {
    final today = DateTime(date.year, date.month, date.day);
    final statuses = recordsByStudentId.values;
    if (statuses.isEmpty) {
      return const ResultError('No attendance rows');
    }

    final present = statuses.where((v) => v == 'P').length;
    final absent = statuses.where((v) => v == 'A').length;
    final leave = statuses.where((v) => v == 'L').length;

    final String dayStatus;
    if (present >= absent && present >= leave) {
      dayStatus = 'present';
    } else if (leave > absent) {
      dayStatus = 'leave';
    } else {
      dayStatus = 'absent';
    }

    final periods = dayStatus == 'present'
        ? (MockData.timetable[_weekdayName(today.weekday)] ??
                  const <MockPeriod>[])
              .map((p) => p.subject)
              .toList()
        : <String>[];

    final updated = MockAttendanceDay(
      date: today,
      status: dayStatus,
      periods: periods,
    );

    MockData.attendance =
        MockData.attendance
            .where(
              (d) =>
                  !(d.date.year == today.year &&
                      d.date.month == today.month &&
                      d.date.day == today.day),
            )
            .toList()
          ..add(updated)
          ..sort((a, b) => a.date.compareTo(b.date));

    bumpGlobalDataSync();

    final recordPayload = <Map<String, dynamic>>[];
    for (final e in recordsByStudentId.entries) {
      final cid = _uuid.v4();
      recordPayload.add(<String, dynamic>{
        'student_id': e.key,
        'status': e.value,
        'client_uuid': cid,
      });
      await _db
          .into(_db.localAttendances)
          .insert(
            LocalAttendancesCompanion.insert(
              id: '${tenantId}_${e.key}_${today.millisecondsSinceEpoch}',
              tenantId: tenantId,
              studentId: e.key,
              classSection: classSection,
              date: today,
              statusCode: e.value,
              clientUuid: cid,
              synced: const Value(false),
            ),
          );
    }

    final body = <String, dynamic>{
      'tenant_id': tenantId,
      'class_section': classSection,
      'date': today.toIso8601String(),
      'teacher_user_id': teacherUserId,
      'records': recordPayload,
    };

    var remoteOk = false;
    if (EnvConfig.apiBaseUrl.isNotEmpty) {
      try {
        await _dio.post<Map<String, dynamic>>('/attendance/batch', data: body);
        remoteOk = true;
      } on DioException {
        remoteOk = false;
      }
    }

    if (!remoteOk) {
      await _db
          .into(_db.syncQueueEntries)
          .insert(
            SyncQueueEntriesCompanion.insert(
              operation: 'mark_attendance',
              payload: jsonEncode(body),
            ),
          );
    }

    return const ResultSuccess(true);
  }

  String _weekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return 'Monday';
    }
  }
}
