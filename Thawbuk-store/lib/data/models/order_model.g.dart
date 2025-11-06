// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: const OrderStatusConverter().fromJson(json['status'] as String),
      shippingAddress: AddressModel.fromJson(
          json['shippingAddress'] as Map<String, dynamic>),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      deliveredAt: json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
    );

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'userId': instance.userId,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'totalAmount': instance.totalAmount,
      'status': const OrderStatusConverter().toJson(instance.status),
      'shippingAddress': instance.shippingAddress.toJson(),
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
    };
