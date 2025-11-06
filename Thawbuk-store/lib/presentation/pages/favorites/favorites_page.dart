import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/guards/auth_guard.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/wishlist/wishlist_bloc.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../widgets/shared/unified_app_bar.dart';
import '../../widgets/shared/guest_access_widget.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/shared/error_widget.dart';
import '../../widgets/products/product_card.dart';
import '../../../core/navigation/navigation_helper.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    // تحميل المفضلة فقط للمستخدمين المسجلين
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<WishlistBloc>().add(GetWishlistEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (!AuthGuard.isAuthenticated(context)) {
          return _buildGuestView(context);
        }

        return Scaffold(
          appBar: UnifiedAppBar(
            title: 'المفضلة',
            customActions: [
              BlocBuilder<WishlistBloc, WishlistState>(
                builder: (context, state) {
                  if (state is WishlistLoaded && 
                      state.wishlist.products.isNotEmpty) {
                    return TextButton.icon(
                      onPressed: () => _showClearWishlistDialog(),
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: const Text('مسح الكل'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          body: BlocListener<WishlistBloc, WishlistState>(
            listener: (context, state) {
              if (state is WishlistItemToggled) {
                final message = state.isAdded 
                    ? 'تم إضافة المنتج للمفضلة'
                    : 'تم حذف المنتج من المفضلة';
                NavigationHelper.showSuccessMessage(context, message);
              } else if (state is WishlistCleared) {
                NavigationHelper.showSuccessMessage(context, 'تم مسح المفضلة بنجاح');
              }
            },
            child: BlocBuilder<WishlistBloc, WishlistState>(
              builder: (context, state) {
                if (state is WishlistLoading) {
                  return const LoadingWidget(message: 'جاري تحميل المفضلة...');
                } else if (state is WishlistError) {
                  return CustomErrorWidget(
                    message: state.message,
                    onRetry: () {
                      context.read<WishlistBloc>().add(GetWishlistEvent());
                    },
                  );
                } else if (state is WishlistLoaded) {
                  return _buildWishlistContent(state.wishlist);
                } else if (state is WishlistCleared) {
                  return _buildEmptyWishlist();
                }
                
                return _buildEmptyWishlist();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildWishlistContent(wishlist) {
    if (wishlist.products.isEmpty) {
      return _buildEmptyWishlist();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<WishlistBloc>().add(GetWishlistEvent());
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: wishlist.products.length,
        itemBuilder: (context, index) {
          final product = wishlist.products[index];
          return ProductCard(
            product: product,
            onTap: () {
              context.push('/product/${product.id}');
            },
            onAddToCart: () {
              if (NavigationHelper.addToCart(context)) {
                context.read<CartBloc>().add(
                  AddToCartEvent(
                    productId: product.id,
                    quantity: 1,
                  ),
                );
                NavigationHelper.showSuccessMessage(context, 'تم إضافة المنتج للسلة');
              }
            },
            onToggleWishlist: () {
              context.read<WishlistBloc>().add(
                ToggleWishlistEvent(product.id),
              );
            },
            isWishlisted: true, // المنتج موجود في المفضلة
          );
        },
      ),
    );
  }

  Widget _buildEmptyWishlist() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: AppColors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'لا توجد منتجات مفضلة',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'ابدأ بإضافة منتجات إلى قائمة المفضلة',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Scaffold(
      appBar: const UnifiedAppBar(
        title: 'المفضلة',
      ),
      body: GuestAccessWidget.favorites(),
    );
  }

  void _showClearWishlistDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('مسح المفضلة'),
          content: const Text('هل أنت متأكد من أنك تريد مسح جميع المنتجات من المفضلة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<WishlistBloc>().add(ClearWishlistEvent());
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text('مسح'),
            ),
          ],
        );
      },
    );
  }
}