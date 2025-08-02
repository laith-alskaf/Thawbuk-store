import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/mock_data.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequestModel request);
  Future<AuthResponseModel> register(RegisterRequestModel request);
  Future<void> logout();
  Future<void> forgotPassword(ForgotPasswordRequestModel request);
  Future<void> verifyEmail(VerifyEmailRequestModel request);
  Future<void> changePassword(ChangePasswordRequestModel request);
  Future<void> resendVerificationCode(String email);
  Future<UserModel> getCurrentUser();
  Future<UserModel> updateUserProfile(UserModel user);
  Future<String> updateProfileImage(String imagePath);
  Future<void> updateFCMToken(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    // في وضع التطوير، استخدام mock data
    if (kDebugMode) {
      await Future.delayed(const Duration(seconds: 1)); // محاكاة تأخير الشبكة
      
      // تحقق من بيانات الاعتماد
      if (request.email == 'admin@test.com' && request.password == '123456') {
        return MockData.mockAdminAuthResponse;
      } else if (request.email == 'user@test.com' && request.password == '123456') {
        return MockData.mockAuthResponse;
      } else {
        throw Exception('بيانات الاعتماد غير صحيحة');
      }
    }

    // في وضع الإنتاج، استخدام API الحقيقي
    final response = await _apiClient.post(
      '/auth/login',
      data: request.toJson(),
    );

    if (response.data['success'] == true) {
      return AuthResponseModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'فشل في تسجيل الدخول');
    }
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    final response = await _apiClient.post(
      '/auth/register',
      data: request.toJson(),
    );

    if (response.data['success'] == true) {
      return AuthResponseModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'فشل في إنشاء الحساب');
    }
  }

  @override
  Future<void> logout() async {
    final response = await _apiClient.post('/auth/logout');

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'فشل في تسجيل الخروج');
    }
  }

  @override
  Future<void> forgotPassword(ForgotPasswordRequestModel request) async {
    final response = await _apiClient.post(
      '/auth/forgot-password',
      data: request.toJson(),
    );

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'فشل في إرسال رابط استعادة كلمة المرور');
    }
  }

  @override
  Future<void> verifyEmail(VerifyEmailRequestModel request) async {
    final response = await _apiClient.post(
      '/auth/verify-email',
      data: request.toJson(),
    );

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'فشل في التحقق من البريد الإلكتروني');
    }
  }

  @override
  Future<void> changePassword(ChangePasswordRequestModel request) async {
    final response = await _apiClient.post(
      '/auth/change-password',
      data: request.toJson(),
    );

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'فشل في تغيير كلمة المرور');
    }
  }

  @override
  Future<void> resendVerificationCode(String email) async {
    final response = await _apiClient.post(
      '/auth/resend-verification',
      data: {'email': email},
    );

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'فشل في إعادة إرسال رمز التحقق');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    // في وضع التطوير، استخدام mock data
    if (kDebugMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockData.mockUser; // يمكن تحسين هذا لاحقاً لإرجاع المستخدم المناسب
    }

    final response = await _apiClient.get('/user/profile');

    if (response.data['success'] == true) {
      return UserModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'فشل في جلب بيانات المستخدم');
    }
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    final response = await _apiClient.put(
      '/user/profile',
      data: user.toJson(),
    );

    if (response.data['success'] == true) {
      return UserModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'فشل في تحديث الملف الشخصي');
    }
  }

  @override
  Future<String> updateProfileImage(String imagePath) async {
    final file = File(imagePath);
    
    final response = await _apiClient.uploadFile(
      '/user/profile/image',
      file,
      fieldName: 'profileImage',
    );

    if (response.data['success'] == true) {
      return response.data['data']['imageUrl'] as String;
    } else {
      throw Exception(response.data['message'] ?? 'فشل في رفع الصورة');
    }
  }

  @override
  Future<void> updateFCMToken(String token) async {
    final response = await _apiClient.put(
      '/user/fcm-token',
      data: {'fcmToken': token},
    );

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'فشل في تحديث رمز الإشعارات');
    }
  }
}