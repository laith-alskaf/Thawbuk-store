import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../entities/product_entity.dart';
import '../usecases/product/get_filtered_products_usecase.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getFilteredProducts(
      GetFilteredProductsParams params);
  Future<Either<Failure, List<ProductEntity>>> getProducts();
  Future<Either<Failure, ProductEntity>> getProductById(String productId);
  Future<Either<Failure, List<ProductEntity>>> searchProducts(String query);
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(String category);
  Future<Either<Failure, ProductEntity>> createProduct({
    required String name,
    required String nameAr,
    required String description,
    required String descriptionAr,
    required double price,
    required String category,
    required List<String> sizes,
    required List<String> colors,
    required int quantity,
    required List<File> images,
  });
  Future<Either<Failure, ProductEntity>> updateProduct({
    required String productId,
    required String name,
    required String nameAr,
    required String description,
    required String descriptionAr,
    required double price,
    required String category,
    required List<String> sizes,
    required List<String> colors,
    required int quantity,
    required List<File> images,
  });
  Future<Either<Failure, void>> deleteProduct(String productId);
  Future<Either<Failure, List<ProductEntity>>> getMyProducts();
}
