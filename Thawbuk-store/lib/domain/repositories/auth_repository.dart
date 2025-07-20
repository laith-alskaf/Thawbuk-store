import 'package:dartz/dartz.dart';

import '../entities/user.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);

  Future<Either<Failure, User>> register(Map<String, dynamic> userData);

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User>> getCurrentUser();

  Future<bool> isUserLoggedIn();

  Future<Either<Failure, String?>> getToken();
}