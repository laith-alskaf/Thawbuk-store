import 'package:dartz/dartz.dart';
import 'dart:io';

import '../entities/product_entity.dart';
import '../../core/errors/failures.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts();

  Future<Either<Failure, ProductEntity>> getProductById(String id);

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
    required String id,
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

  Future<Either<Failure, void>> deleteProduct(String id);
}