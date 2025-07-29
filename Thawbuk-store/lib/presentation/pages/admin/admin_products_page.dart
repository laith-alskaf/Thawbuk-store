import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/product/product_bloc.dart';
import '../../bloc/category/category_bloc.dart';
import '../../bloc/category/category_event.dart';
import '../../bloc/category/category_state.dart';
import '../../../domain/entities/category_entity.dart';
import '../../widgets/shared/custom_card.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/shared/error_widget.dart';
import '../../widgets/shared/custom_button.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({Key? key}) : super(key: key);

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(GetMyProductsEvent());
    context.read<CategoryBloc>().add(GetCategoriesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المنتجات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/admin/add-product'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ProductBloc>().add(GetMyProductsEvent());
        },
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading) {
              return const LoadingWidget();
            }
            
            if (state is ProductError) {
              return CustomErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<ProductBloc>().add(GetMyProductsEvent());
                },
              );
            }
            
            if (state is ProductsLoaded) {
              if (state.products.isEmpty) {
                return _buildEmptyState();
              }
              
              return _buildProductsList(state.products);
            }
            
            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/admin/add-product'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
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
              Icons.inventory_2_outlined,
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
              'ابدأ بإضافة منتجاتك الأولى لعرضها للعملاء',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'إضافة منتج',
              onPressed: () => context.go('/admin/add-product'),
              icon:Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList(List<ProductEntity> products) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, categoryState) {
        if (categoryState is CategoriesLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final category = categoryState.categories.firstWhere(
                (c) => c.id == product.categoryId,
                orElse: () =>  CategoryEntity(
                  id: '',
                  name: '',
                  nameAr: '',
                  createdAt: DateTime.now(),
                ),
              );
              return _buildProductCard(product, category);
            },
          );
        }
        return const LoadingWidget();
      },
    );
  }

  Widget _buildProductCard(ProductEntity product, CategoryEntity category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: CustomCard(
        child: Column(
          children: [
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
                        product.displayName,
                        style: Theme.of(context).textTheme.headlineMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        category.displayName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Text(
                            '${product.price.toStringAsFixed(0)} ل.س',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          const Spacer(),
                          
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: product.isAvailable 
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product.isAvailable ? 'متوفر' : 'غير متوفر',
                              style: TextStyle(
                                color: product.isAvailable 
                                  ? AppColors.success
                                  : AppColors.error,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        'الكمية: ${product.stock}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // أزرار التحكم
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'تعديل',
                    // type: ButtonType.outline,
                    isOutlined: true,
                    // size: ButtonSize.small,
                    onPressed: () => _editProduct(product),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: CustomButton(
                    text: 'حذف',
                    // type: ButtonType.outline,
                    isOutlined: true,
                    // size: ButtonSize.small,
                    onPressed: () => _showDeleteConfirmation(product),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: CustomButton(
                    text: 'عرض',
                    // size: ButtonSize.small,
                    onPressed: () => context.go('/product/${product.id}'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editProduct(ProductEntity product) {
    context.go('/admin/add-product', extra: product);
  }

  void _showDeleteConfirmation(ProductEntity product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف "${product.displayName}"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProduct(product);
              },
              child: const Text(
                'حذف',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(ProductEntity product) {
    context.read<ProductBloc>().add(DeleteProductEvent(product.id));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حذف "${product.displayName}"'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'تراجع',
          onPressed: () {
            // TODO: تنفيذ التراجع عن الحذف
          },
        ),
      ),
    );
  }
}
