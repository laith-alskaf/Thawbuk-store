import 'dart:async';

/// مدير التخزين المؤقت الرئيسي
abstract class CacheManager<T> {
  /// حفظ البيانات في التخزين المؤقت
  Future<void> cache(String key, T data);
  
  /// استرجاع البيانات من التخزين المؤقت
  Future<T?> get(String key);
  
  /// حذف البيانات من التخزين المؤقت
  Future<void> delete(String key);
  
  /// مسح جميع البيانات
  Future<void> clear();
  
  /// التحقق من وجود البيانات
  Future<bool> exists(String key);
  
  /// الحصول على جميع المفاتيح
  Future<List<String>> getAllKeys();
  
  /// حفظ مجموعة من البيانات
  Future<void> cacheAll(Map<String, T> data);
  
  /// استرجاع مجموعة من البيانات
  Future<Map<String, T?>> getAll(List<String> keys);
}

/// سياسة التخزين المؤقت
enum CachePolicy {
  /// استخدام التخزين المؤقت أولاً، ثم الشبكة
  cacheFirst,
  /// استخدام الشبكة أولاً، ثم التخزين المؤقت
  networkFirst,
  /// استخدام التخزين المؤقت فقط
  cacheOnly,
  /// استخدام الشبكة فقط
  networkOnly,
  /// تحديث التخزين المؤقت في الخلفية
  staleWhileRevalidate,
}

/// معلومات انتهاء صلاحية التخزين المؤقت
class CacheExpiry {
  final DateTime cachedAt;
  final Duration ttl; // Time To Live
  
  const CacheExpiry({
    required this.cachedAt,
    required this.ttl,
  });
  
  bool get isExpired => DateTime.now().isAfter(cachedAt.add(ttl));
  
  Duration get timeUntilExpiry => cachedAt.add(ttl).difference(DateTime.now());
  
  Map<String, dynamic> toJson() => {
    'cachedAt': cachedAt.toIso8601String(),
    'ttl': ttl.inMilliseconds,
  };
  
  factory CacheExpiry.fromJson(Map<String, dynamic> json) => CacheExpiry(
    cachedAt: DateTime.parse(json['cachedAt']),
    ttl: Duration(milliseconds: json['ttl']),
  );
}

/// بيانات التخزين المؤقت مع معلومات الانتهاء
class CachedData<T> {
  final T data;
  final CacheExpiry expiry;
  
  const CachedData({
    required this.data,
    required this.expiry,
  });
  
  bool get isExpired => expiry.isExpired;
  
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) dataToJson) => {
    'data': dataToJson(data),
    'expiry': expiry.toJson(),
  };
  
  factory CachedData.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) dataFromJson,
  ) => CachedData(
    data: dataFromJson(json['data']),
    expiry: CacheExpiry.fromJson(json['expiry']),
  );
}

/// استراتيجية التخزين المؤقت
class CacheStrategy {
  final CachePolicy policy;
  final Duration? ttl;
  final bool enableOfflineMode;
  final bool syncOnReconnect;
  
  const CacheStrategy({
    this.policy = CachePolicy.cacheFirst,
    this.ttl,
    this.enableOfflineMode = true,
    this.syncOnReconnect = true,
  });
  
  /// استراتيجية للمنتجات (طويلة الأمد)
  static const products = CacheStrategy(
    policy: CachePolicy.staleWhileRevalidate,
    ttl: Duration(hours: 6),
  );
  
  /// استراتيجية للفئات (طويلة الأمد)
  static const categories = CacheStrategy(
    policy: CachePolicy.staleWhileRevalidate,
    ttl: Duration(hours: 12),
  );
  
  /// استراتيجية للسلة (قصيرة الأمد)
  static const cart = CacheStrategy(
    policy: CachePolicy.networkFirst,
    ttl: Duration(minutes: 30),
  );
  
  /// استراتيجية للمفضلة
  static const wishlist = CacheStrategy(
    policy: CachePolicy.cacheFirst,
    ttl: Duration(hours: 2),
  );
  
  /// استراتيجية للمستخدم
  static const user = CacheStrategy(
    policy: CachePolicy.cacheFirst,
    ttl: Duration(hours: 24),
  );
  
  /// استراتيجية للطلبات
  static const orders = CacheStrategy(
    policy: CachePolicy.networkFirst,
    ttl: Duration(minutes: 15),
  );
}