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
      productId: params.productId,
      quantity: params.quantity,
      selectedSize: params.selectedSize,
      selectedColor: params.selectedColor,
    );
  }
}

class AddToCartParams extends Equatable {
  final String productId;
  final int quantity;
  final String? selectedSize;
  final String? selectedColor;

  const AddToCartParams({
    required this.productId,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
  });

  @override
  List<Object?> get props => [productId, quantity, selectedSize, selectedColor];
}