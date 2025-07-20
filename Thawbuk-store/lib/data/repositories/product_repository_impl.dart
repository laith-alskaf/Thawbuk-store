import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:thawbuk_store/domain/entities/product_entity.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async {
    if (await networkInfo.isConnected) {
      try {
        final productModels = await remoteDataSource.getProducts();
        final products =
            productModels.map((model) => model.toEntity()).toList();
        return Right(products);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final productModel = await remoteDataSource.getProductById(id);
        return Right(productModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts(
      String query) async {
    if (await networkInfo.isConnected) {
      try {
        final productModels = await remoteDataSource.searchProducts(query);
        final products =
            productModels.map((model) => model.toEntity()).toList();
        return Right(products);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
      String category) async {
    if (await networkInfo.isConnected) {
      try {
        final productModels =
            await remoteDataSource.getProductsByCategory(category);
        final products =
            productModels.map((model) => model.toEntity()).toList();
        return Right(products);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct(
      {required String category,
      required List<String> colors,
      required String description,
      required String descriptionAr,
      required List<File> images,
      required String name,
      required String nameAr,
      required double price,
      required int quantity,
      required List<String> sizes}) async {
    if (await networkInfo.isConnected) {
      // try {
      //   final productModel = await remoteDataSource.createProduct(productData);
      //   return Right(productModel.toEntity());
      // } on ServerException catch (e) {
      return Left(ServerFailure('e.message'));
      // }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct(
      {required String category,
      required List<String> colors,
      required String description,
      required String descriptionAr,
      required String id,
      required List<File> images,
      required String name,
      required String nameAr,
      required double price,
      required int quantity,
      required List<String> sizes}) async {
    if (await networkInfo.isConnected) {
      // try {
      //   final productModel =
      //       await remoteDataSource.updateProduct(id, productData);
      //   return Right(productModel.toEntity());
      // } on ServerException catch (e) {
        return Left(ServerFailure('e.message'));
      // }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteProduct(id);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
