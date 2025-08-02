import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String? nameAr;
  final String? description;
  final String? descriptionAr;
  final String image;
  final int? productsCount;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.image,
    this.nameAr,
    this.description,
    this.descriptionAr,
    this.productsCount,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  String get displayName => nameAr?.isNotEmpty == true ? nameAr! : name;
  String get displayDescription =>
      (descriptionAr?.isNotEmpty == true) ? descriptionAr! : description ?? '';

  @override
  List<Object?> get props => [
        id,
        name,
        nameAr,
        description,
        descriptionAr,
        image,
        productsCount,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
