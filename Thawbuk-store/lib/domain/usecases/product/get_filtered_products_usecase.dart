import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/product_entity.dart';
import '../../repositories/product_repository.dart';

class GetFilteredProductsUseCase
    implements UseCase<List<ProductEntity>, GetFilteredProductsParams> {
  final ProductRepository repository;

  GetFilteredProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(
      GetFilteredProductsParams params) async {
    return await repository.getFilteredProducts(params);
  }
}

class GetFilteredProductsParams extends Equatable {
  final String? category;
  final String? searchQuery;
  final List<String>? sizes;
  final List<String>? colors;
  final double? minPrice;
  final double? maxPrice;
  final String? sortBy;

  const GetFilteredProductsParams({
    this.category,
    this.searchQuery,
    this.sizes,
    this.colors,
    this.minPrice,
    this.maxPrice,
    this.sortBy,
  });

  @override
  List<Object?> get props => [
        category,
        searchQuery,
        sizes,
        colors,
        minPrice,
        maxPrice,
        sortBy,
      ];
}
