import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/product_entity.dart';
import '../../../domain/usecases/product/get_products_usecase.dart';
import '../../../domain/usecases/product/get_product_by_id_usecase.dart';
import '../../../domain/usecases/product/search_products_usecase.dart';
import '../../../domain/usecases/product/get_products_by_category_usecase.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';

// Events
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class GetProductsEvent extends ProductEvent {}

class GetProductByIdEvent extends ProductEvent {
  final String productId;

  const GetProductByIdEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class SearchProductsEvent extends ProductEvent {
  final String query;

  const SearchProductsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class GetProductsByCategoryEvent extends ProductEvent {
  final String category;

  const GetProductsByCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class CreateProductEvent extends ProductEvent {
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

  const CreateProductEvent({
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

class UpdateProductEvent extends ProductEvent {
  final String productId;
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

  const UpdateProductEvent({
    required this.productId,
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
        productId,
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

class DeleteProductEvent extends ProductEvent {
  final String productId;

  const DeleteProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

// States
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductsLoaded extends ProductState {
  final List<ProductEntity> products;

  const ProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class ProductLoaded extends ProductState {
  final ProductEntity product;

  const ProductLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductCreated extends ProductState {
  final Product product;

  const ProductCreated(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductUpdated extends ProductState {
  final Product product;

  const ProductUpdated(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductDeleted extends ProductState {
  final String productId;

  const ProductDeleted(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final GetProductByIdUseCase getProductByIdUseCase;
  final SearchProductsUseCase searchProductsUseCase;
  final GetProductsByCategoryUseCase getProductsByCategoryUseCase;

  ProductBloc({
    required this.getProductsUseCase,
    required this.getProductByIdUseCase,
    required this.searchProductsUseCase,
    required this.getProductsByCategoryUseCase,
  }) : super(ProductInitial()) {
    
    on<GetProductsEvent>(_onGetProducts);
    on<GetProductByIdEvent>(_onGetProductById);
    on<SearchProductsEvent>(_onSearchProducts);
    on<GetProductsByCategoryEvent>(_onGetProductsByCategory);
    on<CreateProductEvent>(_onCreateProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
  }

  Future<void> _onGetProducts(
    GetProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final result = await getProductsUseCase(NoParams());

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء تحميل المنتجات';
        if (failure is ServerFailure) {
          message = failure.message;
        } else if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(ProductError(message));
      },
      (products) => emit(ProductsLoaded(products)),
    );
  }

  Future<void> _onGetProductById(
    GetProductByIdEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final result = await getProductByIdUseCase(ProductByIdParams(event.productId));

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء تحميل المنتج';
        if (failure is ServerFailure) {
          message = failure.message;
        } else if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(ProductError(message));
      },
      (product) => emit(ProductLoaded(product)),
    );
  }

  Future<void> _onSearchProducts(
    SearchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final result = await searchProductsUseCase(SearchProductsParams(query: event.query));

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء البحث';
        if (failure is ServerFailure) {
          message = failure.message;
        } else if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(ProductError(message));
      },
      (products) => emit(ProductsLoaded(products)),
    );
  }

  Future<void> _onGetProductsByCategory(
    GetProductsByCategoryEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final result = await getProductsByCategoryUseCase(
      GetProductsByCategoryParams(category: event.category),
    );

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء تحميل المنتجات';
        if (failure is ServerFailure) {
          message = failure.message;
        } else if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(ProductError(message));
      },
      (products) => emit(ProductsLoaded(products)),
    );
  }

  Future<void> _onCreateProduct(
    CreateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    // TODO: Implement product creation with API
    // For now, simulate success
    await Future.delayed(const Duration(seconds: 1));

    // Create mock product
    final product = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: event.name,
      nameAr: event.nameAr,
      description: event.description,
      descriptionAr: event.descriptionAr,
      price: event.price,
      category: event.category,
      images: [], // Will be populated after upload
      sizes: event.sizes,
      colors: event.colors,
      inStock: true,
      quantity: event.quantity,
      createdAt: DateTime.now(),
    );

    emit(ProductCreated(product));
  }

  Future<void> _onUpdateProduct(
    UpdateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    // TODO: Implement product update with API
    await Future.delayed(const Duration(seconds: 1));

    // Create mock updated product
    final product = Product(
      id: event.productId,
      name: event.name,
      nameAr: event.nameAr,
      description: event.description,
      descriptionAr: event.descriptionAr,
      price: event.price,
      category: event.category,
      images: [],
      sizes: event.sizes,
      colors: event.colors,
      inStock: true,
      quantity: event.quantity,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    emit(ProductUpdated(product));
  }

  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    // TODO: Implement product deletion with API
    await Future.delayed(const Duration(seconds: 1));

    emit(ProductDeleted(event.productId));
    
    // Refresh products list
    add(GetProductsEvent());
  }
}