import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String? nameAr;
  final String? description;
  final String? descriptionAr;
  final String? image;
  final int? productsCount;
  final DateTime? createdAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.nameAr,
    this.description,
    this.descriptionAr,
    this.image,
    this.productsCount,
    this.createdAt,
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
        createdAt,
      ];
}
