import 'package:equatable/equatable.dart';
import 'cart_entity.dart';
import 'user_entity.dart'; // For AddressEntity

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
}

enum PaymentMethod {
  cash,
  card,
  online,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
}

class OrderEntity extends Equatable {
  final String id;
  final String userId;
  final List<CartItemEntity> items;
  final double totalAmount;
  final OrderStatus status;
  final AddressEntity shippingAddress;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String orderNumber;
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
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderNumber,
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
        paymentMethod,
        paymentStatus,
        orderNumber,
        notes,
        createdAt,
        updatedAt,
        deliveredAt,
      ];
}
