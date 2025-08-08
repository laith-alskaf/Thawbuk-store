import '../../core/network/api_client.dart';
import '../models/user_model.dart';
import '../models/auth_response_model.dart';
import '../models/auth_request_models.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password);
  Future<void> register(RegisterRequestModel request);
  Future<void> logout();
  Future<void> forgotPassword(String email);
  Future<void> verifyEmail(String code);
  Future<void> changePassword(String oldPassword, String newPassword);
  Future<void> resendVerificationCode(String email);
  Future<UserModel> getCurrentUser();
  Future<UserModel> updateUserProfile(Map<String, dynamic> userData);
  Future<String> updateProfileImage(String imagePath);
  Future<void> updateFCMToken(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    
    final response = await _apiClient.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    if (response['success'] == true) {
      return AuthResponseModel.fromJson(response['body']);
    } else {
      throw Exception(response['message'] ?? 'فشل في تسجيل الدخول');
    }
  }

  @override
  Future<void> register(RegisterRequestModel request) async {
    final response = await _apiClient.post(
      '/auth/register',
      data: request.toJson(),
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'فشل في إنشاء الحساب');
    }
    // لا نحتاج إرجاع أي شيء، فقط التأكد من نجاح العملية
  }

  @override
  Future<void> logout() async {
    final response = await _apiClient.post('/auth/logout');

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'فشل في تسجيل الخروج');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    final response = await _apiClient.post(
      '/auth/forgot-password',
      data: {'email': email},
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'فشل في إرسال رابط استعادة كلمة المرور');
    }
  }

  @override
  Future<void> verifyEmail(String code) async {
    final response = await _apiClient.post(
      '/auth/verify-email',
      data: {'code': code},
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'فشل في التحقق من البريد الإلكتروني');
    }
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    final response = await _apiClient.post(
      '/auth/change-password',
      data: {'oldPassword': oldPassword, 'newPassword': newPassword},
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'فشل في تغيير كلمة المرور');
    }
  }

  @override
  Future<void> resendVerificationCode(String email) async {
    final response = await _apiClient.post(
      '/auth/resend-verification',
      data: {'email': email},
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'فشل في إعادة إرسال رمز التحقق');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    // في وضع التطوير، استخدام mock data
    // if (kDebugMode) {
    //   await Future.delayed(const Duration(milliseconds: 500));
    //   return MockData.mockUser; // يمكن تحسين هذا لاحقاً لإرجاع المستخدم المناسب
    // }

    final response = await _apiClient.get('/user/me');

    if (response['success'] == true) {
      return UserModel.fromJson(response['body']['user']);
    } else {
      throw Exception(response['message'] ?? 'فشل في جلب بيانات المستخدم');
    }
  }

  @override
  Future<UserModel> updateUserProfile(Map<String, dynamic> userData) async {
    final response = await _apiClient.put(
      '/user/me',
      data: userData,
    );

    if (response['success'] == true) {
      return UserModel.fromJson(response['body']['user']);
    } else {
      throw Exception(response['message'] ?? 'فشل في تحديث الملف الشخصي');
    }
  }

  @override
  Future<String> updateProfileImage(String imagePath) async {
    // final response = await _apiClient.uploadFile(
    //   '/user/profile/image',
    //   imagePath,
    //   data: {'fieldName': 'profileImage'},
    // );

    // if (response.data['success'] == true) {
    //   return response.data['data']['imageUrl'] as String;
    // } else {
    //   throw Exception(response.data['message'] ?? 'فشل في رفع الصورة');
    // }
    return '';
  }

  @override
  Future<void> updateFCMToken(String token) async {
    final response = await _apiClient.put(
      '/user/fcm-token',
      data: {'fcmToken': token},
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'فشل في تحديث رمز الإشعارات');
    }
  }
}