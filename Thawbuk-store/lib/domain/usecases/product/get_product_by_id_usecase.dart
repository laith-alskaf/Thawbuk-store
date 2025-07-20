import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

class GetProductByIdUseCase implements UseCase<Product, ProductByIdParams> {
  final ProductRepository repository;

  GetProductByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Product>> call(ProductByIdParams params) async {
    return await repository.getProductById(params.id);
  }
}

class ProductByIdParams extends Equatable {
  final String id;

  const ProductByIdParams(this.id);

  @override
  List<Object> get props => [id];
}