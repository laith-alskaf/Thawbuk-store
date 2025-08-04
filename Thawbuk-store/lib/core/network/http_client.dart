import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import 'network_info.dart';

class HttpClient {
  final SharedPreferences sharedPreferences;
  final NetworkInfo? networkInfo;
  
  HttpClient(this.sharedPreferences, {this.networkInfo});
  static var client = http.Client();
  /// فحص الاتصال بالإنترنت
  Future<void> _checkConnection() async {
    if (networkInfo != null) {
      final isConnected = await networkInfo!.isConnected;
      if (!isConnected) {
        throw NetworkException('لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال والمحاولة مرة أخرى.');
      }
    }
  }

  /// طباعة تفاصيل الطلب
  void _logRequest(String method, String url, Map<String, String> headers, {Map<String, dynamic>? body}) {
    developer.log('🚀 HTTP REQUEST', name: 'HttpClient');
    developer.log('Method: $method', name: 'HttpClient');
    developer.log('URL: $url', name: 'HttpClient');
    developer.log('Headers: ${jsonEncode(headers)}', name: 'HttpClient');
    if (body != null) {
      developer.log('Body: ${jsonEncode(body)}', name: 'HttpClient');
    }
    developer.log('─' * 50, name: 'HttpClient');
  }

  /// طباعة تفاصيل الاستجابة
  void _logResponse(http.Response response) {
    developer.log('📥 HTTP RESPONSE', name: 'HttpClient');
    developer.log('Status Code: ${response.statusCode}', name: 'HttpClient');
    developer.log('Headers: ${jsonEncode(response.headers)}', name: 'HttpClient');
    developer.log('Body: ${response.body}', name: 'HttpClient');
    developer.log('─' * 50, name: 'HttpClient');
  }

  /// الحصول على الرؤوس الأساسية
  Map<String, String> get _headers {
    final token = sharedPreferences.getString(AppConstants.tokenKey);
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// طلب GET
  Future<Map<String, dynamic>> get(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    await _checkConnection();
    try {
      var url = Uri.parse('${AppConstants.baseUrl}$endpoint');

      if (queryParameters != null) {
        // Filter out null values and convert all values to strings
        final validQueryParameters = queryParameters.entries
            .where((entry) => entry.value != null)
            .map((entry) =>
                MapEntry(entry.key, entry.value.toString()))
            .toList();
            
        url = url.replace(queryParameters: Map.fromEntries(validQueryParameters));
      }

      // Log request
      _logRequest('GET', url.toString(), _headers);

      final response = await http.get(url, headers: _headers);
      
      // Log response
      _logResponse(response);

      return _handleResponse(response);
    } catch (e) {
      developer.log('❌ GET ERROR: ${e.toString()}', name: 'HttpClient');
      throw ServerException('GET request failed: ${e.toString()}');
    }
  }

  /// طلب POST
  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    await _checkConnection();
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      
      // Log request
      _logRequest('POST', url.toString(), _headers, body: body);
      
      final response = await client.post(
        url,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );

      // Log response
      _logResponse(response);
      return _handleResponse(response);
    } catch (e) {
      developer.log('❌ POST ERROR: ${e.toString()}', name: 'HttpClient');
      throw ServerException('POST request failed: ${e.toString()}');
    }
  }

  /// طلب PUT
  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body}) async {
    await _checkConnection();
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      
      // Log request
      _logRequest('PUT', url.toString(), _headers, body: body);
      
      final response = await http.put(
        url,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      
      // Log response
      _logResponse(response);
      
      return _handleResponse(response);
    } catch (e) {
      throw ServerException('PUT request failed: ${e.toString()}');
    }
  }

  /// طلب DELETE (مع إرجاع بيانات)
  Future<Map<String, dynamic>> delete(String endpoint) async {
    await _checkConnection();
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      
      // Log request
      _logRequest('DELETE', url.toString(), _headers);
      
      final response = await http.delete(url, headers: _headers);
      
      // Log response
      _logResponse(response);
      
      return _handleResponse(response);
    } catch (e) {
      throw ServerException('DELETE request failed: ${e.toString()}');
    }
  }

  /// طلب DELETE (للحالات التي لا تحتاج رد)
  Future<void> deleteVoid(String endpoint) async {
    await _checkConnection();
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      
      // Log request
      _logRequest('DELETE', url.toString(), _headers);
      
      final response = await http.delete(url, headers: _headers);
      
      // Log response
      _logResponse(response);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        throw ServerException('Delete failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException('DELETE request failed: ${e.toString()}');
    }
  }

  /// معالجة الاستجابة
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    
    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) {
        return {}; // استجابة فارغة صحيحة
      }
      
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw ServerException('Invalid JSON response: ${e.toString()}');
      }
    } else if (statusCode == 401) {
      // إزالة التوكن المنتهي الصلاحية
      sharedPreferences.remove(AppConstants.tokenKey);
      throw UnauthorizedException('Token expired or invalid');
    } else if (statusCode >= 400 && statusCode < 500) {
      try {
        final errorBody = response.body.isNotEmpty 
            ? jsonDecode(response.body)
            : {'message': 'Client error occurred'};
        
        // استخراج الرسالة من البنية المختلفة للاستجابة
        String errorMessage = 'Client error';
        if (errorBody is Map<String, dynamic>) {
          errorMessage = errorBody['message'] ?? 
                        errorBody['error'] ?? 
                        errorBody['details'] ?? 
                        'Client error occurred';
        }
        throw ClientException(errorMessage);
      } catch (e) {
        throw ClientException('خطأ في البيانات المرسلة');
      }
    } else if (statusCode >= 500) {
      try {
        final errorBody = response.body.isNotEmpty 
            ? jsonDecode(response.body)
            : {'message': 'Server error occurred'};
        
        String errorMessage = 'Server error';
        if (errorBody is Map<String, dynamic>) {
          errorMessage = errorBody['message'] ?? 
                        errorBody['error'] ?? 
                        'Server error occurred';
        }
        throw ServerException(errorMessage);
      } catch (e) {
        throw ServerException('خطأ في الخادم');
      }
    }
    
    throw ServerException('Unexpected status code: $statusCode');
  }
}
