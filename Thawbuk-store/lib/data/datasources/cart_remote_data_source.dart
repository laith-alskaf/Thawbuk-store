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
      
      if (response['success'] == true) {
        final body = response['body'] as Map<String, dynamic>;
        final cart = body['cart'];
        
        if (cart != null) {
          return CartModel.fromJson(cart as Map<String, dynamic>);
        } else {
          // إنشاء سلة فارغة
          return CartModel.empty();
        }
      } else {
        throw ServerException(response['message'] ?? 'فشل في تحميل السلة');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('حدث خطأ أثناء تحميل السلة');
    }
  }

  @override
  Future<CartModel> addToCart(Map<String, dynamic> cartData) async {
    try {
      final response = await httpClient.post('/user/cart/add', body: cartData);
      
      if (response['success'] == true) {
        final body = response['body'] as Map<String, dynamic>;
        final cart = body['cart'];
        
        if (cart != null) {
          return CartModel.fromJson(cart as Map<String, dynamic>);
        } else {
          return CartModel.empty();
        }
      } else {
        throw ServerException(response['message'] ?? 'فشل في إضافة المنتج للسلة');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('حدث خطأ أثناء إضافة المنتج للسلة');
    }
  }

  @override
  Future<CartModel> updateCartItem(Map<String, dynamic> updateData) async {
    try {
      final response = await httpClient.put('/user/cart/update', body: updateData);
      
      if (response['success'] == true) {
        final body = response['body'] as Map<String, dynamic>;
        final cart = body['cart'];
        
        if (cart != null) {
          return CartModel.fromJson(cart as Map<String, dynamic>);
        } else {
          return CartModel.empty();
        }
      } else {
        throw ServerException(response['message'] ?? 'فشل في تحديث السلة');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('حدث خطأ أثناء تحديث السلة');
    }
  }

  @override
  Future<CartModel> removeFromCart(String productId) async {
    try {
      final response = await httpClient.delete('/user/cart/remove/$productId');
      
      if (response['success'] == true) {
        final body = response['body'] as Map<String, dynamic>;
        final cart = body['cart'];
        
        if (cart != null) {
          return CartModel.fromJson(cart as Map<String, dynamic>);
        } else {
          return CartModel.empty();
        }
      } else {
        throw ServerException(response['message'] ?? 'فشل في حذف المنتج من السلة');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('حدث خطأ أثناء حذف المنتج من السلة');
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await httpClient.deleteVoid('/user/cart/clear');
    } catch (e) {
      throw ServerException('Failed to clear cart: ${e.toString()}');
    }
  }
}