import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

// --- Models ---

@JsonSerializable(explicitToJson: true)
class AddressModel extends AddressEntity {
  const AddressModel({
    super.street,
    super.city,
    super.state,
    super.country,
    super.postalCode,
    super.phone,
    super.fullName,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  Map<String, dynamic> toJson() => _$AddressModelToJson(this);

  AddressEntity toEntity() => this;
}

@JsonSerializable(explicitToJson: true)
class CompanyModel extends CompanyEntity {
  @override
  final AddressModel? companyAddress;

  const CompanyModel({
    required super.companyName,
    super.companyDescription,
    this.companyAddress,
    super.companyPhone,
    super.companyLogo,
  }) : super(companyAddress: companyAddress);

  factory CompanyModel.fromJson(Map<String, dynamic> json) =>
      _$CompanyModelFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyModelToJson(this);

  CompanyEntity toEntity() => this;
}

@JsonSerializable()
class ChildModel extends ChildEntity {
  const ChildModel({
    required super.age,
    required super.gender,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) =>
      _$ChildModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChildModelToJson(this);

  ChildEntity toEntity() => this;
}

@JsonSerializable(explicitToJson: true)
class UserModel extends UserEntity {

  @JsonKey(name: '_id')
  final String id;
  
  @JsonKey(name: 'companyDetails')
  final CompanyModel? companyModel;

  final AddressModel? addressModel;

  final List<ChildModel>? childrenModel;

  const UserModel({
    required this.id,
    required super.email,
    required super.role,
    required super.isEmailVerified,
    required super.createdAt,
    super.name,
    super.lastLoginAt,
    super.profileImage,
    this.companyModel,
    this.addressModel,
    this.childrenModel,
    super.age,
    super.gender,
    super.fcmToken,
    super.otpCode,
    super.otpCodeExpires,
  }) : super(
    id: id,
    company: companyModel,
    address: addressModel,
    children: childrenModel
  );

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      role: role,
      isEmailVerified: isEmailVerified,
      createdAt: createdAt,
      name: name,
      lastLoginAt: lastLoginAt,
      profileImage: profileImage,
      company: companyModel?.toEntity(),
      age: age,
      gender: gender,
      children: childrenModel?.map((c) => c.toEntity()).toList(),
      address: addressModel?.toEntity(),
      fcmToken: fcmToken,
      otpCode: otpCode,
      otpCodeExpires: otpCodeExpires,
    );
  }
}
