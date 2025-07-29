// import 'package:shared_preferences/shared_preferences.dart';
// import '../constants/app_constants.dart';
//
// class AuthInterceptor extends Interceptor {
//   final SharedPreferences sharedPreferences;
//
//   AuthInterceptor(this.sharedPreferences);
//
//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
//     final token = sharedPreferences.getString(AppConstants.tokenKey);
//
//     if (token != null && token.isNotEmpty) {
//       options.headers['Authorization'] = 'Bearer $token';
//     }
//
//     super.onRequest(options, handler);
//   }
//
//   @override
//   void onResponse(Response response, ResponseInterceptorHandler handler) {
//     // Handle token refresh or other response logic if needed
//     super.onResponse(response, handler);
//   }
//
//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) {
//     if (err.response?.statusCode == 401) {
//       // Token expired or invalid
//       _clearTokenAndRedirect();
//     }
//
//     super.onError(err, handler);
//   }
//
//   void _clearTokenAndRedirect() {
//     sharedPreferences.remove(AppConstants.tokenKey);
//     sharedPreferences.remove(AppConstants.userKey);
//     // Navigate to login screen - this should be handled in the UI layer
//   }
// }