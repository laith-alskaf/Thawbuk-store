import 'package:equatable/equatable.dart';
import 'product_entity.dart';

class Wishlist extends Equatable {
  final String id;
  final String userId;
  final List<WishlistItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Wishlist({
    required this.id,
    required this.userId,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  Wishlist copyWith({
    String? id,
    String? userId,
    List<WishlistItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wishlist(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // الحصول على عدد العناصر
  int get itemsCount => items.length;

  // التحقق من وجود منتج في المفضلة
  bool containsProduct(String productId) {
    return items.any((item) => item.productId == productId);
  }

  // الحصول على عنصر من المفضلة
  WishlistItem? getItem(String productId) {
    try {
      return items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  // التحقق من كون المفضلة فارغة
  bool get isEmpty => items.isEmpty;

  // التحقق من كون المفضلة غير فارغة
  bool get isNotEmpty => items.isNotEmpty;

  // الحصول على قائمة المنتجات
  List<ProductEntity> get products => items
      .where((item) => item.product != null)
      .map((item) => item.product!)
      .toList();

  @override
  List<Object?> get props => [id, userId, items, createdAt, updatedAt];
}

class WishlistItem extends Equatable {
  final String id;
  final String productId;
  final ProductEntity? product; // قد يكون null في بعض الحالات
  final DateTime addedAt;

  const WishlistItem({
    required this.id,
    required this.productId,
    required this.addedAt,
    this.product,
  });

  WishlistItem copyWith({
    String? id,
    String? productId,
    ProductEntity? product,
    DateTime? addedAt,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  // الحصول على اسم المنتج
  String get productName => product?.getLocalizedName() ?? 'منتج غير معروف';

  // الحصول على صورة المنتج
  String? get productImage => product?.mainImage;

  // الحصول على سعر المنتج
  String get productPrice => product?.formattedPrice ?? '0.00 ر.س';

  // التحقق من توفر المنتج
  bool get isProductAvailable => product?.isAvailable ?? false;

  @override
  List<Object?> get props => [id, productId, product, addedAt];
}

// طلب إضافة منتج للمفضلة
class AddToWishlistRequest extends Equatable {
  final String productId;

  const AddToWishlistRequest({required this.productId});

  @override
  List<Object?> get props => [productId];
}

// طلب حذف منتج من المفضلة
class RemoveFromWishlistRequest extends Equatable {
  final String productId;

  const RemoveFromWishlistRequest({required this.productId});

  @override
  List<Object?> get props => [productId];
}

// طلب تبديل حالة المنتج في المفضلة
class ToggleWishlistRequest extends Equatable {
  final String productId;

  const ToggleWishlistRequest({required this.productId});

  @override
  List<Object?> get props => [productId];
}