import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
  final String createdBy;
  final List<String> images;
  final List<String> sizes;
  final List<String> colors;
  final int stock;
  final String? brand;
  final AgeRange? ageRange;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
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
    this.brand,
    this.ageRange,
    required this.createdAt,
    required this.updatedAt,
  });

  String get mainImage => images.isNotEmpty ? images.first : '';
  bool get isInStock => stock > 0;
  bool get hasMultipleSizes => sizes.length > 1;
  bool get hasMultipleColors => colors.length > 1;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        categoryId,
        createdBy,
        images,
        sizes,
        colors,
        stock,
        brand,
        ageRange,
        createdAt,
        updatedAt,
      ];
}

class AgeRange extends Equatable {
  final int minAge;
  final int maxAge;

  const AgeRange({
    required this.minAge,
    required this.maxAge,
  });

  bool isForAge(int age) => age >= minAge && age <= maxAge;

  String get displayText => '$minAge - $maxAge سنة';

  @override
  List<Object?> get props => [minAge, maxAge];
}