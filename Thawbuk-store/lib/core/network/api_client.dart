import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import 'network_info.dart';

class ApiClient {
  final NetworkInfo networkInfo;
  String? _authToken;

  ApiClient({required this.networkInfo});

  // تحديث التوكن
  void updateToken(String? token) {
    _authToken = token;
  }

  // Headers مشتركة
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  // فحص الاتصال قبل أي طلب
  Future<void> _checkConnection() async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      throw NetworkException(
          'لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال والمحاولة مرة أخرى.');
    }
  }

  /// طباعة تفاصيل الطلب
  void _logRequest(String method, String url, Map<String, String> headers,
      {Map<String, dynamic>? data}) {
    developer.log('🚀 API REQUEST', name: 'ApiClient');
    developer.log('Method: $method', name: 'ApiClient');
    developer.log('URL: $url', name: 'ApiClient');
    developer.log('Headers: ${jsonEncode(headers)}', name: 'ApiClient');
    if (data != null) {
      developer.log('Data: ${jsonEncode(data)}', name: 'ApiClient');
    }
    developer.log('─' * 50, name: 'ApiClient');
  }

  /// طباعة تفاصيل الاستجابة
  void _logResponse(http.Response response) {
    developer.log('📥 API RESPONSE', name: 'ApiClient');
    developer.log('Status Code: ${response.statusCode}', name: 'ApiClient');
    developer.log('Headers: ${jsonEncode(response.headers)}',
        name: 'ApiClient');
    developer.log('Body: ${response.body}', name: 'ApiClient');
    developer.log('─' * 50, name: 'ApiClient');
  }

  // معالجة الأخطاء
  Exception _handleError(dynamic error, int? statusCode) {
    // Log error
    developer.log('❌ API ERROR', name: 'ApiClient');
    developer.log('Error: ${error.toString()}', name: 'ApiClient');
    if (statusCode != null) {
      developer.log('Status Code: $statusCode', name: 'ApiClient');
    }
    developer.log('─' * 50, name: 'ApiClient');

    if (error is SocketException) {
      return NetworkException('خطأ في الاتصال بالشبكة');
    }

    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          return ServerException('طلب غير صحيح');
        case 401:
          return ServerException('غير مخول للوصول');
        case 403:
          return ServerException('ممنوع الوصول');
        case 404:
          return ServerException('المورد غير موجود');
        case 500:
          return ServerException('خطأ في الخادم');
        default:
          return ServerException('خطأ غير معروف: $statusCode');
      }
    }

    return ServerException(error.toString());
  }

  // GET request
  Future<Map<String, dynamic>> get(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    await _checkConnection();

    try {
      String url = '${AppConstants.baseUrl}$endpoint';

      if (queryParameters != null && queryParameters.isNotEmpty) {
        final queryString = queryParameters.entries
            .map((e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
            .join('&');
        url += '?$queryString';
      }

      // Log request
      _logRequest('GET', url, _headers);

      final response = await http
          .get(
            Uri.parse(url),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      // Log response
      _logResponse(response);

      return _processResponse(response);
    } catch (e) {
      throw _handleError(e, null);
    }
  }

  // POST request
  Future<Map<String, dynamic>> post(String endpoint,
      {Map<String, dynamic>? data}) async {
    await _checkConnection();

    try {
      final url = '${AppConstants.baseUrl}$endpoint';

      // Log request
      _logRequest('POST', url, _headers, data: data);

      final response = await http
          .post(
            Uri.parse(url),
            headers: _headers,
            body: data != null ? jsonEncode(data) : null,
          )
          .timeout(const Duration(seconds: 30));

      // Log response
      _logResponse(response);

      return _processResponse(response);
    } catch (e) {
      throw _handleError(e, null);
    }
  }

  // PUT request
  Future<Map<String, dynamic>> put(String endpoint,
      {Map<String, dynamic>? data}) async {
    await _checkConnection();

    try {
      final url = '${AppConstants.baseUrl}$endpoint';

      // Log request
      _logRequest('PUT', url, _headers, data: data);

      final response = await http
          .put(
            Uri.parse(url),
            headers: _headers,
            body: data != null ? jsonEncode(data) : null,
          )
          .timeout(const Duration(seconds: 30));

      // Log response
      _logResponse(response);

      return _processResponse(response);
    } catch (e) {
      throw _handleError(e, null);
    }
  }

  // DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    await _checkConnection();

    try {
      final url = '${AppConstants.baseUrl}$endpoint';

      // Log request
      _logRequest('DELETE', url, _headers);

      final response = await http
          .delete(
            Uri.parse(url),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      // Log response
      _logResponse(response);

      return _processResponse(response);
    } catch (e) {
      throw _handleError(e, null);
    }
  }

  // معالجة الاستجابة
  Map<String, dynamic> _processResponse(http.Response response) {
    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseData;
    } else {
      return throw 
         (responseData['message'] ?? 'خطأ في الخادم');
       
      

      // throw _handleError(responseData['message'] ?? 'خطأ في الخادم', response.statusCode);
    }
  }

  // Auth endpoints
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    return await post('/auth/register', data: userData);
  }

  Future<Map<String, dynamic>> login(Map<String, dynamic> credentials) async {
    return await post('/auth/login', data: credentials);
  }

  Future<Map<String, dynamic>> logout() async {
    return await post('/auth/logout');
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    return await get('/user/me');
  }

  Future<Map<String, dynamic>> verifyEmail(String code) async {
    return await post('/auth/verify-email', data: {'code': code});
  }

  Future<Map<String, dynamic>> resendVerificationCode(String email) async {
    return await post('/auth/resend-verification', data: {'email': email});
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return await post('/auth/forgot-password', data: {'email': email});
  }

  // Product endpoints
  Future<Map<String, dynamic>> getProducts(
      {Map<String, dynamic>? queryParameters}) async {
    return await get('/v2/product', queryParameters: queryParameters);
  }

  Future<Map<String, dynamic>> getProductById(String id) async {
    return await get('/v2/product/$id');
  }

  Future<Map<String, dynamic>> searchProducts(String query) async {
    return await get('/v2/product/enhanced-search',
        queryParameters: {'q': query});
  }

  Future<Map<String, dynamic>> getProductsByCategory(String categoryId) async {
    return await get('/v2/product/category/$categoryId');
  }

  Future<Map<String, dynamic>> getFilteredProducts(
      Map<String, dynamic> filters) async {
    return await get('/v2/product/filter', queryParameters: filters);
  }

  Future<Map<String, dynamic>> createProduct(
      Map<String, dynamic> productData) async {
    return await post('/v2/user/product', data: productData);
  }

  Future<Map<String, dynamic>> updateProduct(
      String id, Map<String, dynamic> productData) async {
    return await put('/v2/user/product/$id', data: productData);
  }

  Future<Map<String, dynamic>> deleteProduct(String id) async {
    return await delete('/v2/user/product/$id');
  }

  Future<Map<String, dynamic>> getMyProducts() async {
    return await get('/v2/user/product');
  }

  // Category endpoints
  Future<Map<String, dynamic>> getCategories() async {
    return await get('/v2/category');
  }

  // Cart endpoints
  Future<Map<String, dynamic>> getCart() async {
    return await get('/v2/user/cart');
  }

  Future<Map<String, dynamic>> addToCart(Map<String, dynamic> cartData) async {
    return await post('/v2/user/cart', data: cartData);
  }

  Future<Map<String, dynamic>> updateCartItem(
      String itemId, Map<String, dynamic> updateData) async {
    return await put('/v2/user/cart/$itemId', data: updateData);
  }

  Future<Map<String, dynamic>> removeFromCart(String itemId) async {
    return await delete('/v2/user/cart/$itemId');
  }

  Future<Map<String, dynamic>> clearCart() async {
    return await delete('/v2/user/cart');
  }

  // Order endpoints
  Future<Map<String, dynamic>> getOrders() async {
    return await get('/v2/user/order');
  }

  Future<Map<String, dynamic>> createOrder(
      Map<String, dynamic> orderData) async {
    return await post('/v2/user/order', data: orderData);
  }

  Future<Map<String, dynamic>> getOrderById(String id) async {
    return await get('/v2/user/order/$id');
  }

  // Store endpoints
  Future<Map<String, dynamic>> getStoreProfile(String storeId) async {
    return await get('/v2/store/$storeId');
  }

  Future<Map<String, dynamic>> getStoreProducts(String storeId) async {
    return await get('/v2/store/$storeId/products');
  }
}
