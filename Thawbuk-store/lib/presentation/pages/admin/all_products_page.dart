import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/admin/admin_bloc.dart';
import '../../bloc/category/category_bloc.dart';
import '../../bloc/category/category_event.dart';
import '../../bloc/category/category_state.dart';
import '../../widgets/shared/custom_card.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/shared/error_widget.dart';
import '../../widgets/shared/custom_app_bar.dart';
import '../../widgets/shared/custom_text_field.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({Key? key}) : super(key: key);

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'الكل';
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(GetAllProductsEvent());
    context.read<CategoryBloc>().add(GetCategoriesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'جميع المنتجات في التطبيق',
        showBackButton: true,
        onBackPressed: () => context.pop(),
      ),
      body: Column(
        children: [
          // شريط البحث والفلترة
          _buildSearchAndFilter(),
          
          // قائمة المنتجات
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<AdminBloc>().add(GetAllProductsEvent());
              },
              child: BlocBuilder<AdminBloc, AdminState>(
                builder: (context, state) {
                  if (state is AdminLoading) {
                    return const LoadingWidget();
                  }
                  
                  if (state is AdminError) {
                    return CustomErrorWidget(
                      message: state.message,
                      onRetry: () {
                        context.read<AdminBloc>().add(GetAllProductsEvent());
                      },
                    );
                  }
                  
                  if (state is AllProductsLoaded) {
                    final filteredProducts = _filterProducts(state.products);
                    
                    if (filteredProducts.isEmpty) {
                      return _buildEmptyState();
                    }
                    
                    return _buildProductsList(filteredProducts);
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

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // شريط البحث
          CustomTextField(
            controller: _searchController,
            hint: 'البحث في جميع المنتجات...',
            prefixIcon:const  Icon(Icons.search),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
          ),
          
          const SizedBox(height: 16),
          
          // فلتر التصنيفات
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, categoryState) {
              if (categoryState is CategoriesLoaded) {
                return SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCategoryChip('الكل', true),
                      const SizedBox(width: 8),
                      ...categoryState.categories.map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildCategoryChip(
                            category.name,
                            _selectedCategory == category.name,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, bool isSelected) {
    return FilterChip(
      label: Text(category),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : 'الكل';
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.grey,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: AppColors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _selectedCategory != 'الكل'
                  ? 'لا توجد منتجات تطابق البحث'
                  : 'لا توجد منتجات في التطبيق حالياً',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _selectedCategory != 'الكل'
                  ? 'جرب تغيير معايير البحث'
                  : 'ستظهر المنتجات هنا عند إضافتها من قبل أصحاب المتاجر',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList(List<ProductEntity> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildProductCard(product),
        );
      },
    );
  }

  Widget _buildProductCard(ProductEntity product) {
    return CustomCard(
      onTap: () {
        // الانتقال لصفحة تفاصيل المنتج
        context.go('/product/${product.id}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة المنتج ومعلومات المتجر
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة المنتج
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product.mainImage.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.mainImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_not_supported,
                              color: AppColors.grey,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.image,
                        color: AppColors.grey,
                        size: 40,
                      ),
              ),
              
              const SizedBox(width: 16),
              
              // معلومات المنتج
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم المنتج
                    Text(
                      product.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // اسم المتجر
                    if (product.storeName != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.store,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              product.storeName!,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // السعر والحالة
                    Row(
                      children: [
                        Text(
                          product.formattedPrice,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // حالة التوفر
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: product.isAvailable
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.isAvailable ? 'متوفر' : 'غير متوفر',
                            style: TextStyle(
                              color: product.isAvailable
                                  ? AppColors.success
                                  : AppColors.error,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // إحصائيات المنتج
          Row(
            children: [
              // عدد المفضلة
              _buildStatChip(
                Icons.favorite,
                '${product.favoritesCount ?? 0}',
                AppColors.error,
              ),
              
              const SizedBox(width: 8),
              
              // التقييم
              if (product.rating != null)
                _buildStatChip(
                  Icons.star,
                  product.rating!.toStringAsFixed(1),
                  AppColors.warning,
                ),
              
              const SizedBox(width: 8),
              
              // عدد المراجعات
              if (product.reviewsCount != null && product.reviewsCount! > 0)
                _buildStatChip(
                  Icons.comment,
                  '${product.reviewsCount}',
                  AppColors.info,
                ),
              
              const Spacer(),
              
              // تاريخ الإضافة
              if (product.createdAt != null)
                Text(
                  _formatDate(product.createdAt!),
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<ProductEntity> _filterProducts(List<ProductEntity> products) {
    var filtered = products;
    
    // فلترة حسب البحث
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (product.storeName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }
    
    // فلترة حسب التصنيف
    if (_selectedCategory != 'الكل') {
      filtered = filtered.where((product) {
        // يجب ربط categoryId بـ category name
        // هذا يتطلب الوصول لبيانات التصنيفات
        return true; // مؤقتاً
      }).toList();
    }
    
    return filtered;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}