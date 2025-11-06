import '../../domain/entities/user_entity.dart';
import 'cache_manager.dart';

/// استراتيجية التخزين المؤقت حسب دور المستخدم
class RoleBasedCacheStrategy {
  
  /// استراتيجيات للعملاء العاديين
  static const Map<String, CacheStrategy> customerStrategies = {
    'products': CacheStrategy(
      policy: CachePolicy.staleWhileRevalidate,
      ttl: Duration(hours: 4),
      enableOfflineMode: true,
      syncOnReconnect: true,
    ),
    'categories': CacheStrategy(
      policy: CachePolicy.staleWhileRevalidate,
      ttl: Duration(hours: 8),
      enableOfflineMode: true,
      syncOnReconnect: true,
    ),
    'cart': CacheStrategy(
      policy: CachePolicy.networkFirst,
      ttl: Duration(minutes: 30),
      enableOfflineMode: true,
      syncOnReconnect: true,
    ),
    'wishlist': CacheStrategy(
      policy: CachePolicy.cacheFirst,
      ttl: Duration(hours: 2),
      enableOfflineMode: true,
      syncOnReconnect: true,
    ),
    'profile': CacheStrategy(
      policy: CachePolicy.cacheFirst,
      ttl: Duration(hours: 12),
      enableOfflineMode: true,
      syncOnReconnect: true,
    ),
    'orders': CacheStrategy(
      policy: CachePolicy.networkFirst,
      ttl: Duration(minutes: 15),
      enableOfflineMode: true,
      syncOnReconnect: true,
    ),
  };

  /// استراتيجيات للإدارة والمديرين
  static const Map<String, CacheStrategy> adminStrategies = {
    'products': CacheStrategy(
      policy: CachePolicy.networkFirst,
      ttl: Duration(minutes: 30),
      enableOfflineMode: true,
      syncOnReconnect: true,
    ),
    'categories': CacheStrategy(
      policy: CachePolicy.networkFirst,
      ttl: Duration(hours: 1),
      enableOfflineMode: true,
      syncOnReconnect: true,
    ),
    'users': CacheStrategy(
      policy: CachePolicy.networkFirst,
      ttl: Duration(minutes: 10),
      enableOfflineMode: true,
      syncOnReconnect: true,
    ),
    'orders': CacheStrategy(
      policy: CachePolicy.networkFirst,
      ttl: Duration(minutes: 5),
      enableOfflineMode: true,
      syncOnReconnect: true,
    ),
    'analytics': CacheStrategy(
      policy: CachePolicy.networkOnly,
      ttl: Duration(minutes: 1),
      enableOfflineMode: false,
      syncOnReconnect: true,
    ),
    'inventory': CacheStrategy(
      policy: CachePolicy.networkFirst,
      ttl: Duration(minutes: 15),
      enableOfflineMode: true,
      syncOnReconnect: true,
    ),
    'profile': CacheStrategy(
      policy: CachePolicy.cacheFirst,
      ttl: Duration(hours: 6),
      enableOfflineMode: true,
      syncOnReconnect: true,
    ),
  };

  /// استراتيجيات للزوار
  static const Map<String, CacheStrategy> guestStrategies = {
    'products': CacheStrategy(
      policy: CachePolicy.staleWhileRevalidate,
      ttl: Duration(hours: 6),
      enableOfflineMode: true,
      syncOnReconnect: false,
    ),
    'categories': CacheStrategy(
      policy: CachePolicy.staleWhileRevalidate,
      ttl: Duration(hours: 12),
      enableOfflineMode: true,
      syncOnReconnect: false,
    ),
    // لا يحتاج الزوار لـ cart, wishlist, profile, orders
  };

  /// الحصول على الاستراتيجية المناسبة حسب الدور ونوع البيانات
  static CacheStrategy getStrategy(UserRole? role, String dataType) {
    switch (role) {
      case UserRole.admin:
      case UserRole.superAdmin:
        return adminStrategies[dataType] ?? _getDefaultStrategy(dataType);
      
      case UserRole.customer:
        return customerStrategies[dataType] ?? _getDefaultStrategy(dataType);
      
      case null: // زائر
        return guestStrategies[dataType] ?? _getDefaultStrategy(dataType);
      
      default:
        return _getDefaultStrategy(dataType);
    }
  }

  /// الحصول على جميع الاستراتيجيات للدور المحدد
  static Map<String, CacheStrategy> getAllStrategiesForRole(UserRole? role) {
    switch (role) {
      case UserRole.admin:
      case UserRole.superAdmin:
        return Map.from(adminStrategies);
      
      case UserRole.customer:
        return Map.from(customerStrategies);
      
      case null: // زائر
        return Map.from(guestStrategies);
      
      default:
        return Map.from(guestStrategies);
    }
  }

