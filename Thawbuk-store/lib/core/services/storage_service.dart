import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../errors/failures.dart';

class StorageService {
  static const String _authTokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _languageKey = 'language';
  static const String _themeKey = 'theme';
  static const String _onboardingKey = 'onboarding_completed';
  static const String _cartBoxName = 'cart';
  static const String _wishlistBoxName = 'wishlist';
  static const String _settingsBoxName = 'settings';

  late SharedPreferences _prefs;
  late Box _cartBox;
  late Box _wishlistBox;
  late Box _settingsBox;

  // تهيئة الخدمة
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      
      // تهيئة Hive boxes
      _cartBox = await Hive.openBox(_cartBoxName);
      _wishlistBox = await Hive.openBox(_wishlistBoxName);
      _settingsBox = await Hive.openBox(_settingsBoxName);
    } catch (e) {
      throw CacheFailure(message: 'فشل في تهيئة التخزين المحلي: $e');
    }
  }

  // === إدارة المصادقة ===

  // حفظ التوكن
  Future<void> saveAuthToken(String token) async {
    try {
      await _prefs.setString(_authTokenKey, token);
    } catch (e) {
      throw CacheFailure.writeError();
    }
  }

  // الحصول على التوكن
  Future<String?> getAuthToken() async {
    try {
      return _prefs.getString(_authTokenKey);
    } catch (e) {
      throw CacheFailure.readError();
    }
  }

  // إزالة التوكن
  Future<void> removeAuthToken() async {
    try {
      await _prefs.remove(_authTokenKey);
    } catch (e) {
      throw CacheFailure.writeError();
    }
  }

  // التحقق من وجود التوكن
  Future<bool> hasAuthToken() async {
    try {
      final token = await getAuthToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // === إدارة بيانات المستخدم ===

  // حفظ بيانات المستخدم
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final jsonString = jsonEncode(userData);
      await _prefs.setString(_userDataKey, jsonString);
    } catch (e) {
      throw CacheFailure.writeError();
    }
  }

  // الحصول على بيانات المستخدم
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final jsonString = _prefs.getString(_userDataKey);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw CacheFailure.readError();
    }
  }

  // إزالة بيانات المستخدم
  Future<void> removeUserData() async {
    try {
      await _prefs.remove(_userDataKey);
    } catch (e) {
      throw CacheFailure.writeError();
    }
  }

  // === إدارة الإعدادات ===

  // حفظ اللغة
  Future<void> saveLanguage(String languageCode) async {
    try {
      await _prefs.setString(_languageKey, languageCode);
    } catch (e) {
      throw CacheFailure.writeError();
    }
  }

  // الحصول على اللغة
  Future<String> getLanguage() async {
    try {
      return _prefs.getString(_languageKey) ?? 'ar';
    } catch (e) {
      return 'ar';
    }
  }

  // حفظ المظهر
  Future<void> saveTheme(String theme) async {
    try {
      await _prefs.setString(_themeKey, theme);
    } catch (e) {
      throw CacheFailure.writeError();
    }
  }

  // الحصول على المظهر
  Future<String> getTheme() async {
    try {
      return _prefs.getString(_themeKey) ?? 'light';
    } catch (e) {
      return 'light';
    }
  }

  // حفظ حالة إكمال التعريف بالتطبيق
  Future<void> setOnboardingCompleted(bool completed) async {
    try {
      await _prefs.setBool(_onboardingKey, completed);
    } catch (e) {
      throw CacheFailure.writeError();
    }
  }

  // التحقق من إكمال التعريف بالتطبيق
  Future<bool> isOnboardingCompleted() async {
    try {
      return _prefs.getBool(_onboardingKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  // === إدارة السلة المحلية ===

  // حفظ السلة
  Future<void> saveCart(Map<String, dynamic> cartData) async {
    try {
      await _cartBox.put('cart_data', cartData);
    } catch (e) {
      throw CacheFailure.writeError();
    }
  }

  // الحصول على السلة
  Future<Map<String, dynamic>?> getCart() async {
    try {
      final data = _cartBox.get('cart_data');
      return data != null ? Map<String, dynamic>.from(data) : null;
    } catch (e) {
      throw CacheFailure.readError();
    }
  }

  // مسح السلة
  Future<void> clearCart() async {
    try {
      await _cartBox.delete('cart_data');
    } catch (e) {
      throw CacheFailure.writeError();
    }
  }

  // إضافة عنصر للسلة المحلية
  Future<void> addToLocalCart(String productId, Map<String, dynamic> itemData) async {
    try {
      final cart = await getCart() ?? {'items': <String, dynamic>{}};
      final items = Map<String, dynamic>.from(cart['items'] ?? {});
      items[productId] = itemData;
      cart['items'] = items;
      cart['updatedAt'] = DateTime.now().toIso8601String();
      await saveCart(cart);
    } catch (e) {
      throw CacheFailure.writeError();
    }
  }

  // إزالة عنصر من السلة المحلية
  Future<void> removeFromLocalCart(String productId) async {
    try {
      final cart = await getCart();
      if (cart != null) {
        final items = Map<String, dynamic>.from(cart['items'] ?? {});
        items.remove(productId);
        cart['items'] = items;
        cart['updatedAt'] = DateTime.now().toIso8601String();
        await saveCart(cart);
      }
    } catch (e) {
      throw CacheFailure.writeError();
    }
  }

  // === إدارة المفضلة المحلية ===

  // حفظ المفضلة
  Future<void> saveWishlist(List<String> productIds) async {
    try {
      await _wishlistBox.put('wishlist_items', productIds);
    } catch (e) {
      throw CacheFailure.writeError();
    }
  }

  // الحصول على المفضلة
  Future<List<String>> getWishlist() async {
    try {
      final data = _wishlistBox.get('wishlist_items');
      return data != null ? List<String>.from(data) : [];
    } catch (e) {
      return [];
    }
  }

  // إضافة للمفضلة المحلية
  Future<void> addToLocalWishlist(String productId) async {
    try {
      final wishlist = await getWishlist();
      if (!wishlist.contains(productId)) {
        wishlist.add(productId);
        await saveWishlist(wishlist);
      }
    } catch (e) {
      throw CacheFailure.writeError();
    }
  }

  // إزالة من المفضلة المحلية
  Future<void> removeFromLocalWishlist(String productId) async {
    try {
      final wishlist = await getWishlist();
      wishlist.remove(productId);
      await saveWishlist(wishlist);
    } catch (e) {
      throw CacheFailure.writeError();
    }
  }

  // مسح المفضلة
  Future<void> clearWishlist() async {
    try {
      await _wishlistBox.delete('wishlist_items');
    } catch (e) {
      throw CacheFailure.writeError();
    }
  }

  // === إدارة البيانات المؤقتة ===

  // حفظ بيانات مؤقتة مع انتهاء صلاحية
  Future<void> setCacheData(String key, dynamic data, {Duration? expiry}) async {
    try {
      final cacheItem = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expiry': expiry?.inMilliseconds,
      };
      await _settingsBox.put(key, cacheItem);
    } catch (e) {
      throw CacheFailure.writeError();
    }
  }

  // الحصول على بيانات مؤقتة
  Future<T?> getCacheData<T>(String key) async {
    try {
      final cacheItem = _settingsBox.get(key);
      if (cacheItem == null) return null;

      final timestamp = cacheItem['timestamp'] as int?;
      final expiry = cacheItem['expiry'] as int?;
      
      if (timestamp != null && expiry != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - timestamp > expiry) {
          // البيانات منتهية الصلاحية
          await _settingsBox.delete(key);
          return null;
        }
      }

      return cacheItem['data'] as T?;
    } catch (e) {
      return null;
    }
  }

  // === تنظيف البيانات ===

  // مسح جميع البيانات
  Future<void> clearAll() async {
    try {
      await _prefs.clear();
      await _cartBox.clear();
      await _wishlistBox.clear();
      await _settingsBox.clear();
    } catch (e) {
      throw CacheFailure.writeError();
    }
  }

  // مسح بيانات المستخدم فقط (عند تسجيل الخروج)
  Future<void> clearUserData() async {
    try {
      await removeAuthToken();
      await removeUserData();
      await clearCart();
      await clearWishlist();
    } catch (e) {
      throw CacheFailure.writeError();
    }
  }

  // مسح البيانات المنتهية الصلاحية
  Future<void> clearExpiredCache() async {
    try {
      final keys = _settingsBox.keys.toList();
      final now = DateTime.now().millisecondsSinceEpoch;

      for (final key in keys) {
        final cacheItem = _settingsBox.get(key);
        if (cacheItem is Map) {
          final timestamp = cacheItem['timestamp'] as int?;
          final expiry = cacheItem['expiry'] as int?;
          
          if (timestamp != null && expiry != null) {
            if (now - timestamp > expiry) {
              await _settingsBox.delete(key);
            }
          }
        }
      }
    } catch (e) {
      // تجاهل الأخطاء في التنظيف
    }
  }

  // === معلومات التخزين ===

  // الحصول على حجم التخزين المستخدم
  Future<Map<String, int>> getStorageInfo() async {
    try {
      return {
        'cart_items': _cartBox.length,
        'wishlist_items': _wishlistBox.length,
        'settings_items': _settingsBox.length,
        'preferences_keys': _prefs.getKeys().length,
      };
    } catch (e) {
      return {};
    }
  }
}