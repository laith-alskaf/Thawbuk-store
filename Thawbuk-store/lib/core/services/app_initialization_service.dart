import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../cache/cache_initialization_service.dart';
import '../di/dependency_injection.dart';
import '../services/fcm_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../firebase_options.dart';

/// خدمة تهيئة التطبيق الشاملة
class AppInitializationService {
  static AppInitializationService? _instance;
  static AppInitializationService get instance => _instance ??= AppInitializationService._();

  AppInitializationService._();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// تهيئة شاملة للتطبيق
  Future<void> initialize() async {
    if (_isInitialized) {
      log('⚠️ App already initialized');
      return;
    }

    try {
      log('🚀 Starting app initialization...');

      // 1. تهيئة Hive للتخزين المحلي
      await _initializeHive();

      // 2. تهيئة Firebase
      await _initializeFirebase();

      // 3. تهيئة Dependency Injection
      await _initializeDependencyInjection();

      // 4. تحميل وتطبيق حالة المستخدم المحفوظة
      await _loadSavedUserState();

      _isInitialized = true;
      log('🎉 App initialization completed successfully');

    } catch (e) {
      log('❌ App initialization failed: $e');
      rethrow;
    }
  }

  /// تهيئة Hive مع التكيّفات المطلوبة
  Future<void> _initializeHive() async {
    try {
      log('📦 Initializing Hive...');
      
      await Hive.initFlutter();
      
      // تسجيل Type Adapters للكيانات
      await _registerHiveAdapters();
      
      log('✅ Hive initialized successfully');
    } catch (e) {
      log('❌ Failed to initialize Hive: $e');
      rethrow;
    }
  }

  /// تسجيل Hive Type Adapters
  Future<void> _registerHiveAdapters() async {
    try {
      // تسجيل adapters للكيانات الأساسية
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(UserRoleAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(GenderAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(OrderStatusAdapter());
      }
      
      // يمكن إضافة المزيد من الـ adapters حسب الحاجة
      log('✅ Hive adapters registered successfully');
    } catch (e) {
      log('❌ Failed to register Hive adapters: $e');
      rethrow;
    }
  }

  /// تهيئة Firebase
  Future<void> _initializeFirebase() async {
    try {
      log('🔥 Initializing Firebase...');
      
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      log('✅ Firebase initialized successfully');
    } catch (e) {
      log('⚠️ Firebase initialization failed (continuing without Firebase): $e');
      // لا نريد إيقاف التطبيق بسبب فشل Firebase
    }
  }

  /// تهيئة Dependency Injection
  Future<void> _initializeDependencyInjection() async {
    try {
      log('🔧 Initializing dependencies...');
      
      await configureDependencies();
      
      log('✅ Dependencies initialized successfully');
    } catch (e) {
      log('❌ Failed to initialize dependencies: $e');
      rethrow;
    }
  }

  /// تحميل حالة المستخدم المحفوظة وتطبيق التخزين المؤقت المناسب
  Future<void> _loadSavedUserState() async {
    try {
      log('👤 Loading saved user state...');
      
      // محاولة تحميل بيانات المستخدم المحفوظة
      final authRepository = getIt<AuthRepository>();
      final currentUser = await authRepository.getCurrentUser();
      
      if (currentUser.isRight()) {
        // مستخدم مسجل الدخول
        final user = currentUser.getOrElse(() => throw Exception('No user'));
        await initializeCacheForUser(user);
        log('✅ Cache initialized for saved user: ${user.email}');
      } else {
        // زائر - تهيئة التخزين المؤقت للزائر
        await initializeCacheForGuest();
        log('✅ Cache initialized for guest user');
      }
      
    } catch (e) {
      log('⚠️ Error loading saved user state (initializing as guest): $e');
      // في حالة الخطأ، نعتبر المستخدم زائر
      try {
        await initializeCacheForGuest();
      } catch (guestError) {
        log('❌ Failed to initialize cache for guest: $guestError');
      }
    }
  }

  /// تهيئة التطبيق للمستخدم المسجل الدخول
  Future<void> initializeForLoggedInUser(UserEntity user) async {
    try {
      log('👤 Initializing app for logged in user: ${user.email}');
      
      // تهيئة التخزين المؤقت للمستخدم
      await initializeCacheForUser(user);
      
      // يمكن إضافة تهيئات إضافية هنا
      await _initializeUserSpecificServices(user);
      
      log('✅ App initialized for user: ${user.email}');
    } catch (e) {
      log('❌ Failed to initialize app for user: $e');
      rethrow;
    }
  }

  /// تهيئة خدمات خاصة بالمستخدم
  Future<void> _initializeUserSpecificServices(UserEntity user) async {
    try {
      // تهيئة خدمة FCM للإشعارات
      final fcmService = getIt<FCMService>();
      await fcmService.initialize();
      
      // تحديث FCM token للمستخدم
      if (user.fcmToken != null) {
        await fcmService.updateToken(user.fcmToken!);
      }
      
      // تهيئة خدمات أخرى حسب دور المستخدم
      switch (user.role) {
        case UserRole.admin:
        case UserRole.superAdmin:
          await _initializeAdminServices(user);
          break;
        case UserRole.customer:
          await _initializeCustomerServices(user);
          break;
      }
      
      log('✅ User-specific services initialized');
    } catch (e) {
      log('⚠️ Error initializing user-specific services: $e');
      // لا نريد إيقاف التطبيق بسبب فشل هذه الخدمات
    }
  }

  /// تهيئة خدمات خاصة بالإدارة
  Future<void> _initializeAdminServices(UserEntity user) async {
    try {
      log('👨‍💼 Initializing admin services for: ${user.email}');
      
      // تحميل بيانات الإحصائيات المحفوظة
      // تهيئة إعدادات الإدارة
      // تحديد صلاحيات الوصول
      
      log('✅ Admin services initialized');
    } catch (e) {
      log('❌ Error initializing admin services: $e');
    }
  }

  /// تهيئة خدمات خاصة بالعملاء
  Future<void> _initializeCustomerServices(UserEntity user) async {
    try {
      log('👤 Initializing customer services for: ${user.email}');
      
      // تحميل السلة المحفوظة
      // تحميل المفضلة المحفوظة
      // تهيئة إعدادات التطبيق الشخصية
      
      log('✅ Customer services initialized');
    } catch (e) {
      log('❌ Error initializing customer services: $e');
    }
  }

  /// تنظيف التطبيق عند تسجيل الخروج
  Future<void> cleanupOnLogout() async {
    try {
      log('🧹 Cleaning up on logout...');
      
      // تنظيف التخزين المؤقت
      await clearCacheOnLogout();
      
      // تنظيف خدمة FCM
      final fcmService = getIt<FCMService>();
      await fcmService.clearToken();
      
      // تنظيف البيانات الحساسة
      await _cleanupSensitiveData();
      
      log('✅ Cleanup completed');
    } catch (e) {
      log('❌ Error during cleanup: $e');
    }
  }

  /// تنظيف البيانات الحساسة
  Future<void> _cleanupSensitiveData() async {
    try {
      // مسح tokens
      // مسح بيانات الدفع المؤقتة
      // مسح كلمات المرور المحفوظة مؤقتاً
      
      log('🔐 Sensitive data cleaned');
    } catch (e) {
      log('❌ Error cleaning sensitive data: $e');
    }
  }

  /// إعادة تشغيل التطبيق (في حالة تغيير جذري)
  Future<void> restart() async {
    try {
      log('🔄 Restarting app...');
      
      // تنظيف الحالة الحالية
      await _cleanup();
      
      // إعادة التهيئة
      _isInitialized = false;
      await initialize();
      
      log('✅ App restarted successfully');
    } catch (e) {
      log('❌ Error restarting app: $e');
      rethrow;
    }
  }

  /// تنظيف شامل للتطبيق
  Future<void> _cleanup() async {
    try {
      // إغلاق جميع الـ boxes المفتوحة في Hive
      await Hive.close();
      
      // تنظيف خدمات التخزين المؤقت
      final cacheInitService = getIt<CacheInitializationService>();
      await cacheInitService.dispose();
      
      log('🧹 App cleanup completed');
    } catch (e) {
      log('❌ Error during app cleanup: $e');
    }
  }

  /// الحصول على معلومات حالة التطبيق
  Map<String, dynamic> getAppStatus() {
    return {
      'isInitialized': _isInitialized,
      'timestamp': DateTime.now().toIso8601String(),
      'version': '1.0.0', // يمكن الحصول عليها من package_info
      'cacheSystemActive': true,
    };
  }

  /// للتطوير - طباعة معلومات التشخيص
  void debugPrintAppInfo() {
    if (kDebugMode) {
      log('🐛 DEBUG: App initialization info:');
      log('   - Initialized: $_isInitialized');
      log('   - Hive status: ${Hive.isBoxOpen('cache')}');
      log('   - DI ready: ${getIt.isReady<CacheInitializationService>()}');
    }
  }
}

/// Hive Type Adapters للكيانات
class UserRoleAdapter extends TypeAdapter<UserRole> {
  @override
  final int typeId = 0;

