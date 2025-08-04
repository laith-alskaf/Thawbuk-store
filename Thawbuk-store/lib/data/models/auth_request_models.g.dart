// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_request_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequestModel _$LoginRequestModelFromJson(Map<String, dynamic> json) =>
    LoginRequestModel(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestModelToJson(LoginRequestModel instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
    };

RegisterRequestModel _$RegisterRequestModelFromJson(
        Map<String, dynamic> json) =>
    RegisterRequestModel(
      email: json['email'] as String,
      password: json['password'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$RegisterRequestModelToJson(
        RegisterRequestModel instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'name': instance.name,
      'phone': instance.phone,
      'age': instance.age,
      'gender': instance.gender,
      'city': instance.city,
      'address': instance.address,
    };

ForgotPasswordRequestModel _$ForgotPasswordRequestModelFromJson(
        Map<String, dynamic> json) =>
    ForgotPasswordRequestModel(
      email: json['email'] as String,
    );

Map<String, dynamic> _$ForgotPasswordRequestModelToJson(
        ForgotPasswordRequestModel instance) =>
    <String, dynamic>{
      'email': instance.email,
    };

VerifyEmailRequestModel _$VerifyEmailRequestModelFromJson(
        Map<String, dynamic> json) =>
    VerifyEmailRequestModel(
      email: json['email'] as String,
      otpCode: json['otpCode'] as String,
    );

Map<String, dynamic> _$VerifyEmailRequestModelToJson(
        VerifyEmailRequestModel instance) =>
    <String, dynamic>{
      'email': instance.email,
      'otpCode': instance.otpCode,
    };

ChangePasswordRequestModel _$ChangePasswordRequestModelFromJson(
        Map<String, dynamic> json) =>
    ChangePasswordRequestModel(
      currentPassword: json['currentPassword'] as String,
      newPassword: json['newPassword'] as String,
    );

Map<String, dynamic> _$ChangePasswordRequestModelToJson(
        ChangePasswordRequestModel instance) =>
    <String, dynamic>{
      'currentPassword': instance.currentPassword,
      'newPassword': instance.newPassword,
    };
