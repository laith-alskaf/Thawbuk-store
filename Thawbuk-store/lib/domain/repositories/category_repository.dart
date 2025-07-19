import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/category.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getCategories();

  Future<Either<Failure, Category>> getCategoryById(String categoryId);

  // للادمن فقط
  Future<Either<Failure, Category>> createCategory({
    required String name,
    String? description,
    required String image,
  });

  Future<Either<Failure, Category>> updateCategory({
    required String categoryId,
    String? name,
    String? description,
    String? image,
  });

  Future<Either<Failure, void>> deleteCategory(String categoryId);
}