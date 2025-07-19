import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/product/product_bloc.dart';
import '../../widgets/shared/custom_card.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/shared/error_widget.dart';
import '../../widgets/shared/custom_text_field.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'الكل';
  String _sortBy = 'الأحدث';

  final List<String> _categories = [
    'الكل',
    'الثياب التقليدية',
    'الثياب العصرية',
    'الأحذية',
    'الإكسسوارات'
  ];

  final List<String> _sortOptions = [
    'الأحدث',
    'الأقدم',
    'السعر: من الأقل للأعلى',
    'السعر: من الأعلى للأقل',
    'الأكثر شعبية'
  ];

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(GetProductsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // شريط البحث والفلتر
          _buildSearchAndFilter(),
          
          // قائمة المنتجات
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<ProductBloc>().add(GetProductsEvent());
              },
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const LoadingWidget(message: 'جاري تحميل المنتجات...');
                  }
                  
                  if (state is ProductError) {
                    return CustomErrorWidget(
                      message: state.message,
                      onRetry: () {
                        context.read<ProductBloc>().add(GetProductsEvent());
                      },
                    );
                  }
                  
                  if (state is ProductsLoaded) {
                    final filteredProducts = _filterProducts(state.products);
                    
                    if (filteredProducts.isEmpty) {
                      return _buildEmptyState();
                    }
                    
                    return _buildProductsGrid(filteredProducts);
                  }
                  
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('المنتجات'),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterBottomSheet,
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      color: AppColors.background,
      child: Column(
        children: [
          // شريط البحث
          CustomTextField(
            hint: 'ابحث عن المنتجات...',
            controller: _searchController,
            prefixIcon: const Icon(Icons.search),
            onChanged: (value) {
              setState(() {});
            },
          ),
          
          const SizedBox(height: 12),
          
          // الفئات
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                
                return Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: AppColors.lightGrey,
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(List<ProductEntity> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(ProductEntity product) {
    return CustomCard(
      onTap: () => context.go('/product/${product.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة المنتج
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  // الصورة
                  product.mainImage.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.mainImage,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: AppColors.grey,
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.checkroom,
                          size: 40,
                          color: AppColors.grey,
                        ),
                      ),
                  
                  // حالة التوفر
                  if (!product.isAvailable)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'غير متوفر',
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // زر المفضلة
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 18,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // اسم المنتج
          Text(
            product.displayName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 4),
          
          // الفئة
          Text(
            product.category,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.grey,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // السعر والتقييم
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${product.price.toStringAsFixed(0)} ل.س',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              if (product.rating != null)
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    Text(
                      product.rating!.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 80,
              color: AppColors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد منتجات',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'جرب تغيير معايير البحث أو الفلتر',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<ProductEntity> _filterProducts(List<ProductEntity> products) {
    var filtered = products;
    
    // فلترة حسب البحث
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((product) {
        return product.displayName.toLowerCase().contains(searchTerm) ||
               product.displayDescription.toLowerCase().contains(searchTerm);
      }).toList();
    }
    
    // فلترة حسب الفئة
    if (_selectedCategory != 'الكل') {
      filtered = filtered.where((product) {
        return product.category == _selectedCategory;
      }).toList();
    }
    
    // ترتيب
    switch (_sortBy) {
      case 'السعر: من الأقل للأعلى':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'السعر: من الأعلى للأقل':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'الأقدم':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'الأكثر شعبية':
        filtered.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      default: // الأحدث
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    
    return filtered;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ترتيب حسب',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              
              const SizedBox(height: 16),
              
              ...._sortOptions.map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _sortBy,
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}