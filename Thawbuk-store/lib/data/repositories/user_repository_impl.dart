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

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.getCurrentUser();
        // Optionally cache the user data here if needed
        // await localDataSource.cacheUser(userModel);
        return Right(userModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      // Optionally load from cache if offline
      // try {
      //   final localUser = await localDataSource.getCachedUser();
      //   return Right(localUser.toEntity());
      // } on CacheException {
      //   return Left(CacheFailure('No cached user found.'));
      // }
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> updateLanguage(String language) async {
    // This logic should be moved to a SettingsRepository
    return const Right(null);
  }
  
  @override
  Future<Either<Failure, void>> updateFcmToken(String token) async {
    // This logic might involve a remote call in the future
    return const Right(null);
  }
}