import '../../core/errors/exceptions.dart';
import '../../core/network/http_client.dart';
import '../models/cart_model.dart';

abstract class CartRemoteDataSource {
  Future<CartModel> getCart();
  Future<CartModel> addToCart(Map<String, dynamic> cartData);
  Future<CartModel> updateCartItem(Map<String, dynamic> updateData);
  Future<CartModel> removeFromCart(String productId);
  Future<void> clearCart();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final HttpClient httpClient;

  CartRemoteDataSourceImpl(this.httpClient);

  @override
  Future<CartModel> getCart() async {
    try {
      final response = await httpClient.get('/user/cart');
      
      if (response['data'] != null) {
        return CartModel.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        return CartModel.fromJson(response);
      }
    } catch (e) {
      throw ServerException('Failed to get cart: ${e.toString()}');
    }
  }

  @override
  Future<CartModel> addToCart(Map<String, dynamic> cartData) async {
    try {
      final response = await httpClient.post('/user/cart/add', body: cartData);
      
      if (response['data'] != null) {
        return CartModel.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        return CartModel.fromJson(response);
      }
    } catch (e) {
      throw ServerException('Failed to add to cart: ${e.toString()}');
    }
  }

  @override
  Future<CartModel> updateCartItem(Map<String, dynamic> updateData) async {
    try {
      final response = await httpClient.put('/user/cart/update', body: updateData);
      
      if (response['data'] != null) {
        return CartModel.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        return CartModel.fromJson(response);
      }
    } catch (e) {
      throw ServerException('Failed to update cart item: ${e.toString()}');
    }
  }

  @override
  Future<CartModel> removeFromCart(String productId) async {
    try {
      final response = await httpClient.delete('/user/cart/remove/$productId');
      
      // للتعامل مع الحالة التي قد تعيد فيها API cart محدثة أو مجرد message
      if (response.isEmpty) {
        // إذا لم تعد API أي بيانات، نحتاج للحصول على السلة الحالية
        return await getCart();
      }
      
      if (response['data'] != null) {
        return CartModel.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        return CartModel.fromJson(response);
      }
    } catch (e) {
      throw ServerException('Failed to remove from cart: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await httpClient.delete('/user/cart/clear');
    } catch (e) {
      throw ServerException('Failed to clear cart: ${e.toString()}');
    }
  }
}