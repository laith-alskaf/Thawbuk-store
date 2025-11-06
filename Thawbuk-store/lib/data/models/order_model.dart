import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/order_entity.dart';
import 'cart_model.dart';
import 'user_model.dart';

part 'order_model.g.dart';

/// Converter لتحويل enum OrderStatus إلى/من String
class OrderStatusConverter implements JsonConverter<OrderStatus, String> {
  const OrderStatusConverter();

  @override
  OrderStatus fromJson(String json) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == json,
      orElse: () => OrderStatus.pending, // القيمة الافتراضية
    );
  }

  @override
  String toJson(OrderStatus object) => object.name;
}

@JsonSerializable(explicitToJson: true)
class OrderModel {
  @JsonKey(name: '_id')
  final String id;

  final String userId;

  @JsonKey(name: 'items')
  final List<CartItemModel> items;

  final double totalAmount;

  @OrderStatusConverter()
  final OrderStatus status;

  final AddressModel shippingAddress;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;

  const OrderModel({
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

  /// من JSON إلى Model
  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  /// من Model إلى JSON
  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  /// تحويل إلى Entity
  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      userId: userId,
      items: items.map((item) => item.toEntity()).toList(),
      totalAmount: totalAmount,
      status: status,
      shippingAddress: shippingAddress.toEntity(),
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deliveredAt: deliveredAt,
    );
  }

  /// تحويل من Entity إلى Model
  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      userId: entity.userId,
      items: entity.items.map((e) => CartItemModel.fromEntity(e)).toList(),
      totalAmount: entity.totalAmount,
      status: entity.status,
      shippingAddress: AddressModel.fromEntity(entity.shippingAddress),
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deliveredAt: entity.deliveredAt,
    );
  }
}
