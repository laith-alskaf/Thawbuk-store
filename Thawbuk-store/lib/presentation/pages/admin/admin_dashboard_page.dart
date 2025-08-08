import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/admin/admin_bloc.dart';
import '../../widgets/shared/custom_card.dart';
import '../../widgets/shared/custom_button.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import 'admin_layout.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    // تحميل البيانات الإحصائية للإدارة
    context.read<AdminBloc>().add(GetAdminDashboardDataEvent());
  }
  
  void _navigateToProducts() {
    final adminLayout = AdminLayout.of(context);
    if (adminLayout != null) {
      adminLayout.navigateToTab(1);
    } else {
      context.go('/admin/products');
    }
  }
  
  void _navigateToAddProduct() {
    final adminLayout = AdminLayout.of(context);
    if (adminLayout != null) {
      adminLayout.navigateToTab(2);
    } else {
      context.go('/admin/add-product');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated || !authState.user.isOwner) {
          return const Center(
            child: Text('غير مصرح لك بالوصول لهذه الصفحة'),
          );
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            context.read<AdminBloc>().add(GetAdminDashboardDataEvent());
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // رسالة ترحيب
                _buildWelcomeCard(authState.user),
                
                const SizedBox(height: 24),
                
                // الإحصائيات السريعة
                _buildQuickStats(),
                
                const SizedBox(height: 24),
                
                // الإجراءات السريعة
                _buildQuickActions(),
                
                const SizedBox(height: 24),
                
                // الطلبات الأخيرة
                _buildRecentOrders(),
                
                const SizedBox(height: 24),
                
                // المنتجات الأكثر مبيعاً
                _buildTopProducts(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(user) {
    return CustomCard(
      backgroundColor: AppColors.primary.withOpacity(0.1),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً ${user.name}',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'مرحباً بك في لوحة تحكم متجرك',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'آخر تسجيل دخول: ${_formatDate(user.lastLoginAt ?? DateTime.now())}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.dashboard,
            size: 60,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        int productsCount = 0;
        int inStockCount = 0;
        int outOfStockCount = 0;
        int totalFavorites = 0;
        
        if (state is AdminDashboardLoaded) {
          productsCount = state.stats.totalProducts;
          inStockCount = state.stats.availableProducts;
          outOfStockCount = state.stats.outOfStockProducts;
          totalFavorites = state.stats.totalFavorites;
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إحصائيات متجرك',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'منتجاتي',
                    productsCount.toString(),
                    Icons.inventory,
                    AppColors.primary,
                    _navigateToProducts,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'المتوفر',
                    inStockCount.toString(),
                    Icons.check_circle,
                    AppColors.success,
                    _navigateToProducts,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'نفد المخزون',
                    outOfStockCount.toString(),
                    Icons.warning,
                    AppColors.error,
                    _navigateToProducts,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'المفضلة',
                    totalFavorites.toString(),
                    Icons.favorite,
                    AppColors.secondary,
                    () => _showFavoritesDetails(context),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return CustomCard(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإجراءات السريعة',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'إضافة منتج',
                icon: Icons.add,
                onPressed: _navigateToAddProduct,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomButton(
                text: 'إدارة المنتجات',
                // type: ButtonType.outline,
                isOutlined: true,
                icon:Icons.inventory,
                onPressed: _navigateToProducts,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'جميع المنتجات',
                // type: ButtonType.secondary,
                icon: Icons.store,
                onPressed: _navigateToAllProducts,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomButton(
                text: 'إحصائيات المفضلة',
                // type: ButtonType.outline,
                isOutlined: true,
                icon: Icons.favorite_border,
                onPressed: () => _showFavoritesDetails(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الطلبات الأخيرة',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
              onPressed: () {
                // TODO: عرض جميع الطلبات
              },
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomCard(
          child: Column(
            children: [
              _buildOrderItem('طلب #12345', '150.000 ل.س', 'قيد المراجعة', AppColors.warning),
              const Divider(),
              _buildOrderItem('طلب #12344', '200.000 ل.س', 'مؤكد', AppColors.success),
              const Divider(),
              _buildOrderItem('طلب #12343', '75.000 ل.س', 'تم التسليم', AppColors.info),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'لا توجد طلبات جديدة',
                  style: TextStyle(color: AppColors.grey),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(String orderNumber, String amount, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                orderNumber,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                amount,
                style: const TextStyle(color: AppColors.primary),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProducts() {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is AdminDashboardLoaded && state.stats.topFavoriteProducts.isNotEmpty) {
          final topProducts = state.stats.topFavoriteProducts.take(3).toList();
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المنتجات الأكثر إعجاباً',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  TextButton(
                    onPressed: _navigateToProducts,
                    child: const Text('عرض الكل'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...topProducts.map((product) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: CustomCard(
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
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
                                Icons.checkroom,
                                color: AppColors.grey,
                              ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.displayName,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${product.price.toStringAsFixed(0)} ل.س',
                                style: const TextStyle(color: AppColors.primary),
                              ),
                              Text(
                                'الكمية: ${product.stock}',
                                style: const TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                  ),
                );
              }).toList(),
            ],
          );
        }
        
        return CustomCard(
          child: Center(
            child: Column(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 60,
                  color: AppColors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'لا توجد منتجات بعد',
                  style: TextStyle(color: AppColors.grey),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'إضافة منتج',
                  // size: ButtonSize.small,
                  onPressed: _navigateToAddProduct,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showFavoritesDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تفاصيل المفضلة'),
        content: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            if (state is AdminDashboardLoaded) {
              final topFavorites = state.stats.topFavoriteProducts;
              if (topFavorites.isEmpty) {
                return const Text('لا توجد منتجات في المفضلة بعد');
              }
              
              return SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: topFavorites.length,
                  itemBuilder: (context, index) {
                    final product = topFavorites[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: product.mainImage.isNotEmpty
                          ? NetworkImage(product.mainImage)
                          : null,
                        child: product.mainImage.isEmpty
                          ? const Icon(Icons.checkroom)
                          : null,
                      ),
                      title: Text(product.displayName),
                      subtitle: Text('${product.price.toStringAsFixed(0)} ل.س'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.favorite, color: AppColors.error, size: 16),
                          const SizedBox(width: 4),
                          Text('${product.favoritesCount ?? 0}'),
                        ],
                      ),
                    );
                  },
                ),
              );
            }
            return const CircularProgressIndicator();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _navigateToAllProducts() {
    context.go('/admin/all-products');
  }
}
