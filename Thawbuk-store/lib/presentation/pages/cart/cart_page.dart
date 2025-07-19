import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/cart/cart_bloc.dart';
import '../../widgets/shared/custom_button.dart';
import '../../widgets/shared/custom_card.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/shared/error_widget.dart';
import '../../../domain/entities/cart_entity.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(GetCartEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة التسوق'),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && state.cart.items.isNotEmpty) {
                return TextButton(
                  onPressed: _showClearCartDialog,
                  child: const Text(
                    'مسح الكل',
                    style: TextStyle(color: AppColors.white),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is CartCleared) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم مسح السلة بنجاح'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CartLoading) {
            return const LoadingWidget(message: 'جاري تحميل السلة...');
          }
          
          if (state is CartError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<CartBloc>().add(GetCartEvent());
              },
            );
          }
          
          if (state is CartLoaded) {
            if (state.cart.isEmpty) {
              return _buildEmptyCart();
            }
            
            return _buildCartContent(state.cart);
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: AppColors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              'السلة فارغة',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'ابدأ التسوق وأضف المنتجات التي تعجبك',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'تصفح المنتجات',
              onPressed: () => context.go('/products'),
              icon: const Icon(Icons.shopping_bag),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(CartEntity cart) {
    return Column(
      children: [
        // قائمة المنتجات
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return _buildCartItem(item);
            },
          ),
        ),
        
        // ملخص الطلب
        _buildOrderSummary(cart),
      ],
    );
  }

  Widget _buildCartItem(CartItemEntity item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: CustomCard(
        child: Row(
          children: [
            // صورة المنتج
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: item.product.mainImage.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.product.mainImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: AppColors.grey,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.checkroom,
                    size: 40,
                    color: AppColors.grey,
                  ),
            ),
            
            const SizedBox(width: 16),
            
            // معلومات المنتج
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
                  
                  // الخيارات المحددة
                  if (item.selectedSize != null || item.selectedColor != null)
                    Text(
                      [
                        if (item.selectedSize != null) 'الحجم: ${item.selectedSize}',
                        if (item.selectedColor != null) 'اللون: ${item.selectedColor}',
                      ].join(' • '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // السعر
                      Text(
                        '${item.totalPrice.toStringAsFixed(0)} ل.س',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      // تحكم بالكمية
                      _buildQuantityControls(item),
                    ],
                  ),
                ],
              ),
            ),
            
            // زر الحذف
            IconButton(
              onPressed: () => _removeFromCart(item),
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControls(CartItemEntity item) {
    return Row(
      children: [
        IconButton(
          onPressed: item.quantity > 1 
            ? () => _updateQuantity(item, item.quantity - 1)
            : null,
          icon: const Icon(Icons.remove, size: 18),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.lightGrey,
            minimumSize: const Size(32, 32),
          ),
        ),
        
        Container(
          width: 40,
          alignment: Alignment.center,
          child: Text(
            item.quantity.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        IconButton(
          onPressed: item.quantity < item.product.quantity
            ? () => _updateQuantity(item, item.quantity + 1)
            : null,
          icon: const Icon(Icons.add, size: 18),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.lightGrey,
            minimumSize: const Size(32, 32),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(CartEntity cart) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ملخص التكاليف
          CustomCard(
            backgroundColor: AppColors.lightGrey.withOpacity(0.5),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'عدد المنتجات',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${cart.itemsCount}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'المجموع الفرعي',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${cart.totalAmount.toStringAsFixed(0)} ل.س',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'التوصيل',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'مجاني',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                
                const Divider(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'المجموع الكلي',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${cart.totalAmount.toStringAsFixed(0)} ل.س',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // زر إتمام الطلب
          CustomButton(
            text: 'إتمام الطلب',
            isFullWidth: true,
            onPressed: () => _proceedToCheckout(cart),
            icon: const Icon(Icons.payment),
          ),
        ],
      ),
    );
  }

  void _updateQuantity(CartItemEntity item, int newQuantity) {
    context.read<CartBloc>().add(
      UpdateCartItemEvent(
        itemId: item.id,
        quantity: newQuantity,
      ),
    );
  }

  void _removeFromCart(CartItemEntity item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('إزالة من السلة'),
          content: Text('هل تريد إزالة "${item.product.displayName}" من السلة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<CartBloc>().add(
                  RemoveFromCartEvent(item.productId),
                );
              },
              child: const Text(
                'إزالة',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('مسح السلة'),
          content: const Text('هل تريد مسح جميع المنتجات من السلة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<CartBloc>().add(ClearCartEvent());
              },
              child: const Text(
                'مسح الكل',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _proceedToCheckout(CartEntity cart) {
    // TODO: إضافة صفحة الدفع
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة عملية الدفع قريباً'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}