import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/product_entity.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.nameAr,
    required super.description,
    required super.descriptionAr,
    required super.price,
    required super.category,
    required super.images,
    required super.sizes,
    required super.colors,
    required super.inStock,
    required super.quantity,
    required super.createdAt,
    super.updatedAt,
    super.rating,
    super.reviewsCount,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return _$ProductModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: name,
      nameAr: nameAr,
      description: description,
      descriptionAr: descriptionAr,
      price: price,
      category: category,
      images: images,
      sizes: sizes,
      colors: colors,
      inStock: inStock,
      quantity: quantity,
      createdAt: createdAt,
      updatedAt: updatedAt,
      rating: rating,
      reviewsCount: reviewsCount,
    );
  }
}