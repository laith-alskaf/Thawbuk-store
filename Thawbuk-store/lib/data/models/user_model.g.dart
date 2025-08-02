// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressModel _$AddressModelFromJson(Map<String, dynamic> json) => AddressModel(
      street: json['street'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      phone: json['phone'] as String?,
      fullName: json['fullName'] as String?,
    );

Map<String, dynamic> _$AddressModelToJson(AddressModel instance) =>
    <String, dynamic>{
      'street': instance.street,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
      'postalCode': instance.postalCode,
      'phone': instance.phone,
      'fullName': instance.fullName,
    };

CompanyModel _$CompanyModelFromJson(Map<String, dynamic> json) => CompanyModel(
      companyName: json['companyName'] as String,
      companyDescription: json['companyDescription'] as String?,
      companyAddress: json['companyAddress'] == null
          ? null
          : AddressModel.fromJson(
              json['companyAddress'] as Map<String, dynamic>),
      companyPhone: json['companyPhone'] as String?,
      companyLogo: json['companyLogo'] as String?,
    );

Map<String, dynamic> _$CompanyModelToJson(CompanyModel instance) =>
    <String, dynamic>{
      'companyName': instance.companyName,
      'companyDescription': instance.companyDescription,
      'companyPhone': instance.companyPhone,
      'companyLogo': instance.companyLogo,
      'companyAddress': instance.companyAddress?.toJson(),
    };

ChildModel _$ChildModelFromJson(Map<String, dynamic> json) => ChildModel(
      age: json['age'] as int,
      gender: json['gender'] as String,
    );

Map<String, dynamic> _$ChildModelToJson(ChildModel instance) =>
    <String, dynamic>{
      'age': instance.age,
      'gender': instance.gender,
    };

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['_id'] as String,
      email: json['email'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      isEmailVerified: json['isEmailVerified'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      name: json['name'] as String?,
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
      profileImage: json['profileImage'] as String?,
      companyModel: json['companyDetails'] == null
          ? null
          : CompanyModel.fromJson(
              json['companyDetails'] as Map<String, dynamic>),
      addressModel: json['addressModel'] == null
          ? null
          : AddressModel.fromJson(json['addressModel'] as Map<String, dynamic>),
      childrenModel: (json['childrenModel'] as List<dynamic>?)
          ?.map((e) => ChildModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      fcmToken: json['fcmToken'] as String?,
      otpCode: json['otpCode'] as String?,
      otpCodeExpires: json['otpCodeExpires'] == null
          ? null
          : DateTime.parse(json['otpCodeExpires'] as String),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'name': instance.name,
      'profileImage': instance.profileImage,
      'age': instance.age,
      'gender': instance.gender,
      'fcmToken': instance.fcmToken,
      'otpCode': instance.otpCode,
      'otpCodeExpires': instance.otpCodeExpires?.toIso8601String(),
      'id': instance.id,
      'email': instance.email,
      'role': _$UserRoleEnumMap[instance.role]!,
      'isEmailVerified': instance.isEmailVerified,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'companyDetails': instance.companyModel?.toJson(),
      'addressModel': instance.addressModel?.toJson(),
      'childrenModel': instance.childrenModel?.map((e) => e.toJson()).toList(),
    };

const _$UserRoleEnumMap = {
  UserRole.customer: 'customer',
  UserRole.admin: 'admin',
  UserRole.superAdmin: 'superAdmin',
};
