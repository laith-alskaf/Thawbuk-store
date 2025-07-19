import 'package:equatable/equatable.dart';

enum UserRole { customer, admin, owner }

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String? profileImage;
  final CompanyEntity? company;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    required this.role,
    required this.createdAt,
    this.lastLoginAt,
    this.profileImage,
    this.company,
  });

  bool get isOwner => role == UserRole.owner;
  bool get isAdmin => role == UserRole.admin;
  bool get isCustomer => role == UserRole.customer;

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        phone,
        role,
        createdAt,
        lastLoginAt,
        profileImage,
        company,
      ];
}

class CompanyEntity extends Equatable {
  final String name;
  final String address;
  final String? logo;
  final String? description;

  const CompanyEntity({
    required this.name,
    required this.address,
    this.logo,
    this.description,
  });

  @override
  List<Object?> get props => [name, address, logo, description];
}