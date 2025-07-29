import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../entities/product_entity.dart';
import '../../repositories/product_repository.dart';

class CreateProductUseCase implements UseCase<ProductEntity, CreateProductParams> {
  final ProductRepository repository;

  CreateProductUseCase(this.repository);

  @override
  Future<Either<Failure, ProductEntity>> call(CreateProductParams params) async {
    return await repository.createProduct(
      name: params.name,
      nameAr: params.nameAr,
      description: params.description,
      descriptionAr: params.descriptionAr,
      price: params.price,
      category: params.category,
      sizes: params.sizes,
      colors: params.colors,
      quantity: params.quantity,
      images: params.images,
    );
  }
}

class CreateProductParams extends Equatable {
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final double price;
  final String category;
  final List<String> sizes;
  final List<String> colors;
  final int quantity;
  final List<File> images;

  const CreateProductParams({
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.price,
    required this.category,
    required this.sizes,
    required this.colors,
    required this.quantity,
    required this.images,
  });

  @override
  List<Object?> get props => [
        name,
        nameAr,
        description,
        descriptionAr,
        price,
        category,
        sizes,
        colors,
        quantity,
        images,
      ];
}
