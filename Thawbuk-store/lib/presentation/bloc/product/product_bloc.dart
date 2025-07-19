import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/usecases/product/get_products_usecase.dart';
import '../../../domain/usecases/product/get_product_by_id_usecase.dart';

// Events
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductsEvent extends ProductEvent {
  final int page;
  final int limit;

  const LoadProductsEvent({this.page = 1, this.limit = 10});

  @override
  List<Object?> get props => [page, limit];
}

class LoadProductByIdEvent extends ProductEvent {
  final String productId;

  const LoadProductByIdEvent({required this.productId});

  @override
  List<Object?> get props => [productId];
}

class SearchProductsEvent extends ProductEvent {
  final String query;
  final String? categoryId;

  const SearchProductsEvent({required this.query, this.categoryId});

  @override
  List<Object?> get props => [query, categoryId];
}

// States
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitialState extends ProductState {}

class ProductLoadingState extends ProductState {}

class ProductLoadedState extends ProductState {
  final List<Product> products;
  final bool hasReachedMax;

  const ProductLoadedState({
    required this.products,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [products, hasReachedMax];

  ProductLoadedState copyWith({
    List<Product>? products,
    bool? hasReachedMax,
  }) {
    return ProductLoadedState(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class ProductDetailLoadedState extends ProductState {
  final Product product;

  const ProductDetailLoadedState({required this.product});

  @override
  List<Object?> get props => [product];
}

class ProductErrorState extends ProductState {
  final String message;

  const ProductErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

// Bloc
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final GetProductByIdUseCase getProductByIdUseCase;

  ProductBloc({
    required this.getProductsUseCase,
    required this.getProductByIdUseCase,
  }) : super(ProductInitialState()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<LoadProductByIdEvent>(_onLoadProductById);
    on<SearchProductsEvent>(_onSearchProducts);
  }

  Future<void> _onLoadProducts(
    LoadProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    if (state is ProductLoadingState) return;

    final currentState = state;
    List<Product> oldProducts = [];
    
    if (currentState is ProductLoadedState) {
      oldProducts = currentState.products;
    } else {
      emit(ProductLoadingState());
    }

    final result = await getProductsUseCase(GetProductsParams(
      page: event.page,
      limit: event.limit,
    ));

    result.fold(
      (failure) => emit(ProductErrorState(message: failure.message)),
      (newProducts) {
        final allProducts = event.page == 1 
          ? newProducts 
          : List.of(oldProducts)..addAll(newProducts);
        
        emit(ProductLoadedState(
          products: allProducts,
          hasReachedMax: newProducts.length < event.limit,
        ));
      },
    );
  }

  Future<void> _onLoadProductById(
    LoadProductByIdEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoadingState());

    final result = await getProductByIdUseCase(event.productId);

    result.fold(
      (failure) => emit(ProductErrorState(message: failure.message)),
      (product) => emit(ProductDetailLoadedState(product: product)),
    );
  }

  Future<void> _onSearchProducts(
    SearchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoadingState());

    // مؤقتاً - سيتم تطبيق البحث لاحقاً
    final result = await getProductsUseCase(GetProductsParams());

    result.fold(
      (failure) => emit(ProductErrorState(message: failure.message)),
      (products) {
        // تصفية المنتجات حسب الاستعلام
        final filteredProducts = products.where(
          (product) => product.name.toLowerCase().contains(event.query.toLowerCase())
        ).toList();
        
        emit(ProductLoadedState(products: filteredProducts));
      },
    );
  }
}