  /// الحصول على قائمة البيانات التي يجب تخزينها للدور المحدد
  static List<String> getCachedDataTypesForRole(UserRole? role) {
    return getAllStrategiesForRole(role).keys.toList();
  }

  /// التحقق من إمكانية تخزين نوع البيانات للدور المحدد
  static bool canCacheDataType(UserRole? role, String dataType) {
    return getAllStrategiesForRole(role).containsKey(dataType);
  }

  /// الحصول على أولوية التخزين المؤقت حسب الدور
  static int getCachePriority(UserRole? role, String dataType) {
    final priorities = <String, int>{
      // العملاء العاديين
      'products': 10,
      'categories': 9,
      'profile': 8,
      'wishlist': 7,
      'cart': 6,
      'orders': 5,
      
      // الإدارة
      'analytics': 10,
      'inventory': 9,
      'users': 8,
      'orders': 7,
      'products': 6,
      'categories': 5,
      'profile': 4,
    };

    return priorities[dataType] ?? 1;
  }

  /// الحصول على حد التخزين المؤقت حسب الدور
  static CacheLimit getCacheLimitForRole(UserRole? role) {
    switch (role) {
      case UserRole.admin:
      case UserRole.superAdmin:
        return const CacheLimit(
          maxItems: 2000,
          maxSizeInMB: 100,
          maxAgeInDays: 7,
        );
      
      case UserRole.customer:
        return const CacheLimit(
          maxItems: 1000,
          maxSizeInMB: 50,
          maxAgeInDays: 30,
        );
      
      case null: // زائر
        return const CacheLimit(
          maxItems: 500,
          maxSizeInMB: 25,
          maxAgeInDays: 7,
        );
      
      default:
        return const CacheLimit(
          maxItems: 500,
          maxSizeInMB: 25,
          maxAgeInDays: 7,
        );
    }
  }

  /// استراتيجية افتراضية
  static CacheStrategy _getDefaultStrategy(String dataType) {
    return const CacheStrategy(
      policy: CachePolicy.cacheFirst,
      ttl: Duration(hours: 1),
      enableOfflineMode: true,
      syncOnReconnect: true,
    );
  }

  /// التحقق من إمكانية الوصول لنوع البيانات في الوضع غير المتصل
  static bool canAccessOffline(UserRole? role, String dataType) {
    final strategy = getStrategy(role, dataType);
    return strategy.enableOfflineMode;
  }

  /// الحصول على إعدادات المزامنة للدور المحدد
  static SyncSettings getSyncSettingsForRole(UserRole? role) {
    switch (role) {
      case UserRole.admin:
      case UserRole.superAdmin:
        return const SyncSettings(
          syncIntervalMinutes: 5,
          backgroundSyncEnabled: true,
          conflictResolution: ConflictResolution.serverWins,
          prioritizeRealTimeData: true,
        );
      
      case UserRole.customer:
        return const SyncSettings(
          syncIntervalMinutes: 15,
          backgroundSyncEnabled: true,
          conflictResolution: ConflictResolution.clientWins,
          prioritizeRealTimeData: false,
        );
      
      case null: // زائر
        return const SyncSettings(
          syncIntervalMinutes: 30,
          backgroundSyncEnabled: false,
          conflictResolution: ConflictResolution.serverWins,
          prioritizeRealTimeData: false,
        );
      
      default:
        return const SyncSettings(
          syncIntervalMinutes: 30,
          backgroundSyncEnabled: false,
          conflictResolution: ConflictResolution.serverWins,
          prioritizeRealTimeData: false,
        );
    }
  }
}

/// حدود التخزين المؤقت
class CacheLimit {
  final int maxItems;
  final int maxSizeInMB;
  final int maxAgeInDays;

  const CacheLimit({
    required this.maxItems,
    required this.maxSizeInMB,
    required this.maxAgeInDays,
  });
}

/// إعدادات المزامنة
class SyncSettings {
  final int syncIntervalMinutes;
  final bool backgroundSyncEnabled;
  final ConflictResolution conflictResolution;
  final bool prioritizeRealTimeData;

  const SyncSettings({
    required this.syncIntervalMinutes,
    required this.backgroundSyncEnabled,
    required this.conflictResolution,
    required this.prioritizeRealTimeData,
  });
}

/// حل التضارب في البيانات
enum ConflictResolution {
  serverWins,
  clientWins,
  merge,
  askUser,
}

/// مستويات أولوية التخزين المؤقت
enum CachePriority {
  critical,    // البيانات الحرجة
  high,        // أولوية عالية
  medium,      // أولوية متوسطة
  low,         // أولوية منخفضة
  background,  // في الخلفية
}