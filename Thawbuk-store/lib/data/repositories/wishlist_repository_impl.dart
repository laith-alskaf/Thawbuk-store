import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/wishlist_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_remote_data_source.dart';
import '../datasources/wishlist_local_data_source.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistRemoteDataSource remoteDataSource;
  final WishlistLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  WishlistRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, WishlistEntity>> getWishlist() async {
    try {
      // Try to get from cache first
      final cachedWishlist = await localDataSource.getCachedWishlist();
      
      if (await networkInfo.isConnected) {
        try {
          final wishlistModel = await remoteDataSource.getWishlist();
          await localDataSource.cacheWishlist(wishlistModel);
          return Right(wishlistModel.toEntity());
        } catch (e) {
          // If network fails but we have cache, return cache
          if (cachedWishlist != null) {
            return Right(cachedWishlist.toEntity());
          }
          rethrow;
        }
      } else {
        // No network, return cache if available
        if (cachedWishlist != null) {
          return Right(cachedWishlist.toEntity());
        } else {
          return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
        }
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, void>> addToWishlist(String productId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.addToWishlist(productId);
        await localDataSource.addProductToCache(productId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromWishlist(String productId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.removeFromWishlist(productId);
        await localDataSource.removeProductFromCache(productId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> toggleWishlist(String productId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.toggleWishlist(productId);
        
        // Update local cache based on result
        if (result['added'] == true) {
          await localDataSource.addProductToCache(productId);
        } else {
          await localDataSource.removeProductFromCache(productId);
        }
        
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, void>> clearWishlist() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.clearWishlist();
        await localDataSource.clearWishlistCache();
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, bool>> isInWishlist(String productId) async {
    try {
      final isInCache = await localDataSource.isProductInWishlist(productId);
      return Right(isInCache);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}