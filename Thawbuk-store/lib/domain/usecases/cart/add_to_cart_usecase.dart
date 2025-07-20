import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/cart_entity.dart';
import '../../repositories/cart_repository.dart';

class AddToCartUseCase implements UseCase<CartEntity, AddToCartParams> {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  @override
  Future<Either<Failure, CartEntity>> call(AddToCartParams params) async {
    return await repository.addToCart(
      params.productId,
      params.quantity,
      size: params.size,
      color: params.color,
    );
  }
}

class AddToCartParams extends Equatable {
  final String productId;
  final int quantity;
  final String? size;
  final String? color;

  const AddToCartParams({
    required this.productId,
    required this.quantity,
    this.size,
    this.color,
  });

  @override
  List<Object?> get props => [productId, quantity, size, color];
}