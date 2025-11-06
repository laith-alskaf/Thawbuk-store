import 'package:equatable/equatable.dart';
import 'product_entity.dart';

class WishlistEntity extends Equatable {
  final String id;
  final String userId;
  final List<ProductEntity> products;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WishlistEntity({
    required this.id,
    required this.userId,
    required this.products,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isEmpty => products.isEmpty;
  int get itemsCount => products.length;

  bool containsProduct(String productId) {
    return products.any((product) => product.id == productId);
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        products,
        createdAt,
        updatedAt,
      ];
}