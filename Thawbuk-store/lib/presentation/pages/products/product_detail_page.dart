import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../bloc/product/product_bloc.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/product_entity.dart';
import '../../widgets/shared/custom_button.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/shared/error_widget.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  PageController _imageController = PageController();
  ScrollController _scrollController = ScrollController();
  
  int _currentImageIndex = 0;
  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;
  bool _isWishlisted = false;
  bool _showFullDescription = false;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
    
    context.read<ProductBloc>().add(GetProductByIdEvent(widget.productId));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _imageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const LoadingWidget();
          } else if (state is ProductError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () => context.read<ProductBloc>().add(
                GetProductByIdEvent(widget.productId),
              ),
            );
          } else if (state is ProductLoaded) {
            return _buildProductDetail(state.product);
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProductDetail(ProductEntity product) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSliverAppBar(product),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductInfo(product),
                  _buildImageGallery(product),
                  _buildProductOptions(product),
                  _buildProductDescription(product),
                  _buildRelatedProducts(),
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(ProductEntity product) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.white,
      iconTheme: const IconThemeData(color: AppColors.white),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            _buildMainImage(product),
            _buildImageOverlay(),
            _buildImageIndicators(product),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              _isWishlisted = !_isWishlisted;
            });
          },
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              _isWishlisted ? Icons.favorite : Icons.favorite_outline,
              key: ValueKey(_isWishlisted),
              color: _isWishlisted ? AppColors.error : AppColors.white,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            // Share functionality
          },
          icon: const Icon(Icons.share, color: AppColors.white),
        ),
      ],
    );
  }

  Widget _buildMainImage(ProductEntity product) {
    if (product.images.isEmpty) {
      return Container(
        color: AppColors.lightGrey,
        child: const Center(
          child: Icon(
            Icons.image,
            size: 80,
            color: AppColors.grey,
          ),
        ),
      );
    }

    return PageView.builder(
      controller: _imageController,
      onPageChanged: (index) {
        setState(() {
          _currentImageIndex = index;
        });
      },
      itemCount: product.images.length,
      itemBuilder: (context, index) {
        return Hero(
          tag: 'product-image-${product.id}-$index',
          child: CachedNetworkImage(
            imageUrl: product.images[index],
            fit: BoxFit.cover,
            placeholder: (context, url) => const LoadingWidget(),
            errorWidget: (context, url, error) => Container(
              color: AppColors.lightGrey,
              child: const Icon(
                Icons.error_outline,
                size: 80,
                color: AppColors.grey,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageIndicators(ProductEntity product) {
    if (product.images.length <= 1) return const SizedBox.shrink();

    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: product.images.asMap().entries.map((entry) {
          final index = entry.key;
          final isActive = index == _currentImageIndex;
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isActive ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isActive ? AppColors.white : AppColors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductInfo(ProductEntity product) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Title and Rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  product.displayName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGrey,
                  ),
                ),
              ),
              if (product.rating != null && product.rating! > 0)
                _buildRatingWidget(product),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Price and Stock
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${product.price.toStringAsFixed(2)} ريال',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (product.reviewsCount > 0)
                    Text(
                      '${product.reviewsCount} تقييم',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                ],
              ),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: product.isAvailable ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: product.isAvailable ? AppColors.success : AppColors.error,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      product.isAvailable ? Icons.check_circle : Icons.cancel,
                      color: product.isAvailable ? AppColors.success : AppColors.error,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.isAvailable ? 'متوفر' : 'غير متوفر',
                      style: TextStyle(
                        color: product.isAvailable ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingWidget(ProductEntity product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            color: AppColors.warning,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${product.rating!.toStringAsFixed(1)}',
            style: const TextStyle(
              color: AppColors.warning,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(ProductEntity product) {
    if (product.images.length <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'صور المنتج',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: product.images.length,
              itemBuilder: (context, index) {
                final isSelected = index == _currentImageIndex;
                
                return GestureDetector(
                  onTap: () {
                    _imageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.lightGrey,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: product.images[index],
                        fit: BoxFit.cover,
                      ),
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

  Widget _buildProductOptions(ProductEntity product) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.lightGrey.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Size Selection
          if (product.sizes.isNotEmpty) ...[
            _buildSizeSelection(product),
            const SizedBox(height: 20),
          ],
          
          // Color Selection
          if (product.colors.isNotEmpty) ...[
            _buildColorSelection(product),
            const SizedBox(height: 20),
          ],
          
          // Quantity Selection
          _buildQuantitySelection(product),
        ],
      ),
    );
  }

  Widget _buildSizeSelection(ProductEntity product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر الحجم',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: product.sizes.map((size) {
            final isSelected = size == _selectedSize;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSize = size;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.grey.withOpacity(0.3),
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Text(
                  size,
                  style: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.darkGrey,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSelection(ProductEntity product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر اللون',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: product.colors.map((color) {
            final isSelected = color == _selectedColor;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.secondary.withOpacity(0.1) : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.secondary : AppColors.grey.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getColorFromName(color),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.grey.withOpacity(0.3)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      color,
                      style: TextStyle(
                        color: isSelected ? AppColors.secondary : AppColors.darkGrey,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantitySelection(ProductEntity product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الكمية',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppColors.lightGrey),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _quantity > 1 ? () {
                      setState(() {
                        _quantity--;
                      });
                    } : null,
                    icon: const Icon(Icons.remove),
                    iconSize: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: const BoxDecoration(
                      color: AppColors.lightGrey,
                    ),
                    child: Text(
                      '$_quantity',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _quantity < product.quantity ? () {
                      setState(() {
                        _quantity++;
                      });
                    } : null,
                    icon: const Icon(Icons.add),
                    iconSize: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'متوفر: ${product.quantity} قطعة',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductDescription(ProductEntity product) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'وصف المنتج',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedCrossFade(
            firstChild: Text(
              product.displayDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: AppColors.darkGrey,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            secondChild: Text(
              product.displayDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: AppColors.darkGrey,
              ),
            ),
            crossFadeState: _showFullDescription 
                ? CrossFadeState.showSecond 
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          if (product.displayDescription.length > 100)
            TextButton(
              onPressed: () {
                setState(() {
                  _showFullDescription = !_showFullDescription;
                });
              },
              child: Text(
                _showFullDescription ? 'عرض أقل' : 'عرض المزيد',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.lightGrey.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'منتجات مشابهة',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3, // Placeholder
              itemBuilder: (context, index) {
                return Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('منتج مشابه'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Sheet and Actions
  Widget _buildBottomBar(ProductEntity product) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'إضافة للسلة',
                onPressed: product.isAvailable ? _addToCart : null,
                isLoading: _isAddingToCart,
                icon: Icons.add_shopping_cart,
              ),
            ),
            const SizedBox(width: 12),
            CustomButton(
              text: 'شراء الآن',
              onPressed: product.isAvailable ? _buyNow : null,
              backgroundColor: AppColors.secondary,
              width: 120,
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  Color _getColorFromName(String colorName) {
    final colorMap = {
      'أحمر': Colors.red,
      'أزرق': Colors.blue,
      'أخضر': Colors.green,
      'أصفر': Colors.yellow,
      'بني': Colors.brown,
      'أسود': Colors.black,
      'أبيض': Colors.white,
      'رمادي': Colors.grey,
      'بنفسجي': Colors.purple,
      'وردي': Colors.pink,
    };
    
    return colorMap[colorName] ?? AppColors.primary;
  }

  void _addToCart() async {
    setState(() => _isAddingToCart = true);

    context.read<CartBloc>().add(AddToCartEvent(
      productId: widget.productId,
      quantity: _quantity,
      selectedSize: _selectedSize,
      selectedColor: _selectedColor,
    ));

    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (mounted) {
      setState(() => _isAddingToCart = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم إضافة المنتج للسلة بنجاح'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'عرض السلة',
            textColor: AppColors.white,
            onPressed: () => context.push('/cart'),
          ),
        ),
      );
    }
  }

  void _buyNow() {
    // Add to cart then navigate to checkout
    _addToCart();
    Future.delayed(const Duration(milliseconds: 500), () {
      context.push('/checkout');
    });
  }
}