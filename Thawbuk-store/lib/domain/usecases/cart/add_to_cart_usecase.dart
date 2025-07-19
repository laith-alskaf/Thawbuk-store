import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/cart.dart';
import '../../repositories/cart_repository.dart';

class AddToCartUseCase implements UseCase<Cart, AddToCartParams> {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  @override
  Future<Either<Failure, Cart>> call(AddToCartParams params) async {
    return await repository.addToCart(
      productId: params.productId,
      quantity: params.quantity,
      selectedSize: params.selectedSize,
      selectedColor: params.selectedColor,
    );
  }
}

class AddToCartParams {
  final String productId;
  final int quantity;
  final String? selectedSize;
  final String? selectedColor;

  AddToCartParams({
    required this.productId,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
  });
}