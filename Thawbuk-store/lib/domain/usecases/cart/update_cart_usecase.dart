import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/cart.dart';
import '../../repositories/cart_repository.dart';

class UpdateCartUseCase implements UseCase<Cart, UpdateCartParams> {
  final CartRepository repository;

  UpdateCartUseCase(this.repository);

  @override
  Future<Either<Failure, Cart>> call(UpdateCartParams params) async {
    return await repository.updateCartItem(params.productId, params.quantity);
  }
}

class UpdateCartParams extends Equatable {
  final String productId;
  final int quantity;

  const UpdateCartParams({
    required this.productId,
    required this.quantity,
  });

  @override
  List<Object> get props => [productId, quantity];
}