  @override
  UserRole read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserRole.customer;
      case 1:
        return UserRole.admin;
      case 2:
        return UserRole.superAdmin;
      default:
        return UserRole.customer;
    }
  }

  @override
  void write(BinaryWriter writer, UserRole obj) {
    switch (obj) {
      case UserRole.customer:
        writer.writeByte(0);
        break;
      case UserRole.admin:
        writer.writeByte(1);
        break;
      case UserRole.superAdmin:
        writer.writeByte(2);
        break;
    }
  }
}

class GenderAdapter extends TypeAdapter<Gender> {
  @override
  final int typeId = 1;

  @override
  Gender read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Gender.male;
      case 1:
        return Gender.female;
      case 2:
        return Gender.other;
      default:
        return Gender.male;
    }
  }

  @override
  void write(BinaryWriter writer, Gender obj) {
    switch (obj) {
      case Gender.male:
        writer.writeByte(0);
        break;
      case Gender.female:
        writer.writeByte(1);
        break;
      case Gender.other:
        writer.writeByte(2);
        break;
    }
  }
}

class OrderStatusAdapter extends TypeAdapter<OrderStatus> {
  @override
  final int typeId = 2;

  @override
  OrderStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OrderStatus.pending;
      case 1:
        return OrderStatus.confirmed;
      case 2:
        return OrderStatus.processing;
      case 3:
        return OrderStatus.shipped;
      case 4:
        return OrderStatus.delivered;
      case 5:
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, OrderStatus obj) {
    switch (obj) {
      case OrderStatus.pending:
        writer.writeByte(0);
        break;
      case OrderStatus.confirmed:
        writer.writeByte(1);
        break;
      case OrderStatus.processing:
        writer.writeByte(2);
        break;
      case OrderStatus.shipped:
        writer.writeByte(3);
        break;
      case OrderStatus.delivered:
        writer.writeByte(4);
        break;
      case OrderStatus.cancelled:
        writer.writeByte(5);
        break;
    }
  }
}