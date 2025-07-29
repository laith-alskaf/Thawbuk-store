import 'package:dartz/dartz.dart';
import 'package:thawbuk_store/domain/entities/product_entity.dart';
import 'package:thawbuk_store/domain/entities/user_entity.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_data_source.dart';
import '../datasources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> updateProfile(Map<String, dynamic> userData) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.updateProfile(userData);
        return Right(userModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  // @override
  Future<Either<Failure, List<ProductEntity>>> getWishlist() async {
    try {
      if (await networkInfo.isConnected) {
        final productModels = await remoteDataSource.getWishlist();
        final products = productModels.map((model) => model.toEntity()).toList();
        await localDataSource.cacheWishlist(productModels);
        return Right(products);
      } else {
        // Get from local cache when offline
        final cachedProducts = await localDataSource.getCachedWishlist();
        final products = cachedProducts.map((model) => model.toEntity()).toList();
        return Right(products);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  // @override
  Future<Either<Failure, void>> addToWishlist(String productId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.addToWishlist({productId:productId});
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  // @override
  Future<Either<Failure, void>> removeFromWishlist(String productId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.removeFromWishlist(productId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  // @override
  Future<Either<Failure, String>> getLanguage() async {
    try {
      final language = await localDataSource.getLanguage();
      return Right(language ?? 'ar');
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateLanguage(String language) async {
    try {
      await localDataSource.setLanguage(language);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> getThemeMode() async {
    try {
      final themeMode = await localDataSource.getThemeMode();
      return Right(themeMode ?? 'light');
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> setThemeMode(String themeMode) async {
    try {
      await localDataSource.setThemeMode(themeMode);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
  @override
  Future<Either<Failure, void>> updateFcmToken(String token) async {
    // try {
      // await localDataSource.setThemeMode(token);
      return const Right(null);
    // } on CacheException catch (e) {
      // return Left(CacheFailure(e.message));
    // }
  }
  
  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }
}