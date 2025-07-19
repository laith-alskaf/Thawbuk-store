import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    required super.role,
    super.age,
    super.gender,
    super.address,
    super.children,
    super.companyDetails,
    super.fcmToken,
    required super.isEmailVerified,
    required super.lastLogin,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return _$UserModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      role: role,
      age: age,
      gender: gender,
      address: address,
      children: children,
      companyDetails: companyDetails,
      fcmToken: fcmToken,
      isEmailVerified: isEmailVerified,
      lastLogin: lastLogin,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

@JsonSerializable()
class AddressModel {
  final String street;
  final String city;
  final String? country;
  final String? postalCode;
  final String? phone;

  const AddressModel({
    required this.street,
    required this.city,
    this.country,
    this.postalCode,
    this.phone,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return _$AddressModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AddressModelToJson(this);
}

@JsonSerializable()
class ChildModel {
  final int age;
  final String gender;

  const ChildModel({
    required this.age,
    required this.gender,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return _$ChildModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ChildModelToJson(this);
}

@JsonSerializable()
class CompanyDetailsModel {
  final String companyName;
  final String? companyDescription;
  final AddressModel companyAddress;
  final String companyPhone;
  final String? companyLogo;

  const CompanyDetailsModel({
    required this.companyName,
    this.companyDescription,
    required this.companyAddress,
    required this.companyPhone,
    this.companyLogo,
  });

  factory CompanyDetailsModel.fromJson(Map<String, dynamic> json) {
    return _$CompanyDetailsModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CompanyDetailsModelToJson(this);
}