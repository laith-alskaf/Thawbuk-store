import 'package:dartz/dartz.dart';

import '../entities/user_entity.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);

  Future<Either<Failure, void>> register(Map<String, dynamic> userData);

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Future<bool> isUserLoggedIn();

  Future<Either<Failure, String?>> getToken();

  Future<Either<Failure, void>> verifyEmail(String code);
  
  Future<Either<Failure, void>> resendVerificationCode(String email);
  
  Future<Either<Failure, void>> forgotPassword(String email);
  
  Future<Either<Failure, void>> changePassword(String oldPassword, String newPassword);
  
  Future<Either<Failure, UserEntity>> updateUserProfile(Map<String, dynamic> userData);
}
