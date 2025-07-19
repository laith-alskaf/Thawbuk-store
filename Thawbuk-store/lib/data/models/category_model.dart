import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/category.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    super.description,
    required super.image,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return _$CategoryModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      description: description,
      image: image,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}