import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/order.dart';
import 'product_model.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.userId,
    required super.items,
    required super.totalAmount,
    required super.shippingAddress,
    required super.status,
    required super.paymentMethod,
    required super.paymentStatus,
    required super.orderNumber,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return _$OrderModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  Order toEntity() {
    return Order(
      id: id,
      userId: userId,
      items: items.map((item) => item.toEntity()).toList(),
      totalAmount: totalAmount,
      shippingAddress: shippingAddress,
      status: status,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      orderNumber: orderNumber,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

@JsonSerializable()
class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.productId,
    required super.quantity,
    required super.price,
    super.selectedSize,
    super.selectedColor,
    super.product,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return _$OrderItemModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);

  OrderItem toEntity() {
    return OrderItem(
      productId: productId,
      quantity: quantity,
      price: price,
      selectedSize: selectedSize,
      selectedColor: selectedColor,
      product: product?.toEntity(),
    );
  }
}

@JsonSerializable()
class ShippingAddressModel {
  final String street;
  final String city;
  final String country;
  final String? postalCode;
  final String? phone;

  const ShippingAddressModel({
    required this.street,
    required this.city,
    required this.country,
    this.postalCode,
    this.phone,
  });

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json) {
    return _$ShippingAddressModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ShippingAddressModelToJson(this);
}