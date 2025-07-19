import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String role; // 'admin', 'customer', 'superAdmin'
  final int? age;
  final String? gender; // 'male', 'female', 'other'
  final Address? address;
  final List<Child>? children;
  final CompanyDetails? companyDetails;
  final String? fcmToken;
  final bool isEmailVerified;
  final DateTime lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    this.name,
    required this.role,
    this.age,
    this.gender,
    this.address,
    this.children,
    this.companyDetails,
    this.fcmToken,
    required this.isEmailVerified,
    required this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAdmin => role == 'admin' || role == 'superAdmin';
  bool get isCustomer => role == 'customer';

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        role,
        age,
        gender,
        address,
        children,
        companyDetails,
        fcmToken,
        isEmailVerified,
        lastLogin,
        createdAt,
        updatedAt,
      ];
}

class Address extends Equatable {
  final String street;
  final String city;
  final String? country;
  final String? postalCode;
  final String? phone;

  const Address({
    required this.street,
    required this.city,
    this.country,
    this.postalCode,
    this.phone,
  });

  @override
  List<Object?> get props => [street, city, country, postalCode, phone];
}

class Child extends Equatable {
  final int age;
  final String gender; // 'male', 'female'

  const Child({
    required this.age,
    required this.gender,
  });

  @override
  List<Object?> get props => [age, gender];
}

class CompanyDetails extends Equatable {
  final String companyName;
  final String? companyDescription;
  final Address companyAddress;
  final String companyPhone;
  final String? companyLogo;

  const CompanyDetails({
    required this.companyName,
    this.companyDescription,
    required this.companyAddress,
    required this.companyPhone,
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