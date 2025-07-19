import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/product/product_bloc.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../widgets/shared/custom_button.dart';
import '../../widgets/shared/custom_card.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/shared/error_widget.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _selectedImageIndex = 0;
  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(GetProductByIdEvent(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المنتج'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareProduct,
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: _toggleWishlist,
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const LoadingWidget(message: 'جاري تحميل المنتج...');
          }
          
          if (state is ProductError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<ProductBloc>().add(
                  GetProductByIdEvent(widget.productId),
                );
              },
            );
          }
          
          if (state is ProductLoaded) {
            return _buildProductDetails(state.product);
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProductDetails(ProductEntity product) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // معرض الصور
                _buildImageGallery(product),
                
                // معلومات المنتج
                _buildProductInfo(product),
                
                // خيارات المنتج
                _buildProductOptions(product),
                
                // الوصف
                _buildDescription(product),
              ],
            ),
          ),
        ),
        
        // شريط الإضافة للسلة
        _buildBottomBar(product),
      ],
    );
  }

  Widget _buildImageGallery(ProductEntity product) {
    final images = product.images.isNotEmpty ? product.images : [''];
    
    return Container(
      height: 300,
      child: Column(
        children: [
          // الصورة الرئيسية
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: images[_selectedImageIndex].isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    child: Image.network(
                      images[_selectedImageIndex],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 80,
                            color: AppColors.grey,
                          ),
                        );
                      },
                    ),
                  )
                : const Center(
                    child: Icon(
                      Icons.checkroom,
                      size: 80,
                      color: AppColors.grey,
                    ),
                  ),
            ),
          ),
          
          // الصور المصغرة
          if (images.length > 1)
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImageIndex = index;
                      });
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedImageIndex == index
                            ? AppColors.primary
                            : AppColors.transparent,
                          width: 2,
                        ),
                      ),
                      child: images[index].isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              images[index],
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.checkroom,
                            color: AppColors.grey,
                          ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductInfo(ProductEntity product) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // اسم المنتج
          Text(
            product.displayName,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          
          const SizedBox(height: 8),
          
          // الفئة والتقييم
          Row(
            children: [
              Text(
                product.category,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey,
                ),
              ),
              
              if (product.rating != null) ...[
                const SizedBox(width: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.rating!.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      ' (${product.reviewsCount} تقييم)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 16),
          
          // السعر
          Row(
            children: [
              Text(
                '${product.price.toStringAsFixed(0)} ل.س',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const Spacer(),
              
              // حالة التوفر
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: product.isAvailable 
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  product.isAvailable ? 'متوفر' : 'غير متوفر',
                  style: TextStyle(
                    color: product.isAvailable 
                      ? AppColors.success
                      : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          if (product.isAvailable) ...[
            const SizedBox(height: 8),
            Text(
              'الكمية المتاحة: ${product.quantity}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductOptions(ProductEntity product) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الأحجام
          if (product.sizes.isNotEmpty) ...[
            Text(
              'الحجم',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: product.sizes.map((size) {
                final isSelected = _selectedSize == size;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSize = size;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      size,
                      style: TextStyle(
                        color: isSelected ? AppColors.white : AppColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          
          // الألوان
          if (product.colors.isNotEmpty) ...[
            Text(
              'اللون',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: product.colors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      color,
                      style: TextStyle(
                        color: isSelected ? AppColors.white : AppColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          
          // الكمية
          Text(
            'الكمية',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                onPressed: _quantity > 1 ? () {
                  setState(() {
                    _quantity--;
                  });
                } : null,
                icon: const Icon(Icons.remove),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.lightGrey,
                ),
              ),
              
              Container(
                width: 60,
                alignment: Alignment.center,
                child: Text(
                  _quantity.toString(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              
              IconButton(
                onPressed: _quantity < product.quantity ? () {
                  setState(() {
                    _quantity++;
                  });
                } : null,
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.lightGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(ProductEntity product) {
    if (product.displayDescription.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الوصف',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              product.displayDescription,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(ProductEntity product) {
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
      child: Row(
        children: [
          // معلومات السعر
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'السعر الإجمالي',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.grey,
                ),
              ),
              Text(
                '${(product.price * _quantity).toStringAsFixed(0)} ل.س',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // أزرار التحكم
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: BlocConsumer<CartBloc, CartState>(
                    listener: (context, state) {
                      if (state is CartItemAdded) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم إضافة المنتج للسلة'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      } else if (state is CartError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return CustomButton(
                        text: 'أضف للسلة',
                        isLoading: state is CartLoading,
                        onPressed: product.isAvailable && state is! CartLoading
                          ? () => _addToCart(product)
                          : null,
                        icon: const Icon(Icons.shopping_cart),
                      );
                    },
                  ),
                ),
                
                const SizedBox(width: 12),
                
                CustomButton(
                  text: 'اشتر الآن',
                  type: ButtonType.secondary,
                  onPressed: product.isAvailable ? () => _buyNow(product) : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(ProductEntity product) {
    // التحقق من الخيارات المطلوبة
    if (product.sizes.isNotEmpty && _selectedSize == null) {
      _showSnackBar('يرجى اختيار الحجم', AppColors.warning);
      return;
    }
    
    if (product.colors.isNotEmpty && _selectedColor == null) {
      _showSnackBar('يرجى اختيار اللون', AppColors.warning);
      return;
    }

    context.read<CartBloc>().add(
      AddToCartEvent(
        productId: product.id,
        quantity: _quantity,
        selectedSize: _selectedSize,
        selectedColor: _selectedColor,
      ),
    );
  }

  void _buyNow(ProductEntity product) {
    _addToCart(product);
    // الانتقال للسلة
    Future.delayed(const Duration(seconds: 1), () {
      context.go('/cart');
    });
  }

  void _shareProduct() {
    // TODO: تنفيذ مشاركة المنتج
    _showSnackBar('سيتم إضافة المشاركة قريباً', AppColors.info);
  }

  void _toggleWishlist() {
    // TODO: تنفيذ إضافة/إزالة من المفضلة
    _showSnackBar('سيتم إضافة المفضلة قريباً', AppColors.info);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}