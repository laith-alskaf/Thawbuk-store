import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/cart_entity.dart';
import 'product_model.dart';

part 'cart_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CartItemModel extends CartItemEntity {
  @override
  final ProductModel product;

  const CartItemModel({
    required super.id,
    required super.productId,
    required this.product,
    required super.quantity,
    required super.unitPrice,
    required super.totalPrice,
    super.selectedSize,
    super.selectedColor,
  }) : super(product: product);

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CartModel extends CartEntity {
  @override
  final List<CartItemModel> items;

  const CartModel({
    required super.id,
    required super.userId,
    required this.items,
    required super.totalAmount,
    required super.totalItems,
    required super.createdAt,
    required super.updatedAt,
  }) : super(items: items);

  factory CartModel.fromJson(Map<String, dynamic> json) =>
      _$CartModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartModelToJson(this);
}
