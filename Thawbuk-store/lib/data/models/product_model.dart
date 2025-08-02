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
    required super.createdAt,
    required super.updatedAt,
    super.nameAr,
    super.descriptionAr,
    super.brand,
    this.ageRange,
    super.rating,
    super.reviewsCount,
  }) : super(ageRange: ageRange);

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}
