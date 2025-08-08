import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/store_profile_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/store_repository.dart';
import '../datasources/store_remote_data_source.dart';

class StoreRepositoryImpl implements StoreRepository {
  final StoreRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  StoreRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, StoreProfileEntity>> getStoreProfile(String storeId) async {
    if (await networkInfo.isConnected) {
      try {
        final storeProfile = await remoteDataSource.getStoreProfile(storeId);
        return Right(storeProfile);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure('حدث خطأ غير متوقع'));
      }
    } else {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getStoreProducts(
    String storeId, {
    int page = 1,
    int limit = 20,
    String? category,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final products = await remoteDataSource.getStoreProducts(
          storeId,
          page: page,
          limit: limit,
          category: category,
        );
        return Right(products);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure('حدث خطأ غير متوقع'));
      }
    } else {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, void>> followStore(String storeId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.followStore(storeId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure('حدث خطأ غير متوقع'));
      }
    } else {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, void>> unfollowStore(String storeId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.unfollowStore(storeId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure('حدث خطأ غير متوقع'));
      }
    } else {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, bool>> isFollowingStore(String storeId) async {
    if (await networkInfo.isConnected) {
      try {
        final isFollowing = await remoteDataSource.isFollowingStore(storeId);
        return Right(isFollowing);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure('حدث خطأ غير متوقع'));
      }
    } else {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }
}