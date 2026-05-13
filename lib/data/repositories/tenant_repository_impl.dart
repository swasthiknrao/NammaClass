import 'package:dio/dio.dart';

import '../../core/config/env_config.dart';
import '../../core/config/tenant_config_asset.dart';
import '../../core/mock/mock_tenant_profiles.dart';
import '../../core/services/app_logger.dart';
import '../../domain/entities/tenant_profile.dart';
import '../../domain/repositories/tenant_repository.dart';

/// Fetches tenant config from the remote API when [EnvConfig.apiBaseUrl] is set,
/// otherwise returns a mock profile for development / demo mode.
class TenantRepositoryImpl implements TenantRepository {
  TenantRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<TenantProfile> fetchTenantConfig(String tenantId) async {
    if (EnvConfig.apiBaseUrl.isEmpty) {
      // Mock mode — prefer editable `assets/config/tenant_config.json`, then
      // bundled sample profiles keyed by [tenantId].
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final fromJsonFile = await loadTenantProfileFromAsset();
      if (fromJsonFile != null) {
        return fromJsonFile;
      }
      return MockTenantProfiles.byId[tenantId] ?? MockTenantProfiles.demo;
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/tenant/config',
        queryParameters: {'tenantId': tenantId},
      );
      final data = response.data;
      if (data == null) throw Exception('Empty tenant config response');
      return TenantProfile.fromJson(data);
    } on DioException catch (e) {
      AppLogger.instance.error(
        'TenantRepository: failed to fetch config for $tenantId',
        e,
        e.stackTrace,
      );
      // Graceful degradation — fall back to demo profile so the app stays usable.
      return MockTenantProfiles.demo;
    }
  }
}
