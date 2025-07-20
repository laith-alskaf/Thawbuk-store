import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/order_entity.dart';
import 'cart_model.dart';

part 'order_model.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderModel extends OrderEntity {
  @JsonKey(name: 'items')
  @override
  final List<CartItemModel> items;
  
  @JsonKey(name: 'shippingAddress')
  @override
  final AddressModel shippingAddress;

  const OrderModel({
    required super.id,
    required super.userId,
    required this.items,
    required super.totalAmount,
    required super.status,
    required this.shippingAddress,
    super.notes,
    required super.createdAt,
    super.updatedAt,
    super.deliveredAt,
  }) : super(items: items, shippingAddress: shippingAddress);

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return _$OrderModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

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
}

@JsonSerializable(explicitToJson: true)
class AddressModel extends AddressEntity {
  const AddressModel({
    required super.fullName,
    required super.phone,
    required super.street,
    required super.city,
    required super.state,
    required super.country,
    super.postalCode,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return _$AddressModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AddressModelToJson(this);

  AddressEntity toEntity() {
    return AddressEntity(
      fullName: fullName,
      phone: phone,
      street: street,
      city: city,
      state: state,
      country: country,
      postalCode: postalCode,
    );
  }
}