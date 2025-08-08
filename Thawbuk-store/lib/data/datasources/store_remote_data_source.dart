import '../../core/errors/exceptions.dart';
import '../../core/network/http_client.dart';
import '../models/store_profile_model.dart';
import '../models/product_model.dart';

abstract class StoreRemoteDataSource {
  Future<StoreProfileModel> getStoreProfile(String storeId);
  Future<List<ProductModel>> getStoreProducts(
    String storeId, {
    int page = 1,
    int limit = 20,
    String? category,
  });
  Future<void> followStore(String storeId);
  Future<void> unfollowStore(String storeId);
  Future<bool> isFollowingStore(String storeId);
}

class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  final HttpClient httpClient;

  StoreRemoteDataSourceImpl(this.httpClient);

  @override
  Future<StoreProfileModel> getStoreProfile(String storeId) async {
    try {
      final response = await httpClient.get('/stores/$storeId');
      return StoreProfileModel.fromJson(response);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw const ServerException('حدث خطأ أثناء تحميل بيانات المتجر');
    }
  }

  @override
  Future<List<ProductModel>> getStoreProducts(
    String storeId, {
    int page = 1,
    int limit = 20,
    String? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (category != null) 'category': category,
      };

      final response = await httpClient.get(
        '/stores/$storeId/products',
        queryParameters: queryParams,
      );
      
      final List<dynamic> productsJson = response['products'] ?? [];
      return productsJson
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw const ServerException('حدث خطأ أثناء تحميل منتجات المتجر');
    }
  }

  @override
  Future<void> followStore(String storeId) async {
    try {
      await httpClient.post('/stores/$storeId/follow');
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw const ServerException('حدث خطأ أثناء متابعة المتجر');
    }
  }

  @override
  Future<void> unfollowStore(String storeId) async {
    try {
      await httpClient.delete('/stores/$storeId/follow');
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw const ServerException('حدث خطأ أثناء إلغاء متابعة المتجر');
    }
  }

  @override
  Future<bool> isFollowingStore(String storeId) async {
    try {
      final response = await httpClient.get('/stores/$storeId/following-status');
      return response['isFollowing'] ?? false;
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw const ServerException('حدث خطأ أثناء التحقق من حالة المتابعة');
    }
  }
}