import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../entities/product_entity.dart';
import '../../repositories/product_repository.dart';

class GetMyProductsUseCase extends UseCase<List<ProductEntity>, NoParams> {
  final ProductRepository repository;

  GetMyProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(NoParams params) async {
    return await repository.getMyProducts();
  }
}