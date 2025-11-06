import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel extends UserEntity {
  @JsonKey(name: '_id')
  @override
  final String id;
  
  @JsonKey(name: 'companyDetails')
  @override
  final CompanyModel? company;

  @override
  final List<ChildModel>? children;

  @override
  final AddressModel? address;

  const UserModel({
    required this.id,
    required super.email,
    required super.name,
    super.phone,
    required super.role,
    required super.createdAt,
    super.lastLoginAt,
    super.profileImage,
    this.company,
    super.age,
    super.gender,
    this.children,
    this.address,
    super.fcmToken,
    required super.isEmailVerified,
    super.otpCode,
    super.otpCodeExpires,
  }) : super(
          id: id,
          company: company,
          children: children,
          address: address,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return _$UserModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      phone: phone,
      role: role,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      profileImage: profileImage,
      company: company?.toEntity(),
      age: age,
      gender: gender,
      children: children?.map((c) => c.toEntity()).toList(),
      address: address?.toEntity(),
      fcmToken: fcmToken,
      isEmailVerified: isEmailVerified,
      otpCode: otpCode,
      otpCodeExpires: otpCodeExpires,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      phone: entity.phone,
      role: entity.role,
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
      profileImage: entity.profileImage,
      company: entity.company != null ? CompanyModel.fromEntity(entity.company!) : null,
      age: entity.age,
      gender: entity.gender,
      children: entity.children?.map((c) => ChildModel.fromEntity(c)).toList(),
      address: entity.address != null ? AddressModel.fromEntity(entity.address!) : null,
      fcmToken: entity.fcmToken,
      isEmailVerified: entity.isEmailVerified,
      otpCode: entity.otpCode,
      otpCodeExpires: entity.otpCodeExpires,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CompanyModel extends CompanyEntity {
  const CompanyModel({
    required super.name,
    required super.address,
    super.logo,
    super.description,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return _$CompanyModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CompanyModelToJson(this);

  CompanyEntity toEntity() {
    return CompanyEntity(
      name: name,
      address: address,
      logo: logo,
      description: description,
    );
  }

  factory CompanyModel.fromEntity(CompanyEntity entity) {
    return CompanyModel(
      name: entity.name,
      address: entity.address,
      logo: entity.logo,
      description: entity.description,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ChildModel extends ChildEntity {
  const ChildModel({
    required super.name,
    required super.age,
    required super.gender,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return _$ChildModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ChildModelToJson(this);

  ChildEntity toEntity() {
    return ChildEntity(
      name: name,
      age: age,
      gender: gender,
    );
  }

  factory ChildModel.fromEntity(ChildEntity entity) {
    return ChildModel(
      name: entity.name,
      age: entity.age,
      gender: entity.gender,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AddressModel extends AddressEntity {
  const AddressModel({
    required super.fullName,
    required super.phone,
    required super.street,
    required super.city,
    required super.state,
    required super.country,
    super.postalCode,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return _$AddressModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AddressModelToJson(this);

  AddressEntity toEntity() {
    return AddressEntity(
      fullName: fullName,
      phone: phone,
      street: street,
      city: city,
      state: state,
      country: country,
      postalCode: postalCode,
    );
  }

  factory AddressModel.fromEntity(AddressEntity entity) {
    return AddressModel(
      fullName: entity.fullName,
      phone: entity.phone,
      street: entity.street,
      city: entity.city,
      state: entity.state,
      country: entity.country,
      postalCode: entity.postalCode,
    );
  }
}