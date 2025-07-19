class AppConstants {
  // معلومات التطبيق
  static const String appName = 'ثوبك';
  static const String appVersion = '1.0.0';
  
  // الشبكة
  static const String baseUrl = 'http://localhost:5000/api';
  static const int connectTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;
  
  // التخزين المحلي
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String languageKey = 'language';
  static const String themeKey = 'theme_mode';
  
  // الصفحات
  static const int productsPerPage = 10;
  static const int maxCartItems = 99;
  
  // التصميم
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
}

class ApiEndpoints {
  // المصادقة
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyEmail = '/auth/verify-email';
  
  // المنتجات
  static const String products = '/product';
  static const String productsByCategory = '/product/byCategory';
  static const String searchProducts = '/product/search';
  
  // الفئات
  static const String categories = '/category';
  
  // المستخدم
  static const String userProfile = '/user/me';
  static const String updateProfile = '/user/me';
  
  // السلة
  static const String cart = '/user/cart';
  static const String addToCart = '/user/cart/add';
  static const String updateCart = '/user/cart/update';
  static const String removeFromCart = '/user/cart/remove';
  static const String clearCart = '/user/cart/clear';
  
  // الطلبات
  static const String orders = '/user/order';
  static const String createOrder = '/user/order';
  
  // المفضلة
  static const String wishlist = '/user/wishlist';
}