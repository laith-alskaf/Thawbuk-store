// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['_id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
      profileImage: json['profileImage'] as String?,
      company: json['companyDetails'] == null
          ? null
          : CompanyModel.fromJson(
              json['companyDetails'] as Map<String, dynamic>),
      age: (json['age'] as num?)?.toInt(),
      gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => ChildModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      address: json['address'] == null
          ? null
          : AddressModel.fromJson(json['address'] as Map<String, dynamic>),
      fcmToken: json['fcmToken'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool,
      otpCode: json['otpCode'] as String?,
      otpCodeExpires: json['otpCodeExpires'] == null
          ? null
          : DateTime.parse(json['otpCodeExpires'] as String),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'email': instance.email,
      'name': instance.name,
      'phone': instance.phone,
      'role': _$UserRoleEnumMap[instance.role]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'profileImage': instance.profileImage,
      'age': instance.age,
      'gender': _$GenderEnumMap[instance.gender],
      'fcmToken': instance.fcmToken,
      'isEmailVerified': instance.isEmailVerified,
      'otpCode': instance.otpCode,
      'otpCodeExpires': instance.otpCodeExpires?.toIso8601String(),
      '_id': instance.id,
      'companyDetails': instance.company?.toJson(),
      'children': instance.children?.map((e) => e.toJson()).toList(),
      'address': instance.address?.toJson(),
    };

const _$UserRoleEnumMap = {
  UserRole.customer: 'customer',
  UserRole.admin: 'admin',
  UserRole.superAdmin: 'superAdmin',
};

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.other: 'other',
};

CompanyModel _$CompanyModelFromJson(Map<String, dynamic> json) => CompanyModel(
      name: json['name'] as String,
      address: json['address'] as String,
      logo: json['logo'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$CompanyModelToJson(CompanyModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'logo': instance.logo,
      'description': instance.description,
    };

ChildModel _$ChildModelFromJson(Map<String, dynamic> json) => ChildModel(
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
      gender: json['gender'] as String,
    );

Map<String, dynamic> _$ChildModelToJson(ChildModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'age': instance.age,
      'gender': instance.gender,
    };

AddressModel _$AddressModelFromJson(Map<String, dynamic> json) => AddressModel(
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String,
      postalCode: json['postalCode'] as String?,
    );

Map<String, dynamic> _$AddressModelToJson(AddressModel instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'phone': instance.phone,
      'street': instance.street,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
      'postalCode': instance.postalCode,
    };
