import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel {
  final String token;
  @JsonKey(name: 'userInfo')
  final UserInfoModel user;
  final String? refreshToken;

  const AuthResponseModel({
    required this.token,
    required this.user,
    this.refreshToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);

  // Convert to entity
  UserEntity toEntity() => user.toEntity();
}

@JsonSerializable()
class UserInfoModel {
  final String id;
  @JsonKey(name: 'userName')
  final String name;
  final String email;
  final UserRole role;

  const UserInfoModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) =>
      _$UserInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoModelToJson(this);

  // Convert to entity with default values for missing fields
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      role: role,
      createdAt: DateTime.now(), // Default value
      isEmailVerified: true, // Default value - user is logged in
      phone: null,
      lastLoginAt: DateTime.now(),
      profileImage: null,
      company: null,
      age: null,
      gender: null,
      children: null,
      address: null,
      fcmToken: null,
      otpCode: null,
      otpCodeExpires: null,
    );
  }
}