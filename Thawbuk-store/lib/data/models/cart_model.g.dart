// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartModel _$CartModelFromJson(Map<String, dynamic> json) => CartModel(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CartModelToJson(CartModel instance) => <String, dynamic>{
      '_id': instance.id,
      'userId': instance.userId,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'totalAmount': instance.totalAmount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

CartItemModel _$CartItemModelFromJson(Map<String, dynamic> json) =>
    CartItemModel(
      id: json['_id'] as String,
      productId: json['productId'] as String,
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toInt(),
      selectedSize: json['selectedSize'] as String?,
      selectedColor: json['selectedColor'] as String?,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );

Map<String, dynamic> _$CartItemModelToJson(CartItemModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'productId': instance.productId,
      'product': instance.product.toJson(),
      'quantity': instance.quantity,
      'selectedSize': instance.selectedSize,
      'selectedColor': instance.selectedColor,
      'unitPrice': instance.unitPrice,
      'totalPrice': instance.totalPrice,
    };
