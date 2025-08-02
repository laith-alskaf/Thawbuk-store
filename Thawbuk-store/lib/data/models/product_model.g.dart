// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      description: json['description'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
      price: (json['price'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      createdBy: json['createdBy'] as String?,
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      sizes:
          (json['sizes'] as List<dynamic>?)?.map((e) => e as String).toList(),
      colors:
          (json['colors'] as List<dynamic>?)?.map((e) => e as String).toList(),
      stock: (json['stock'] as num).toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      rating: (json['rating'] as num?)?.toDouble(),
      reviewsCount: (json['reviewsCount'] as num?)?.toInt(),
      brand: json['brand'] as String?,
      ageRange: (json['ageRange'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      favoritesCount: (json['favoritesCount'] as num?)?.toInt(),
      viewsCount: (json['viewsCount'] as num?)?.toInt(),
      isActive: json['isActive'] as bool?,
    );

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'nameAr': instance.nameAr,
      'description': instance.description,
      'descriptionAr': instance.descriptionAr,
      'price': instance.price,
      'categoryId': instance.categoryId,
      'createdBy': instance.createdBy,
      'images': instance.images,
      'sizes': instance.sizes,
      'colors': instance.colors,
      'stock': instance.stock,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'rating': instance.rating,
      'reviewsCount': instance.reviewsCount,
      'brand': instance.brand,
      'ageRange': instance.ageRange,
      'favoritesCount': instance.favoritesCount,
      'viewsCount': instance.viewsCount,
      'isActive': instance.isActive,
      '_id': instance.id,
    };
