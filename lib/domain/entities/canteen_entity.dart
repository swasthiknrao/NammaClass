/// A single menu item in the canteen catalog.
class CanteenItem {
  const CanteenItem({
    required this.id,
    required this.name,
    required this.category,
    required this.pricePaise,
    this.isVeg = true,
    this.allergens = const [],
    this.available = true,
    this.imageUrl,
    this.calories,
    this.ratingAvg,
    this.ratingCount = 0,
    this.campusPointsCost,
  });

  final String id;
  final String name;
  final String category;

  /// Price in paise (100 paise = ₹1) — avoids floating-point issues.
  final int pricePaise;
  final bool isVeg;
  final List<String> allergens;
  final bool available;
  final String? imageUrl;
  final int? calories;
  final double? ratingAvg;
  final int ratingCount;

  /// If non-null, students can also pay with campus points.
  final int? campusPointsCost;

  factory CanteenItem.fromJson(Map<String, dynamic> json) => CanteenItem(
    id: json['id'] as String,
    name: json['name'] as String,
    category: (json['category'] as String?) ?? 'Other',
    pricePaise: (json['price_paise'] as int?) ?? 0,
    isVeg: (json['is_veg'] as bool?) ?? true,
    allergens: List<String>.from(json['allergens'] as List? ?? []),
    available: (json['available'] as bool?) ?? true,
    imageUrl: json['image_url'] as String?,
    calories: json['calories'] as int?,
    ratingAvg: (json['rating_avg'] as num?)?.toDouble(),
    ratingCount: (json['rating_count'] as int?) ?? 0,
    campusPointsCost: json['campus_points_cost'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'price_paise': pricePaise,
    'is_veg': isVeg,
    'allergens': allergens,
    'available': available,
    'image_url': imageUrl,
    'calories': calories,
    'rating_avg': ratingAvg,
    'rating_count': ratingCount,
    'campus_points_cost': campusPointsCost,
  };
}

/// A canteen order placed by a student/staff.
class CanteenOrder {
  const CanteenOrder({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPaise,
    required this.status,
    required this.orderedAt,
    this.pickedUpAt,
    this.paymentMode = 'wallet',
  });

  final String id;
  final String userId;
  final List<OrderLineItem> items;
  final int totalPaise;

  /// "placed" | "preparing" | "ready" | "collected" | "cancelled"
  final String status;
  final DateTime orderedAt;
  final DateTime? pickedUpAt;

  /// "wallet" | "cash" | "points"
  final String paymentMode;

  factory CanteenOrder.fromJson(Map<String, dynamic> json) => CanteenOrder(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    items: (json['items'] as List<dynamic>? ?? [])
        .map((e) => OrderLineItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    totalPaise: (json['total_paise'] as int?) ?? 0,
    status: (json['status'] as String?) ?? 'placed',
    orderedAt: DateTime.parse(json['ordered_at'] as String),
    pickedUpAt: json['picked_up_at'] != null
        ? DateTime.parse(json['picked_up_at'] as String)
        : null,
    paymentMode: (json['payment_mode'] as String?) ?? 'wallet',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'items': items.map((i) => i.toJson()).toList(),
    'total_paise': totalPaise,
    'status': status,
    'ordered_at': orderedAt.toIso8601String(),
    'picked_up_at': pickedUpAt?.toIso8601String(),
    'payment_mode': paymentMode,
  };
}

/// One line in a canteen order.
class OrderLineItem {
  const OrderLineItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPricePaise,
  });

  final String itemId;
  final String itemName;
  final int quantity;
  final int unitPricePaise;

  int get subtotalPaise => quantity * unitPricePaise;

  factory OrderLineItem.fromJson(Map<String, dynamic> json) => OrderLineItem(
    itemId: json['item_id'] as String,
    itemName: (json['item_name'] as String?) ?? '',
    quantity: (json['quantity'] as int?) ?? 1,
    unitPricePaise: (json['unit_price_paise'] as int?) ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'item_id': itemId,
    'item_name': itemName,
    'quantity': quantity,
    'unit_price_paise': unitPricePaise,
  };
}
