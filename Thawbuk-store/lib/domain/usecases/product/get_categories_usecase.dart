import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../entities/category_entity.dart';
import '../repositories/product_repository.dart';

class GetCategoriesUseCase implements UseCase<List<CategoryEntity>, NoParams> {
  final ProductRepository repository;

  GetCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(NoParams params) async {
    return await repository.getCategories();
  }
}
