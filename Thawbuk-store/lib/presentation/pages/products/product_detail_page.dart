import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/shared/error_widget.dart';
import '../../widgets/shared/custom_button.dart';
import '../../../domain/entities/product_entity.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _currentImageIndex = 0;
  int _selectedQuantity = 1;
  String? _selectedSize;
  String? _selectedColor;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(GetProductByIdEvent(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          final product = state.selectedProduct;
          if (product == null) {
            return const NotFoundWidget(
              message: 'المنتج غير موجود',
            );
          }

          return _buildProductDetail(product);
        },
      ),
    );
  }

  Widget _buildProductDetail(ProductEntity product) {
    return CustomScrollView(
      slivers: [
        // App bar with images
        SliverAppBar(
          expandedHeight: 400,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildImageCarousel(product.images),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {
                // Add to wishlist
              },
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // Share product
              },
            ),
          ],
        ),

        // Product details
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and price
                _buildTitleSection(product),
                const SizedBox(height: 16),

                // Rating and reviews
                _buildRatingSection(product),
                const SizedBox(height: 16),

                // Size selection
                if (product.sizes!=null) ...[
                  _buildSizeSelection(product.sizes!),
                  const SizedBox(height: 16),
                ],

                // Color selection
                if (product.colors!=null) ...[
                  _buildColorSelection(product.colors!),
                  const SizedBox(height: 16),
                ],

                // Quantity selection
                _buildQuantitySelection(),
                const SizedBox(height: 24),

                // Description
                _buildDescriptionSection(product),
                const SizedBox(height: 24),

                // Store info
                _buildStoreSection(product),
                const SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCarousel(List<String> images) {
    if (images.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(
          Icons.image,
          size: 100,
          color: Colors.grey,
        ),
      );
    }

    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 400,
            viewportFraction: 1.0,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
          items: images.map((image) {
            return CachedNetworkImage(
              imageUrl: image,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => const LoadingWidget(),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.error),
              ),
            );
          }).toList(),
        ),
        
        // Image indicators
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: images.asMap().entries.map((entry) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImageIndex == entry.key
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection(ProductEntity product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '${product.price} ر.س',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (product.originalPrice != null && 
                product.originalPrice! > product.price) ...[
              const SizedBox(width: 8),
              Text(
                '${product.originalPrice} ر.س',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildRatingSection(ProductEntity product) {
    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < (product.rating ?? 0).floor()
                  ? Icons.star
                  : Icons.star_border,
              color: Colors.amber,
              size: 20,
            );
          }),
        ),
        const SizedBox(width: 8),
        Text(
          '${product.rating ?? 0}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 4),
        Text(
          '(${product.reviewsCount ?? 0} تقييم)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelection(List<String> sizes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المقاس',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: sizes.map((size) {
            final isSelected = _selectedSize == size;
            return ChoiceChip(
              label: Text(size),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedSize = selected ? size : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSelection(List<String> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اللون',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: colors.map((color) {
            final isSelected = _selectedColor == color;
            return ChoiceChip(
              label: Text(color),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedColor = selected ? color : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantitySelection() {
    return Row(
      children: [
        Text(
          'الكمية',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Row(
          children: [
            IconButton(
              onPressed: _selectedQuantity > 1
                  ? () {
                      setState(() {
                        _selectedQuantity--;
                      });
                    }
                  : null,
              icon: const Icon(Icons.remove),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_selectedQuantity',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedQuantity++;
                });
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(ProductEntity product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الوصف',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.displayDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildStoreSection(ProductEntity product) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: product.storeImage != null
                  ? CachedNetworkImageProvider(product.storeImage!)
                  : null,
              child: product.storeImage == null
                  ? const Icon(Icons.store)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.storeName ?? 'متجر غير محدد',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (product.storeRating != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${product.storeRating}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to store page
              },
              child: const Text('زيارة المتجر'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(ProductEntity product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'إضافة للسلة',
              onPressed: () {
                context.read<CartBloc>().add(
                  AddToCartEvent(
                    productId: product.id,
                    quantity: _selectedQuantity,
                    selectedSize: _selectedSize,
                    selectedColor: _selectedColor,
                  ),
                );
              },
              icon: Icons.shopping_cart,
            ),
          ),
          const SizedBox(width: 12),
          CustomButton(
            text: 'شراء الآن',
            onPressed: () {
              // Navigate to checkout
            },
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
    );
  }
}