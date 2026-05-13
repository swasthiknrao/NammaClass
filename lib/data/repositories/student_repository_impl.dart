import 'package:dio/dio.dart';

import '../../core/config/env_config.dart';
import '../../core/models/result.dart';
import '../../domain/constants/demo_tenant.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/student_repository.dart';
import '../../core/mock/mock_data.dart';

class StudentRepositoryImpl implements StudentRepository {
  StudentRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<StudentPage>> getStudents({
    required int limit,
    required int offset,
    String? classSection,
  }) async {
    if (EnvConfig.apiBaseUrl.isNotEmpty) {
      try {
        final res = await _dio.get<Map<String, dynamic>>(
          '/students',
          queryParameters: <String, dynamic>{
            'limit': limit,
            'offset': offset,
            if (classSection != null) 'class_section': classSection,
          },
        );
        final data = res.data;
        if (data == null) {
          return const ResultError('Empty students response');
        }
        final raw = data['items'] as List<dynamic>? ?? [];
        final items = raw.map((e) {
          final m = e as Map<String, dynamic>;
          return StudentEntity(
            id: m['id'] as String,
            tenantId: m['tenant_id'] as String? ?? kDemoTenantId,
            name: m['name'] as String,
            rollNo: m['roll_no'] as String? ?? '',
            classSection: m['class_section'] as String? ?? '',
            attendancePercent:
                (m['attendance_percent'] as num?)?.toDouble() ?? 0,
            avatarUrl: m['avatar_url'] as String?,
            parentName: m['parent_name'] as String?,
            parentPhone: m['parent_phone'] as String?,
            feeStatus: m['fee_status'] as String? ?? 'paid',
          );
        }).toList();
        final hasMore = data['has_more'] as bool? ?? false;
        return ResultSuccess(
          StudentPage(items: items, offset: offset, hasMore: hasMore),
        );
      } on DioException {
        // Offline / API error — fall back to mock slice
      }
    }

    var list = MockData.students;
    if (classSection != null) {
      list = list.where((s) => s.classSection == classSection).toList();
    }
    final slice = list.skip(offset).take(limit).toList();
    final entities = slice
        .map(
          (s) => StudentEntity(
            id: s.id,
            tenantId: kDemoTenantId,
            name: s.name,
            rollNo: s.rollNo,
            classSection: s.classSection,
            attendancePercent: s.attendancePercent,
            avatarUrl: s.avatarUrl,
            parentName: s.parentName,
            parentPhone: s.parentPhone,
            feeStatus: s.feeStatus,
          ),
        )
        .toList();
    final hasMore = offset + entities.length < list.length;
    return ResultSuccess(
      StudentPage(items: entities, offset: offset, hasMore: hasMore),
    );
  }
}
