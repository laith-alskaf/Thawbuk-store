import 'package:shared_preferences/shared_preferences.dart';
import '../../core/errors/exceptions.dart';
import '../models/cart_model.dart';
import 'dart:convert';

abstract class CartLocalDataSource {
  Future<CartModel?> getCachedCart();
  Future<void> cacheCart(CartModel cart);
  Future<void> clearCart();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String cartKey = 'cached_cart';

  CartLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<CartModel?> getCachedCart() async {
    try {
      final cartJson = sharedPreferences.getString(cartKey);
      if (cartJson != null) {
        return CartModel.fromJson(jsonDecode(cartJson));
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached cart: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheCart(CartModel cart) async {
    try {
      await sharedPreferences.setString(
        cartKey,
        jsonEncode(cart.toJson()),
      );
    } catch (e) {
      throw CacheException('Failed to cache cart: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCart() async {
    await sharedPreferences.remove(cartKey);
  }
}