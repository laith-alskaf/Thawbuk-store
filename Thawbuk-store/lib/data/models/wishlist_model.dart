import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/wishlist_entity.dart';
import 'product_model.dart';

part 'wishlist_model.g.dart';

@JsonSerializable(explicitToJson: true)
class WishlistModel extends WishlistEntity {
  @JsonKey(name: 'products')
  final List<ProductModel> products;

  const WishlistModel({
    required this.products,
  }) : super(products: products);

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      products: (json['products'] as List<dynamic>)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => _$WishlistModelToJson(this);
}
