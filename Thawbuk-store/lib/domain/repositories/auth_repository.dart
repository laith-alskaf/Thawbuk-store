import 'package:dartz/dartz.dart';

import '../entities/user_entity.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);

  Future<Either<Failure, UserEntity>> register(Map<String, dynamic> userData);

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Future<bool> isUserLoggedIn();

  Future<Either<Failure, String?>> getToken();

  Future<Either<Failure, void>> verifyEmail(String email, String code);
}
