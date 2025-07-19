import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/cart.dart';
import 'product_model.dart';

part 'cart_model.g.dart';

@JsonSerializable()
class CartModel extends Cart {
  const CartModel({
    required super.id,
    required super.userId,
    required super.items,
    required super.totalAmount,
    required super.totalItems,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return _$CartModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CartModelToJson(this);

  Cart toEntity() {
    return Cart(
      id: id,
      userId: userId,
      items: items.map((item) => item.toEntity()).toList(),
      totalAmount: totalAmount,
      totalItems: totalItems,
    );
  }
}

@JsonSerializable()
class CartItemModel extends CartItem {
  const CartItemModel({
    required super.productId,
    required super.quantity,
    super.selectedSize,
    super.selectedColor,
    super.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return _$CartItemModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CartItemModelToJson(this);

  CartItem toEntity() {
    return CartItem(
      productId: productId,
      quantity: quantity,
      selectedSize: selectedSize,
      selectedColor: selectedColor,
      product: product?.toEntity(),
    );
  }
}