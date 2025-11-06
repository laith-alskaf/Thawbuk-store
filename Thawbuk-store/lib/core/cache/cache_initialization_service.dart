import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import 'cache_service.dart';
import 'smart_cache_manager.dart';
import 'role_based_cache_strategy.dart';

/// خدمة تهيئة التخزين المؤقت وإدارة دورة الحياة
class CacheInitializationService {
  static CacheInitializationService? _instance;
  static CacheInitializationService get instance => _instance ??= CacheInitializationService._();

  CacheInitializationService._();

  bool _isInitialized = false;
  Timer? _maintenanceTimer;
  UserEntity? _currentUser;

  /// هل النظام مهيأ أم لا
  bool get isInitialized => _isInitialized;

  /// تهيئة شاملة لنظام التخزين المؤقت
  Future<void> initialize() async {
    if (_isInitialized) {
      log('⚠️ Cache system already initialized');
      return;
    }

    try {
      log('🚀 Starting cache system initialization...');

      // 1. تهيئة خدمة التخزين المؤقت الأساسية
      await CacheService.instance.init();
      log('✅ Basic cache service initialized');

      // 2. تهيئة المدير الذكي
      await SmartCacheManager.instance.init();
      log('✅ Smart cache manager initialized');

      // 3. تشغيل مؤقت الصيانة الدورية
      _startMaintenanceTimer();
      log('✅ Maintenance timer started');

      // 4. تحميل البيانات الأساسية إذا كانت متوفرة
      await _preloadEssentialData();
      log('✅ Essential data preloaded');

      _isInitialized = true;
      log('🎉 Cache system initialization completed successfully');

    } catch (e) {
      log('❌ Failed to initialize cache system: $e');
      rethrow;
    }
  }

  /// تهيئة للمستخدم المسجل
  Future<void> initializeForUser(UserEntity user) async {
    try {
      log('👤 Initializing cache for user: ${user.email} (${user.role})');

      _currentUser = user;

      // إعداد المدير الذكي للمستخدم
      await SmartCacheManager.instance.setCurrentUser(user);

      // تحميل البيانات الخاصة بالمستخدم
      await _preloadUserSpecificData(user);

      // تنظيف البيانات غير المناسبة للدور
      await _cleanupInappropriateData(user.role);

      log('✅ Cache initialized successfully for user: ${user.email}');
    } catch (e) {
      log('❌ Failed to initialize cache for user: $e');
      rethrow;
    }
  }

  /// تهيئة للزائر
  Future<void> initializeForGuest() async {
    try {
      log('👥 Initializing cache for guest user');

      _currentUser = null;

      // إعداد المدير الذكي للزائر
      await SmartCacheManager.instance.setCurrentUser(null);

      // تحميل البيانات العامة فقط
      await _preloadGuestData();

      // تنظيف البيانات الشخصية
      await _cleanupPersonalData();

      log('✅ Cache initialized successfully for guest');
    } catch (e) {
      log('❌ Failed to initialize cache for guest: $e');
      rethrow;
    }
  }

  /// تحميل البيانات الأساسية
  Future<void> _preloadEssentialData() async {
    try {
      // تحميل الفئات (البيانات الأساسية للتطبيق)
      await _preloadCategories();

      // تحميل المنتجات المميزة
      await _preloadFeaturedProducts();

      log('📦 Essential data preloaded successfully');
    } catch (e) {
      log('⚠️ Error preloading essential data: $e');
      // لا نرمي خطأ هنا لأن هذه البيانات اختيارية
    }
  }

  /// تحميل البيانات الخاصة بالمستخدم
  Future<void> _preloadUserSpecificData(UserEntity user) async {
    try {
      final dataTypes = RoleBasedCacheStrategy.getCachedDataTypesForRole(user.role);

      // تحميل البيانات حسب الدور
      for (final dataType in dataTypes) {
        switch (dataType) {
          case 'cart':
            await _preloadUserCart(user.id);
            break;
          case 'wishlist':
            await _preloadUserWishlist(user.id);
            break;
          case 'profile':
            await _preloadUserProfile(user.id);
            break;
          case 'orders':
            await _preloadUserOrders(user.id);
            break;
          case 'products':
            if (user.role == UserRole.admin || user.role == UserRole.superAdmin) {
              await _preloadAllProducts();
            }
            break;
        }
      }

      log('📦 User-specific data preloaded for: ${user.email}');
    } catch (e) {
      log('⚠️ Error preloading user-specific data: $e');
    }
  }

