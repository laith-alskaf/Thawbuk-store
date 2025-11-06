import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:hive_flutter/hive_flutter.dart';

import 'cache_manager.dart';

/// تنفيذ مدير التخزين المؤقت باستخدام Hive
class HiveCacheManager<T> implements CacheManager<T> {
  final String boxName;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;
  Box<String>? _box;
  
  HiveCacheManager({
    required this.boxName,
    required this.fromJson,
    required this.toJson,
  });
  
  /// تهيئة الصندوق
  Future<void> init() async {
    try {
      if (_box == null || !_box!.isOpen) {
        _box = await Hive.openBox<String>(boxName);
        log('✅ Hive box "$boxName" initialized successfully');
      }
    } catch (e) {
      log('❌ Failed to initialize Hive box "$boxName": $e');
      rethrow;
    }
  }
  
  /// التأكد من تهيئة الصندوق
  Future<Box<String>> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      await init();
    }
    return _box!;
  }
  
  @override
  Future<void> cache(String key, T data) async {
    try {
      final box = await _getBox();
      final cachedData = CachedData(
        data: data,
        expiry: CacheExpiry(
          cachedAt: DateTime.now(),
          ttl: const Duration(hours: 24), // افتراضي
        ),
      );
      
      final jsonString = jsonEncode(cachedData.toJson(toJson));
      await box.put(key, jsonString);
      
      log('💾 Cached data for key "$key" in box "$boxName"');
    } catch (e) {
      log('❌ Failed to cache data for key "$key": $e');
      rethrow;
    }
  }
  
  /// حفظ البيانات مع تخصيص انتهاء الصلاحية
  Future<void> cacheWithExpiry(String key, T data, Duration ttl) async {
    try {
      final box = await _getBox();
      final cachedData = CachedData(
        data: data,
        expiry: CacheExpiry(
          cachedAt: DateTime.now(),
          ttl: ttl,
        ),
      );
      
      final jsonString = jsonEncode(cachedData.toJson(toJson));
      await box.put(key, jsonString);
      
      log('💾 Cached data with TTL ${ttl.inMinutes}m for key "$key"');
    } catch (e) {
      log('❌ Failed to cache data with expiry for key "$key": $e');
      rethrow;
    }
  }
  
  @override
  Future<T?> get(String key) async {
    try {
      final box = await _getBox();
      final jsonString = box.get(key);
      
      if (jsonString == null) {
        log('📭 No cached data found for key "$key"');
        return null;
      }
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final cachedData = CachedData.fromJson(json, fromJson);
      
      if (cachedData.isExpired) {
        log('⏰ Cached data expired for key "$key", removing...');
        await delete(key);
        return null;
      }
      
      log('📦 Retrieved cached data for key "$key"');
      return cachedData.data;
    } catch (e) {
      log('❌ Failed to get cached data for key "$key": $e');
      return null;
    }
  }
  
  /// الحصول على البيانات حتى لو انتهت صلاحيتها
  Future<T?> getStale(String key) async {
    try {
      final box = await _getBox();
      final jsonString = box.get(key);
      
      if (jsonString == null) return null;
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final cachedData = CachedData.fromJson(json, fromJson);
      
      if (cachedData.isExpired) {
        log('⚠️ Returning stale data for key "$key"');
      }
      
      return cachedData.data;
    } catch (e) {
      log('❌ Failed to get stale data for key "$key": $e');
      return null;
    }
  }
  
  @override
  Future<void> delete(String key) async {
    try {
      final box = await _getBox();
      await box.delete(key);
      log('🗑️ Deleted cached data for key "$key"');
    } catch (e) {
      log('❌ Failed to delete cached data for key "$key": $e');
      rethrow;
    }
  }
  
  @override
  Future<void> clear() async {
    try {
      final box = await _getBox();
      await box.clear();
      log('🧹 Cleared all cached data from box "$boxName"');
    } catch (e) {
      log('❌ Failed to clear cache box "$boxName": $e');
      rethrow;
    }
  }
  
  @override
  Future<bool> exists(String key) async {
    try {
      final box = await _getBox();
      return box.containsKey(key);
    } catch (e) {
      log('❌ Failed to check existence for key "$key": $e');
      return false;
    }
  }
  
  @override
  Future<List<String>> getAllKeys() async {
    try {
      final box = await _getBox();
      return box.keys.cast<String>().toList();
    } catch (e) {
      log('❌ Failed to get all keys from box "$boxName": $e');
      return [];
    }
  }
  
  @override
  Future<void> cacheAll(Map<String, T> data) async {
    try {
      final box = await _getBox();
      final Map<String, String> jsonData = {};
      
      for (final entry in data.entries) {
        final cachedData = CachedData(
          data: entry.value,
          expiry: CacheExpiry(
            cachedAt: DateTime.now(),
            ttl: const Duration(hours: 24),
          ),
        );
        jsonData[entry.key] = jsonEncode(cachedData.toJson(toJson));
      }
      
      await box.putAll(jsonData);
      log('💾 Cached ${data.length} items in box "$boxName"');
    } catch (e) {
      log('❌ Failed to cache all data: $e');
      rethrow;
    }
  }
  
  @override
  Future<Map<String, T?>> getAll(List<String> keys) async {
    try {
      final box = await _getBox();
      final Map<String, T?> result = {};
      
      for (final key in keys) {
        result[key] = await get(key);
      }
      
      log('📦 Retrieved ${result.length} items from box "$boxName"');
      return result;
    } catch (e) {
      log('❌ Failed to get all data: $e');
      return {};
    }
  }
  
  /// تنظيف البيانات المنتهية الصلاحية
  Future<void> cleanExpired() async {
    try {
      final box = await _getBox();
      final keysToDelete = <String>[];
      
      for (final key in box.keys) {
        final jsonString = box.get(key);
        if (jsonString != null) {
          try {
            final json = jsonDecode(jsonString) as Map<String, dynamic>;
            final cachedData = CachedData.fromJson(json, fromJson);
            
            if (cachedData.isExpired) {
              keysToDelete.add(key as String);
            }
          } catch (e) {
            // بيانات معطوبة، احذفها
            keysToDelete.add(key as String);
          }
        }
      }
      
      for (final key in keysToDelete) {
        await box.delete(key);
      }
      
      if (keysToDelete.isNotEmpty) {
        log('🧹 Cleaned ${keysToDelete.length} expired items from box "$boxName"');
      }
    } catch (e) {
      log('❌ Failed to clean expired data: $e');
    }
  }
  
  /// إحصائيات التخزين المؤقت
  Future<CacheStats> getStats() async {
    try {
      final box = await _getBox();
      int total = 0;
      int expired = 0;
      int valid = 0;
      
      for (final key in box.keys) {
        total++;
        final jsonString = box.get(key);
        
        if (jsonString != null) {
          try {
            final json = jsonDecode(jsonString) as Map<String, dynamic>;
            final cachedData = CachedData.fromJson(json, fromJson);
            
            if (cachedData.isExpired) {
              expired++;
            } else {
              valid++;
            }
          } catch (e) {
            expired++; // عدّ البيانات المعطوبة كمنتهية الصلاحية
          }
        }
      }
      
      return CacheStats(
        boxName: boxName,
        totalItems: total,
        validItems: valid,
        expiredItems: expired,
      );
    } catch (e) {
      log('❌ Failed to get cache stats: $e');
      return CacheStats(boxName: boxName, totalItems: 0, validItems: 0, expiredItems: 0);
    }
  }
  
  /// إغلاق الصندوق
  Future<void> close() async {
    try {
      if (_box != null && _box!.isOpen) {
        await _box!.close();
        _box = null;
        log('🔐 Closed Hive box "$boxName"');
      }
    } catch (e) {
      log('❌ Failed to close box "$boxName": $e');
    }
  }
}

/// إحصائيات التخزين المؤقت
class CacheStats {
  final String boxName;
  final int totalItems;
  final int validItems;
  final int expiredItems;
  
  const CacheStats({
    required this.boxName,
    required this.totalItems,
    required this.validItems,
    required this.expiredItems,
  });
  
  double get hitRate => totalItems > 0 ? validItems / totalItems : 0.0;
  
  @override
  String toString() {
    return 'CacheStats(box: $boxName, total: $totalItems, valid: $validItems, expired: $expiredItems, hitRate: ${(hitRate * 100).toStringAsFixed(1)}%)';
  }
}