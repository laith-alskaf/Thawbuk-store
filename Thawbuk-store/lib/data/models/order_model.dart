import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/order_entity.dart';
import 'cart_model.dart';
import 'user_model.dart'; // For AddressModel

part 'order_model.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderModel extends OrderEntity {
  @override
  final List<CartItemModel> items;

  @override
  final AddressModel shippingAddress;

  const OrderModel({
    required super.id,
    required super.userId,
    required this.items,
    required super.totalAmount,
    required super.status,
    required this.shippingAddress,
    required super.paymentMethod,
    required super.paymentStatus,
    required super.orderNumber,
    super.notes,
    required super.createdAt,
    super.updatedAt,
    super.deliveredAt,
  }) : super(
          items: items,
          shippingAddress: shippingAddress,
        );

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}
