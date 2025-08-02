import 'package:equatable/equatable.dart';

class AgeRangeEntity extends Equatable {
  final int minAge;
  final int maxAge;

  const AgeRangeEntity({
    required this.minAge,
    required this.maxAge,
  });

  @override
  List<Object?> get props => [minAge, maxAge];
}

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String? nameAr;
  final String description;
  final String? descriptionAr;
  final double price;
  final String categoryId;
  final String createdBy;
  final List<String> images;
  final List<String> sizes;
  final List<String> colors;
  final int stock;
  final String? brand;
  final AgeRangeEntity? ageRange;
  final double? rating;
  final int? reviewsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.createdBy,
    required this.images,
    required this.sizes,
    required this.colors,
    required this.stock,
    required this.createdAt,
    required this.updatedAt,
    this.nameAr,
    this.descriptionAr,
    this.brand,
    this.ageRange,
    this.rating,
    this.reviewsCount,
  });

  String get displayName => nameAr?.isNotEmpty == true ? nameAr! : name;
  String get displayDescription =>
      descriptionAr?.isNotEmpty == true ? descriptionAr! : description ?? '';
  String get mainImage => images.isNotEmpty ? images.first : '';
  bool get isAvailable => stock > 0;

  @override
  List<Object?> get props => [
        id,
        name,
        nameAr,
        description,
        descriptionAr,
        price,
        categoryId,
        createdBy,
        images,
        sizes,
        colors,
        stock,
        brand,
        ageRange,
        rating,
        reviewsCount,
        createdAt,
        updatedAt,
      ];
}
