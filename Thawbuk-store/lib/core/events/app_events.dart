import 'dart:async';

/// نظام الأحداث العامة للتطبيق
class AppEvents {
  static final AppEvents _instance = AppEvents._internal();
  factory AppEvents() => _instance;
  AppEvents._internal();

  final StreamController<AppEvent> _eventController = StreamController<AppEvent>.broadcast();

  /// Stream للاستماع للأحداث
  Stream<AppEvent> get events => _eventController.stream;

  /// إرسال حدث
  void emit(AppEvent event) {
    _eventController.add(event);
  }

  /// إغلاق الـ stream
  void dispose() {
    _eventController.close();
  }
}

/// الأحداث المختلفة في التطبيق
abstract class AppEvent {}

/// حدث تسجيل الخروج - لتنظيف جميع البيانات
class AppLogoutEvent extends AppEvent {}

/// حدث تسجيل الدخول - لتحديث البيانات
class AppLoginEvent extends AppEvent {
  final String userId;
  final String email;

  AppLoginEvent({required this.userId, required this.email});
}

/// حدث تنظيف السلة
class ClearCartEvent extends AppEvent {}

/// حدث تنظيف المفضلة
class ClearFavoritesEvent extends AppEvent {}

/// حدث تنظيف الكاش
class ClearCacheEvent extends AppEvent {}

/// حدث إعادة تحميل البيانات
class RefreshDataEvent extends AppEvent {}

/// مساعد للوصول السريع لنظام الأحداث
class EventBus {
  static final AppEvents _events = AppEvents();

  /// إرسال حدث تسجيل الخروج
  static void logout() {
    _events.emit(AppLogoutEvent());
    _events.emit(ClearCartEvent());
    _events.emit(ClearFavoritesEvent());
    _events.emit(ClearCacheEvent());
  }

  /// إرسال حدث تسجيل الدخول
  static void login(String userId, String email) {
    _events.emit(AppLoginEvent(userId: userId, email: email));
    _events.emit(RefreshDataEvent());
  }

  /// الاستماع للأحداث
  static Stream<AppEvent> get events => _events.events;

  /// إرسال حدث مخصص
  static void emit(AppEvent event) {
    _events.emit(event);
  }
}