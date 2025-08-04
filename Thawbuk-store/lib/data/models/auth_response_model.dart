import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';
import 'user_model.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel {
  final String token;
  final UserModel user;
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