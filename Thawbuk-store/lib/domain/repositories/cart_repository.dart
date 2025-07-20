import 'package:dartz/dartz.dart';

import '../entities/cart_entity.dart';
import '../../core/errors/failures.dart';

abstract class CartRepository {
  Future<Either<Failure, CartEntity>> getCart();

  Future<Either<Failure, CartEntity>> addToCart(String productId, int quantity, {String? size, String? color});

  Future<Either<Failure, CartEntity>> updateCartItem(String productId, int quantity);

  Future<Either<Failure, CartEntity>> removeFromCart(String productId);

  Future<Either<Failure, void>> clearCart();
}