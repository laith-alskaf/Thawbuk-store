import 'package:equatable/equatable.dart';
import 'product.dart';

class Cart extends Equatable {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final int totalItems;

  const Cart({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.totalItems,
  });

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  double get displayTotalAmount => totalAmount;
  
  CartItem? findItem(String productId, {String? size, String? color}) {
    try {
      return items.firstWhere(
        (item) =>
            item.productId == productId &&
            item.selectedSize == size &&
            item.selectedColor == color,
      );
    } catch (e) {
      return null;
    }
  }

  int getItemQuantity(String productId, {String? size, String? color}) {
    final item = findItem(productId, size: size, color: color);
    return item?.quantity ?? 0;
  }

  @override
  List<Object?> get props => [id, userId, items, totalAmount, totalItems];
}

class CartItem extends Equatable {
  final String productId;
  final int quantity;
  final String? selectedSize;
  final String? selectedColor;
  final Product? product;

  const CartItem({
    required this.productId,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
    this.product,
  });

  double get totalPrice {
    if (product == null) return 0.0;
    return product!.price * quantity;
  }

  String get displayText {
    final parts = <String>[];
    if (selectedSize != null) parts.add('المقاس: $selectedSize');
    if (selectedColor != null) parts.add('اللون: $selectedColor');
    return parts.join(' • ');
  }

  @override
  List<Object?> get props => [
        productId,
        quantity,
        selectedSize,
        selectedColor,
        product,
      ];
}