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

  @JsonKey(name: '_id')
  final String id;

  @override
  @JsonKey(name: 'ageRange')
  final AgeRangeModel? ageRange;

  const ProductModel({
    required this.id,
    required super.name,
    super.nameAr,
    super.description,
    super.descriptionAr,
    required super.price,
    required super.categoryId,
    super.createdBy,
    required super.images,
    super.sizes,
    super.colors,
    required super.stock,
    super.createdAt,
    super.updatedAt,
    super.rating,
    super.reviewsCount,
    super.brand,
    this.ageRange,
    super.favoritesCount,
    super.viewsCount,
    super.isActive,
  }) : super(id: id, ageRange: ageRange);

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
      ageRange: ageRange?.toEntity(),
      favoritesCount: favoritesCount,
      viewsCount: viewsCount,
      isActive: isActive,
    );
  }
}
