import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final double price;
  final String category;
  final List<String> images;
  final List<String> sizes;
  final List<String> colors;
  final bool inStock;
  final int quantity;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double? rating;
  final int reviewsCount;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.price,
    required this.category,
    required this.images,
    required this.sizes,
    required this.colors,
    required this.inStock,
    required this.quantity,
    required this.createdAt,
    this.updatedAt,
    this.rating,
    this.reviewsCount = 0,
  });

  String get displayName => nameAr.isNotEmpty ? nameAr : name;
  String get displayDescription => descriptionAr.isNotEmpty ? descriptionAr : description;
  String get mainImage => images.isNotEmpty ? images.first : '';
  bool get isAvailable => inStock && quantity > 0;

  @override
  List<Object?> get props => [
        id,
        name,
        nameAr,
        description,
        descriptionAr,
        price,
        category,
        images,
        sizes,
        colors,
        inStock,
        quantity,
        createdAt,
        updatedAt,
        rating,
        reviewsCount,
      ];
}