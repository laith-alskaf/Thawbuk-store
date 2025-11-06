import 'package:dartz/dartz.dart';
import 'dart:developer';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../core/network/network_info.dart';
import '../../core/cache/smart_cache_manager.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';

/// تنفيذ محسن لمستودع السلة مع التخزين المؤقت الذكي
class EnhancedCartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final SmartCacheManager cacheManager;

  EnhancedCartRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.cacheManager,
  });

  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    try {
      final cart = await cacheManager.loadData<CartEntity>(
        dataType: 'cart',
        key: 'user_cart',
        networkLoader: () async {
          log('🌐 Loading cart from network');
          final cartModel = await remoteDataSource.getCart();
          return cartModel.toEntity();
        },
      );

      if (cart != null) {
        log('✅ Cart loaded successfully: ${cart.items.length} items, total: ${cart.totalAmount}');
        return Right(cart);
      } else {
        // إنشاء سلة فارغة إذا لم توجد
        log('📭 No cart found, creating empty cart');
        return Right(CartEntity.empty());
      }
    } on ServerException catch (e) {
      log('❌ Server error in getCart: ${e.message}');
      
      // محاولة استخدام السلة المخزنة في حالة فشل الخادم
      final cachedCart = await _getCachedCartFallback();
      if (cachedCart != null) {
        log('📦 Using cached cart as fallback: ${cachedCart.items.length} items');
        return Right(cachedCart);
      }
      
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      log('❌ Network error in getCart: ${e.message}');
      
      // استخدام السلة المخزنة في الوضع غير المتصل
      final cachedCart = await _getCachedCartFallback();
      if (cachedCart != null) {
        log('📦 Using cached cart in offline mode: ${cachedCart.items.length} items');
        return Right(cachedCart);
      }
      
      return Left(NetworkFailure(e.message));
    } catch (e) {
      log('❌ Unexpected error in getCart: $e');
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> addToCart(String productId, int quantity, {String? size, String? color}) async {
    try {
      // إضافة للسلة في الشبكة أولاً
      if (await networkInfo.isConnected) {
        final cartData = {
          'productId': productId,
          'quantity': quantity,
          if (size != null) 'size': size,
          if (color != null) 'color': color,
        };

        final cartModel = await remoteDataSource.addToCart(cartData);
        final cart = cartModel.toEntity();

        // تحديث التخزين المؤقت
        await _updateCachedCart(cart);

        log('✅ Product added to cart successfully: $productId (qty: $quantity)');
        return Right(cart);
      } else {
        // الوضع غير المتصل - تحديث السلة المحلية
        log('📡 Adding to cart in offline mode: $productId');
        final updatedCart = await _addToCartOffline(productId, quantity, size, color);
        if (updatedCart != null) {
          return Right(updatedCart);
        } else {
          return const Left(NetworkFailure('لا يمكن إضافة المنتج للسلة في الوضع غير المتصل'));
        }
      }
    } on ServerException catch (e) {
      log('❌ Server error in addToCart: ${e.message}');
      
      // محاولة إضافة محلياً في حالة فشل الخادم
      final updatedCart = await _addToCartOffline(productId, quantity, size, color);
      if (updatedCart != null) {
        log('📦 Added to cart locally after server error');
        return Right(updatedCart);
      }
      
      return Left(ServerFailure(e.message));
    } catch (e) {
      log('❌ Unexpected error in addToCart: $e');
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> updateCartItem(String productId, int quantity) async {
    try {
      if (await networkInfo.isConnected) {
        final updateData = {
          'productId': productId,
          'quantity': quantity,
        };

        final cartModel = await remoteDataSource.updateCartItem(updateData);
        final cart = cartModel.toEntity();

        // تحديث التخزين المؤقت
        await _updateCachedCart(cart);

        log('✅ Cart item updated successfully: $productId (new qty: $quantity)');
        return Right(cart);
      } else {
        // الوضع غير المتصل - تحديث السلة المحلية
        log('📡 Updating cart item in offline mode: $productId');
        final updatedCart = await _updateCartItemOffline(productId, quantity);
        if (updatedCart != null) {
          return Right(updatedCart);
        } else {
          return const Left(NetworkFailure('لا يمكن تحديث السلة في الوضع غير المتصل'));
        }
      }
    } on ServerException catch (e) {
      log('❌ Server error in updateCartItem: ${e.message}');
      
      // محاولة تحديث محلياً
      final updatedCart = await _updateCartItemOffline(productId, quantity);
      if (updatedCart != null) {
        log('📦 Updated cart locally after server error');
        return Right(updatedCart);
      }
      
      return Left(ServerFailure(e.message));
    } catch (e) {
      log('❌ Unexpected error in updateCartItem: $e');
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> removeFromCart(String productId) async {
    try {
      if (await networkInfo.isConnected) {
        final cartModel = await remoteDataSource.removeFromCart(productId);
        final cart = cartModel.toEntity();

        // تحديث التخزين المؤقت
        await _updateCachedCart(cart);

        log('✅ Product removed from cart successfully: $productId');
        return Right(cart);
      } else {
        // الوضع غير المتصل - حذف من السلة المحلية
        log('📡 Removing from cart in offline mode: $productId');
        final updatedCart = await _removeFromCartOffline(productId);
        if (updatedCart != null) {
          return Right(updatedCart);
        } else {
          return const Left(NetworkFailure('لا يمكن حذف المنتج من السلة في الوضع غير المتصل'));
        }
      }
    } on ServerException catch (e) {
      log('❌ Server error in removeFromCart: ${e.message}');
      
      // محاولة حذف محلياً
      final updatedCart = await _removeFromCartOffline(productId);
      if (updatedCart != null) {
        log('📦 Removed from cart locally after server error');
        return Right(updatedCart);
      }
      
      return Left(ServerFailure(e.message));
    } catch (e) {
      log('❌ Unexpected error in removeFromCart: $e');
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.clearCart();
        
        // مسح التخزين المؤقت
        await _clearCachedCart();
        
        log('✅ Cart cleared successfully');
        return const Right(null);
      } else {
        // مسح السلة محلياً
        await _clearCachedCart();
        log('📡 Cart cleared locally (offline mode)');
        return const Right(null);
      }
    } on ServerException catch (e) {
      log('❌ Server error in clearCart: ${e.message}');
      
      // مسح محلياً حتى لو فشل الخادم
      await _clearCachedCart();
      log('📦 Cart cleared locally after server error');
      
      return Left(ServerFailure(e.message));
    } catch (e) {
      log('❌ Unexpected error in clearCart: $e');
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

  /// استرجاع السلة المخزنة كبديل
  Future<CartEntity?> _getCachedCartFallback() async {
    try {
      return await cacheManager.loadData<CartEntity>(
        dataType: 'cart',
        key: 'user_cart',
        networkLoader: () async => null, // cache-only
      );
    } catch (e) {
      log('❌ Error in cached cart fallback: $e');
      return null;
    }
  }

  /// تحديث السلة المخزنة
  Future<void> _updateCachedCart(CartEntity cart) async {
    try {
      await cacheManager.loadData<CartEntity>(
        dataType: 'cart',
        key: 'user_cart',
        networkLoader: () async => cart,
      );
    } catch (e) {
      log('❌ Error updating cached cart: $e');
    }
  }

  /// مسح السلة المخزنة
  Future<void> _clearCachedCart() async {
    try {
      final emptyCart = CartEntity.empty();
      await _updateCachedCart(emptyCart);
    } catch (e) {
      log('❌ Error clearing cached cart: $e');
    }
  }

  /// إضافة للسلة في الوضع غير المتصل
  Future<CartEntity?> _addToCartOffline(String productId, int quantity, String? size, String? color) async {
    try {
      final currentCart = await _getCachedCartFallback() ?? CartEntity.empty();
      
      // البحث عن المنتج في السلة
      final existingItemIndex = currentCart.items.indexWhere(
        (item) => item.productId == productId && 
                  item.selectedSize == size && 
                  item.selectedColor == color
      );

      List<CartItemEntity> updatedItems = List.from(currentCart.items);

      if (existingItemIndex >= 0) {
        // تحديث الكمية للمنتج الموجود
        final existingItem = updatedItems[existingItemIndex];
        updatedItems[existingItemIndex] = CartItemEntity(
          id: existingItem.id,
          productId: existingItem.productId,
          product: existingItem.product,
          quantity: existingItem.quantity + quantity,
          selectedSize: existingItem.selectedSize,
          selectedColor: existingItem.selectedColor,
          unitPrice: existingItem.unitPrice,
          totalPrice: existingItem.unitPrice * (existingItem.quantity + quantity),
        );
      } else {
        // إضافة منتج جديد (يحتاج لتحميل بيانات المنتج من التخزين المؤقت)
        final product = await _getProductFromCache(productId);
        if (product != null) {
          final newItem = CartItemEntity(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            productId: productId,
            product: product,
            quantity: quantity,
            selectedSize: size,
            selectedColor: color,
            unitPrice: product.price,
            totalPrice: product.price * quantity,
          );
          updatedItems.add(newItem);
        } else {
          log('❌ Product not found in cache for offline add: $productId');
          return null;
        }
      }

      // حساب المجموع الجديد
      final totalAmount = updatedItems.fold<double>(
        0.0, 
        (sum, item) => sum + item.totalPrice
      );

      final updatedCart = CartEntity(
        id: currentCart.id,
        userId: currentCart.userId,
        items: updatedItems,
        totalAmount: totalAmount,
        createdAt: currentCart.createdAt,
        updatedAt: DateTime.now(),
      );

      await _updateCachedCart(updatedCart);
      return updatedCart;
    } catch (e) {
      log('❌ Error in offline add to cart: $e');
      return null;
    }
  }

  /// تحديث عنصر السلة في الوضع غير المتصل
  Future<CartEntity?> _updateCartItemOffline(String productId, int quantity) async {
    try {
      final currentCart = await _getCachedCartFallback();
      if (currentCart == null) return null;

      final itemIndex = currentCart.items.indexWhere((item) => item.productId == productId);
      if (itemIndex < 0) return null;

      List<CartItemEntity> updatedItems = List.from(currentCart.items);

      if (quantity <= 0) {
        // حذف العنصر إذا كانت الكمية صفر أو أقل
        updatedItems.removeAt(itemIndex);
      } else {
        // تحديث الكمية
        final existingItem = updatedItems[itemIndex];
        updatedItems[itemIndex] = CartItemEntity(
          id: existingItem.id,
          productId: existingItem.productId,
          product: existingItem.product,
          quantity: quantity,
          selectedSize: existingItem.selectedSize,
          selectedColor: existingItem.selectedColor,
          unitPrice: existingItem.unitPrice,
          totalPrice: existingItem.unitPrice * quantity,
        );
      }

      // حساب المجموع الجديد
      final totalAmount = updatedItems.fold<double>(
        0.0, 
        (sum, item) => sum + item.totalPrice
      );

      final updatedCart = CartEntity(
        id: currentCart.id,
        userId: currentCart.userId,
        items: updatedItems,
        totalAmount: totalAmount,
        createdAt: currentCart.createdAt,
        updatedAt: DateTime.now(),
      );

      await _updateCachedCart(updatedCart);
      return updatedCart;
    } catch (e) {
      log('❌ Error in offline cart item update: $e');
      return null;
    }
  }

  /// حذف من السلة في الوضع غير المتصل
  Future<CartEntity?> _removeFromCartOffline(String productId) async {
    try {
      final currentCart = await _getCachedCartFallback();
      if (currentCart == null) return null;

      final updatedItems = currentCart.items
          .where((item) => item.productId != productId)
          .toList();

      // حساب المجموع الجديد
      final totalAmount = updatedItems.fold<double>(
        0.0, 
        (sum, item) => sum + item.totalPrice
      );

      final updatedCart = CartEntity(
        id: currentCart.id,
        userId: currentCart.userId,
        items: updatedItems,
        totalAmount: totalAmount,
        createdAt: currentCart.createdAt,
        updatedAt: DateTime.now(),
      );

      await _updateCachedCart(updatedCart);
      return updatedCart;
    } catch (e) {
      log('❌ Error in offline remove from cart: $e');
      return null;
    }
  }

  /// الحصول على المنتج من التخزين المؤقت
  Future<ProductEntity?> _getProductFromCache(String productId) async {
    try {
      return await cacheManager.loadData<ProductEntity>(
        dataType: 'products',
        key: 'product_$productId',
        networkLoader: () async => null, // cache-only
      );
    } catch (e) {
      log('❌ Error getting product from cache: $e');
      return null;
    }
  }

  /// مزامنة السلة المحلية مع الخادم
  Future<Either<Failure, CartEntity>> syncCartWithServer() async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت للمزامنة'));
      }

      // الحصول على السلة الحالية من الخادم
      final serverCart = await remoteDataSource.getCart();
      final localCart = await _getCachedCartFallback();

      if (localCart != null && localCart.items.isNotEmpty) {
        // إذا كانت هناك تغييرات محلية، قم بمزامنتها
        log('🔄 Syncing local cart changes with server');
        
        // هذا يحتاج لمنطق مزامنة أكثر تعقيداً حسب متطلبات التطبيق
        // يمكن استخدام timestamps للمقارنة
        
        return Right(serverCart.toEntity());
      } else {
        // استخدم السلة من الخادم
        await _updateCachedCart(serverCart.toEntity());
        return Right(serverCart.toEntity());
      }
    } catch (e) {
      log('❌ Error syncing cart with server: $e');
      return Left(ServerFailure('فشل في مزامنة السلة'));
    }
  }
}