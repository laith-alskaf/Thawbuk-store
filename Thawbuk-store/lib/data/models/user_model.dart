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
}

@JsonSerializable(explicitToJson: true)
class UserModel extends UserEntity {

  @JsonKey(name: '_id')
  @override
  final String id;
  
  @JsonKey(name: 'companyDetails')
  @override
  final AddressModel? address;
  @override
  @JsonKey(name: 'companyDetails')
  final CompanyModel? companyDetails;
  @override
  final List<ChildModel>? children;

  const UserModel({
    required this.id,
    required super.email,
    required super.role,
    required super.isEmailVerified,
    required super.createdAt,
    super.name,
    super.lastLoginAt,
    super.profileImage,
    this.company,
    super.age,
    super.gender,
    super.children,
    super.address,
    super.fcmToken,
    required super.isEmailVerified,
    super.otpCode,
    super.otpCodeExpires,
  }) : super(id: id, company: company);

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // Note: toEntity method might need to be implemented if you need to map from data model to domain entity.
  // For now, it's commented out as the entity structure is not fully defined in the provided snippet.
  /*
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      role: role,
      isEmailVerified: isEmailVerified,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      profileImage: profileImage,
      company: company?.toEntity(),
      age: age,
      gender: gender,
      children: children?.map((c) => c.toEntity()).toList(),
      address: address?.toEntity(),
      fcmToken: fcmToken,
      otpCode: otpCode,
      otpCodeExpires: otpCodeExpires,
    );
  }
  */
}
