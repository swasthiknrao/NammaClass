import 'package:dio/dio.dart';

import '../../core/config/env_config.dart';
import '../../core/mock/mock_data.dart';
import '../../core/services/app_logger.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/repositories/staff_repository.dart';

class StaffRepositoryImpl implements StaffRepository {
  StaffRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<StaffMember>> getStaff({
    String? department,
    String? query,
  }) async {
    if (EnvConfig.apiBaseUrl.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      var members = MockData.staff.map(
        (s) => StaffMember(
          id: s.id,
          name: s.name,
          role: s.role,
          department: s.department,
          phone: s.phone,
          email: s.email,
          joinDate: s.joinDate,
          status: s.status,
          salaryCTC: s.salaryCTC,
        ),
      );
      if (department != null && department.isNotEmpty) {
        members = members.where((s) => s.department == department);
      }
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        members = members.where((s) => s.name.toLowerCase().contains(q));
      }
      return members.toList();
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        '/staff',
        queryParameters: {
          if (department != null) 'department': department,
          if (query != null) 'query': query,
        },
      );
      return (response.data ?? [])
          .map((e) => StaffMember.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger.instance.error('StaffRepository: getStaff', e, e.stackTrace);
      return [];
    }
  }

  @override
  Future<StaffMember> getStaffById(String staffId) async {
    if (EnvConfig.apiBaseUrl.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      final match = MockData.staff.where((s) => s.id == staffId).firstOrNull;
      if (match != null) {
        return StaffMember(
          id: match.id,
          name: match.name,
          role: match.role,
          department: match.department,
          phone: match.phone,
          email: match.email,
          joinDate: match.joinDate,
          status: match.status,
          salaryCTC: match.salaryCTC,
        );
      }
      throw Exception('Staff member $staffId not found');
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>('/staff/$staffId');
      return StaffMember.fromJson(response.data!);
    } on DioException catch (e) {
      AppLogger.instance.error(
        'StaffRepository: getStaffById',
        e,
        e.stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<Payslip>> getPayslips(String staffId) async {
    if (EnvConfig.apiBaseUrl.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return MockData.payslips.map((p) {
        // Parse "March 2026" → month=3, year=2026
        final parts = p.month.split(' ');
        final monthNames = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ];
        final month = monthNames.indexOf(parts.first) + 1;
        final year = int.tryParse(parts.last) ?? DateTime.now().year;
        return Payslip(
          id: p.id,
          staffId: staffId,
          month: month.clamp(1, 12),
          year: year,
          grossPaise: p.grossPaise,
          deductionsPaise: p.totalDeductionsPaise,
          netPaise: p.netPaise,
        );
      }).toList();
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        '/payroll',
        queryParameters: {'staffId': staffId},
      );
      return (response.data ?? [])
          .map((e) => Payslip.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger.instance.error('StaffRepository: getPayslips', e, e.stackTrace);
      return [];
    }
  }
}
