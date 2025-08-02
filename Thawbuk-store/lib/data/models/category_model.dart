import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/category_entity.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel extends CategoryEntity {
  @JsonKey(name: '_id')
  final String id;

  const CategoryModel({
    required this.id,
    required String name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    String? image,
    int? productsCount,
    DateTime? createdAt,
  }) : super(
          id: id,
          name: name,
          nameAr: nameAr,
          description: description,
          descriptionAr: descriptionAr,
          image: image,
          productsCount: productsCount,
          createdAt: createdAt,
        );

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

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
