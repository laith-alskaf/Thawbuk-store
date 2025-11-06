import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/wishlist_entity.dart';
import '../../domain/entities/order_entity.dart';
import 'cache_service.dart';
import 'role_based_cache_strategy.dart';
import 'cache_manager.dart';

/// مدير التخزين المؤقت الذكي
class SmartCacheManager {
  static SmartCacheManager? _instance;
  static SmartCacheManager get instance => _instance ??= SmartCacheManager._();

  SmartCacheManager._();

  final CacheService _cacheService = CacheService.instance;
  UserRole? _currentUserRole;
  String? _currentUserId;
  Timer? _syncTimer;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isOnline = true;

  /// تهيئة المدير الذكي
  Future<void> init() async {
    await _cacheService.init();
    _startConnectivityMonitoring();
    log('✅ Smart Cache Manager initialized');
  }

  /// تعيين المستخدم الحالي وإعداد الاستراتيجيات
  Future<void> setCurrentUser(UserEntity? user) async {
    final oldRole = _currentUserRole;
    final oldUserId = _currentUserId;

    _currentUserRole = user?.role;
    _currentUserId = user?.id;

    // إذا تغير الدور، قم بتنظيف البيانات غير المناسبة
    if (oldRole != _currentUserRole) {
      await _handleRoleChange(oldRole, _currentUserRole, oldUserId, _currentUserId);
    }

    // إعداد مؤقت المزامنة حسب الدور الجديد
    _setupSyncTimer();

    log('👤 User role changed from $oldRole to $_currentUserRole');
  }

  /// تحميل البيانات بذكاء (offline-first)
  Future<T?> loadData<T>({
    required String dataType,
    required String key,
    required Future<T?> Function() networkLoader,
    Duration? customTtl,
  }) async {
    final strategy = RoleBasedCacheStrategy.getStrategy(_currentUserRole, dataType);
    
    switch (strategy.policy) {
      case CachePolicy.cacheFirst:
        return await _loadCacheFirst<T>(dataType, key, networkLoader, strategy, customTtl);
      
      case CachePolicy.networkFirst:
        return await _loadNetworkFirst<T>(dataType, key, networkLoader, strategy, customTtl);
      
      case CachePolicy.staleWhileRevalidate:
        return await _loadStaleWhileRevalidate<T>(dataType, key, networkLoader, strategy, customTtl);
      
      case CachePolicy.cacheOnly:
        return await _loadCacheOnly<T>(dataType, key);
      
      case CachePolicy.networkOnly:
        return await _loadNetworkOnly<T>(dataType, key, networkLoader, strategy, customTtl);
    }
  }

  /// تحميل البيانات cache-first
  Future<T?> _loadCacheFirst<T>(
    String dataType, 
    String key, 
    Future<T?> Function() networkLoader,
    CacheStrategy strategy,
    Duration? customTtl,
  ) async {
    try {
      // محاولة التحميل من التخزين المؤقت أولاً
      final cachedData = await _getCachedData<T>(dataType, key);
      if (cachedData != null) {
        log('📦 Cache hit for $dataType:$key');
        
        // تحديث في الخلفية إذا كان متصلاً بالإنترنت
        if (_isOnline && strategy.syncOnReconnect) {
          _backgroundUpdate(dataType, key, networkLoader, customTtl);
        }
        
        return cachedData;
      }

      // إذا لم توجد في التخزين المؤقت، حمل من الشبكة
      if (_isOnline) {
        return await _loadFromNetworkAndCache(dataType, key, networkLoader, customTtl);
      } else {
        log('📭 No cached data and offline for $dataType:$key');
        return null;
      }
    } catch (e) {
      log('❌ Error in cache-first load for $dataType:$key: $e');
      return null;
    }
  }

  /// تحميل البيانات network-first
  Future<T?> _loadNetworkFirst<T>(
    String dataType, 
    String key, 
    Future<T?> Function() networkLoader,
    CacheStrategy strategy,
    Duration? customTtl,
  ) async {
    try {
      if (_isOnline) {
        // محاولة التحميل من الشبكة أولاً
        final networkData = await networkLoader();
        if (networkData != null) {
          await _cacheData(dataType, key, networkData, customTtl);
          log('🌐 Network data loaded and cached for $dataType:$key');
          return networkData;
        }
      }

      // في حالة فشل الشبكة أو عدم الاتصال، استخدم التخزين المؤقت
      if (strategy.enableOfflineMode) {
        final cachedData = await _getCachedData<T>(dataType, key);
        if (cachedData != null) {
          log('📦 Fallback to cache for $dataType:$key');
          return cachedData;
        }
      }

      log('❌ No data available for $dataType:$key');
      return null;
    } catch (e) {
      log('❌ Error in network-first load for $dataType:$key: $e');
      
      // في حالة الخطأ، حاول التخزين المؤقت
      if (strategy.enableOfflineMode) {
        return await _getCachedData<T>(dataType, key);
      }
      return null;
    }
  }

