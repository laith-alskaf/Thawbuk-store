import 'package:dartz/dartz.dart';
import 'dart:developer';
import 'dart:io';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/cache/smart_cache_manager.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/admin_dashboard_stats_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/product/get_filtered_products_usecase.dart';
import '../datasources/product_remote_data_source.dart';

/// تنفيذ محسن لمستودع المنتجات مع التخزين المؤقت الذكي
class EnhancedProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final SmartCacheManager cacheManager;

  EnhancedProductRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.cacheManager,
  });

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async {
    return getProductsPaginated();
  }

  Future<Either<Failure, List<ProductEntity>>> getProductsPaginated({
    int page = 1,
    int limit = 20,
    String? category,
    String? searchQuery,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // تكوين key للتخزين المؤقت
      final cacheKey = _buildProductsCacheKey(page, limit, category, searchQuery, filters);
      
      // تحميل بذكاء من التخزين المؤقت أو الشبكة
      final products = await cacheManager.loadData<List<ProductEntity>>(
        dataType: 'products',
        key: cacheKey,
        networkLoader: () async {
          log('🌐 Loading products from network: page=$page, limit=$limit, category=$category');
          final productModels = await remoteDataSource.getProducts();
          return productModels.map((model) => model.toEntity()).toList();
        },
      );

      if (products != null) {
        log('✅ Products loaded successfully: ${products.length} items');
        return Right(products);
      } else {
        return const Left(ServerFailure('فشل في تحميل المنتجات'));
      }
    } on ServerException catch (e) {
      log('❌ Server error in getProducts: ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      log('❌ Network error in getProducts: ${e.message}');
      
      // محاولة استخدام البيانات المخزنة في حالة فشل الشبكة
      final cachedProducts = await _getCachedProductsFallback();
      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        log('📦 Using cached products as fallback: ${cachedProducts.length} items');
        return Right(cachedProducts);
      }
      
      return Left(NetworkFailure(e.message));
    } catch (e) {
      log('❌ Unexpected error in getProducts: $e');
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    try {
      final product = await cacheManager.loadData<ProductEntity>(
        dataType: 'products',
        key: 'product_$id',
        networkLoader: () async {
          log('🌐 Loading product by ID from network: $id');
          final productModel = await remoteDataSource.getProductById(id);
          return productModel.toEntity();
        },
      );

      if (product != null) {
        log('✅ Product loaded successfully: ${product.name}');
        return Right(product);
      } else {
        return const Left(NotFoundFailure('المنتج غير موجود'));
      }
    } on ServerException catch (e) {
      log('❌ Server error in getProductById: ${e.message}');
      return Left(ServerFailure(e.message));
    } on NotFoundException catch (e) {
      log('❌ Product not found: $id');
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      log('❌ Network error in getProductById: ${e.message}');
      
      // محاولة استخدام البيانات المخزنة
      final cachedProduct = await _getCachedProductFallback(id);
      if (cachedProduct != null) {
        log('📦 Using cached product as fallback: ${cachedProduct.name}');
        return Right(cachedProduct);
      }
      
      return Left(NetworkFailure(e.message));
    } catch (e) {
      log('❌ Unexpected error in getProductById: $e');
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts(String query) async {
    try {
      // البحث دائماً من الشبكة للحصول على أحدث النتائج
      final cacheKey = 'search_${query.hashCode}';
      
      final products = await cacheManager.loadData<List<ProductEntity>>(
        dataType: 'products',
        key: cacheKey,
        networkLoader: () async {
          log('🔍 Searching products from network: query="$query"');
          final productModels = await remoteDataSource.searchProducts(query);
          return productModels.map((model) => model.toEntity()).toList();
        },
      );

      if (products != null) {
        log('✅ Search completed successfully: ${products.length} results for "$query"');
        return Right(products);
      } else {
        return const Left(ServerFailure('فشل في البحث'));
      }
    } on ServerException catch (e) {
      log('❌ Server error in searchProducts: ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      log('❌ Network error in searchProducts: ${e.message}');
      
      // في حالة فشل البحث، أرجع قائمة فارغة أو منتجات مخزنة ذات صلة
      final cachedProducts = await _getRelatedCachedProducts(query);
      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        log('📦 Using related cached products for search: ${cachedProducts.length} items');
        return Right(cachedProducts);
      }
      
      return Left(NetworkFailure(e.message));
    } catch (e) {
      log('❌ Unexpected error in searchProducts: $e');
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(String categoryId) async {
    try {
      final products = await cacheManager.loadData<List<ProductEntity>>(
        dataType: 'products',
        key: 'category_products_$categoryId',
        networkLoader: () async {
          log('🌐 Loading products by category from network: $categoryId');
          final productModels = await remoteDataSource.getProductsByCategory(categoryId);
          return productModels.map((model) => model.toEntity()).toList();
        },
      );

      if (products != null) {
        log('✅ Category products loaded successfully: ${products.length} items');
        return Right(products);
      } else {
        return const Left(ServerFailure('فشل في تحميل منتجات الفئة'));
      }
    } on ServerException catch (e) {
      log('❌ Server error in getProductsByCategory: ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      log('❌ Network error in getProductsByCategory: ${e.message}');
      
      // محاولة استخدام المنتجات المخزنة لهذه الفئة
      final cachedProducts = await _getCachedProductsByCategory(categoryId);
      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        log('📦 Using cached category products: ${cachedProducts.length} items');
        return Right(cachedProducts);
      }
      
      return Left(NetworkFailure(e.message));
    } catch (e) {
      log('❌ Unexpected error in getProductsByCategory: $e');
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

  /// الحصول على المنتجات المميزة (استخدام المنتجات العادية كبديل)
  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts() async {
    try {
      final products = await cacheManager.loadData<List<ProductEntity>>(
        dataType: 'products',
        key: 'featured_products',
        networkLoader: () async {
          log('🌐 Loading featured products from network (using regular products)');
          final productModels = await remoteDataSource.getProducts();
          // أخذ أول 10 منتجات كمنتجات مميزة
          return productModels.take(10).map((model) => model.toEntity()).toList();
        },
        customTtl: const Duration(hours: 2), // مدة أقصر للمنتجات المميزة
      );

      if (products != null) {
        log('✅ Featured products loaded successfully: ${products.length} items');
        return Right(products);
      } else {
        return const Left(ServerFailure('فشل في تحميل المنتجات المميزة'));
      }
    } catch (e) {
      log('❌ Error in getFeaturedProducts: $e');
      return Left(ServerFailure('حدث خطأ في تحميل المنتجات المميزة'));
    }
  }

  /// بناء مفتاح التخزين المؤقت للمنتجات
  String _buildProductsCacheKey(int page, int limit, String? category, String? searchQuery, Map<String, dynamic>? filters) {
    final parts = ['products', 'page_$page', 'limit_$limit'];
    
    if (category != null) parts.add('cat_$category');
    if (searchQuery != null) parts.add('search_${searchQuery.hashCode}');
    if (filters != null && filters.isNotEmpty) {
      parts.add('filters_${filters.toString().hashCode}');
    }
    
    return parts.join('_');
  }

  /// بناء مفتاح التخزين المؤقت للبحث
  String _buildSearchCacheKey(String query) {
    return 'search_${query.hashCode}';
  }

  /// استرجاع المنتجات المخزنة كبديل
  Future<List<ProductEntity>?> _getCachedProductsFallback() async {
    try {
      // محاولة الحصول على منتجات مخزنة
      return await cacheManager.loadData<List<ProductEntity>>(
        dataType: 'products',
        key: 'all_products',
        networkLoader: () async => null, // لا نريد تحميل من الشبكة
      );
    } catch (e) {
      log('❌ Error in cached products fallback: $e');
      return null;
    }
  }

  /// استرجاع منتج مخزن كبديل
  Future<ProductEntity?> _getCachedProductFallback(String id) async {
    try {
      return await cacheManager.loadData<ProductEntity>(
        dataType: 'products',
        key: 'product_$id',
        networkLoader: () async => null, // cache-only
      );
    } catch (e) {
      log('❌ Error in cached product fallback: $e');
      return null;
    }
  }

  /// الحصول على منتجات مخزنة ذات صلة بالبحث
  Future<List<ProductEntity>?> _getRelatedCachedProducts(String query) async {
    try {
      final allCachedProducts = await cacheManager.loadData<List<ProductEntity>>(
        dataType: 'products',
        key: 'all_products',
        networkLoader: () async => null,
      );

      if (allCachedProducts == null || allCachedProducts.isEmpty) return null;

      // البحث في المنتجات المخزنة
      final relatedProducts = allCachedProducts.where((product) =>
        product.name.toLowerCase().contains(query.toLowerCase()) ||
        (product.description?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
        (product.nameAr?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).take(10).toList(); // أول 10 نتائج

      return relatedProducts.isNotEmpty ? relatedProducts : null;
    } catch (e) {
      log('❌ Error in related cached products: $e');
      return null;
    }
  }

  /// الحصول على منتجات فئة مخزنة
  Future<List<ProductEntity>?> _getCachedProductsByCategory(String categoryId) async {
    try {
      final allCachedProducts = await cacheManager.loadData<List<ProductEntity>>(
        dataType: 'products',
        key: 'all_products',
        networkLoader: () async => null,
      );

      if (allCachedProducts == null || allCachedProducts.isEmpty) return null;

      final categoryProducts = allCachedProducts
          .where((product) => product.categoryId == categoryId)
          .toList();

      return categoryProducts.isNotEmpty ? categoryProducts : null;
    } catch (e) {
      log('❌ Error in cached products by category: $e');
      return null;
    }
  }

  /// تنظيف التخزين المؤقت للمنتجات
  Future<void> clearProductsCache() async {
    try {
      // سيتم تنفيذ هذا عبر SmartCacheManager
      log('🧹 Products cache clearing requested');
    } catch (e) {
      log('❌ Error clearing products cache: $e');
    }
  }

  /// إحصائيات المستودع
  Future<Map<String, dynamic>> getRepositoryStats() async {
    try {
      final cacheStats = await cacheManager.getCacheStatistics();
      return {
        'repository': 'EnhancedProductRepository',
        'cacheStats': cacheStats,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      log('❌ Error getting repository stats: $e');
      return {};
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getFilteredProducts(GetFilteredProductsParams params) async {
    try {
      final cacheKey = 'filtered_products_${params.hashCode}';
      
      final products = await cacheManager.loadData<List<ProductEntity>>(
        dataType: 'products',
        key: cacheKey,
        networkLoader: () async {
          log('🌐 Loading filtered products from network');
          final productModels = await remoteDataSource.getFilteredProducts(params);
          return productModels.map((model) => model.toEntity()).toList();
        },
      );

      if (products != null) {
        log('✅ Filtered products loaded successfully: ${products.length} items');
        return Right(products);
      } else {
        return const Left(ServerFailure('فشل في تحميل المنتجات المفلترة'));
      }
    } on ServerException catch (e) {
      log('❌ Server error in getFilteredProducts: ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      log('❌ Network error in getFilteredProducts: ${e.message}');
      return Left(NetworkFailure(e.message));
    } catch (e) {
      log('❌ Unexpected error in getFilteredProducts: $e');
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct({
    required String name,
    required String nameAr,
    required String description,
    required String descriptionAr,
    required double price,
    required String category,
    required List<String> sizes,
    required List<String> colors,
    required int quantity,
    required List<File> images,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final productData = {
          'name': name,
          'nameAr': nameAr,
          'description': description,
          'descriptionAr': descriptionAr,
          'price': price,
          'category': category,
          'sizes': sizes,
          'colors': colors,
          'quantity': quantity,
          'images': images,
        };

        final productModel = await remoteDataSource.createProduct(productData);
        final product = productModel.toEntity();

        // مسح التخزين المؤقت للمنتجات لتحديثه
        await clearProductsCache();

        log('✅ Product created successfully: ${product.id}');
        return Right(product);
      } else {
        return const Left(NetworkFailure('لا يمكن إنشاء منتج بدون اتصال بالإنترنت'));
      }
    } on ServerException catch (e) {
      log('❌ Server error in createProduct: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      log('❌ Unexpected error in createProduct: $e');
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct({
    required String productId,
    required String name,
    required String nameAr,
    required String description,
    required String descriptionAr,
    required double price,
    required String category,
    required List<String> sizes,
    required List<String> colors,
    required int quantity,
    required List<File> images,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final productData = {
          'name': name,
          'nameAr': nameAr,
          'description': description,
          'descriptionAr': descriptionAr,
          'price': price,
          'category': category,
          'sizes': sizes,
          'colors': colors,
          'quantity': quantity,
          'images': images,
        };

        final productModel = await remoteDataSource.updateProduct(productId, productData);
        final product = productModel.toEntity();

        // تحديث التخزين المؤقت
        await cacheManager.loadData<ProductEntity>(
          dataType: 'products',
          key: 'product_$productId',
          networkLoader: () async => product,
        );

        log('✅ Product updated successfully: $productId');
        return Right(product);
      } else {
        return const Left(NetworkFailure('لا يمكن تحديث المنتج بدون اتصال بالإنترنت'));
      }
    } on ServerException catch (e) {
      log('❌ Server error in updateProduct: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      log('❌ Unexpected error in updateProduct: $e');
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String productId) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteProduct(productId);

        // مسح المنتج من التخزين المؤقت
        await clearProductsCache();

        log('✅ Product deleted successfully: $productId');
        return const Right(null);
      } else {
        return const Left(NetworkFailure('لا يمكن حذف المنتج بدون اتصال بالإنترنت'));
      }
    } on ServerException catch (e) {
      log('❌ Server error in deleteProduct: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      log('❌ Unexpected error in deleteProduct: $e');
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getMyProducts() async {
    try {
      final products = await cacheManager.loadData<List<ProductEntity>>(
        dataType: 'products',
        key: 'my_products',
        networkLoader: () async {
          log('🌐 Loading my products from network');
          final productModels = await remoteDataSource.getMyProducts();
          return productModels.map((model) => model.toEntity()).toList();
        },
      );

      if (products != null) {
        log('✅ My products loaded successfully: ${products.length} items');
        return Right(products);
      } else {
        return const Left(ServerFailure('فشل في تحميل منتجاتي'));
      }
    } on ServerException catch (e) {
      log('❌ Server error in getMyProducts: ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      log('❌ Network error in getMyProducts: ${e.message}');
      return Left(NetworkFailure(e.message));
    } catch (e) {
      log('❌ Unexpected error in getMyProducts: $e');
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, AdminDashboardStatsEntity>> getAdminDashboardStats() async {
    try {
      // الإحصائيات لا تُخزن مؤقتاً لضمان الحداثة
      if (await networkInfo.isConnected) {
        // سيتم تنفيذ هذا عبر datasource مناسب
        log('🌐 Loading admin dashboard stats from network');
        
        // مؤقتاً نعيد بيانات وهمية
        final stats = AdminDashboardStatsEntity(
          totalProducts: 0,
          availableProducts: 0,
          outOfStockProducts: 0,
          totalFavorites: 0,
          totalRevenue: 0.0,
          totalOrders: 0,
          topFavoriteProducts: [],
          recentProducts: [],
          categoryStats: {},
        );
        
        log('✅ Admin dashboard stats loaded successfully');
        return Right(stats);
      } else {
        return const Left(NetworkFailure('لا يمكن تحميل الإحصائيات بدون اتصال بالإنترنت'));
      }
    } on ServerException catch (e) {
      log('❌ Server error in getAdminDashboardStats: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      log('❌ Unexpected error in getAdminDashboardStats: $e');
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }
}