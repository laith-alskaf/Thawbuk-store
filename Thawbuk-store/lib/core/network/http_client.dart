import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

class HttpClient {
  final SharedPreferences sharedPreferences;
  
  HttpClient(this.sharedPreferences);
  static var client = http.Client();
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

      final response = await http.get(url, headers: _headers);

      return _handleResponse(response);
    } catch (e) {
      throw ServerException('GET request failed: ${e.toString()}');
    }
  }

  /// طلب POST
  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final response = await client.post(
        url,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );

      print(url);
      print(response.body);
      return _handleResponse(response);
    } catch (e) {
      throw ServerException('POST request failed: ${e.toString()}');
    }
  }

  /// طلب PUT
  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final response = await http.put(
        url,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw ServerException('PUT request failed: ${e.toString()}');
    }
  }

  /// طلب DELETE (مع إرجاع بيانات)
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final response = await http.delete(url, headers: _headers);
      
      return _handleResponse(response);
    } catch (e) {
      throw ServerException('DELETE request failed: ${e.toString()}');
    }
  }

  /// طلب DELETE (للحالات التي لا تحتاج رد)
  Future<void> deleteVoid(String endpoint) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final response = await http.delete(url, headers: _headers);
      
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
      final errorBody = response.body.isNotEmpty 
          ? jsonDecode(response.body)
          : {'message': 'Client error occurred'};
      throw ClientException(errorBody['message'] ?? 'Client error');
    } else if (statusCode >= 500) {
      final errorBody = response.body.isNotEmpty 
          ? jsonDecode(response.body)
          : {'message': 'Server error occurred'};
      throw ServerException(errorBody['message'] ?? 'Server error');
    }
    
    throw ServerException('Unexpected status code: $statusCode');
  }
}
