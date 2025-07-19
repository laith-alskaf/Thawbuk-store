import 'package:dartz/dartz.dart';

import '../entities/category_entity.dart';
import '../../core/errors/failures.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  Future<Either<Failure, CategoryEntity>> getCategoryById(String id);

  Future<Either<Failure, CategoryEntity>> createCategory({
    required String name,
    required String nameAr,
    String? description,
    String? descriptionAr,
    String? image,
  });

  Future<Either<Failure, CategoryEntity>> updateCategory({
    required String id,
    required String name,
    required String nameAr,
    String? description,
    String? descriptionAr,
    String? image,
  });

  Future<Either<Failure, void>> deleteCategory(String id);
}