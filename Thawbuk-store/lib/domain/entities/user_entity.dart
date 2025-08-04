import 'package:equatable/equatable.dart';

enum UserRole { customer, admin, superAdmin }

enum Gender { male, female, other }

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
  // خصائص إضافية من Backend
  final int? age;
  final Gender? gender;
  final List<ChildEntity>? children;
  final AddressEntity? address;
  final String? fcmToken;
  final bool isEmailVerified;
  final String? otpCode;
  final DateTime? otpCodeExpires;

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
    this.age,
    this.gender,
    this.children,
    this.address,
    this.fcmToken,
    required this.isEmailVerified,
    this.otpCode,
    this.otpCodeExpires,
  });

  bool get isSuperAdmin => role == UserRole.superAdmin;
  bool get isAdmin => role == UserRole.admin;
  bool get isCustomer => role == UserRole.customer;
  bool get isOwner => role == UserRole.admin || role == UserRole.superAdmin;

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
        age,
        gender,
        children,
        address,
        fcmToken,
        isEmailVerified,
        otpCode,
        otpCodeExpires,
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

class ChildEntity extends Equatable {
  final String name;
  final int age;
  final String gender;

  const ChildEntity({
    required this.name,
    required this.age,
    required this.gender,
  });

  @override
  List<Object?> get props => [name, age, gender];
}

class AddressEntity extends Equatable {
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String country;
  final String? postalCode;

  const AddressEntity({
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    this.postalCode,
  });

  String get fullAddress {
    final parts = [street, city, state, country];
    if (postalCode != null && postalCode!.isNotEmpty) {
      parts.add(postalCode!);
    }
    return parts.where((part) => part.isNotEmpty).join(', ');
  }

  @override
  List<Object?> get props => [fullName, phone, street, city, state, country, postalCode];
}