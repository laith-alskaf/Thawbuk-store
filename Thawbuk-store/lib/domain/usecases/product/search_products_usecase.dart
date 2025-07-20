import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:thawbuk_store/domain/entities/product_entity.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/product_repository.dart';

class SearchProductsUseCase implements UseCase<List<ProductEntity>, SearchProductsParams> {
  final ProductRepository repository;

  SearchProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(SearchProductsParams params) async {
    return await repository.searchProducts(params.query);
  }
}

class SearchProductsParams extends Equatable {
  final String query;

  const SearchProductsParams({
    required this.query,
  });

  @override
  List<Object> get props => [query];
}