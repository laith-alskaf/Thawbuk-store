import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> getUserProfile();

  Future<Either<Failure, User>> updateUserProfile({
    String? name,
    String? email,
    int? age,
    String? gender,
    Map<String, dynamic>? address,
    List<Map<String, dynamic>>? children,
    Map<String, dynamic>? companyDetails,
  });

  Future<Either<Failure, void>> deleteAccount();

  Future<Either<Failure, void>> updateFCMToken(String token);

  // للتخزين المحلي
  Future<void> saveUserLocally(User user);
  Future<User?> getLocalUser();
  Future<void> clearLocalUser();
}