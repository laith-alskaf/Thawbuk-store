import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/store_profile_entity.dart';
import '../../widgets/shared/custom_button.dart';
import '../../widgets/store/store_card.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;
  
  const ProductDetailsPage({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _currentImageIndex = 0;
  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // TODO: Load product details
    // context.read<ProductBloc>().add(LoadProductDetails(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual BlocBuilder when ProductBloc is implemented
    return _buildMockProductDetails();
  }

  // Mock data for demonstration - replace with actual BlocBuilder
  Widget _buildMockProductDetails() {
    // Mock store data
    final mockStore = StoreProfileEntity(
      id: 'store_1',
      name: 'متجر الأزياء الراقية',
      description: 'متجر متخصص في الأزياء النسائية والرجالية العصرية',
      logo: 'https://via.placeholder.com/100',
      coverImage: 'https://via.placeholder.com/400x200',
      address: const StoreAddressEntity(
        city: 'دمشق',
        street: 'شارع الثورة',
        country: 'سوريا',
      ),
      phone: '+963987654321',
      email: 'store@example.com',
      joinedDate: DateTime(2020, 1, 1),
      rating: 4.5,
      reviewsCount: 150,
      productsCount: 85,
      followersCount: 1200,
      isVerified: true,
      isActive: true,
      categories: ['ملابس نسائية', 'ملابس رجالية'],
      stats: const StoreStatsEntity(
        totalSales: 500,
        totalOrders: 300,
        averageRating: 4.5,
        responseTime: 2,
        completionRate: 95.0,
      ),
      socialLinks: const StoreSocialLinksEntity(
        website: 'https://store.com',
        facebook: 'https://facebook.com/store',
        instagram: 'https://instagram.com/store',
        whatsapp: '963987654321',
      ),
    );

    // Mock product data
    final mockProduct = ProductEntity(
      id: widget.productId,
      name: 'فستان صيفي أنيق',
      nameAr: 'فستان صيفي أنيق',
      description: 'فستان صيفي جميل مناسب للمناسبات الخاصة',
      descriptionAr: 'فستان صيفي جميل مناسب للمناسبات الخاصة',
      price: 150.0,
      categoryId: 'cat_1',
      createdBy: 'store_1',
      images: [
        'https://via.placeholder.com/400x600',
        'https://via.placeholder.com/400x600/ff0000',
        'https://via.placeholder.com/400x600/00ff00',
      ],
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['أحمر', 'أزرق', 'أخضر'],
      stock: 10,
      rating: 4.3,
      reviewsCount: 25,
      brand: 'علامة تجارية',
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(mockProduct),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductInfo(mockProduct),
                  const SizedBox(height: 24),
                  _buildStoreSection(mockStore),
                  const SizedBox(height: 24),
                  _buildProductOptions(mockProduct),
                  const SizedBox(height: 24),
                  _buildDescription(mockProduct),
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomBar(mockProduct),
    );
  }

  Widget _buildSliverAppBar(ProductEntity product) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.black),
      flexibleSpace: FlexibleSpaceBar(
        background: product.images.isNotEmpty
            ? CarouselSlider(
                options: CarouselOptions(
                  height: 400,
                  viewportFraction: 1.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                ),
                items: product.images.map((imageUrl) {
                  return CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(
                      color: AppColors.lightGrey,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.lightGrey,
                      child: const Icon(Icons.error),
                    ),
                  );
                }).toList(),
              )
            : Container(
                color: AppColors.lightGrey,
                child: const Icon(Icons.image, size: 100),
              ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.favorite_border),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.share),
        ),
      ],
      bottom: product.images.length > 1
          ? PreferredSize(
              preferredSize: const Size.fromHeight(20),
              child: Container(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: product.images.asMap().entries.map((entry) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == entry.key
                            ? AppColors.primary
                            : Colors.white.withOpacity(0.5),
                      ),
                    );
                  }).toList(),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildProductInfo(ProductEntity product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.displayName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Row(
          children: [
            if (product.rating != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    product.rating!.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${product.reviewsCount ?? 0} تقييم)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
            ],
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: product.isAvailable 
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                product.isAvailable ? 'متوفر' : 'غير متوفر',
                style: TextStyle(
                  color: product.isAvailable ? AppColors.success : AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Text(
          '${product.price.toStringAsFixed(0)} ل.س',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStoreSection(StoreProfileEntity store) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات المتجر',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        StoreCard(
          store: store,
          showFullInfo: false,
        ),
      ],
    );
  }

  Widget _buildProductOptions(ProductEntity product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.sizes?.isNotEmpty == true) ...[
          Text(
            'المقاس',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: product.sizes!.map((size) {
              final isSelected = _selectedSize == size;
              return ChoiceChip(
                label: Text(size),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedSize = selected ? size : null;
                  });
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.grey,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
        
        if (product.colors?.isNotEmpty == true) ...[
          Text(
            'اللون',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: product.colors!.map((color) {
              final isSelected = _selectedColor == color;
              return ChoiceChip(
                label: Text(color),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedColor = selected ? color : null;
                  });
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.grey,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
        
        Text(
          'الكمية',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
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
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                _quantity.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: _quantity < product.stock ? () {
                setState(() {
                  _quantity++;
                });
              } : null,
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.lightGrey,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'متوفر: ${product.stock}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription(ProductEntity product) {
    if (product.displayDescription.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الوصف',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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

  Widget _buildBottomBar(ProductEntity product) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'إضافة للسلة',
              onPressed: product.isAvailable ? () {
                // TODO: Add to cart
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إضافة المنتج للسلة')),
                );
              } : null,
              backgroundColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              text: 'شراء الآن',
              onPressed: product.isAvailable ? () {
                // TODO: Buy now
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('شراء المنتج')),
                );
              } : null,
              backgroundColor: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}