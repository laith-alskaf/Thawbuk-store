import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../models/cart_model.dart';

abstract class CartRemoteDataSource {
  Future<CartModel> getCart();
  Future<CartModel> addToCart(Map<String, dynamic> cartData);
  Future<CartModel> updateCartItem(Map<String, dynamic> updateData);
  Future<CartModel> removeFromCart(String productId);
  Future<void> clearCart();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final ApiClient apiClient;

  CartRemoteDataSourceImpl(this.apiClient);

  @override
  Future<CartModel> getCart() async {
    try {
      final response = await apiClient.getCart();
      return response;
    } catch (e) {
      throw ServerException('Failed to get cart: ${e.toString()}');
    }
  }

  @override
  Future<CartModel> addToCart(Map<String, dynamic> cartData) async {
    try {
      final response = await apiClient.addToCart(cartData);
      return response;
    } catch (e) {
      throw ServerException('Failed to add to cart: ${e.toString()}');
    }
  }

  @override
  Future<CartModel> updateCartItem(Map<String, dynamic> updateData) async {
    try {
      final response = await apiClient.updateCartItem(updateData);
      return response;
    } catch (e) {
      throw ServerException('Failed to update cart item: ${e.toString()}');
    }
  }

  @override
  Future<CartModel> removeFromCart(String productId) async {
    try {
      final response = await apiClient.removeFromCart(productId);
      return response;
    } catch (e) {
      throw ServerException('Failed to remove from cart: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await apiClient.clearCart();
    } catch (e) {
      throw ServerException('Failed to clear cart: ${e.toString()}');
    }
  }
}