  /// تحميل البيانات مع stale-while-revalidate
  Future<T?> _loadStaleWhileRevalidate<T>(
    String dataType, 
    String key, 
    Future<T?> Function() networkLoader,
    CacheStrategy strategy,
    Duration? customTtl,
  ) async {
    try {
      // إرجاع البيانات المخزنة فوراً (حتى لو انتهت صلاحيتها)
      final cachedData = await _getStaleData<T>(dataType, key);
      
      // تحديث في الخلفية
      if (_isOnline) {
        _backgroundUpdate(dataType, key, networkLoader, customTtl);
      }

      if (cachedData != null) {
        log('📦 Stale data returned for $dataType:$key');
        return cachedData;
      }

      // إذا لم توجد بيانات مخزنة على الإطلاق، حمل من الشبكة
      if (_isOnline) {
        return await _loadFromNetworkAndCache(dataType, key, networkLoader, customTtl);
      }

      return null;
    } catch (e) {
      log('❌ Error in stale-while-revalidate for $dataType:$key: $e');
      return null;
    }
  }

  /// تحميل من التخزين المؤقت فقط
  Future<T?> _loadCacheOnly<T>(String dataType, String key) async {
    return await _getCachedData<T>(dataType, key);
  }

  /// تحميل من الشبكة فقط
  Future<T?> _loadNetworkOnly<T>(
    String dataType, 
    String key, 
    Future<T?> Function() networkLoader,
    CacheStrategy strategy,
    Duration? customTtl,
  ) async {
    if (!_isOnline) {
      log('🚫 Network-only policy but offline for $dataType:$key');
      return null;
    }

    return await _loadFromNetworkAndCache(dataType, key, networkLoader, customTtl);
  }

  /// تحميل من الشبكة وحفظ في التخزين المؤقت
  Future<T?> _loadFromNetworkAndCache<T>(
    String dataType, 
    String key, 
    Future<T?> Function() networkLoader,
    Duration? customTtl,
  ) async {
    try {
      final data = await networkLoader();
      if (data != null) {
        await _cacheData(dataType, key, data, customTtl);
        log('🌐 Data loaded from network and cached for $dataType:$key');
      }
      return data;
    } catch (e) {
      log('❌ Error loading from network for $dataType:$key: $e');
      return null;
    }
  }

  /// تحديث في الخلفية
  void _backgroundUpdate<T>(
    String dataType, 
    String key, 
    Future<T?> Function() networkLoader,
    Duration? customTtl,
  ) {
    // تشغيل في الخلفية دون انتظار
    Timer(Duration.zero, () async {
      try {
        final data = await networkLoader();
        if (data != null) {
          await _cacheData(dataType, key, data, customTtl);
          log('🔄 Background update completed for $dataType:$key');
        }
      } catch (e) {
        log('⚠️ Background update failed for $dataType:$key: $e');
      }
    });
  }

  /// حفظ البيانات في التخزين المؤقت
  Future<void> _cacheData<T>(String dataType, String key, T data, Duration? customTtl) async {
    if (!RoleBasedCacheStrategy.canCacheDataType(_currentUserRole, dataType)) {
      log('🚫 Cannot cache $dataType for role $_currentUserRole');
      return;
    }

    switch (dataType) {
      case 'products':
        if (data is ProductEntity) {
          await _cacheService.cacheProduct(data);
        } else if (data is List<ProductEntity>) {
          await _cacheService.cacheProducts(data);
        }
        break;
      
      case 'categories':
        if (data is CategoryEntity) {
          await _cacheService.cacheCategory(data);
        } else if (data is List<CategoryEntity>) {
          await _cacheService.cacheCategories(data);
        }
        break;
      
      case 'cart':
        if (data is CartEntity && _currentUserId != null) {
          await _cacheService.cacheCart(data, _currentUserId!);
        }
        break;
      
      case 'wishlist':
        if (data is WishlistEntity && _currentUserId != null) {
          await _cacheService.cacheWishlist(data, _currentUserId!);
        }
        break;
      
      case 'profile':
        if (data is UserEntity) {
          await _cacheService.cacheUser(data);
        }
        break;
      
      case 'orders':
        if (data is OrderEntity) {
          await _cacheService.cacheOrder(data);
        } else if (data is List<OrderEntity> && _currentUserId != null) {
          await _cacheService.cacheOrders(data, _currentUserId!);
        }
        break;
    }
  }

