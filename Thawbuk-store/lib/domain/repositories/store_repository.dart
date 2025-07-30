import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/store_profile_entity.dart';
import '../entities/product_entity.dart';

abstract class StoreRepository {
  Future<Either<Failure, StoreProfileEntity>> getStoreProfile(String storeId);
  Future<Either<Failure, List<ProductEntity>>> getStoreProducts(
    String storeId, {
    int page = 1,
    int limit = 20,
    String? category,
  });
  Future<Either<Failure, void>> followStore(String storeId);
  Future<Either<Failure, void>> unfollowStore(String storeId);
  Future<Either<Failure, bool>> isFollowingStore(String storeId);
}