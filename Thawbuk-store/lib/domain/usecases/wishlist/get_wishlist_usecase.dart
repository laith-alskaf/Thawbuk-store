import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../entities/wishlist_entity.dart';
import '../repositories/wishlist_repository.dart';

class GetWishlistUseCase implements UseCase<WishlistEntity, NoParams> {
  final WishlistRepository repository;

  GetWishlistUseCase(this.repository);

  @override
  Future<Either<Failure, WishlistEntity>> call(NoParams params) async {
    return await repository.getWishlist();
  }
}
