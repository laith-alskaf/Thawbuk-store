import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel extends UserEntity {
  @JsonKey(name: 'company')
  @override
  final CompanyModel? company;

  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.phone,
    required super.role,
    required super.createdAt,
    super.lastLoginAt,
    super.profileImage,
    this.company,
  }) : super(company: company);

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
}