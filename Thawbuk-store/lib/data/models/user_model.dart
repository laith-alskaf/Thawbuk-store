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
  @override
  final AddressModel? address;
  @override
  @JsonKey(name: 'companyDetails')
  final CompanyModel? companyDetails;
  @override
  final List<ChildModel>? children;

  const UserModel({
    required super.id,
    required super.email,
    required super.role,
    required super.isEmailVerified,
    required super.createdAt,
    super.name,
    super.lastLoginAt,
    super.age,
    super.gender,
    this.address,
    this.children,
    this.companyDetails,
    super.fcmToken,
  }) : super(
          address: address,
          children: children,
          companyDetails: companyDetails,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
