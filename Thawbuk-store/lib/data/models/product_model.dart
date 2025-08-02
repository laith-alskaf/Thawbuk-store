import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/product_entity.dart';

part 'product_model.g.dart';

@JsonSerializable(explicitToJson: true)
class AgeRangeModel extends AgeRangeEntity {
  const AgeRangeModel({
    required super.minAge,
    required super.maxAge,
  });

  factory AgeRangeModel.fromJson(Map<String, dynamic> json) =>
      _$AgeRangeModelFromJson(json);

  Map<String, dynamic> toJson() => _$AgeRangeModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ProductModel extends ProductEntity {
  @override
  @JsonKey(name: 'ageRange')
  final AgeRangeModel? ageRange;

  const ProductModel({
    required this.id,
    required String name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    required double price,
    required String categoryId,
    String? createdBy,
    required List<String> images,
    List<String>? sizes,
    List<String>? colors,
    required int stock,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? rating,
    int? reviewsCount,
    String? brand,
    Map<String, int>? ageRange,
    int? favoritesCount,
    int? viewsCount,
    bool? isActive,
  }) : super(
          id: id,
          name: name,
          nameAr: nameAr,
          description: description,
          descriptionAr: descriptionAr,
          price: price,
          categoryId: categoryId,
          createdBy: createdBy,
          images: images,
          sizes: sizes,
          colors: colors,
          stock: stock,
          createdAt: createdAt,
          updatedAt: updatedAt,
          rating: rating,
          reviewsCount: reviewsCount,
          brand: brand,
          ageRange: ageRange,
          favoritesCount: favoritesCount,
          viewsCount: viewsCount,
          isActive: isActive,
        );
>>>>>>> main

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: name,
      nameAr: nameAr,
      description: description,
      descriptionAr: descriptionAr,
      price: price,
      categoryId: categoryId,
      createdBy: createdBy,
      images: images,
      sizes: sizes,
      colors: colors,
      stock: stock,
      createdAt: createdAt,
      updatedAt: updatedAt,
      rating: rating,
      reviewsCount: reviewsCount,
      brand: brand,
      ageRange: ageRange,
      favoritesCount: favoritesCount,
      viewsCount: viewsCount,
      isActive: isActive,
    );
  }
}
