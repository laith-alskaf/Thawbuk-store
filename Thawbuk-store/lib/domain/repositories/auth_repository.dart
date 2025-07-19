import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, Map<String, dynamic>>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> register({
    required String email,
    required String password,
    String? name,
    String role = 'customer',
    int? age,
    String? gender,
    List<Map<String, dynamic>>? children,
    Map<String, dynamic>? address,
    Map<String, dynamic>? companyDetails,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> forgotPassword({
    required String email,
  });

  Future<Either<Failure, void>> verifyEmail({
    required String email,
    required String otpCode,
  });

  Future<Either<Failure, void>> changePassword({
    required String email,
    required String otpCode,
    required String newPassword,
  });

  Future<Either<Failure, User>> getCurrentUser();
  
  Future<bool> isLoggedIn();
  Future<void> saveAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> clearAuthData();
}