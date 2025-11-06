import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/cart_entity.dart';
import 'product_model.dart';

part 'cart_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CartModel {
  @JsonKey(name: '_id')
  final String id;
  final String userId;
  @JsonKey(name: 'items')
  final List<CartItemModel> items;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CartModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  // Empty cart constructor
  factory CartModel.empty() {
    final now = DateTime.now();
    return CartModel(
      id: 'empty-cart',
      userId: 'temp-user',
      items: const [],
      totalAmount: 0.0,
      createdAt: now,
      updatedAt: now,
    );
  }

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

  factory CartModel.fromEntity(CartEntity entity) {
    return CartModel(
      id: entity.id,
      userId: entity.userId,
      items: entity.items.map((item) => CartItemModel.fromEntity(item)).toList(),
      totalAmount: entity.totalAmount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CartItemModel {
  @JsonKey(name: '_id')
  final String id;
  final String productId;
  @JsonKey(name: 'product')
  final ProductModel product;
  final int quantity;
  final String? selectedSize;
  final String? selectedColor;
  final double unitPrice;
  final double totalPrice;

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.product,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
    required this.unitPrice,
    required this.totalPrice,
  });

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

  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      id: entity.id,
      productId: entity.productId,
      product: ProductModel.fromEntity(entity.product),
      quantity: entity.quantity,
      selectedSize: entity.selectedSize,
      selectedColor: entity.selectedColor,
      unitPrice: entity.unitPrice,
      totalPrice: entity.totalPrice,
    );
  }
}