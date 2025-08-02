import 'package:equatable/equatable.dart';

// --- Canonical Address Entity ---
// This will be the single source of truth for addresses.
class AddressEntity extends Equatable {
  final String street;
  final String city;
  final String? state;
  final String country;
  final String? postalCode;
  final String? phone;
  final String? fullName;

  const AddressEntity({
    this.street = '',
    this.city = '',
    this.state,
    this.country = '',
    this.postalCode,
    this.phone,
    this.fullName,
  });

  String get fullAddress => [street, city, state, country]
      .where((s) => s != null && s.isNotEmpty)
      .join(', ');

  @override
  List<Object?> get props =>
      [street, city, state, country, postalCode, phone, fullName];
}


// --- Canonical Company Entity ---
class CompanyEntity extends Equatable {
  final String companyName;
  final String? companyDescription;
  final AddressEntity? companyAddress;
  final String? companyPhone;
  final String? companyLogo;

  const CompanyEntity({
    required this.companyName,
    this.companyDescription,
    this.companyAddress,
    this.companyPhone,
    this.companyLogo,
  });

  @override
  List<Object?> get props => [
        companyName,
        companyDescription,
        companyAddress,
        companyPhone,
        companyLogo,
      ];
}

// --- Canonical Child Entity ---
class ChildEntity extends Equatable {
  final int age;
  final String gender; // 'male', 'female'

  const ChildEntity({
    required this.age,
    required this.gender,
  });

  @override
  List<Object?> get props => [age, gender];
}

// --- Canonical User Entity ---
enum UserRole { customer, admin, superAdmin }

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final UserRole role;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  // Customer specific
  final int? age;
  final String? gender; // 'male', 'female', 'other'
  final AddressEntity? address;
  final List<ChildEntity>? children;

  // Admin/Owner specific
  final CompanyEntity? companyDetails;

  // Technical
  final String? fcmToken;

  const UserEntity({
    required this.id,
    required this.email,
    required this.role,
    required this.isEmailVerified,
    required this.createdAt,
    this.name,
    this.lastLoginAt,
    this.age,
    this.gender,
    this.address,
    this.children,
    this.companyDetails,
    this.fcmToken,
  });

  bool get isSuperAdmin => role == UserRole.superAdmin;
  bool get isAdmin => role == UserRole.admin;
  bool get isCustomer => role == UserRole.customer;

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        role,
        isEmailVerified,
        createdAt,
        lastLoginAt,
        age,
        gender,
        address,
        children,
        companyDetails,
        fcmToken,
      ];
}
