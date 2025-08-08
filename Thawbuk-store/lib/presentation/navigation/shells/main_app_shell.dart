import 'package:flutter/material.dart';
import '../../pages/main/main_layout_improved.dart';

/// Shell route للتطبيق الرئيسي مع bottom navigation
class MainAppShell extends StatelessWidget {
  final Widget child;
  
  const MainAppShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MainLayoutImproved(child: child);
  }
}

/// تحديد الـ navigation paths للتطبيق الرئيسي
class MainAppPaths {
  static const String home = '/app/home';
  static const String products = '/app/products';
  static const String cart = '/app/cart';
  static const String favorites = '/app/favorites';
}

/// Helper لتحديد الـ tab الحالي بناءً على المسار
class MainAppTabHelper {
  static int getTabIndex(String location) {
    switch (location) {
      case MainAppPaths.home:
        return 0;
      case MainAppPaths.products:
        return 1;
      case MainAppPaths.cart:
        return 2;
      case MainAppPaths.favorites:
        return 3;
      default:
        return 0;
    }
  }

  static String getTabPath(int index) {
    switch (index) {
      case 0:
        return MainAppPaths.home;
      case 1:
        return MainAppPaths.products;
      case 2:
        return MainAppPaths.cart;
      case 3:
        return MainAppPaths.favorites;
      default:
        return MainAppPaths.home;
    }
  }
}