import 'package:thawbuk_store/data/models/product_model.dart';

import '../../core/network/api_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/wishlist_model.dart';

abstract class WishlistRemoteDataSource {
  Future<WishlistModel> getWishlist();
  Future<void> addToWishlist(String productId);
  Future<void> removeFromWishlist(String productId);
  Future<Map<String, dynamic>> toggleWishlist(String productId);
  Future<void> clearWishlist();
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  final ApiClient _apiClient;

  WishlistRemoteDataSourceImpl(this._apiClient);

  @override
  Future<WishlistModel> getWishlist() async {
    try {
      final response = await _apiClient.get('/user/wishlist/');
      
      if (response['success'] == true) {
        final body = response['body'] as Map<String, dynamic>;
        
        // إنشاء wishlist model مع البيانات المتاحة
        return WishlistModel(
          id: body['_id'] ?? 'temp-id',
          userId: body['userId'] ?? 'temp-user-id',
          products: (body['products'] as List<dynamic>? ?? [])
              .map((product) => ProductModel.fromJson(product as Map<String, dynamic>))
              .toList(),
          createdAt: body['createdAt'] != null 
              ? DateTime.parse(body['createdAt'] as String)
              : DateTime.now(),
          updatedAt: body['updatedAt'] != null 
              ? DateTime.parse(body['updatedAt'] as String)
              : DateTime.now(),
        );
      } else {
        throw ServerException(response['message'] ?? 'فشل في تحميل المفضلة');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('حدث خطأ أثناء تحميل المفضلة');
    }
  }

  @override
  Future<void> addToWishlist(String productId) async {
    try {
      final response = await _apiClient.post(
        '/user/wishlist/',
        data: {'productId': productId},
      );

      if (response['success'] != true) {
        throw ServerException(response['message'] ?? 'فشل في إضافة المنتج للمفضلة');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('حدث خطأ أثناء إضافة المنتج للمفضلة');
    }
  }

  @override
  Future<void> removeFromWishlist(String productId) async {
    try {
      final response = await _apiClient.delete(
        '/user/wishlist/product',
        data: {'productId': productId},
      );

      if (response['success'] != true) {
        throw ServerException(response['message'] ?? 'فشل في حذف المنتج من المفضلة');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('حدث خطأ أثناء حذف المنتج من المفضلة');
    }
  }

  @override
  Future<Map<String, dynamic>> toggleWishlist(String productId) async {
    try {
      final response = await _apiClient.post(
        '/user/wishlist/toggle',
        data: {'productId': productId},
      );

      if (response['success'] == true) {
        return response['body'] ?? {};
      } else {
        throw ServerException(response['message'] ?? 'فشل في تحديث المفضلة');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('حدث خطأ أثناء تحديث المفضلة');
    }
  }

  @override
  Future<void> clearWishlist() async {
    try {
      final response = await _apiClient.delete('/user/wishlist/all-product');

      if (response['success'] != true) {
        throw ServerException(response['message'] ?? 'فشل في مسح المفضلة');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('حدث خطأ أثناء مسح المفضلة');
    }
  }
}