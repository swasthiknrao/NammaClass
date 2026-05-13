import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/env_config.dart';
import '../../core/mock/mock_data.dart';
import '../../core/services/app_logger.dart';
import '../../domain/entities/canteen_entity.dart';
import '../../domain/repositories/canteen_repository.dart';

class CanteenRepositoryImpl implements CanteenRepository {
  CanteenRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<CanteenItem>> getMenu({String? category}) async {
    if (EnvConfig.apiBaseUrl.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      var items = MockData.canteenMenu.map(
        (i) => CanteenItem(
          id: i.id,
          name: i.name,
          category: i.category,
          pricePaise: i.pricePaise,
          isVeg: i.isVeg,
          allergens: i.allergens,
          available: i.available,
        ),
      );
      if (category != null && category.isNotEmpty) {
        items = items.where((i) => i.category == category);
      }
      return items.toList();
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        '/canteen/menu',
        queryParameters: {if (category != null) 'category': category},
      );
      return (response.data ?? [])
          .map((e) => CanteenItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger.instance.error('CanteenRepository: getMenu', e, e.stackTrace);
      return [];
    }
  }

  @override
  Future<CanteenOrder> placeOrder(CanteenOrder order) async {
    final id = order.id.isEmpty ? const Uuid().v4() : order.id;
    final payload = order.toJson();

    if (EnvConfig.apiBaseUrl.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return CanteenOrder.fromJson({...payload, 'id': id, 'status': 'placed'});
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/canteen/order',
        data: payload,
      );
      return CanteenOrder.fromJson(response.data!);
    } on DioException catch (e) {
      AppLogger.instance.error(
        'CanteenRepository: placeOrder',
        e,
        e.stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<CanteenOrder>> getOrderHistory(String userId) async {
    if (EnvConfig.apiBaseUrl.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return [];
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        '/canteen/orders',
        queryParameters: {'userId': userId},
      );
      return (response.data ?? [])
          .map((e) => CanteenOrder.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger.instance.error(
        'CanteenRepository: getOrderHistory',
        e,
        e.stackTrace,
      );
      return [];
    }
  }

  @override
  Future<int> getWalletBalance(String userId) async {
    if (EnvConfig.apiBaseUrl.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final wallet = MockData.campusWallets
          .where((w) => w.personId == userId)
          .firstOrNull;
      return wallet?.balancePaise ?? 50000; // ₹500 default demo balance
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/wallet/balance',
        queryParameters: {'userId': userId},
      );
      return (response.data?['balance_paise'] as int?) ?? 0;
    } on DioException catch (e) {
      AppLogger.instance.error(
        'CanteenRepository: getWalletBalance',
        e,
        e.stackTrace,
      );
      return 0;
    }
  }
}
