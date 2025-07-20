import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getCurrentUser();
  Future<UserModel> updateProfile(Map<String, dynamic> userData);
  Future<List<ProductModel>> getWishlist();
  Future<void> addToWishlist(String productId);
  Future<void> removeFromWishlist(String productId);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient apiClient;

  UserRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await apiClient.getCurrentUser();
      return response;
    } catch (e) {
      throw ServerException('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> userData) async {
    try {
      // Note: This endpoint might need to be added to ApiClient
      // For now using getCurrentUser as placeholder
      final response = await apiClient.getCurrentUser();
      return response;
    } catch (e) {
      throw ServerException('Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductModel>> getWishlist() async {
    try {
      final response = await apiClient.getWishlist();
      return response;
    } catch (e) {
      throw ServerException('Failed to get wishlist: ${e.toString()}');
    }
  }

  @override
  Future<void> addToWishlist(String productId) async {
    try {
      await apiClient.addToWishlist({'productId': productId});
    } catch (e) {
      throw ServerException('Failed to add to wishlist: ${e.toString()}');
    }
  }

  @override
  Future<void> removeFromWishlist(String productId) async {
    try {
      await apiClient.removeFromWishlist(productId);
    } catch (e) {
      throw ServerException('Failed to remove from wishlist: ${e.toString()}');
    }
  }
}