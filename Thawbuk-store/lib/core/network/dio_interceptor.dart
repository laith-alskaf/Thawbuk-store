import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class AuthInterceptor extends Interceptor {
  final SharedPreferences sharedPreferences;

  AuthInterceptor(this.sharedPreferences);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = sharedPreferences.getString(AppConstants.tokenKey);
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token منتهي الصلاحية - قم بتنظيف البيانات المحلية
      _clearAuthData();
    }
    
    super.onError(err, handler);
  }

  void _clearAuthData() {
    sharedPreferences.remove(AppConstants.tokenKey);
    sharedPreferences.remove(AppConstants.userKey);
  }
}