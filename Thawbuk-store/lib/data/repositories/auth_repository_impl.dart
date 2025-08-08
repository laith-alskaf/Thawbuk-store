import 'package:dartz/dartz.dart';
import 'package:thawbuk_store/data/models/auth_request_models.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final ApiClient apiClient;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.apiClient,
  });

  @override
  Future<Either<Failure, UserEntity>> login(
      String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final authResponse = await remoteDataSource.login(email, password);
        
        // إصلاح: حفظ التوكن وتحديث ApiClient
        await localDataSource.saveToken(authResponse.token);
        apiClient.updateToken(authResponse.token);
        
        // تحويل UserInfoModel إلى UserModel لحفظها
        final userModel = UserModel(
          id: authResponse.user.id,
          email: authResponse.user.email,
          name: authResponse.user.name,
          role: authResponse.user.role,
          createdAt: DateTime.now(),
          isEmailVerified: true,
          lastLoginAt: DateTime.now(),
        );
        
        await localDataSource.cacheUser(userModel);
        return Right(authResponse.toEntity());
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> register(Map<String, dynamic> userData) async {
    if (await networkInfo.isConnected) {
      try {
        final registerRequest = RegisterRequestModel.fromJson(userData);
        await remoteDataSource.register(registerRequest);
        return const Right(null);
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.logout();
      }
      await localDataSource.clearUserData();
      // مسح التوكن من ApiClient
      apiClient.updateToken(null);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      // تحديث ApiClient بالتوكن المحفوظ
      final token = await localDataSource.getToken();
      if (token != null) {
        apiClient.updateToken(token);
      }
      
      // Try to get from cache first
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser.toEntity());
      }

      // If not in cache and connected, get from remote
      if (await networkInfo.isConnected) {
        final userModel = await remoteDataSource.getCurrentUser();
        await localDataSource.cacheUser(userModel);
        return Right(userModel.toEntity());
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    try {
      final token = await localDataSource.getToken();
      return token != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<Failure, String?>> getToken() async {
    try {
      final token = await localDataSource.getToken();
      return Right(token);
    } on CacheException {
      return const Left(CacheFailure('Failed to get token'));
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmail(String code) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.verifyEmail(code);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> resendVerificationCode(String email) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.resendVerificationCode(email);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.forgotPassword(email);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
      String oldPassword, String newPassword) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.changePassword(oldPassword, newPassword);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUserProfile(Map<String, dynamic> userData) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.updateUserProfile(userData);
        final userEntity = userModel.toEntity();
        
        // حفظ البيانات المحدثة محلياً
        await localDataSource.cacheUser(userModel);
        
        return Right(userEntity);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
