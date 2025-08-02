import 'package:equatable/equatable.dart';
import 'product_entity.dart';

class WishlistEntity extends Equatable {
  final List<ProductEntity> products;

  const WishlistEntity({
    required this.products,
  });

  @override
  List<Object?> get props => [products];
}
