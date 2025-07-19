import 'package:equatable/equatable.dart';
import 'product_entity.dart';

class CartEntity extends Equatable {
  final String id;
  final String userId;
  final List<CartItemEntity> items;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CartEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;

  @override
  List<Object?> get props => [
        id,
        userId,
        items,
        totalAmount,
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
    this.selectedSize,
    this.selectedColor,
    required this.unitPrice,
    required this.totalPrice,
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