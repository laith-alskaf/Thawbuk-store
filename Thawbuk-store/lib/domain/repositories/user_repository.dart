import 'package:dartz/dartz.dart';

import '../entities/user.dart';
import '../entities/product.dart';
import '../../core/errors/failures.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> updateProfile(Map<String, dynamic> userData);
  
  Future<Either<Failure, List<Product>>> getWishlist();
  
  Future<Either<Failure, void>> addToWishlist(String productId);
  
  Future<Either<Failure, void>> removeFromWishlist(String productId);
  
  Future<Either<Failure, String>> getLanguage();
  
  Future<Either<Failure, void>> setLanguage(String language);
  
  Future<Either<Failure, String>> getThemeMode();
  
  Future<Either<Failure, void>> setThemeMode(String themeMode);
}