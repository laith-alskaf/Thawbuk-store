import 'package:dartz/dartz.dart';
import 'package:thawbuk_store/domain/entities/product_entity.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/product_repository.dart';

class GetProductsUseCase implements UseCase<List<ProductEntity>, NoParams> {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(NoParams params) async {
    return await repository.getProducts();
  }
}