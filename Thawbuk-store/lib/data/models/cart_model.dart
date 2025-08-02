import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/cart_entity.dart';
import 'product_model.dart';

part 'cart_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CartModel extends CartEntity {
  @JsonKey(name: 'items')
  @override
  final List<CartItemModel> items;

  const CartModel({
    required super.id,
    required super.userId,
    required this.items,
    required super.totalAmount,
    required super.createdAt,
    required super.updatedAt,
  }) : super(items: items);

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return _$CartModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CartModelToJson(this);

  CartEntity toEntity() {
    return CartEntity(
      id: id,
      userId: userId,
      items: items.map((item) => item.toEntity()).toList(),
      totalAmount: totalAmount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CartItemModel extends CartItemEntity {
  @JsonKey(name: 'product')
  @override
  final ProductModel product;

  const CartItemModel({
    required super.id,
    required super.productId,
    required this.product,
    required super.quantity,
    super.selectedSize,
    super.selectedColor,
    required super.unitPrice,
    required super.totalPrice,
  }) : super(product: product);

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return _$CartItemModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CartItemModelToJson(this);

  CartItemEntity toEntity() {
    return CartItemEntity(
      id: id,
      productId: productId,
      product: product.toEntity(),
      quantity: quantity,
      selectedSize: selectedSize,
      selectedColor: selectedColor,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
    );
  }
}