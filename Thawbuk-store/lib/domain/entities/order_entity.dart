import 'package:equatable/equatable.dart';
import 'cart_entity.dart';
import 'user_entity.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled
}

extension OrderStatusExtension on OrderStatus {
  String get statusText {
    switch (this) {
      case OrderStatus.pending:
        return 'في الانتظار';
      case OrderStatus.confirmed:
        return 'مؤكد';
      case OrderStatus.processing:
        return 'جاري التحضير';
      case OrderStatus.shipped:
        return 'تم الشحن';
      case OrderStatus.delivered:
        return 'تم التسليم';
      case OrderStatus.cancelled:
        return 'ملغى';
    }
  }
}

class OrderEntity extends Equatable {
  final String id;
  final String userId;
  final List<CartItemEntity> items;
  final double totalAmount;
  final OrderStatus status;
  final AddressEntity shippingAddress;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.deliveredAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        items,
        totalAmount,
        status,
        shippingAddress,
        notes,
        createdAt,
        updatedAt,
        deliveredAt,
      ];
}

// AddressEntity is imported from user_entity.dart