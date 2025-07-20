import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import 'dart:convert';

abstract class UserLocalDataSource {
  Future<String?> getLanguage();
  Future<void> setLanguage(String language);
  Future<String?> getThemeMode();
  Future<void> setThemeMode(String themeMode);
  Future<List<ProductModel>> getCachedWishlist();
  Future<void> cacheWishlist(List<ProductModel> wishlist);
  Future<void> clearWishlist();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String wishlistKey = 'cached_wishlist';

  UserLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<String?> getLanguage() async {
    return sharedPreferences.getString(AppConstants.languageKey);
  }

  @override
  Future<void> setLanguage(String language) async {
    await sharedPreferences.setString(AppConstants.languageKey, language);
  }

  @override
  Future<String?> getThemeMode() async {
    return sharedPreferences.getString(AppConstants.themeKey);
  }

  @override
  Future<void> setThemeMode(String themeMode) async {
    await sharedPreferences.setString(AppConstants.themeKey, themeMode);
  }

  @override
  Future<List<ProductModel>> getCachedWishlist() async {
    try {
      final wishlistJson = sharedPreferences.getString(wishlistKey);
      if (wishlistJson != null) {
        final List<dynamic> jsonList = jsonDecode(wishlistJson);
        return jsonList.map((json) => ProductModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw CacheException('Failed to get cached wishlist: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheWishlist(List<ProductModel> wishlist) async {
    try {
      final jsonList = wishlist.map((product) => product.toJson()).toList();
      await sharedPreferences.setString(
        wishlistKey,
        jsonEncode(jsonList),
      );
    } catch (e) {
      throw CacheException('Failed to cache wishlist: ${e.toString()}');
    }
  }

  @override
  Future<void> clearWishlist() async {
    await sharedPreferences.remove(wishlistKey);
  }
}