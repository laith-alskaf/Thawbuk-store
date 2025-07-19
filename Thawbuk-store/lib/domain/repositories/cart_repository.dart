import 'package:dartz/dartz.dart';

import '../entities/cart_entity.dart';
import '../../core/errors/failures.dart';

abstract class CartRepository {
  Future<Either<Failure, CartEntity>> getCart();

  Future<Either<Failure, CartEntity>> addToCart({
    required String productId,
    required int quantity,
    String? selectedSize,
    String? selectedColor,
  });

  Future<Either<Failure, CartEntity>> updateCartItem({
    required String itemId,
    required int quantity,
  });

  Future<Either<Failure, CartEntity>> removeFromCart(String productId);

  Future<Either<Failure, void>> clearCart();

  Future<Either<Failure, CartEntity>> syncCart();
}