import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

class ApiClient {
  final Dio _dio;
  
  ApiClient() : _dio = Dio() {
    _dio.options.baseUrl = AppConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    
    // إضافة Interceptors
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }
  
  // تحديث التوكن
  void updateToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }
  
  // Auth endpoints
  Future<Response> register(Map<String, dynamic> userData) async {
    try {
      return await _dio.post('/auth/register', data: userData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> login(Map<String, dynamic> credentials) async {
    try {
      return await _dio.post('/auth/login', data: credentials);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> logout() async {
    try {
      return await _dio.post('/auth/logout');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> getCurrentUser() async {
    try {
      return await _dio.get('/user/me');
    } catch (e) {
      throw _handleError(e);
    }
  }
  // Product endpoints
  Future<Response> getProducts({Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get('/public/products', queryParameters: queryParameters);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> getProductById(String id) async {
    try {
      return await _dio.get('/public/products/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> searchProducts(String query) async {
    try {
      return await _dio.get('/public/products/search', queryParameters: {'q': query});
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> getProductsByCategory(String categoryId) async {
    try {
      return await _dio.get('/public/products/byCategory/$categoryId');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> filterProducts(Map<String, dynamic> filters) async {
    try {
      return await _dio.get('/public/products/filter', queryParameters: filters);
    } catch (e) {
      throw _handleError(e);
    }
  }
  // Category endpoints
  Future<Response> getCategories() async {
    try {
      return await _dio.get('/public/categories');
    } catch (e) {
      throw _handleError(e);
    }
  }
  // Cart endpoints
  Future<Response> getCart() async {
    try {
      return await _dio.get('/cart');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> addToCart(Map<String, dynamic> cartData) async {
    try {
      return await _dio.post('/cart/add', data: cartData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> updateCartItem(Map<String, dynamic> updateData) async {
    try {
      return await _dio.put('/cart/update', data: updateData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> removeFromCart(String productId) async {
    try {
      return await _dio.delete('/cart/remove/$productId');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> clearCart() async {
    try {
      return await _dio.delete('/cart/clear');
    } catch (e) {
      throw _handleError(e);
    }
  }
  // Wishlist endpoints
  Future<Response> getWishlist() async {
    try {
      return await _dio.get('/wishlist');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> addToWishlist(Map<String, dynamic> wishlistData) async {
    try {
      return await _dio.post('/wishlist', data: wishlistData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> toggleWishlist(Map<String, dynamic> toggleData) async {
    try {
      return await _dio.post('/wishlist/toggle', data: toggleData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> removeFromWishlist(String productId) async {
    try {
      return await _dio.delete('/wishlist/product', data: {'productId': productId});
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> clearWishlist() async {
    try {
      return await _dio.delete('/wishlist/all-product');
    } catch (e) {
      throw _handleError(e);
    }
  }
  // معالجة الأخطاء
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return NetworkException('انتهت مهلة الاتصال');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            return UnauthorizedException('غير مصرح لك بالوصول');
          } else if (statusCode == 404) {
            return NotFoundException('المورد غير موجود');
          } else if (statusCode! >= 500) {
            return ServerException('خطأ في الخادم');
          } else {
            return ClientException('خطأ في البيانات المرسلة');
          }
        case DioExceptionType.cancel:
          return NetworkException('تم إلغاء الطلب');
        case DioExceptionType.unknown:
          return NetworkException('خطأ في الشبكة');
        default:
          return ServerException('خطأ غير معروف');
      }
    }
    return ServerException(error.toString());
  }
}