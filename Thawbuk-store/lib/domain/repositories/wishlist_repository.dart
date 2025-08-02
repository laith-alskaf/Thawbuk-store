import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/wishlist_entity.dart';

abstract class WishlistRepository {
  Future<Either<Failure, WishlistEntity>> getWishlist();
  Future<Either<Failure, WishlistEntity>> toggleWishlist(String productId);
}
