import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, Product>> getProductById(String productId);

  Future<Either<Failure, List<Product>>> getProductsByCategory({
    required String categoryId,
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, List<Product>>> searchProducts({
    required String query,
    String? categoryId,
    int page = 1,
    int limit = 10,
  });

  // للادمن فقط
  Future<Either<Failure, Product>> createProduct({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required List<String> images,
    required List<String> sizes,
    required List<String> colors,
    required int stock,
    String? brand,
    Map<String, int>? ageRange,
  });

  Future<Either<Failure, Product>> updateProduct({
    required String productId,
    String? name,
    String? description,
    double? price,
    String? categoryId,
    List<String>? images,
    List<String>? sizes,
    List<String>? colors,
    int? stock,
    String? brand,
    Map<String, int>? ageRange,
  });

  Future<Either<Failure, void>> deleteProduct(String productId);
}