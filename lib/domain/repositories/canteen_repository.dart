import '../entities/canteen_entity.dart';

/// Contract for the canteen menu and order lifecycle.
abstract class CanteenRepository {
  /// Returns the full menu, optionally filtered by [category].
  Future<List<CanteenItem>> getMenu({String? category});

  /// Places a new order — queued for offline submission if no connectivity.
  Future<CanteenOrder> placeOrder(CanteenOrder order);

  /// Returns order history for [userId].
  Future<List<CanteenOrder>> getOrderHistory(String userId);

  /// Returns the current wallet balance in paise for [userId].
  Future<int> getWalletBalance(String userId);
}
