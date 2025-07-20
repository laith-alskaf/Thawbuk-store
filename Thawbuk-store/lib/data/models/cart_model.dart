import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/cart_entity.dart';
import 'product_model.dart';

part 'cart_model.g.dart';

@JsonSerializable()
class CartModel extends CartEntity {
  const CartModel({
    required super.id,
    required super.userId,
    required super.items,
    required super.totalAmount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return _$CartModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CartModelToJson(this);

  CartEntity toEntity() {
    return CartEntity(
      id: id,
      userId: userId,
      items: items.map((item) => (item as CartItemModel).toEntity()).toList(),
      totalAmount: totalAmount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

@JsonSerializable()
class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.id,
    required super.productId,
    required super.product,
    required super.quantity,
    super.selectedSize,
    super.selectedColor,
    required super.unitPrice,
    required super.totalPrice,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return _$CartItemModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CartItemModelToJson(this);

  CartItemEntity toEntity() {
    return CartItemEntity(
      id: id,
      productId: productId,
      product: (product as ProductModel).toEntity(),
      quantity: quantity,
      selectedSize: selectedSize,
      selectedColor: selectedColor,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
    );
  }
}