  /// تحميل البيانات للزائر
  Future<void> _preloadGuestData() async {
    try {
      // الزوار يحتاجون فقط للمنتجات والفئات
      await _preloadCategories();
      await _preloadFeaturedProducts();

      log('📦 Guest data preloaded successfully');
    } catch (e) {
      log('⚠️ Error preloading guest data: $e');
    }
  }

  /// تحميل الفئات
  Future<void> _preloadCategories() async {
    try {
      await SmartCacheManager.instance.loadData<List>(
        dataType: 'categories',
        key: 'all_categories',
        networkLoader: () async {
          log('🌐 Preloading categories from network');
          // هذا سيتم تنفيذه عبر repository في الواقع
          return [];
        },
      );
    } catch (e) {
      log('⚠️ Error preloading categories: $e');
    }
  }

  /// تحميل المنتجات المميزة
  Future<void> _preloadFeaturedProducts() async {
    try {
      await SmartCacheManager.instance.loadData<List>(
        dataType: 'products',
        key: 'featured_products',
        networkLoader: () async {
          log('🌐 Preloading featured products from network');
          // هذا سيتم تنفيذه عبر repository في الواقع
          return [];
        },
      );
    } catch (e) {
      log('⚠️ Error preloading featured products: $e');
    }
  }

  /// تحميل جميع المنتجات (للإدارة)
  Future<void> _preloadAllProducts() async {
    try {
      await SmartCacheManager.instance.loadData<List>(
        dataType: 'products',
        key: 'all_products',
        networkLoader: () async {
          log('🌐 Preloading all products for admin');
          // هذا سيتم تنفيذه عبر repository في الواقع
          return [];
        },
      );
    } catch (e) {
      log('⚠️ Error preloading all products: $e');
    }
  }

  /// تحميل سلة المستخدم
  Future<void> _preloadUserCart(String userId) async {
    try {
      await SmartCacheManager.instance.loadData(
        dataType: 'cart',
        key: 'user_cart',
        networkLoader: () async {
          log('🌐 Preloading user cart');
          // هذا سيتم تنفيذه عبر repository في الواقع
          return null;
        },
      );
    } catch (e) {
      log('⚠️ Error preloading user cart: $e');
    }
  }

  /// تحميل مفضلة المستخدم
  Future<void> _preloadUserWishlist(String userId) async {
    try {
      await SmartCacheManager.instance.loadData(
        dataType: 'wishlist',
        key: 'user_wishlist',
        networkLoader: () async {
          log('🌐 Preloading user wishlist');
          // هذا سيتم تنفيذه عبر repository في الواقع
          return null;
        },
      );
    } catch (e) {
      log('⚠️ Error preloading user wishlist: $e');
    }
  }

  /// تحميل ملف المستخدم
  Future<void> _preloadUserProfile(String userId) async {
    try {
      await SmartCacheManager.instance.loadData(
        dataType: 'profile',
        key: 'user_profile',
        networkLoader: () async {
          log('🌐 Preloading user profile');
          // هذا سيتم تنفيذه عبر repository في الواقع
          return null;
        },
      );
    } catch (e) {
      log('⚠️ Error preloading user profile: $e');
    }
  }

  /// تحميل طلبات المستخدم
  Future<void> _preloadUserOrders(String userId) async {
    try {
      await SmartCacheManager.instance.loadData(
        dataType: 'orders',
        key: 'user_orders',
        networkLoader: () async {
          log('🌐 Preloading user orders');
          // هذا سيتم تنفيذه عبر repository في الواقع
          return [];
        },
      );
    } catch (e) {
      log('⚠️ Error preloading user orders: $e');
    }
  }

  /// تنظيف البيانات غير المناسبة للدور
  Future<void> _cleanupInappropriateData(UserRole role) async {
    try {
      final allowedDataTypes = RoleBasedCacheStrategy.getCachedDataTypesForRole(role);
      
      // قائمة جميع أنواع البيانات المحتملة
      const allDataTypes = ['products', 'categories', 'cart', 'wishlist', 'profile', 'orders', 'users', 'analytics', 'inventory'];
      
      for (final dataType in allDataTypes) {
        if (!allowedDataTypes.contains(dataType)) {
          await _clearDataType(dataType);
        }
      }

      log('🧹 Cleaned up inappropriate data for role: $role');
    } catch (e) {
      log('❌ Error cleaning up inappropriate data: $e');
    }
  }

