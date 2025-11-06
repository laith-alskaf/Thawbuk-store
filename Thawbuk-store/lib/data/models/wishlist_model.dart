import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/wishlist_entity.dart';
import 'product_model.dart';

part 'wishlist_model.g.dart';

@JsonSerializable()
class WishlistModel extends WishlistEntity {
  @override
  @JsonKey(name: '_id')
  final String id;

  @override
  final String userId;

  @override
  final List<ProductModel> products;

  @override
  final DateTime createdAt;

  @override
  final DateTime updatedAt;

  const WishlistModel({
    required this.id,
    required this.userId,
    required this.products,
    required this.createdAt,
    required this.updatedAt,
  }) : super(
          id: id,
          userId: userId,
          products: products,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory WishlistModel.fromJson(Map<String, dynamic> json) =>
      _$WishlistModelFromJson(json);

  Map<String, dynamic> toJson() => _$WishlistModelToJson(this);

  WishlistEntity toEntity() {
    return WishlistEntity(
      id: id,
      userId: userId,
      products: products.map((product) => product.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory WishlistModel.fromEntity(WishlistEntity entity) {
    return WishlistModel(
      id: entity.id,
      userId: entity.userId,
      products: entity.products.map((product) => ProductModel.fromEntity(product)).toList(),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}