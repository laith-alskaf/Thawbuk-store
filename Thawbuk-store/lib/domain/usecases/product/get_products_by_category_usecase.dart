import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

class GetProductsByCategoryUseCase implements UseCase<List<Product>, GetProductsByCategoryParams> {
  final ProductRepository repository;

  GetProductsByCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(GetProductsByCategoryParams params) async {
    return await repository.getProductsByCategory(params.category);
  }
}

class GetProductsByCategoryParams extends Equatable {
  final String category;

  const GetProductsByCategoryParams({
    required this.category,
  });

  @override
  List<Object> get props => [category];
}