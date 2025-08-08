import 'package:flutter/material.dart';
import '../../pages/admin/admin_layout_improved.dart';

/// Shell route للوحة الإدارة مع bottom navigation
class AdminShell extends StatelessWidget {
  final Widget child;
  
  const AdminShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AdminLayoutImproved(child: child);
  }
}

/// تحديد الـ navigation paths للوحة الإدارة
class AdminPaths {
  static const String dashboard = '/admin/dashboard';
  static const String products = '/admin/products';
  static const String addProduct = '/admin/add-product';
  static const String allProducts = '/admin/all-products';
  static const String profile = '/admin/profile';
  
  // Sub-routes (ستفتح كـ push وليس tab navigation)
  static const String editProduct = '/admin/edit-product';
  static const String productsAnalytics = '/admin/products-analytics';
  static const String storeProfile = '/admin/store-profile';
  static const String settings = '/admin/settings';
}

/// Helper لتحديد الـ tab الحالي بناءً على المسار
class AdminTabHelper {
  static int getTabIndex(String location) {
    switch (location) {
      case AdminPaths.dashboard:
        return 0;
      case AdminPaths.products:
        return 1;
      case AdminPaths.addProduct:
        return 2;
      case AdminPaths.allProducts:
        return 3;
      case AdminPaths.profile:
        return 4;
      default:
        return 0;
    }
  }

  static String getTabPath(int index) {
    switch (index) {
      case 0:
        return AdminPaths.dashboard;
      case 1:
        return AdminPaths.products;
      case 2:
        return AdminPaths.addProduct;
      case 3:
        return AdminPaths.allProducts;
      case 4:
        return AdminPaths.profile;
      default:
        return AdminPaths.dashboard;
    }
  }

  /// تحديد ما إذا كان المسار يتطلب bottom navigation أم لا
  static bool shouldShowBottomNav(String location) {
    return [
      AdminPaths.dashboard,
      AdminPaths.products,
      AdminPaths.addProduct,
      AdminPaths.allProducts,
      AdminPaths.profile,
    ].contains(location);
  }
}