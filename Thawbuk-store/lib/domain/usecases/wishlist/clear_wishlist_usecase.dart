import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/wishlist_repository.dart';

class ClearWishlistUseCase implements UseCase<void, NoParams> {
  final WishlistRepository repository;

  ClearWishlistUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.clearWishlist();
  }
}