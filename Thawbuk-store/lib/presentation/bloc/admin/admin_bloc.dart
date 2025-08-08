import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/admin_dashboard_stats_entity.dart';
import '../../../domain/usecases/product/get_my_products_usecase.dart';
import '../../../domain/usecases/product/get_products_usecase.dart';
import '../../../domain/usecases/product/create_product_usecase.dart';
import '../../../domain/usecases/product/update_product_usecase.dart';
import '../../../domain/usecases/product/delete_product_usecase.dart';
import '../../../domain/usecases/admin/get_admin_dashboard_stats_usecase.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';

// Events
abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class GetAdminDashboardDataEvent extends AdminEvent {}

class GetAdminDashboardStatsEvent extends AdminEvent {}

class GetMyProductsEvent extends AdminEvent {}

class GetAllProductsEvent extends AdminEvent {}

class GetProductFavoritesStatsEvent extends AdminEvent {
  final String productId;

  const GetProductFavoritesStatsEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class CreateProductEvent extends AdminEvent {
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

class UpdateProductEvent extends AdminEvent {
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

class DeleteProductEvent extends AdminEvent {
  final String productId;

  const DeleteProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

// States
abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminDashboardLoaded extends AdminState {
  final List<ProductEntity> myProducts;
  final AdminDashboardStatsEntity stats;

  const AdminDashboardLoaded({
    required this.myProducts,
    required this.stats,
  });

  @override
  List<Object?> get props => [myProducts, stats];
}

class AdminDashboardStatsLoaded extends AdminState {
  final AdminDashboardStatsEntity stats;

  const AdminDashboardStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class MyProductsLoaded extends AdminState {
  final List<ProductEntity> products;

  const MyProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class AllProductsLoaded extends AdminState {
  final List<ProductEntity> products;

  const AllProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class ProductFavoritesStatsLoaded extends AdminState {
  final String productId;
  final int favoritesCount;

  const ProductFavoritesStatsLoaded({
    required this.productId,
    required this.favoritesCount,
  });

  @override
  List<Object?> get props => [productId, favoritesCount];
}

class ProductCreated extends AdminState {
  final ProductEntity product;

  const ProductCreated(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductUpdated extends AdminState {
  final ProductEntity product;

  const ProductUpdated(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductDeleted extends AdminState {
  final String productId;

  const ProductDeleted(this.productId);

  @override
  List<Object?> get props => [productId];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}



// BLoC
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetMyProductsUseCase getMyProductsUseCase;
  final GetProductsUseCase getProductsUseCase;
  final CreateProductUseCase createProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;
  final GetAdminDashboardStatsUseCase getAdminDashboardStatsUseCase;

  AdminBloc({
    required this.getMyProductsUseCase,
    required this.getProductsUseCase,
    required this.createProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
    required this.getAdminDashboardStatsUseCase,
  }) : super(AdminInitial()) {
    on<GetAdminDashboardDataEvent>(_onGetAdminDashboardData);
    on<GetAdminDashboardStatsEvent>(_onGetAdminDashboardStats);
    on<GetMyProductsEvent>(_onGetMyProducts);
    on<GetAllProductsEvent>(_onGetAllProducts);
    on<GetProductFavoritesStatsEvent>(_onGetProductFavoritesStats);
    on<CreateProductEvent>(_onCreateProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
  }

  Future<void> _onGetAdminDashboardData(
    GetAdminDashboardDataEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());

    final result = await getMyProductsUseCase(NoParams());

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء تحميل بيانات لوحة التحكم';
        if (failure is ServerFailure) {
          message = failure.message;
        } else if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(AdminError(message));
      },
      (products) {
        final stats = _calculateDashboardStats(products);
        emit(AdminDashboardLoaded(
          myProducts: products,
          stats: stats,
        ));
      },
    );
  }

  Future<void> _onGetAdminDashboardStats(
    GetAdminDashboardStatsEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());

    final result = await getAdminDashboardStatsUseCase(NoParams());

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء تحميل الإحصائيات';
        if (failure is ServerFailure) {
          message = failure.message;
        } else if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(AdminError(message));
      },
      (stats) {
        emit(AdminDashboardStatsLoaded(stats));
      },
    );
  }

  Future<void> _onGetMyProducts(
    GetMyProductsEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());

    final result = await getMyProductsUseCase(NoParams());

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء تحميل منتجاتك';
        if (failure is ServerFailure) {
          message = failure.message;
        } else if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(AdminError(message));
      },
      (products) => emit(MyProductsLoaded(products)),
    );
  }

  Future<void> _onGetAllProducts(
    GetAllProductsEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());

    final result = await getProductsUseCase(NoParams());

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء تحميل جميع المنتجات';
        if (failure is ServerFailure) {
          message = failure.message;
        } else if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(AdminError(message));
      },
      (products) => emit(AllProductsLoaded(products)),
    );
  }

  Future<void> _onGetProductFavoritesStats(
    GetProductFavoritesStatsEvent event,
    Emitter<AdminState> emit,
  ) async {
    // TODO: Implement when backend provides favorites count endpoint
    // For now, we'll use the favoritesCount from product entity
    emit(ProductFavoritesStatsLoaded(
      productId: event.productId,
      favoritesCount: 0, // Will be updated when backend is ready
    ));
  }

  Future<void> _onCreateProduct(
    CreateProductEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());

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
        emit(AdminError(message));
      },
      (product) {
        emit(ProductCreated(product));
        // Refresh dashboard data
        add(GetAdminDashboardDataEvent());
      },
    );
  }

  Future<void> _onUpdateProduct(
    UpdateProductEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());

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
        emit(AdminError(message));
      },
      (product) {
        emit(ProductUpdated(product));
        // Refresh dashboard data and my products list
        add(GetAdminDashboardDataEvent());
        add(GetMyProductsEvent());
      },
    );
  }

  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());

    final result = await deleteProductUseCase(DeleteProductParams(event.productId));

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء حذف المنتج';
        if (failure is ServerFailure) {
          message = failure.message;
        } else if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(AdminError(message));
      },
      (_) {
        emit(ProductDeleted(event.productId));
        // Refresh dashboard data
        add(GetAdminDashboardDataEvent());
      },
    );
  }

  AdminDashboardStatsEntity _calculateDashboardStats(List<ProductEntity> products) {
    final totalProducts = products.length;
    final availableProducts = products.where((p) => p.isAvailable).length;
    final outOfStockProducts = totalProducts - availableProducts;
    
    // Calculate total favorites
    final totalFavorites = products.fold<int>(
      0,
      (sum, product) => sum + (product.favoritesCount ?? 0),
    );

    // Get top favorite products (sorted by favorites count)
    final sortedByFavorites = List<ProductEntity>.from(products)
      ..sort((a, b) => (b.favoritesCount ?? 0).compareTo(a.favoritesCount ?? 0));
    final topFavoriteProducts = sortedByFavorites.take(5).toList();

    // Get recent products (sorted by creation date)
    final sortedByDate = List<ProductEntity>.from(products)
      ..sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
    final recentProducts = sortedByDate.take(5).toList();

    // إحصائيات التصنيفات
    final categoryStats = <String, int>{};
    for (final product in products) {
      categoryStats[product.categoryId] = (categoryStats[product.categoryId] ?? 0) + 1;
    }

    return AdminDashboardStatsEntity(
      totalProducts: totalProducts,
      availableProducts: availableProducts,
      outOfStockProducts: outOfStockProducts,
      totalFavorites: totalFavorites,
      totalRevenue: 0.0, // سيتم حسابها من الطلبات لاحقاً
      totalOrders: 0, // سيتم حسابها من الطلبات لاحقاً
      topFavoriteProducts: topFavoriteProducts,
      recentProducts: recentProducts,
      categoryStats: categoryStats,
    );
  }
}