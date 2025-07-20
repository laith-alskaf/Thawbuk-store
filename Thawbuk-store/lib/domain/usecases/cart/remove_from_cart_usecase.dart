import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/cart.dart';
import '../../repositories/cart_repository.dart';

class RemoveFromCartUseCase implements UseCase<Cart, RemoveFromCartParams> {
  final CartRepository repository;

  RemoveFromCartUseCase(this.repository);

  @override
  Future<Either<Failure, Cart>> call(RemoveFromCartParams params) async {
    return await repository.removeFromCart(params.productId);
  }
}

class RemoveFromCartParams extends Equatable {
  final String productId;

  const RemoveFromCartParams({
    required this.productId,
  });

  @override
  List<Object> get props => [productId];
}