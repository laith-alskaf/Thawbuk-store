import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/admin/admin_bloc.dart';
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
import '../../../core/navigation/navigation_service.dart';
import 'admin_layout.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({Key? key}) : super(key: key);

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(GetMyProductsEvent());
    context.read<CategoryBloc>().add(GetCategoriesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<AdminBloc>().add(GetMyProductsEvent());
        },
        child: BlocConsumer<AdminBloc, AdminState>(
          listener: (context, state) {
            if (state is ProductDeleted) {
              // إخفاء رسالة التحميل
              ScaffoldMessenger.of(context).clearSnackBars();
              
              // إظهار رسالة نجاح الحذف
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.white),
                      SizedBox(width: 8),
                      Text('تم حذف المنتج بنجاح'),
                    ],
                  ),
                  backgroundColor: AppColors.success,
                  duration: Duration(seconds: 2),
                ),
              );
              
              // إعادة تحميل القائمة
              context.read<AdminBloc>().add(GetMyProductsEvent());
            } else if (state is ProductUpdated) {
              // تحديث القائمة عند تعديل منتج
              context.read<AdminBloc>().add(GetMyProductsEvent());
            } else if (state is AdminError && state.message.contains('حذف')) {
              // إخفاء رسالة التحميل
              ScaffoldMessenger.of(context).clearSnackBars();
              
              // إظهار رسالة خطأ
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error, color: AppColors.white),
                      const SizedBox(width: 8),
                      Expanded(child: Text(state.message)),
                    ],
                  ),
                  backgroundColor: AppColors.error,
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'إعادة المحاولة',
                    textColor: AppColors.white,
                    onPressed: () {
                      context.read<AdminBloc>().add(GetMyProductsEvent());
                    },
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is AdminLoading) {
              return const LoadingWidget();
            }
            
            if (state is AdminError) {
              return CustomErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<AdminBloc>().add(GetMyProductsEvent());
                },
              );
            }
            
            if (state is MyProductsLoaded) {
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
        onPressed: () {
          // التنقل داخل AdminLayout
          final adminLayout = AdminLayout.of(context);
          if (adminLayout != null) {
            adminLayout.navigateToTab(2);
          } else {
            context.go('/admin/add-product');
          }
        },
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
                      // اسم المنتج مع أيقونة المفضلة
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.displayName,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if ((product.favoritesCount ?? 0) > 0) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.favorite,
                                    size: 12,
                                    color: AppColors.error,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${product.favoritesCount}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // الفئة مع أيقونة
                      Row(
                        children: [
                          const Icon(
                            Icons.category_outlined,
                            size: 14,
                            color: AppColors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            category.displayName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // السعر والحالة
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${product.price.toStringAsFixed(0)} ل.س',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
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
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: product.isAvailable 
                                  ? AppColors.success.withOpacity(0.3)
                                  : AppColors.error.withOpacity(0.3),
                              ),
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
                      
                      const SizedBox(height: 6),
                      
                      // الكمية والتاريخ
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 14,
                            color: product.stock > 10 
                              ? AppColors.success 
                              : product.stock > 0 
                                ? AppColors.warning
                                : AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'الكمية: ${product.stock}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: product.stock > 10 
                                ? AppColors.success 
                                : product.stock > 0 
                                  ? AppColors.warning
                                  : AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          
                          const Spacer(),
                          
                          if (product.createdAt != null) ...[
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: AppColors.grey.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(product.createdAt!),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.grey.withOpacity(0.7),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      // شريط المخزون
                      const SizedBox(height: 6),
                      Container(
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: AppColors.grey.withOpacity(0.2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (product.stock / 50).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: product.stock > 20 
                                ? AppColors.success 
                                : product.stock > 10 
                                  ? AppColors.warning
                                  : AppColors.error,
                            ),
                          ),
                        ),
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
    context.nav.pushEditProduct(product);
  }

  void _showDeleteConfirmation(ProductEntity product) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'تأكيد حذف المنتج',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    const TextSpan(text: 'هل أنت متأكد من حذف المنتج '),
                    TextSpan(
                      text: '"${product.displayName}"',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                    const TextSpan(text: '؟'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.warning.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'هذا الإجراء لا يمكن التراجع عنه',
                        style: TextStyle(
                          color: AppColors.warning.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'السعر: ${product.price.toStringAsFixed(0)} ل.س',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.grey,
                ),
              ),
              Text(
                'الكمية: ${product.stock}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProduct(product);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline, size: 18),
                  SizedBox(width: 4),
                  Text('حذف نهائياً'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(ProductEntity product) {
    // إظهار رسالة تحميل
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text('جاري حذف "${product.displayName}"...'),
          ],
        ),
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // تنفيذ عملية الحذف
    context.read<AdminBloc>().add(DeleteProductEvent(product.id));
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 7) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}
