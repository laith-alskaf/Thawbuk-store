import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/cart/cart_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/cart_entity.dart';
import '../../widgets/shared/custom_button.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/shared/error_widget.dart';
import '../../widgets/shared/unified_app_bar.dart';
import '../../widgets/shared/guest_access_widget.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    // تحميل السلة فقط للمستخدمين المسجلين
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CartBloc>().add(GetCartEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UnifiedAppBar(
        title: 'سلة التسوق',
        customActions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && 
                  state.cart.items.isNotEmpty && 
                  context.read<AuthBloc>().state is AuthAuthenticated) {
                return TextButton.icon(
                  onPressed: () => _showClearCartDialog(),
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
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          // إذا كان المستخدم زائر، اعرض رسالة تسجيل الدخول
          if (authState is AuthGuest) {
            return GuestAccessWidget.cart();
          }
          
          return BlocListener<CartBloc, CartState>(
            listener: (context, state) {
          if (state is CartItemAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إضافة المنتج للسلة'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is CartItemRemoved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم حذف المنتج من السلة'),
                backgroundColor: AppColors.warning,
              ),
            );
          } else if (state is CartCleared) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم مسح السلة بنجاح'),
                backgroundColor: AppColors.info,
              ),
            );
          }
        },
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state is CartLoading) {
              return const ListLoadingWidget();
            } else if (state is CartError) {
              return CustomErrorWidget(
                message: state.message,
                onRetry: () {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthAuthenticated) {
                    context.read<CartBloc>().add(GetCartEvent());
                  }
                },
              );
            } else if (state is CartLoaded) {
              return _buildCartContent(state.cart);
            } else if (state is CartCleared) {
              return const EmptyWidget(
                title: 'سلة التسوق فارغة',
                message: 'لم تقم بإضافة أي منتجات بعد',
                icon: Icons.shopping_cart_outlined,
              );
            }
            
            return const EmptyWidget(
              title: 'سلة التسوق فارغة',
              message: 'لم تقم بإضافة أي منتجات بعد',
              icon: Icons.shopping_cart_outlined,
            );
          },
        ),
      );
    },
  ),
    bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoaded && state.cart.items.isNotEmpty) {
            return _buildCheckoutBar(state.cart);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCartContent(CartEntity cart) {
    if (cart.isEmpty) {
      return Column(
        children: [
          const Expanded(
            child: EmptyWidget(
              title: 'سلة التسوق فارغة',
              message: 'ابدأ التسوق لإضافة منتجات',
              icon: Icons.shopping_cart_outlined,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomButton(
              text: 'تصفح المنتجات',
              onPressed: () => context.push('/products'),
              icon: Icons.store,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        // Cart Summary
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إجمالي المنتجات',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  Text(
                    '${cart.itemsCount} منتج',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'المجموع',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  Text(
                    '${cart.totalAmount.toStringAsFixed(2)} ريال',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Cart Items
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cart.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return _buildCartItem(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItemEntity item) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  image: item.product.images.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(item.product.images.first),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: item.product.images.isEmpty
                    ? const Icon(Icons.image, color: AppColors.grey)
                    : null,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.displayName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  if (item.selectedSize != null || item.selectedColor != null)
                    Row(
                      children: [
                        if (item.selectedSize != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'الحجم: ${item.selectedSize}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        if (item.selectedSize != null && item.selectedColor != null)
                          const SizedBox(width: 8),
                        if (item.selectedColor != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'اللون: ${item.selectedColor}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.unitPrice.toStringAsFixed(2)} ريال',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      Row(
                        children: [
                          Text(
                            'المجموع: ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${item.totalPrice.toStringAsFixed(2)} ريال',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Quantity Controls
            Column(
              children: [
                // Remove Button
                IconButton(
                  onPressed: () => _removeItem(item.productId),
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.error,
                  iconSize: 20,
                ),
                
                // Quantity Controls
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightGrey),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: item.quantity > 1 
                            ? () => _updateQuantity(item.productId, item.quantity - 1)
                            : null,
                        icon: const Icon(Icons.remove),
                        iconSize: 16,
                      ),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: const BoxDecoration(
                          color: AppColors.lightGrey,
                        ),
                        child: Text(
                          '${item.quantity}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      IconButton(
                        onPressed: () => _updateQuantity(item.productId, item.quantity + 1),
                        icon: const Icon(Icons.add),
                        iconSize: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutBar(CartEntity cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المجموع الإجمالي',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${cart.totalAmount.toStringAsFixed(2)} ريال',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  return CustomButton(
                    text: 'إتمام الطلب',
                    onPressed: authState is AuthAuthenticated
                        ? () => _proceedToCheckout(cart)
                        : () => context.push('/login'),
                    icon: Icons.shopping_bag_outlined,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateQuantity(String productId, int newQuantity) {
    context.read<CartBloc>().add(UpdateCartItemEvent(
      productId: productId,
      quantity: newQuantity,
    ));
  }

  void _removeItem(String productId) {
    context.read<CartBloc>().add(RemoveFromCartEvent(productId));
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح السلة'),
        content: const Text('هل أنت متأكد من مسح جميع المنتجات من السلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CartBloc>().add(ClearCartEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout(CartEntity cart) {
    // Navigate to checkout/order page
    context.push('/app/checkout');
  }


}