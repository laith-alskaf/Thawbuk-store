import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:thawbuk_store/domain/entities/product_entity.dart';
import 'package:thawbuk_store/domain/entities/admin_dashboard_stats_entity.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/product/get_filtered_products_usecase.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ProductEntity>>> getFilteredProducts(
      GetFilteredProductsParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final productModels =
            await remoteDataSource.getFilteredProducts(params);
        final products =
            productModels.map((model) => model.toEntity()).toList();
        return Right(products);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async {
    if (await networkInfo.isConnected) {
      try {
        final productModels = await remoteDataSource.getProducts();
        final products =
            productModels.map((model) => model.toEntity()).toList();
        return Right(products);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final productModel = await remoteDataSource.getProductById(id);
        return Right(productModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts(
      String query) async {
    if (await networkInfo.isConnected) {
      try {
        final productModels = await remoteDataSource.searchProducts(query);
        final products =
            productModels.map((model) => model.toEntity()).toList();
        return Right(products);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
      String category) async {
    if (await networkInfo.isConnected) {
      try {
        final productModels =
            await remoteDataSource.getProductsByCategory(category);
        final products =
            productModels.map((model) => model.toEntity()).toList();
        return Right(products);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct(
      {required String category,
      required List<String> colors,
      required String description,
      required String descriptionAr,
      required List<File> images,
      required String name,
      required String nameAr,
      required double price,
      required int quantity,
      required List<String> sizes}) async {
    if (await networkInfo.isConnected) {
      try {
        final productModel = await remoteDataSource.createProduct({
          'name': name,
          'nameAr': nameAr,
          'description': description,
          'descriptionAr': descriptionAr,
          'price': price,
          'categoryId': category,
          'sizes': sizes,
          'colors': colors,
          'quantity': quantity,
          'images': images,
        });
        return Right(productModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct(
      {required String category,
      required List<String> colors,
      required String description,
      required String descriptionAr,
      required String productId,
      required List<File> images,
      required String name,
      required String nameAr,
      required double price,
      required int quantity,
      required List<String> sizes}) async {
    if (await networkInfo.isConnected) {
      try {
        // تحويل Files إلى URLs (لأن updateProduct لا يدعم رفع صور جديدة)
        final imageUrls = <String>[];
        // في حالة التعديل، نحتفظ بالصور الموجودة
        // الصور الجديدة تحتاج endpoint منفصل لرفعها
        
        final productModel = await remoteDataSource.updateProduct(productId, {
          'product': {  // ✅ تصحيح رئيسي: wrap البيانات في object "product"
            'name': name,
            'nameAr': nameAr,
            'description': description,
            'descriptionAr': descriptionAr,
            'price': price,
            'categoryId': category,
            'sizes': sizes,
            'colors': colors,
            'stock': quantity,
            // ملاحظة: لا نرسل images هنا لأن updateProduct لا يدعم Files
          }
        });
        return Right(productModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteProduct(id);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getMyProducts() async {
    if (await networkInfo.isConnected) {
      try {
        final productModels = await remoteDataSource.getMyProducts();
        final products = productModels.map((model) => model.toEntity()).toList();
        return Right(products);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, AdminDashboardStatsEntity>> getAdminDashboardStats() async {
    if (await networkInfo.isConnected) {
      try {
        final myProducts = await remoteDataSource.getMyProducts();
        final products = myProducts.map((model) => model.toEntity()).toList();
        
        // حساب الإحصائيات من المنتجات
        final totalProducts = products.length;
        final availableProducts = products.where((p) => p.isAvailable).length;
        final outOfStockProducts = totalProducts - availableProducts;
        final totalFavorites = products.fold<int>(0, (sum, p) => sum + (p.favoritesCount ?? 0));
        
        // ترتيب المنتجات حسب المفضلة
        final sortedByFavorites = List<ProductEntity>.from(products)
          ..sort((a, b) => (b.favoritesCount ?? 0).compareTo(a.favoritesCount ?? 0));
        
        // أحدث المنتجات
        final sortedByDate = List<ProductEntity>.from(products)
          ..sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
        
        // إحصائيات التصنيفات
        final categoryStats = <String, int>{};
        for (final product in products) {
          categoryStats[product.categoryId] = (categoryStats[product.categoryId] ?? 0) + 1;
        }
        
        final stats = AdminDashboardStatsEntity(
          totalProducts: totalProducts,
          availableProducts: availableProducts,
          outOfStockProducts: outOfStockProducts,
          totalFavorites: totalFavorites,
          totalRevenue: 0.0, // سيتم حسابها من الطلبات لاحقاً
          totalOrders: 0, // سيتم حسابها من الطلبات لاحقاً
          topFavoriteProducts: sortedByFavorites.take(5).toList(),
          recentProducts: sortedByDate.take(5).toList(),
          categoryStats: categoryStats,
        );
        
        return Right(stats);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
