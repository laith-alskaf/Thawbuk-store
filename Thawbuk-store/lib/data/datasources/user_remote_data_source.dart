import '../../core/errors/exceptions.dart';
import '../../core/network/http_client.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getCurrentUser();
  Future<UserModel> updateProfile(Map<String, dynamic> userData);
  Future<List<ProductModel>> getWishlist();
  Future<void> addToWishlist(Map<String, dynamic> wishlistData);
  Future<void> removeFromWishlist(String productId);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final HttpClient httpClient;

  UserRemoteDataSourceImpl(this.httpClient);

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await httpClient.get('/user/me');
      
      if (response['data'] != null) {
        return UserModel.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        return UserModel.fromJson(response);
      }
    } catch (e) {
      throw ServerException('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> userData) async {
    try {
      final response = await httpClient.put('/user/me', body: userData);
      
      if (response['data'] != null) {
        return UserModel.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        return UserModel.fromJson(response);
      }
    } catch (e) {
      throw ServerException('Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductModel>> getWishlist() async {
    try {
      final response = await httpClient.get('/user/wishlist');
      
      if (response['data'] is List) {
        return (response['data'] as List)
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response is List) {
        return response
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      throw ServerException('Invalid response format for wishlist');
    } catch (e) {
      throw ServerException('Failed to get wishlist: ${e.toString()}');
    }
  }

  @override
  Future<void> addToWishlist(Map<String, dynamic> wishlistData) async {
    try {
      await httpClient.post('/user/wishlist', body: wishlistData);
    } catch (e) {
      throw ServerException('Failed to add to wishlist: ${e.toString()}');
    }
  }

  @override
  Future<void> removeFromWishlist(String productId) async {
    try {
      await httpClient.deleteVoid('/user/wishlist/$productId');
    } catch (e) {
      throw ServerException('Failed to remove from wishlist: ${e.toString()}');
    }
  }
}