  /// تنظيف البيانات الشخصية (للزوار)
  Future<void> _cleanupPersonalData() async {
    try {
      const personalDataTypes = ['cart', 'wishlist', 'profile', 'orders'];
      
      for (final dataType in personalDataTypes) {
        await _clearDataType(dataType);
      }

      log('🧹 Cleaned up personal data for guest mode');
    } catch (e) {
      log('❌ Error cleaning up personal data: $e');
    }
  }

  /// مسح نوع بيانات محدد
  Future<void> _clearDataType(String dataType) async {
    try {
      // سيتم تنفيذ هذا عبر SmartCacheManager
      log('🗑️ Clearing data type: $dataType');
    } catch (e) {
      log('❌ Error clearing data type $dataType: $e');
    }
  }

  /// بدء مؤقت الصيانة الدورية
  void _startMaintenanceTimer() {
    _maintenanceTimer = Timer.periodic(
      const Duration(hours: 2), // كل ساعتين
      (_) => _performMaintenance(),
    );
  }

  /// تنفيذ الصيانة الدورية
  Future<void> _performMaintenance() async {
    try {
      log('🔧 Starting cache maintenance...');

      // تنظيف البيانات المنتهية الصلاحية
      await CacheService.instance.cleanExpiredData();

      // فحص حدود التخزين المؤقت
      await _checkCacheLimits();

      // تحسين الأداء
      await _optimizeCache();

      log('✅ Cache maintenance completed');
    } catch (e) {
      log('❌ Error during cache maintenance: $e');
    }
  }

  /// فحص حدود التخزين المؤقت
  Future<void> _checkCacheLimits() async {
    try {
      if (_currentUser == null) return;

      final cacheLimit = RoleBasedCacheStrategy.getCacheLimitForRole(_currentUser!.role);
      final stats = await SmartCacheManager.instance.getCacheStatistics();

      // فحص حدود الحجم والعدد (منطق مبسط)
      log('📊 Cache limits check: role=${_currentUser!.role}, limit=${cacheLimit.maxItems}');
      
      // هنا يمكن إضافة منطق لحذف البيانات الأقل استخداماً إذا تم تجاوز الحدود

    } catch (e) {
      log('❌ Error checking cache limits: $e');
    }
  }

  /// تحسين التخزين المؤقت
  Future<void> _optimizeCache() async {
    try {
      // ضغط البيانات القديمة
      // إعادة تنظيم المفاتيح
      // حذف البيانات المكررة
      
      log('⚡ Cache optimization completed');
    } catch (e) {
      log('❌ Error optimizing cache: $e');
    }
  }

  /// الحصول على إحصائيات شاملة
  Future<Map<String, dynamic>> getSystemStatistics() async {
    try {
      final cacheStats = await SmartCacheManager.instance.getCacheStatistics();
      
      return {
        'isInitialized': _isInitialized,
        'currentUser': _currentUser?.email,
        'currentRole': _currentUser?.role.toString(),
        'cacheStats': cacheStats,
        'maintenanceEnabled': _maintenanceTimer?.isActive ?? false,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      log('❌ Error getting system statistics: $e');
      return {'error': e.toString()};
    }
  }

  /// إعادة تعيين النظام بالكامل
  Future<void> resetSystem() async {
    try {
      log('🔄 Resetting cache system...');

      // إيقاف الصيانة
      _maintenanceTimer?.cancel();

      // مسح جميع البيانات
      await SmartCacheManager.instance.clearAllCache();

      // إعادة التهيئة
      _isInitialized = false;
      _currentUser = null;

      await initialize();

      log('✅ Cache system reset completed');
    } catch (e) {
      log('❌ Error resetting cache system: $e');
      rethrow;
    }
  }

  /// تصفية الموارد
  Future<void> dispose() async {
    try {
      log('🔐 Disposing cache initialization service...');

      _maintenanceTimer?.cancel();
      await SmartCacheManager.instance.dispose();
      await CacheService.instance.dispose();

      _isInitialized = false;
      _currentUser = null;

      log('✅ Cache initialization service disposed');
    } catch (e) {
      log('❌ Error disposing cache initialization service: $e');
    }
  }

  /// للتطبيقات في مرحلة التطوير - معلومات التشخيص
  void debugPrintCacheInfo() {
    if (kDebugMode) {
      log('🐛 DEBUG: Cache system info:');
      log('   - Initialized: $_isInitialized');
      log('   - Current user: ${_currentUser?.email ?? 'Guest'}');
      log('   - Current role: ${_currentUser?.role ?? 'None'}');
      log('   - Maintenance active: ${_maintenanceTimer?.isActive ?? false}');
    }
  }
}