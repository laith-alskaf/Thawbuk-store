import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../entities/wishlist_entity.dart';
import '../repositories/wishlist_repository.dart';

class ToggleWishlistUseCase implements UseCase<WishlistEntity, ToggleWishlistParams> {
  final WishlistRepository repository;

  ToggleWishlistUseCase(this.repository);

  @override
  Future<Either<Failure, WishlistEntity>> call(ToggleWishlistParams params) async {
    return await repository.toggleWishlist(params.productId);
  }
}

class ToggleWishlistParams extends Equatable {
  final String productId;

  const ToggleWishlistParams({required this.productId});

  @override
  List<Object> get props => [productId];
}
