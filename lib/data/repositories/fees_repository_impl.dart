import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import '../../core/config/env_config.dart';
import '../../core/models/result.dart';
import '../../core/mock/mock_data.dart';
import '../../domain/entities/fee_installment_entity.dart';
import '../../domain/repositories/fees_repository.dart';

class FeesRepositoryImpl implements FeesRepository {
  FeesRepositoryImpl(this._dio);

  final Dio _dio;

  Future<bool> _isOnline() async {
    final r = await Connectivity().checkConnectivity();
    return r.any((e) => e != ConnectivityResult.none);
  }

  @override
  Future<Result<List<FeeInstallmentEntity>>> getFeesForStudent({
    required String tenantId,
    required String studentId,
  }) async {
    if (EnvConfig.apiBaseUrl.isNotEmpty) {
      try {
        final res = await _dio.get<Map<String, dynamic>>(
          '/students/$studentId/fees',
        );
        final list = res.data?['items'] as List<dynamic>? ?? [];
        final mapped = list.map((e) {
          final m = e as Map<String, dynamic>;
          return FeeInstallmentEntity(
            id: m['id'] as String,
            tenantId: m['tenant_id'] as String? ?? tenantId,
            label: m['label'] as String,
            amountPaise: (m['amount_paise'] as num).toInt(),
            dueDate: DateTime.parse(m['due_date'] as String),
            status: m['status'] as String,
            paidDate: m['paid_date'] != null
                ? DateTime.tryParse(m['paid_date'] as String)
                : null,
            transactionId: m['transaction_id'] as String?,
          );
        }).toList();
        return ResultSuccess(mapped);
      } on DioException {
        // fallback mock
      }
    }

    final mock = MockData.fees
        .map(
          (f) => FeeInstallmentEntity(
            id: f.id,
            tenantId: tenantId,
            label: f.label,
            amountPaise: f.amountPaise,
            dueDate: f.dueDate,
            status: f.status,
            paidDate: f.paidDate,
            transactionId: f.transactionId,
          ),
        )
        .toList();
    return ResultSuccess(mock);
  }

  @override
  Future<Result<bool>> recordPayment({
    required String tenantId,
    required String installmentId,
    required String transactionReference,
  }) async {
    if (!await _isOnline()) {
      return const ResultError('Fee payments require an internet connection.');
    }
    if (EnvConfig.apiBaseUrl.isEmpty) {
      return const ResultError(
        'Configure API_BASE_URL to record payments against the server.',
      );
    }
    try {
      await _dio.post<Map<String, dynamic>>(
        '/fees/payments',
        data: {
          'tenant_id': tenantId,
          'installment_id': installmentId,
          'transaction_reference': transactionReference,
        },
      );
      return const ResultSuccess(true);
    } on DioException catch (e) {
      return ResultError(e.message ?? 'Payment failed');
    }
  }
}
