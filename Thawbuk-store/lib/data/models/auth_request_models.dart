import 'package:json_annotation/json_annotation.dart';

part 'auth_request_models.g.dart';

@JsonSerializable()
class LoginRequestModel {
  final String email;
  final String password;

  const LoginRequestModel({
    required this.email,
    required this.password,
  });

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestModelToJson(this);
}

@JsonSerializable()
class RegisterRequestModel {
  final String email;
  final String password;
  final String name;
  final String? phone;
  final int? age;
  final String? gender;
  final String? city;
  final String? address;

  const RegisterRequestModel({
    required this.email,
    required this.password,
    required this.name,
    this.phone,
    this.age,
    this.gender,
    this.city,
    this.address,
  });

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestModelToJson(this);
}

@JsonSerializable()
class ForgotPasswordRequestModel {
  final String email;

  const ForgotPasswordRequestModel({
    required this.email,
  });

  factory ForgotPasswordRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordRequestModelToJson(this);
}

@JsonSerializable()
class VerifyEmailRequestModel {
  final String email;
  final String otpCode;

  const VerifyEmailRequestModel({
    required this.email,
    required this.otpCode,
  });

  factory VerifyEmailRequestModel.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyEmailRequestModelToJson(this);
}

@JsonSerializable()
class ChangePasswordRequestModel {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequestModel({
    required this.currentPassword,
    required this.newPassword,
  });

  factory ChangePasswordRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChangePasswordRequestModelToJson(this);
}