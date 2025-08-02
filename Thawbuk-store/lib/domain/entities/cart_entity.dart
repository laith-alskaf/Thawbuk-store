import 'package:equatable/equatable.dart';
import 'product_entity.dart';

class CartEntity extends Equatable {
  final String id;
  final String userId;
  final List<CartItemEntity> items;
  final double totalAmount;
  final int totalItems;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CartEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.totalItems,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isEmpty => items.isEmpty;

  @override
  List<Object?> get props => [
        id,
        userId,
        items,
        totalAmount,
        totalItems,
        createdAt,
        updatedAt,
      ];
}

class CartItemEntity extends Equatable {
  final String id;
  final String productId;
  final ProductEntity product;
  final int quantity;
  final String? selectedSize;
  final String? selectedColor;
  final double unitPrice;
  final double totalPrice;

  const CartItemEntity({
    required this.id,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.selectedSize,
    this.selectedColor,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        product,
        quantity,
        selectedSize,
        selectedColor,
        unitPrice,
        totalPrice,
      ];
}
