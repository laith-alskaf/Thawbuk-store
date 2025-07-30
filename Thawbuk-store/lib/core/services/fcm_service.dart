import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// تهيئة FCM وطلب الأذونات
  Future<void> initialize() async {
    try {
      // طلب الأذونات
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('FCM: User granted permission');
        
        // الحصول على FCM Token
        await _getFCMToken();
        
        // الاستماع لتحديث التوكن
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          debugPrint('FCM Token refreshed: $newToken');
          // يمكن إرسال التوكن الجديد للخادم هنا
        });

        // معالجة الرسائل في المقدمة
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        
        // معالجة النقر على الإشعار
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
        
      } else {
        debugPrint('FCM: User declined or has not accepted permission');
      }
    } catch (e) {
      debugPrint('FCM initialization error: $e');
    }
  }

  /// الحصول على FCM Token
  Future<String?> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $_fcmToken');
      return _fcmToken;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// معالجة الرسائل في المقدمة
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    
    // يمكن إضافة منطق إضافي هنا مثل إظهار dialog أو snackbar
  }

  /// معالجة النقر على الإشعار
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message clicked: ${message.messageId}');
    
    // يمكن إضافة منطق التنقل هنا حسب محتوى الرسالة
    if (message.data.isNotEmpty) {
      debugPrint('Message data: ${message.data}');
    }
  }

  /// إعادة تحديث التوكن
  Future<String?> refreshToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      return await _getFCMToken();
    } catch (e) {
      debugPrint('Error refreshing FCM token: $e');
      return null;
    }
  }

  /// حذف التوكن (عند تسجيل الخروج)
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      debugPrint('FCM Token deleted');
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }
}