import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/http_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);

  Future<UserModel> register(Map<String, dynamic> userData);

  Future<void> logout();

  Future<UserModel> getCurrentUser();
  Future<void> verifyEmail(String email, String code);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final HttpClient httpClient;

  AuthRemoteDataSourceImpl(this.httpClient);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await httpClient.post('/auth/login', body: {
        'email': email,
        'password': password,
      });

      if (response['body']['token'] != null) {
        await httpClient.sharedPreferences
            .setString('auth_token', response['body']['token']);
      }

      return UserModel.fromJson(response['body']['userInfo'] ?? response);
    } catch (e) {
      throw ServerException('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> register(Map<String, dynamic> userData) async {
    try {
      final response = await httpClient.post('/auth/register', body: userData);

      // حفظ التوكن إذا كان موجوداً في الاستجابة
      if (response['body']['token'] != null) {
        await httpClient.sharedPreferences
            .setString('auth_token', response['body']['token']);
      }

      return UserModel.fromJson(response['body']['userInfo'] ?? response);
    } catch (e) {
      throw ServerException('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await httpClient.deleteVoid('/auth/logout');
    } catch (e) {
      throw ServerException('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await httpClient.get('/user/me');
      return UserModel.fromJson(response['body']['userInfo']);
    } catch (e) {
      throw ServerException('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<void> verifyEmail(String email, String code) async {
    try {
      await httpClient.post('/auth/verify-email', body: {
        'email': email,
        'code': code,
      });
    } catch (e) {
      throw ServerException('Email verification failed: ${e.toString()}');
    }
  }
}
