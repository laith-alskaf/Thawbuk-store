import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/widgets/dialogs/login_required_dialog.dart';

class AuthGuard {
  static bool _isAuthenticated(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated;
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

  /// يتحقق من تسجيل الدخول للتنقل
  static bool canNavigate(BuildContext context, String route) {
    // الصفحات المسموحة للزوار
    final publicRoutes = [
      '/',
      '/home',
      '/products',
      '/product',
      '/login',
      '/register',
      '/verify-email',
    ];

    // إذا كان الراوت عام، اسمح بالدخول
    if (publicRoutes.any((route) => route.startsWith(route))) {
      return true;
    }

    // إذا كان مسجل دخول، اسمح بالدخول
    if (_isAuthenticated(context)) {
      return true;
    }

    // منع الدخول وعرض popup
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

  /// للحصول على المستخدم الحالي
  static String? getCurrentUserEmail(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.email;
    }
    return null;
  }
}