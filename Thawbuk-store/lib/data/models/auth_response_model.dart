import 'package:json_annotation/json_annotation.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class UserInfoModel {
  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'userName')
  final String? userName;
  final String email;
  final String role;

  UserInfoModel({
    required this.id,
    this.userName,
    required this.email,
    required this.role,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) =>
      _$UserInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoModelToJson(this);

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: userName,
      role: _mapRole(role),
      isEmailVerified: false, // Login response doesn't contain this, default to false
      createdAt: DateTime.now(), // Login response doesn't contain this
    );
  }

  UserRole _mapRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'superadmin':
        return UserRole.superAdmin;
      default:
        return UserRole.customer;
    }
  }
}

@JsonSerializable(explicitToJson: true)
class AuthResponseModel {
  final String token;
  @JsonKey(name: 'userInfo')
  final UserInfoModel userInfo;

  AuthResponseModel({
    required this.token,
    required this.userInfo,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}
