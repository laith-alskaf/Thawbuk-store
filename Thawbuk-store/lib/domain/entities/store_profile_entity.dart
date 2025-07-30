import 'package:equatable/equatable.dart';

class StoreProfileEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? logo;
  final String? coverImage;
  final StoreAddressEntity address;
  final String? phone;
  final String email;
  final DateTime joinedDate;
  final double rating;
  final int reviewsCount;
  final int productsCount;
  final int followersCount;
  final bool isVerified;
  final bool isActive;
  final List<String> categories;
  final StoreStatsEntity stats;
  final StoreSocialLinksEntity? socialLinks;

  const StoreProfileEntity({
    required this.id,
    required this.name,
    this.description,
    this.logo,
    this.coverImage,
    required this.address,
    this.phone,
    required this.email,
    required this.joinedDate,
    required this.rating,
    required this.reviewsCount,
    required this.productsCount,
    required this.followersCount,
    required this.isVerified,
    required this.isActive,
    required this.categories,
    required this.stats,
    this.socialLinks,
  });

  String get displayRating => rating.toStringAsFixed(1);
  String get joinedYear => joinedDate.year.toString();
  bool get hasLogo => logo?.isNotEmpty == true;
  bool get hasCoverImage => coverImage?.isNotEmpty == true;
  bool get hasDescription => description?.isNotEmpty == true;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        logo,
        coverImage,
        address,
        phone,
        email,
        joinedDate,
        rating,
        reviewsCount,
        productsCount,
        followersCount,
        isVerified,
        isActive,
        categories,
        stats,
        socialLinks,
      ];
}

class StoreAddressEntity extends Equatable {
  final String city;
  final String? street;
  final String? country;

  const StoreAddressEntity({
    required this.city,
    this.street,
    this.country,
  });

  String get fullAddress {
    final parts = <String>[];
    if (street?.isNotEmpty == true) parts.add(street!);
    parts.add(city);
    if (country?.isNotEmpty == true) parts.add(country!);
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [city, street, country];
}

class StoreStatsEntity extends Equatable {
  final int totalSales;
  final int totalOrders;
  final double averageRating;
  final int responseTime; // in hours
  final double completionRate; // percentage

  const StoreStatsEntity({
    required this.totalSales,
    required this.totalOrders,
    required this.averageRating,
    required this.responseTime,
    required this.completionRate,
  });

  String get responseTimeText {
    if (responseTime < 24) {
      return '$responseTime ساعة';
    } else {
      final days = (responseTime / 24).round();
      return '$days يوم';
    }
  }

  String get completionRateText => '${completionRate.toStringAsFixed(0)}%';

  @override
  List<Object?> get props => [
        totalSales,
        totalOrders,
        averageRating,
        responseTime,
        completionRate,
      ];
}

class StoreSocialLinksEntity extends Equatable {
  final String? website;
  final String? facebook;
  final String? instagram;
  final String? twitter;
  final String? whatsapp;

  const StoreSocialLinksEntity({
    this.website,
    this.facebook,
    this.instagram,
    this.twitter,
    this.whatsapp,
  });

  bool get hasAnyLink =>
      website?.isNotEmpty == true ||
      facebook?.isNotEmpty == true ||
      instagram?.isNotEmpty == true ||
      twitter?.isNotEmpty == true ||
      whatsapp?.isNotEmpty == true;

  @override
  List<Object?> get props => [website, facebook, instagram, twitter, whatsapp];
}