  /// الحصول على البيانات المخزنة
  Future<T?> _getCachedData<T>(String dataType, String key) async {
    switch (dataType) {
      case 'products':
        if (key.startsWith('product_')) {
          final productId = key.substring(8);
          return await _cacheService.getProduct(productId) as T?;
        } else if (key == 'all_products') {
          return await _cacheService.getAllCachedProducts() as T?;
        }
        break;
      
      case 'categories':
        if (key.startsWith('category_')) {
          final categoryId = key.substring(9);
          return await _cacheService.getCategory(categoryId) as T?;
        } else if (key == 'all_categories') {
          return await _cacheService.getAllCachedCategories() as T?;
        }
        break;
      
      case 'cart':
        if (_currentUserId != null) {
          return await _cacheService.getCart(_currentUserId!) as T?;
        }
        break;
      
      case 'wishlist':
        if (_currentUserId != null) {
          return await _cacheService.getWishlist(_currentUserId!) as T?;
        }
        break;
      
      case 'profile':
        if (_currentUserId != null) {
          return await _cacheService.getUser(_currentUserId!) as T?;
        }
        break;
      
      case 'orders':
        if (key.startsWith('order_')) {
          final orderId = key.substring(6);
          return await _cacheService.getOrder(orderId) as T?;
        } else if (key == 'user_orders' && _currentUserId != null) {
          return await _cacheService.getUserOrders(_currentUserId!) as T?;
        }
        break;
    }
    return null;
  }

  /// الحصول على البيانات المنتهية الصلاحية
  Future<T?> _getStaleData<T>(String dataType, String key) async {
    // نفس منطق _getCachedData لكن نقبل البيانات المنتهية الصلاحية
    return await _getCachedData<T>(dataType, key);
  }

  /// مراقبة الاتصال بالإنترنت
  void _startConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;
      
      if (!wasOnline && _isOnline) {
        log('🌐 Connection restored, starting sync...');
        _syncOnReconnect();
      } else if (wasOnline && !_isOnline) {
        log('📡 Connection lost, switching to offline mode');
      }
    });
  }

  /// إعداد مؤقت المزامنة
  void _setupSyncTimer() {
    _syncTimer?.cancel();
    
    final syncSettings = RoleBasedCacheStrategy.getSyncSettingsForRole(_currentUserRole);
    
    if (syncSettings.backgroundSyncEnabled) {
      _syncTimer = Timer.periodic(
        Duration(minutes: syncSettings.syncIntervalMinutes),
        (_) => _performBackgroundSync(),
      );
    }
  }

  /// مزامنة عند استعادة الاتصال
  Future<void> _syncOnReconnect() async {
    if (!_isOnline || _currentUserRole == null) return;

    final syncSettings = RoleBasedCacheStrategy.getSyncSettingsForRole(_currentUserRole);
    if (!syncSettings.backgroundSyncEnabled) return;

    await _performBackgroundSync();
  }

  /// تنفيذ المزامنة في الخلفية
  Future<void> _performBackgroundSync() async {
    if (!_isOnline) return;

    try {
      log('🔄 Starting background sync for role $_currentUserRole');
      
      // تنظيف البيانات المنتهية الصلاحية
      await _cacheService.cleanExpiredData();
      
      // مزامنة البيانات حسب الدور
      // هذا سيتم تنفيذه عبر الـ repositories
      
      log('✅ Background sync completed');
    } catch (e) {
      log('❌ Background sync failed: $e');
    }
  }

  /// التعامل مع تغيير الدور
  Future<void> _handleRoleChange(UserRole? oldRole, UserRole? newRole, String? oldUserId, String? newUserId) async {
    // مسح البيانات غير المناسبة للدور الجديد
    if (oldRole != null && newRole != null) {
      final oldDataTypes = RoleBasedCacheStrategy.getCachedDataTypesForRole(oldRole);
      final newDataTypes = RoleBasedCacheStrategy.getCachedDataTypesForRole(newRole);
      
      // مسح البيانات التي لا يجب أن يصل إليها الدور الجديد
      for (final dataType in oldDataTypes) {
        if (!newDataTypes.contains(dataType)) {
          await _clearDataType(dataType, oldUserId);
        }
      }
    }

    // مسح بيانات المستخدم السابق إذا تغير المستخدم
    if (oldUserId != null && oldUserId != newUserId) {
      await _cacheService.clearUserData(oldUserId);
    }
  }

  /// مسح نوع بيانات محدد
  Future<void> _clearDataType(String dataType, String? userId) async {
    switch (dataType) {
      case 'cart':
        if (userId != null) await _cacheService.clearCart(userId);
        break;
      case 'wishlist':
        if (userId != null) await _cacheService.clearWishlist(userId);
        break;
      case 'profile':
        if (userId != null) await _cacheService.clearUser(userId);
        break;
      // المنتجات والفئات عامة، لا نحذفها
    }
  }

  /// الحصول على إحصائيات التخزين المؤقت
  Future<Map<String, dynamic>> getCacheStatistics() async {
    final stats = await _cacheService.getAllStats();
    return {
      'role': _currentUserRole?.toString(),
      'userId': _currentUserId,
      'isOnline': _isOnline,
      'cacheStats': stats,
      'allowedDataTypes': RoleBasedCacheStrategy.getCachedDataTypesForRole(_currentUserRole),
    };
  }

  /// مسح جميع البيانات المخزنة
  Future<void> clearAllCache() async {
    await _cacheService.clearAll();
    log('🧹 All cache cleared');
  }

  /// تصفية الذاكرة
  Future<void> dispose() async {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    await _cacheService.dispose();
    log('🔐 Smart Cache Manager disposed');
  }
}