import '../../domain/entities/store_profile_entity.dart';

class StoreProfileModel extends StoreProfileEntity {
  const StoreProfileModel({
    required super.id,
    required super.name,
    super.description,
    super.logo,
    super.coverImage,
    required super.address,
    super.phone,
    required super.email,
    required super.joinedDate,
    required super.rating,
    required super.reviewsCount,
    required super.productsCount,
    required super.followersCount,
    required super.isVerified,
    required super.isActive,
    required super.categories,
    required super.stats,
    super.socialLinks,
  });

  factory StoreProfileModel.fromJson(Map<String, dynamic> json) {
    return StoreProfileModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      logo: json['logo'],
      coverImage: json['coverImage'],
      address: StoreAddressModel.fromJson(json['address'] ?? {}),
      phone: json['phone'],
      email: json['email'] ?? '',
      joinedDate: DateTime.tryParse(json['joinedDate'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewsCount: json['reviewsCount'] ?? 0,
      productsCount: json['productsCount'] ?? 0,
      followersCount: json['followersCount'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      categories: List<String>.from(json['categories'] ?? []),
      stats: StoreStatsModel.fromJson(json['stats'] ?? {}),
      socialLinks: json['socialLinks'] != null 
          ? StoreSocialLinksModel.fromJson(json['socialLinks'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo': logo,
      'coverImage': coverImage,
      'address': (address as StoreAddressModel).toJson(),
      'phone': phone,
      'email': email,
      'joinedDate': joinedDate.toIso8601String(),
      'rating': rating,
      'reviewsCount': reviewsCount,
      'productsCount': productsCount,
      'followersCount': followersCount,
      'isVerified': isVerified,
      'isActive': isActive,
      'categories': categories,
      'stats': (stats as StoreStatsModel).toJson(),
      'socialLinks': socialLinks != null 
          ? (socialLinks as StoreSocialLinksModel).toJson()
          : null,
    };
  }
}

class StoreAddressModel extends StoreAddressEntity {
  const StoreAddressModel({
    required super.city,
    super.street,
    super.country,
  });

  factory StoreAddressModel.fromJson(Map<String, dynamic> json) {
    return StoreAddressModel(
      city: json['city'] ?? '',
      street: json['street'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'street': street,
      'country': country,
    };
  }
}

class StoreStatsModel extends StoreStatsEntity {
  const StoreStatsModel({
    required super.totalSales,
    required super.totalOrders,
    required super.averageRating,
    required super.responseTime,
    required super.completionRate,
  });

  factory StoreStatsModel.fromJson(Map<String, dynamic> json) {
    return StoreStatsModel(
      totalSales: json['totalSales'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      responseTime: json['responseTime'] ?? 24,
      completionRate: (json['completionRate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSales': totalSales,
      'totalOrders': totalOrders,
      'averageRating': averageRating,
      'responseTime': responseTime,
      'completionRate': completionRate,
    };
  }
}

class StoreSocialLinksModel extends StoreSocialLinksEntity {
  const StoreSocialLinksModel({
    super.website,
    super.facebook,
    super.instagram,
    super.twitter,
    super.whatsapp,
  });

  factory StoreSocialLinksModel.fromJson(Map<String, dynamic> json) {
    return StoreSocialLinksModel(
      website: json['website'],
      facebook: json['facebook'],
      instagram: json['instagram'],
      twitter: json['twitter'],
      whatsapp: json['whatsapp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'website': website,
      'facebook': facebook,
      'instagram': instagram,
      'twitter': twitter,
      'whatsapp': whatsapp,
    };
  }
}