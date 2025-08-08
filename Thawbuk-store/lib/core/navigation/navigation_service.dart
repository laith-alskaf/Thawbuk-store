import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// خدمة التنقل المركزية للتطبيق
/// تسهل عملية التنقل وتوفر methods واضحة ومنظمة
class NavigationService {
  static NavigationService? _instance;
  static NavigationService get instance => _instance ??= NavigationService._internal();
  
  NavigationService._internal();
  
  late final GoRouter _router;
  GoRouter get router => _router;
  
  void setRouter(GoRouter router) {
    _router = router;
  }

  // Main App Navigation
  void goToHome() => _router.go('/app/home');
  void goToProducts() => _router.go('/app/products');
  void goToCart() => _router.go('/app/cart');
  void goToFavorites() => _router.go('/app/favorites');
  void goToProfile() => _router.go('/app/profile');

  // Product Navigation
  void goToProductDetail(String productId) => _router.push('/product/$productId');

  // Admin Navigation
  void goToAdminDashboard() => _router.go('/admin/dashboard');
  void goToAdminProducts() => _router.go('/admin/products');
  void goToAddProduct() => _router.go('/admin/add-product');
  void goToAllProducts() => _router.go('/admin/all-products');
  void goToAdminProfile() => _router.go('/admin/profile');

  // Admin Actions (با push لإمكانية الرجوع)
  void pushAdminProducts() => _router.push('/admin/products');
  void pushAddProduct() => _router.push('/admin/add-product');
  void pushAllProducts() => _router.push('/admin/all-products');
  void pushAdminProfile() => _router.push('/admin/profile');
  void pushEditProduct(dynamic product) => _router.push('/admin/edit-product', extra: product);
  void pushProductAnalytics() => _router.push('/admin/products-analytics');
  void pushAdminStoreProfile() => _router.push('/admin/store-profile');
  void pushAdminSettings() => _router.push('/admin/settings');

  // Auth Navigation
  void goToLogin() => _router.go('/auth/login');
  void goToRegister() => _router.go('/auth/register');
  void goToVerifyEmail(String email) => _router.go('/auth/verify-email/$email');

  // Utility Methods
  void back() => _router.pop();
  void goBack() => _router.pop();
  bool canPop() => _router.canPop();

  // Settings and Others
  void pushSettings() => _router.push('/settings');
  void pushOrders() => _router.push('/orders');
  void pushStoreProfile(String storeId) => _router.push('/store/$storeId');

  // Root level navigation
  void goToRoot() => _router.go('/');

  // Error and utility
  void replace(String location) => _router.replace(location);
  void pushReplacement(String location) => _router.pushReplacement(location);
  
  /// Navigate to location with custom transition
  void navigateWithTransition(String location, {Object? extra}) {
    _router.push(location, extra: extra);
  }
  
  /// Clear stack and navigate to location
  void clearAndNavigateTo(String location) {
    _router.go(location);
  }

  /// Get current route information
  String get currentLocation => _router.routerDelegate.currentConfiguration.uri.path;
  
  /// Check if we're in admin area
  bool get isInAdminArea => currentLocation.startsWith('/admin');
  
  /// Check if we're in main app area
  bool get isInMainApp => currentLocation.startsWith('/app');
}

/// Extension لسهولة الاستخدام مع BuildContext
extension NavigationExtension on BuildContext {
  NavigationService get nav => NavigationService.instance;
}

/// Route paths constants لتجنب الأخطاء
abstract class AppRoutes {
  // Auth Routes
  static const String splash = '/splash';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyEmail = '/auth/verify-email';

  // Main App Routes
  static const String appHome = '/app/home';
  static const String appProducts = '/app/products';
  static const String appCart = '/app/cart';
  static const String appFavorites = '/app/favorites';
  static const String appProfile = '/app/profile';

  // Product Routes
  static const String productDetail = '/product';

  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminProducts = '/admin/products';
  static const String adminAddProduct = '/admin/add-product';
  static const String adminEditProduct = '/admin/edit-product';
  static const String adminAllProducts = '/admin/all-products';
  static const String adminProfile = '/admin/profile';
  static const String adminProductAnalytics = '/admin/products-analytics';
  static const String adminStoreProfile = '/admin/store-profile';
  static const String adminSettings = '/admin/settings';

  // Other Routes
  static const String settings = '/settings';
  static const String orders = '/orders';
  static const String storeProfile = '/store';
}

/// Navigation result types
enum NavigationResult {
  success,
  cancelled,
  error,
}

/// Navigation animation types
enum NavigationTransition {
  slide,
  fade,
  scale,
  none,
}