import 'dart:convert';
import 'package:hive/hive.dart';
import '../../core/errors/exceptions.dart';
import '../models/wishlist_model.dart';

abstract class WishlistLocalDataSource {
  Future<WishlistModel?> getCachedWishlist();
  Future<void> cacheWishlist(WishlistModel wishlist);
  Future<void> clearWishlistCache();
  Future<bool> isProductInWishlist(String productId);
  Future<void> addProductToCache(String productId);
  Future<void> removeProductFromCache(String productId);
}

class WishlistLocalDataSourceImpl implements WishlistLocalDataSource {
  static const String _wishlistBoxName = 'wishlist';
  static const String _wishlistKey = 'user_wishlist';
  static const String _wishlistProductsKey = 'wishlist_products';

  @override
  Future<WishlistModel?> getCachedWishlist() async {
    try {
      final box = await Hive.openBox(_wishlistBoxName);
      final wishlistJson = box.get(_wishlistKey);
      
      if (wishlistJson != null) {
        final Map<String, dynamic> wishlistMap = 
            Map<String, dynamic>.from(json.decode(wishlistJson));
        return WishlistModel.fromJson(wishlistMap);
      }
      return null;
    } catch (e) {
      throw CacheException('فشل في تحميل المفضلة من التخزين المحلي');
    }
  }

  @override
  Future<void> cacheWishlist(WishlistModel wishlist) async {
    try {
      final box = await Hive.openBox(_wishlistBoxName);
      final wishlistJson = json.encode(wishlist.toJson());
      await box.put(_wishlistKey, wishlistJson);
      
      // Cache product IDs for quick lookup
      final productIds = wishlist.products.map((p) => p.id).toList();
      await box.put(_wishlistProductsKey, productIds);
    } catch (e) {
      throw CacheException('فشل في حفظ المفضلة في التخزين المحلي');
    }
  }

  @override
  Future<void> clearWishlistCache() async {
    try {
      final box = await Hive.openBox(_wishlistBoxName);
      await box.delete(_wishlistKey);
      await box.delete(_wishlistProductsKey);
    } catch (e) {
      throw CacheException('فشل في مسح المفضلة من التخزين المحلي');
    }
  }

  @override
  Future<bool> isProductInWishlist(String productId) async {
    try {
      final box = await Hive.openBox(_wishlistBoxName);
      final productIds = box.get(_wishlistProductsKey, defaultValue: <String>[]);
      return (productIds as List).contains(productId);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> addProductToCache(String productId) async {
    try {
      final box = await Hive.openBox(_wishlistBoxName);
      final productIds = List<String>.from(
          box.get(_wishlistProductsKey, defaultValue: <String>[]));
      
      if (!productIds.contains(productId)) {
        productIds.add(productId);
        await box.put(_wishlistProductsKey, productIds);
      }
    } catch (e) {
      // Silent fail for cache operations
    }
  }

  @override
  Future<void> removeProductFromCache(String productId) async {
    try {
      final box = await Hive.openBox(_wishlistBoxName);
      final productIds = List<String>.from(
          box.get(_wishlistProductsKey, defaultValue: <String>[]));
      
      productIds.remove(productId);
      await box.put(_wishlistProductsKey, productIds);
    } catch (e) {
      // Silent fail for cache operations
    }
  }
}