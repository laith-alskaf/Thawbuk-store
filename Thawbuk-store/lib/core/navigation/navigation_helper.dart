import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/bloc/auth/auth_bloc.dart' as auth_bloc;
import '../guards/auth_guard.dart';
import '../events/app_events.dart';

class NavigationHelper {
  /// التنقل مع حذف الصفحات السابقة (للأداء العالي)
  static void pushAndClearStack(BuildContext context, String route) {
    // حذف جميع الصفحات السابقة والانتقال للصفحة الجديدة
    while (context.canPop()) {
      context.pop();
    }
    context.pushReplacement(route);
  }

  /// التنقل للصفحة الرئيسية مع حذف التاريخ
  static void goToHome(BuildContext context) {
    pushAndClearStack(context, '/home');
  }

  /// التنقل لتسجيل الدخول مع حذف التاريخ
  static void goToLogin(BuildContext context) {
    pushAndClearStack(context, '/login');
  }

  /// التنقل للتسجيل مع حذف التاريخ
  static void goToRegister(BuildContext context) {
    pushAndClearStack(context, '/register');
  }

  /// تسجيل الخروج مع التنظيف والتوجيه
  static void logout(BuildContext context) {
    // إرسال أحداث التنظيف عبر EventBus
    EventBus.logout();
    
    // إرسال حدث تسجيل الخروج للـ AuthBloc
    context.read<auth_bloc.AuthBloc>().add(auth_bloc.LogoutEvent());
    
    // التوجه لصفحة تسجيل الدخول مع حذف التاريخ
    pushAndClearStack(context, '/login');
  }

  /// التنقل للصفحات المحمية مع التحقق من التسجيل
  static void navigateToProtectedRoute(
    BuildContext context, 
    String route, 
    {String? feature}
  ) {
    if (AuthGuard.requireAuth(context, feature: feature)) {
      context.push(route);
    }
    // إذا لم يكن مسجلاً، سيظهر الـ popup تلقائياً
  }

  /// التنقل للسلة مع التحقق
  static void goToCart(BuildContext context) {
    navigateToProtectedRoute(context, '/cart', feature: 'cart');
  }

  /// التنقل للمفضلة مع التحقق
  static void goToFavorites(BuildContext context) {
    navigateToProtectedRoute(context, '/favorites', feature: 'favorites');
  }

  /// التنقل للطلبات مع التحقق
  static void goToOrders(BuildContext context) {
    navigateToProtectedRoute(context, '/orders', feature: 'orders');
  }

  /// التنقل للملف الشخصي مع التحقق
  static void goToProfile(BuildContext context) {
    navigateToProtectedRoute(context, '/profile', feature: 'profile');
  }

  /// إضافة للسلة مع التحقق
  static bool addToCart(BuildContext context) {
    return AuthGuard.requireAuth(context, feature: 'cart');
  }

  /// إضافة للمفضلة مع التحقق
  static bool addToFavorites(BuildContext context) {
    return AuthGuard.requireAuth(context, feature: 'favorites');
  }

  /// كتابة تقييم مع التحقق
  static bool writeReview(BuildContext context) {
    return AuthGuard.requireAuth(context, feature: 'reviews');
  }

  /// التنقل للدفع مع التحقق
  static void goToCheckout(BuildContext context) {
    navigateToProtectedRoute(context, '/checkout', feature: 'checkout');
  }

  /// التحقق من حالة التسجيل
  static bool isLoggedIn(BuildContext context) {
    return AuthGuard.isAuthenticated(context);
  }

  /// الحصول على إيميل المستخدم الحالي
  static String? getCurrentUserEmail(BuildContext context) {
    return AuthGuard.getCurrentUserEmail(context);
  }

  /// التنقل بناءً على حالة التسجيل
  static void navigateBasedOnAuth(BuildContext context) {
    final authState = context.read<auth_bloc.AuthBloc>().state;
    
    if (authState is auth_bloc.AuthAuthenticated) {
      goToHome(context);
    } else if (authState is auth_bloc.AuthUnauthenticated) {
      goToLogin(context);
    } else if (authState is auth_bloc.AuthRegistrationSuccess) {
      context.pushReplacement('/verify-email/${authState.email}');
    }
  }

  /// معالجة الأخطاء في التنقل
  static void handleNavigationError(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// عرض رسالة نجاح
  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}