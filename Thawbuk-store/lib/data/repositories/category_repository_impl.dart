import 'package:dartz/dartz.dart';
import 'package:thawbuk_store/domain/entities/category_entity.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_data_source.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CategoryRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final categoryModels = await remoteDataSource.getCategories();
        final categories =
            categoryModels.map((model) => model.toEntity()).toList();
        return Right(categories);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> getCategoryById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final categoryModel = await remoteDataSource.getCategoryById(id);
        return Right(categoryModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> createCategory(
      {String? description,
      String? descriptionAr,
      String? image,
      required String name,
      required String nameAr}) async {
    if (await networkInfo.isConnected) {
      // try {
      // final categoryModel =
      //     await remoteDataSource.createCategory(categoryData);
      // return Right(categoryModel.toEntity());
      // } on ServerException catch (e) {
      return Left(ServerFailure(''));
      // }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> updateCategory(
      {String? description,
      String? descriptionAr,
      required String id,
      String? image,
      required String name,
      required String nameAr}) async {
    if (await networkInfo.isConnected) {
      // try {
      // final categoryModel =
      //     await remoteDataSource.updateCategory(id, categoryData);
      //   return Right(categoryModel.toEntity());
      // } on ServerException catch (e) {
      return Left(ServerFailure(''));
      // }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteCategory(id);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
