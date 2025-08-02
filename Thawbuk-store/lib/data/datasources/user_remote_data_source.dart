import '../../core/errors/exceptions.dart';
import '../../core/network/http_client.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getCurrentUser();
  Future<UserModel> updateProfile(Map<String, dynamic> userData);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final HttpClient httpClient;

  UserRemoteDataSourceImpl(this.httpClient);

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await httpClient.get('/user/me');
      
      if (response['data'] != null) {
        return UserModel.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        return UserModel.fromJson(response);
      }
    } catch (e) {
      throw ServerException('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> userData) async {
    try {
      final response = await httpClient.put('/user/me', body: userData);
      
      if (response['data'] != null) {
        return UserModel.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        return UserModel.fromJson(response);
      }
    } catch (e) {
      throw ServerException('Failed to update profile: ${e.toString()}');
    }
  }
}