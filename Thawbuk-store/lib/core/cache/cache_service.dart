import 'dart:async';
import 'dart:developer';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/wishlist_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/wishlist_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/order_model.dart';
import 'hive_cache_manager.dart';
import 'cache_manager.dart';

/// خدمة التخزين المؤقت المركزية
class CacheService {
  static CacheService? _instance;
  static CacheService get instance => _instance ??= CacheService._();
  
  CacheService._();
  
  // مديري التخزين المؤقت لكل نوع بيانات
  late final HiveCacheManager<ProductEntity> _productCache;
  late final HiveCacheManager<CategoryEntity> _categoryCache;
  late final HiveCacheManager<CartEntity> _cartCache;
  late final HiveCacheManager<WishlistEntity> _wishlistCache;
  late final HiveCacheManager<UserEntity> _userCache;
  late final HiveCacheManager<OrderEntity> _orderCache;
  
  // مدير للإعدادات العامة
  late final HiveCacheManager<Map<String, dynamic>> _settingsCache;
  
  bool _isInitialized = false;
  
  /// تهيئة خدمة التخزين المؤقت
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      log('🚀 Initializing Cache Service...');
      
      // تهيئة Hive
      await Hive.initFlutter();
      
      // تهيئة مديري التخزين المؤقت
      _productCache = HiveCacheManager<ProductEntity>(
        boxName: 'products_cache',
        fromJson: (json) => ProductModel.fromJson(json).toEntity(),
        toJson: (product) => ProductModel.fromEntity(product).toJson(),
      );
      
      _categoryCache = HiveCacheManager<CategoryEntity>(
        boxName: 'categories_cache',
        fromJson: (json) => CategoryModel.fromJson(json).toEntity(),
        toJson: (category) => CategoryModel.fromEntity(category).toJson(),
      );
      
      _cartCache = HiveCacheManager<CartEntity>(
        boxName: 'cart_cache',
        fromJson: (json) => CartModel.fromJson(json).toEntity(),
        toJson: (cart) => CartModel.fromEntity(cart).toJson(),
      );
      
      _wishlistCache = HiveCacheManager<WishlistEntity>(
        boxName: 'wishlist_cache',
        fromJson: (json) => WishlistModel.fromJson(json).toEntity(),
        toJson: (wishlist) => WishlistModel.fromEntity(wishlist).toJson(),
      );
      
      _userCache = HiveCacheManager<UserEntity>(
        boxName: 'user_cache',
        fromJson: (json) => UserModel.fromJson(json).toEntity(),
        toJson: (user) => UserModel.fromEntity(user).toJson(),
      );
      
      _orderCache = HiveCacheManager<OrderEntity>(
        boxName: 'orders_cache',
        fromJson: (json) => OrderModel.fromJson(json).toEntity(),
        toJson: (order) => OrderModel.fromEntity(order).toJson(),
      );
      
      _settingsCache = HiveCacheManager<Map<String, dynamic>>(
        boxName: 'settings_cache',
        fromJson: (json) => json,
        toJson: (settings) => settings,
      );
      
      // تهيئة جميع الصناديق
      await Future.wait([
        _productCache.init(),
        _categoryCache.init(),
        _cartCache.init(),
        _wishlistCache.init(),
        _userCache.init(),
        _orderCache.init(),
        _settingsCache.init(),
      ]);
      
      _isInitialized = true;
      log('✅ Cache Service initialized successfully');
      
