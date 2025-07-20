import 'package:dartz/dartz.dart';

import '../entities/cart.dart';
import '../../core/errors/failures.dart';

abstract class CartRepository {
  Future<Either<Failure, Cart>> getCart();

  Future<Either<Failure, Cart>> addToCart(String productId, int quantity, {String? size, String? color});

  Future<Either<Failure, Cart>> updateCartItem(String productId, int quantity);

  Future<Either<Failure, Cart>> removeFromCart(String productId);

  Future<Either<Failure, void>> clearCart();
}