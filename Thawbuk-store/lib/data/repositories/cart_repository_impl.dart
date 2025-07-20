import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';
import '../datasources/cart_remote_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;
  final CartLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  CartRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    try {
      if (await networkInfo.isConnected) {
        final cartModel = await remoteDataSource.getCart();
        await localDataSource.cacheCart(cartModel);
        return Right(cartModel.toEntity());
      } else {
        // Get from local cache when offline
        final cachedCart = await localDataSource.getCachedCart();
        if (cachedCart != null) {
          return Right(cachedCart.toEntity());
        } else {
          return const Left(NetworkFailure('No internet connection and no cached cart'));
        }
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> addToCart(String productId, int quantity, {String? size, String? color}) async {
    if (await networkInfo.isConnected) {
      try {
        final cartData = {
          'productId': productId,
          'quantity': quantity,
          if (size != null) 'size': size,
          if (color != null) 'color': color,
        };
        final cartModel = await remoteDataSource.addToCart(cartData);
        await localDataSource.cacheCart(cartModel);
        return Right(cartModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Cart>> updateCartItem(String productId, int quantity) async {
    if (await networkInfo.isConnected) {
      try {
        final updateData = {
          'productId': productId,
          'quantity': quantity,
        };
        final cartModel = await remoteDataSource.updateCartItem(updateData);
        await localDataSource.cacheCart(cartModel);
        return Right(cartModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Cart>> removeFromCart(String productId) async {
    if (await networkInfo.isConnected) {
      try {
        final cartModel = await remoteDataSource.removeFromCart(productId);
        await localDataSource.cacheCart(cartModel);
        return Right(cartModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.clearCart();
        await localDataSource.clearCart();
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}