      // تنظيف البيانات المنتهية الصلاحية في الخلفية
      _scheduleCleanup();
      
    } catch (e) {
      log('❌ Failed to initialize Cache Service: $e');
      rethrow;
    }
  }
  
  /// ضمان التهيئة
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('Cache Service not initialized. Call init() first.');
    }
  }
  
  // === مديري المنتجات ===
  
  /// حفظ منتج واحد
  Future<void> cacheProduct(ProductEntity product) async {
    _ensureInitialized();
    await _productCache.cacheWithExpiry(
      'product_${product.id}',
      product,
      CacheStrategy.products.ttl!,
    );
  }
  
  /// حفظ قائمة منتجات
  Future<void> cacheProducts(List<ProductEntity> products) async {
    _ensureInitialized();
    final Map<String, ProductEntity> productsMap = {};
    for (final product in products) {
      productsMap['product_${product.id}'] = product;
    }
    await _productCache.cacheAll(productsMap);
  }
  
  /// الحصول على منتج
  Future<ProductEntity?> getProduct(String productId) async {
    _ensureInitialized();
    return await _productCache.get('product_$productId');
  }
  
  /// الحصول على قائمة منتجات
  Future<List<ProductEntity>> getProducts(List<String> productIds) async {
    _ensureInitialized();
    final keys = productIds.map((id) => 'product_$id').toList();
    final results = await _productCache.getAll(keys);
    return results.values.whereType<ProductEntity>().toList();
  }
  
  /// الحصول على جميع المنتجات المخزنة
  Future<List<ProductEntity>> getAllCachedProducts() async {
    _ensureInitialized();
    final keys = await _productCache.getAllKeys();
    final productKeys = keys.where((key) => key.startsWith('product_')).toList();
    final results = await _productCache.getAll(productKeys);
    return results.values.whereType<ProductEntity>().toList();
  }
  
  // === مديري الفئات ===
  
  /// حفظ فئة
  Future<void> cacheCategory(CategoryEntity category) async {
    _ensureInitialized();
    await _categoryCache.cacheWithExpiry(
      'category_${category.id}',
      category,
      CacheStrategy.categories.ttl!,
    );
  }
  
  /// حفظ قائمة فئات
  Future<void> cacheCategories(List<CategoryEntity> categories) async {
    _ensureInitialized();
    final Map<String, CategoryEntity> categoriesMap = {};
    for (final category in categories) {
      categoriesMap['category_${category.id}'] = category;
    }
    await _categoryCache.cacheAll(categoriesMap);
  }
  
  /// الحصول على فئة
  Future<CategoryEntity?> getCategory(String categoryId) async {
    _ensureInitialized();
    return await _categoryCache.get('category_$categoryId');
  }
  
  /// الحصول على جميع الفئات المخزنة
  Future<List<CategoryEntity>> getAllCachedCategories() async {
    _ensureInitialized();
    final keys = await _categoryCache.getAllKeys();
    final categoryKeys = keys.where((key) => key.startsWith('category_')).toList();
    final results = await _categoryCache.getAll(categoryKeys);
    return results.values.whereType<CategoryEntity>().toList();
  }
  
  // === مديري السلة ===
  
  /// حفظ السلة
  Future<void> cacheCart(CartEntity cart, String userId) async {
    _ensureInitialized();
    await _cartCache.cacheWithExpiry(
      'cart_$userId',
      cart,
      CacheStrategy.cart.ttl!,
    );
  }
  
  /// الحصول على السلة
  Future<CartEntity?> getCart(String userId) async {
    _ensureInitialized();
    return await _cartCache.get('cart_$userId');
  }
  
  /// مسح السلة
  Future<void> clearCart(String userId) async {
    _ensureInitialized();
    await _cartCache.delete('cart_$userId');
  }
  
  // === مديري المفضلة ===
  
  /// حفظ المفضلة
  Future<void> cacheWishlist(WishlistEntity wishlist, String userId) async {
    _ensureInitialized();
    await _wishlistCache.cacheWithExpiry(
      'wishlist_$userId',
      wishlist,
      CacheStrategy.wishlist.ttl!,
    );
  }
  
  /// الحصول على المفضلة
  Future<WishlistEntity?> getWishlist(String userId) async {
    _ensureInitialized();
    return await _wishlistCache.get('wishlist_$userId');
  }
  
  /// مسح المفضلة
  Future<void> clearWishlist(String userId) async {
    _ensureInitialized();
    await _wishlistCache.delete('wishlist_$userId');
  }
  
  // === مديري المستخدم ===
  
  /// حفظ المستخدم
  Future<void> cacheUser(UserEntity user) async {
    _ensureInitialized();
    await _userCache.cacheWithExpiry(
      'user_${user.id}',
      user,
      CacheStrategy.user.ttl!,
    );
  }
  
  /// الحصول على المستخدم
  Future<UserEntity?> getUser(String userId) async {
    _ensureInitialized();
    return await _userCache.get('user_$userId');
  }
  
  /// مسح المستخدم
  Future<void> clearUser(String userId) async {
    _ensureInitialized();
    await _userCache.delete('user_$userId');
  }
  
  // === مديري الطلبات ===
  
  /// حفظ طلب
  Future<void> cacheOrder(OrderEntity order) async {
    _ensureInitialized();
    await _orderCache.cacheWithExpiry(
      'order_${order.id}',
      order,
      CacheStrategy.orders.ttl!,
    );
  }
  
  /// حفظ قائمة طلبات
  Future<void> cacheOrders(List<OrderEntity> orders, String userId) async {
    _ensureInitialized();
    final Map<String, OrderEntity> ordersMap = {};
    for (final order in orders) {
      ordersMap['order_${order.id}'] = order;
    }
    await _orderCache.cacheAll(ordersMap);
    
    // حفظ قائمة معرفات الطلبات للمستخدم
    final orderIds = orders.map((o) => o.id).toList();
    await _settingsCache.cache('user_orders_$userId', {
      'orderIds': orderIds,
      'lastUpdated': DateTime.now().toIso8601String(),
    });
  }
  
  /// الحصول على طلب
  Future<OrderEntity?> getOrder(String orderId) async {
    _ensureInitialized();
    return await _orderCache.get('order_$orderId');
  }
  
  /// الحصول على طلبات المستخدم
  Future<List<OrderEntity>> getUserOrders(String userId) async {
    _ensureInitialized();
    
    // الحصول على قائمة معرفات الطلبات
    final userOrdersData = await _settingsCache.get('user_orders_$userId');
    if (userOrdersData == null) return [];
    
    final orderIds = List<String>.from(userOrdersData['orderIds'] ?? []);
    return await getOrders(orderIds);
  }
  
  /// الحصول على قائمة طلبات
  Future<List<OrderEntity>> getOrders(List<String> orderIds) async {
    _ensureInitialized();
    final keys = orderIds.map((id) => 'order_$id').toList();
    final results = await _orderCache.getAll(keys);
    return results.values.whereType<OrderEntity>().toList();
  }
  
  // === إدارة عامة ===
  
  /// الحصول على إعداد
  Future<T?> getSetting<T>(String key) async {
    _ensureInitialized();
    final data = await _settingsCache.get(key);
    return data?['value'] as T?;
  }
  
  /// حفظ إعداد
  Future<void> setSetting<T>(String key, T value) async {
    _ensureInitialized();
    await _settingsCache.cache(key, {
      'value': value,
      'type': T.toString(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
  
  /// مسح جميع البيانات
  Future<void> clearAll() async {
    _ensureInitialized();
    await Future.wait([
      _productCache.clear(),
      _categoryCache.clear(),
      _cartCache.clear(),
      _wishlistCache.clear(),
      _userCache.clear(),
      _orderCache.clear(),
      _settingsCache.clear(),
    ]);
    log('🧹 Cleared all cache data');
  }
  
  /// مسح بيانات المستخدم فقط
  Future<void> clearUserData(String userId) async {
    _ensureInitialized();
    await Future.wait([
      clearCart(userId),
      clearWishlist(userId),
      clearUser(userId),
      _settingsCache.delete('user_orders_$userId'),
    ]);
    log('🧹 Cleared user data for user: $userId');
  }
  
  /// الحصول على إحصائيات التخزين المؤقت
  Future<Map<String, CacheStats>> getAllStats() async {
    _ensureInitialized();
    return {
      'products': await _productCache.getStats(),
      'categories': await _categoryCache.getStats(),
      'cart': await _cartCache.getStats(),
      'wishlist': await _wishlistCache.getStats(),
      'user': await _userCache.getStats(),
      'orders': await _orderCache.getStats(),
      'settings': await _settingsCache.getStats(),
    };
  }
  
  /// تنظيف البيانات المنتهية الصلاحية
  Future<void> cleanExpiredData() async {
    _ensureInitialized();
    await Future.wait([
      _productCache.cleanExpired(),
      _categoryCache.cleanExpired(),
      _cartCache.cleanExpired(),
      _wishlistCache.cleanExpired(),
      _userCache.cleanExpired(),
      _orderCache.cleanExpired(),
      _settingsCache.cleanExpired(),
    ]);
    log('🧹 Cleaned expired data from all caches');
  }
  
  /// جدولة تنظيف دوري
  void _scheduleCleanup() {
    Timer.periodic(const Duration(hours: 6), (timer) {
      cleanExpiredData();
    });
  }
  
  /// إغلاق خدمة التخزين المؤقت
  Future<void> dispose() async {
    if (!_isInitialized) return;
    
    await Future.wait([
      _productCache.close(),
      _categoryCache.close(),
      _cartCache.close(),
      _wishlistCache.close(),
      _userCache.close(),
      _orderCache.close(),
      _settingsCache.close(),
    ]);
    
    _isInitialized = false;
    log('🔐 Cache Service disposed');
  }
}