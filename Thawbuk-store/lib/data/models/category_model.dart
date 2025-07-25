import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/category_entity.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.nameAr,
    super.description,
    super.descriptionAr,
    super.image,
    super.productsCount,
    required super.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return _$CategoryModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      nameAr: nameAr,
      description: description,
      descriptionAr: descriptionAr,
      image: image,
      productsCount: productsCount,
      createdAt: createdAt,
    );
  }
}