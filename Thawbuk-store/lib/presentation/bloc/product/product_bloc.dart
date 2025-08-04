import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/product_entity.dart';
import '../../../domain/usecases/product/get_products_usecase.dart';
import '../../../domain/usecases/product/get_product_by_id_usecase.dart';
import '../../../domain/usecases/product/search_products_usecase.dart';
import '../../../domain/usecases/product/get_products_by_category_usecase.dart';
import '../../../domain/usecases/product/get_filtered_products_usecase.dart';
import '../../../domain/usecases/product/create_product_usecase.dart';
import '../../../domain/usecases/product/update_product_usecase.dart';
import '../../../domain/usecases/product/delete_product_usecase.dart';
import '../../../domain/usecases/product/get_my_products_usecase.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';

// Events
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class GetProductsEvent extends ProductEvent {}

class GetMyProductsEvent extends ProductEvent {}

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

class GetFilteredProductsEvent extends ProductEvent {
  final String? category;
  final String? searchQuery;
  final List<String>? sizes;
  final List<String>? colors;
  final double? minPrice;
  final double? maxPrice;
  final String? sortBy;

  const GetFilteredProductsEvent({
    this.category,
    this.searchQuery,
    this.sizes,
    this.colors,
    this.minPrice,
    this.maxPrice,
    this.sortBy,
  });

  @override
  List<Object?> get props => [
        category,
        searchQuery,
        sizes,
        colors,
        minPrice,
        maxPrice,
        sortBy,
      ];
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

class LoadMoreProductsEvent extends ProductEvent {}

class FilterProductsEvent extends ProductEvent {
  final String? category;
  final String? searchQuery;
  final List<String>? sizes;
  final List<String>? colors;
  final double? minPrice;
  final double? maxPrice;
  final String? sortBy;

  const FilterProductsEvent({
    this.category,
    this.searchQuery,
    this.sizes,
    this.colors,
    this.minPrice,
    this.maxPrice,
    this.sortBy,
  });

  @override
  List<Object?> get props => [
        category,
        searchQuery,
        sizes,
        colors,
        minPrice,
        maxPrice,
        sortBy,
      ];
}

// States
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
  
  // Getters for common properties
  List<ProductEntity> get products => [];
  ProductEntity? get selectedProduct => null;
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {
  final List<ProductEntity> currentProducts;
  
  const ProductLoading({this.currentProducts = const []});
  
  @override
  List<ProductEntity> get products => currentProducts;
  
  @override
  List<Object?> get props => [currentProducts];
}

class ProductsLoaded extends ProductState {
  final List<ProductEntity> _products;

  const ProductsLoaded(this._products);

  @override
  List<ProductEntity> get products => _products;

  @override
  List<Object?> get props => [_products];
}

class ProductLoaded extends ProductState {
  final ProductEntity product;

  const ProductLoaded(this.product);

  @override
  ProductEntity? get selectedProduct => product;

  @override
  List<Object?> get props => [product];
}

class ProductCreated extends ProductState {
  final ProductEntity product;

  const ProductCreated(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductUpdated extends ProductState {
  final ProductEntity product;

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
  final List<ProductEntity> currentProducts;

  const ProductError(this.message, {this.currentProducts = const []});

  @override
  List<ProductEntity> get products => currentProducts;

  @override
  List<Object?> get props => [message, currentProducts];
}

// BLoC
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final GetProductByIdUseCase getProductByIdUseCase;
  final SearchProductsUseCase searchProductsUseCase;
  final GetProductsByCategoryUseCase getProductsByCategoryUseCase;
  final GetFilteredProductsUseCase getFilteredProductsUseCase;
  final CreateProductUseCase createProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;
  final GetMyProductsUseCase getMyProductsUseCase;

  ProductBloc({
    required this.getProductsUseCase,
    required this.getMyProductsUseCase,
    required this.getProductByIdUseCase,
    required this.searchProductsUseCase,
    required this.getProductsByCategoryUseCase,
    required this.getFilteredProductsUseCase,
    required this.createProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
  }) : super(ProductInitial()) {
    
    on<GetProductsEvent>(_onGetProducts);
    on<GetMyProductsEvent>(_onGetMyProducts);
    on<GetProductByIdEvent>(_onGetProductById);
    on<SearchProductsEvent>(_onSearchProducts);
    on<GetProductsByCategoryEvent>(_onGetProductsByCategory);
    on<GetFilteredProductsEvent>(_onGetFilteredProducts);
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

  Future<void> _onGetMyProducts(
    GetMyProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final result = await getMyProductsUseCase(NoParams());

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء تحميل منتجاتك';
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

  Future<void> _onGetFilteredProducts(
    GetFilteredProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final result = await getFilteredProductsUseCase(
      GetFilteredProductsParams(
        category: event.category,
        searchQuery: event.searchQuery,
        sizes: event.sizes,
        colors: event.colors,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        sortBy: event.sortBy,
      ),
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

    final result = await createProductUseCase(
      CreateProductParams(
        name: event.name,
        nameAr: event.nameAr,
        description: event.description,
        descriptionAr: event.descriptionAr,
        price: event.price,
        category: event.category,
        sizes: event.sizes,
        colors: event.colors,
        quantity: event.quantity,
        images: event.images,
      ),
    );

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء إنشاء المنتج';
        if (failure is ServerFailure) {
          message = failure.message;
        } else if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(ProductError(message));
      },
      (product) => emit(ProductCreated(product)),
    );
  }

  Future<void> _onUpdateProduct(
    UpdateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final result = await updateProductUseCase(
      UpdateProductParams(
        productId: event.productId,
        name: event.name,
        nameAr: event.nameAr,
        description: event.description,
        descriptionAr: event.descriptionAr,
        price: event.price,
        category: event.category,
        sizes: event.sizes,
        colors: event.colors,
        quantity: event.quantity,
        images: event.images,
      ),
    );

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء تحديث المنتج';
        if (failure is ServerFailure) {
          message = failure.message;
        } else if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(ProductError(message));
      },
      (product) => emit(ProductUpdated(product)),
    );
  }

  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final result = await deleteProductUseCase(DeleteProductParams(event.productId));

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء حذف المنتج';
        if (failure is ServerFailure) {
          message = failure.message;
        } else if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(ProductError(message));
      },
      (_) {
        emit(ProductDeleted(event.productId));
        add(GetProductsEvent());
      },
    );
  }
}
