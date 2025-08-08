import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/widgets/dialogs/login_required_dialog.dart';

class AuthGuard {
  static bool _isAuthenticated(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated;
  }

  static bool _isGuest(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthGuest;
  }

  static bool _hasAccess(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated || authState is AuthGuest;
  }

  /// يتحقق من تسجيل الدخول ويعرض popup إذا لم يكن مسجلاً
  static bool requireAuth(BuildContext context, {String? feature}) {
    if (_isAuthenticated(context)) {
      return true;
    }

    // عرض popup للمستخدم غير المسجل
    _showLoginRequiredDialog(context, feature: feature);
    return false;
  }

  /// يتحقق من التنقل حسب نوع المستخدم
  static bool canNavigate(BuildContext context, String route) {
    // الصفحات المسموحة للجميع (مسجلين وزوار)
    final publicRoutes = [
      '/',
      '/app/home',
      '/app/products', 
      '/product',
      '/auth/login',
      '/auth/register',
      '/auth/verify-email',
      '/splash',
    ];

    // الصفحات التي تتطلب تسجيل دخول فقط
    final authRequiredRoutes = [
      '/app/cart',
      '/app/profile',
      '/orders',
      '/settings',
      '/admin',
    ];

    // الصفحات العامة مسموحة للجميع
    if (publicRoutes.any((publicRoute) => route.startsWith(publicRoute))) {
      return true;
    }

    // إذا كان الراوت يتطلب تسجيل دخول
    if (authRequiredRoutes.any((authRoute) => route.startsWith(authRoute))) {
      if (_isAuthenticated(context)) {
        return true;
      }
      
      // منع الزوار من الوصول
      if (_isGuest(context)) {
        _showLoginRequiredDialog(context);
        return false;
      }
      
      // غير مسجل أصلاً
      _showLoginRequiredDialog(context);
      return false;
    }

    // افتراضياً، يحتاج تسجيل دخول
    if (_hasAccess(context)) {
      return true;
    }

    _showLoginRequiredDialog(context);
    return false;
  }

  static void _showLoginRequiredDialog(BuildContext context, {String? feature}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => LoginRequiredDialog(feature: feature),
    );
  }

  /// للتحقق من الحالة فقط دون عرض popup
  static bool isAuthenticated(BuildContext context) {
    return _isAuthenticated(context);
  }

  /// للتحقق من حالة الزائر
  static bool isGuest(BuildContext context) {
    return _isGuest(context);
  }

  /// للتحقق من إمكانية الوصول (مسجل أو زائر)
  static bool hasAccess(BuildContext context) {
    return _hasAccess(context);
  }

  /// للتحقق من نوع المستخدم
  static String getUserType(BuildContext context) {
    if (_isAuthenticated(context)) {
      return 'authenticated';
    } else if (_isGuest(context)) {
      return 'guest';
    } else {
      return 'anonymous';
    }
  }

  /// للحصول على المستخدم الحالي
  static String? getCurrentUserEmail(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.email;
    }
    return null;
  }
}