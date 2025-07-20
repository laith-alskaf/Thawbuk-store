import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/product_entity.dart';

class ProductCard extends StatefulWidget {
  final ProductEntity product;
  final bool isListView;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onToggleWishlist;

  const ProductCard({
    Key? key,
    required this.product,
    this.isListView = false,
    required this.onTap,
    required this.onAddToCart,
    required this.onToggleWishlist,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  bool _isWishlisted = false;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isListView ? _buildListCard() : _buildGridCard();
  }

  Widget _buildGridCard() {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: _buildCardContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListCard() {
    return GestureDetector(
      onTap: widget.onTap,
      child: _buildListCardContent(),
    );
  }

  Widget _buildCardContent() {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(),
          _buildInfoSection(),
        ],
      ),
    );
  }

  Widget _buildListCardContent() {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildListImage(),
            const SizedBox(width: 12),
            Expanded(child: _buildListInfo()),
            _buildListActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Expanded(
      flex: 3,
      child: Stack(
        children: [
          _buildProductImage(),
          _buildImageOverlay(),
          _buildTopActions(),
          if (!widget.product.isAvailable) _buildOutOfStockBadge(),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: widget.product.images.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: widget.product.images.first,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildImagePlaceholder(),
              errorWidget: (context, url, error) => _buildImageError(),
            )
          : _buildImageError(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey,
      highlightColor: AppColors.white,
      child: Container(
        color: AppColors.lightGrey,
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: AppColors.lightGrey,
      child: const Icon(
        Icons.image,
        size: 48,
        color: AppColors.grey,
      ),
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
              Colors.transparent,
              Colors.black.withOpacity(0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopActions() {
    return Positioned(
      top: 8,
      right: 8,
      child: Column(
        children: [
          _buildWishlistButton(),
          const SizedBox(height: 8),
          if (widget.product.rating != null && widget.product.rating! > 0)
            _buildRatingBadge(),
        ],
      ),
    );
  }

  Widget _buildWishlistButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isWishlisted = !_isWishlisted;
        });
        widget.onToggleWishlist();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          _isWishlisted ? Icons.favorite : Icons.favorite_outline,
          color: _isWishlisted ? AppColors.error : AppColors.grey,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildRatingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            color: AppColors.white,
            size: 12,
          ),
          const SizedBox(width: 2),
          Text(
            '${widget.product.rating!.toStringAsFixed(1)}',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutOfStockBadge() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: const Center(
          child: Text(
            'غير متوفر',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildProductTitle(),
            const SizedBox(height: 4),
            _buildProductDetails(),
            const SizedBox(height: 8),
            _buildBottomRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductTitle() {
    return Text(
      widget.product.displayName,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.product.colors.isNotEmpty)
          _buildColorIndicators(),
        if (widget.product.sizes.isNotEmpty)
          _buildSizeInfo(),
      ],
    );
  }

  Widget _buildColorIndicators() {
    return Row(
      children: [
        ...widget.product.colors.take(3).map((color) => 
          Container(
            margin: const EdgeInsets.only(right: 4),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getColorFromName(color),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
        ),
        if (widget.product.colors.length > 3)
          Text(
            '+${widget.product.colors.length - 3}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.grey,
            ),
          ),
      ],
    );
  }

  Widget _buildSizeInfo() {
    return Text(
      'الأحجام: ${widget.product.sizes.take(3).join(", ")}${widget.product.sizes.length > 3 ? "..." : ""}',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppColors.grey,
      ),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPriceInfo(),
        _buildAddToCartButton(),
      ],
    );
  }

  Widget _buildPriceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.product.price.toStringAsFixed(2)} ريال',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (widget.product.reviewsCount > 0)
          Text(
            '${widget.product.reviewsCount} تقييم',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.grey,
            ),
          ),
      ],
    );
  }

  Widget _buildAddToCartButton() {
    return GestureDetector(
      onTap: widget.product.isAvailable && !_isAddingToCart
          ? () async {
              setState(() => _isAddingToCart = true);
              widget.onAddToCart();
              await Future.delayed(const Duration(milliseconds: 500));
              if (mounted) setState(() => _isAddingToCart = false);
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.product.isAvailable 
              ? AppColors.primary 
              : AppColors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _isAddingToCart
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : const Icon(
                Icons.add_shopping_cart,
                color: AppColors.white,
                size: 18,
              ),
      ),
    );
  }

  // List View Specific Widgets
  Widget _buildListImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 80,
        height: 80,
        child: widget.product.images.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: widget.product.images.first,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildImagePlaceholder(),
                errorWidget: (context, url, error) => _buildImageError(),
              )
            : _buildImageError(),
      ),
    );
  }

  Widget _buildListInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.displayName,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          widget.product.displayDescription,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.grey,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '${widget.product.price.toStringAsFixed(2)} ريال',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.product.rating != null && widget.product.rating! > 0) ...[
              const SizedBox(width: 12),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: AppColors.warning,
                    size: 14,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${widget.product.rating!.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildListActions() {
    return Column(
      children: [
        _buildWishlistButton(),
        const SizedBox(height: 8),
        _buildAddToCartButton(),
      ],
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
}