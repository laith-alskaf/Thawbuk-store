import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/cart.dart';

abstract class CartRepository {
  Future<Either<Failure, Cart>> getCart();

  Future<Either<Failure, Cart>> addToCart({
    required String productId,
    required int quantity,
    String? selectedSize,
    String? selectedColor,
  });

  Future<Either<Failure, Cart>> updateCartItem({
    required String productId,
    required int quantity,
    String? selectedSize,
    String? selectedColor,
  });

  Future<Either<Failure, Cart>> removeFromCart({
    required String productId,
  });

  Future<Either<Failure, void>> clearCart();

  // للتخزين المحلي
  Future<void> saveCartLocally(Cart cart);
  Future<Cart?> getLocalCart();
  Future<void> clearLocalCart();
}