import 'package:dartz/dartz.dart';

import '../entities/user_entity.dart';
import '../../core/errors/failures.dart';

abstract class UserRepository {
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Future<Either<Failure, UserEntity>> updateProfile(Map<String, dynamic> userData);
  Future<Either<Failure, void>> updateLanguage(String language);
  Future<Either<Failure, void>> updateFcmToken(String token);
}