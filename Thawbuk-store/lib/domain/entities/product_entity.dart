import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String? nameAr;
  final String? description;
  final String? descriptionAr;
  final double price;
  final String categoryId;
  final String? createdBy;
  final List<String> images;
  final List<String>? sizes;
  final List<String>? colors;
  final int stock;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? rating;
  final int? reviewsCount;
  final String? brand;
  final Map<String, int>? ageRange;

  const ProductEntity({
    required this.id,
    required this.name,
    this.nameAr,
    this.description,
    this.descriptionAr,
    required this.price,
    required this.categoryId,
    this.createdBy,
    required this.images,
    this.sizes,
    this.colors,
    required this.stock,
    this.createdAt,
    this.updatedAt,
    this.rating,
    this.reviewsCount,
    this.brand,
    this.ageRange,
  });

  String get displayName => nameAr?.isNotEmpty == true ? nameAr! : name;
  String get displayDescription => descriptionAr?.isNotEmpty == true ? descriptionAr! : description ?? '';
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
        createdAt,
        updatedAt,
        rating,
        reviewsCount,
        brand,
        ageRange,
      ];
}
