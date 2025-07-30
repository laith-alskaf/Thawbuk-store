import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/product_entity.dart';
import '../../repositories/store_repository.dart';

class GetStoreProductsUseCase implements UseCase<List<ProductEntity>, GetStoreProductsParams> {
  final StoreRepository repository;

  GetStoreProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(GetStoreProductsParams params) async {
    return await repository.getStoreProducts(
      params.storeId,
      page: params.page,
      limit: params.limit,
      category: params.category,
    );
  }
}

class GetStoreProductsParams extends Equatable {
  final String storeId;
  final int page;
  final int limit;
  final String? category;

  const GetStoreProductsParams({
    required this.storeId,
    this.page = 1,
    this.limit = 20,
    this.category,
  });

  @override
  List<Object?> get props => [storeId, page, limit, category];
}