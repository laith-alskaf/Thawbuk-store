import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.categoryId,
    required super.createdBy,
    required super.images,
    required super.sizes,
    required super.colors,
    required super.stock,
    super.brand,
    super.ageRange,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return _$ProductModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      categoryId: categoryId,
      createdBy: createdBy,
      images: images,
      sizes: sizes,
      colors: colors,
      stock: stock,
      brand: brand,
      ageRange: ageRange,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

@JsonSerializable()
class AgeRangeModel {
  final int minAge;
  final int maxAge;

  const AgeRangeModel({
    required this.minAge,
    required this.maxAge,
  });

  factory AgeRangeModel.fromJson(Map<String, dynamic> json) {
    return _$AgeRangeModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AgeRangeModelToJson(this);
}