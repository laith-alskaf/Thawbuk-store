import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../repositories/product_repository.dart';

class DeleteProductUseCase implements UseCase<void, DeleteProductParams> {
  final ProductRepository repository;

  DeleteProductUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteProductParams params) async {
    return await repository.deleteProduct(params.productId);
  }
}

class DeleteProductParams extends Equatable {
  final String productId;

  const DeleteProductParams(this.productId);

  @override
  List<Object?> get props => [productId];
}
