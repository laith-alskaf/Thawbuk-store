import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/wishlist_entity.dart';

abstract class WishlistRepository {
  Future<Either<Failure, WishlistEntity>> getWishlist();
  Future<Either<Failure, void>> addToWishlist(String productId);
  Future<Either<Failure, void>> removeFromWishlist(String productId);
  Future<Either<Failure, Map<String, dynamic>>> toggleWishlist(String productId);
  Future<Either<Failure, void>> clearWishlist();
  Future<Either<Failure, bool>> isInWishlist(String productId);
}