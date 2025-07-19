import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/product/product_bloc.dart';
import '../../widgets/shared/custom_card.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/shared/error_widget.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // تحميل المنتجات عند بداية الصفحة
    context.read<ProductBloc>().add(GetProductsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ProductBloc>().add(GetProductsEvent());
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رسالة ترحيب
              _buildWelcomeSection(),
              
              const SizedBox(height: 24),
              
              // إحصائيات سريعة (للمالك فقط)
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated && state.user.isOwner) {
                    return _buildOwnerStats();
                  }
                  return const SizedBox.shrink();
                },
              ),
              
              // الفئات الرئيسية
              _buildCategoriesSection(),
              
              const SizedBox(height: 24),
              
              // المنتجات المميزة
              _buildFeaturedProducts(),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          const Icon(Icons.storefront),
          const SizedBox(width: 8),
          const Text(AppConstants.appName),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // TODO: تنفيذ البحث
          },
        ),
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.shopping_cart),
              // عدد العناصر في السلة
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '0',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () => context.go('/cart'),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) return const SizedBox.shrink();
        
        final user = state.user;
        
        return Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(user.name),
                accountEmail: Text(user.email),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                ),
              ),
              
              // الصفحة الرئيسية
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('الصفحة الرئيسية'),
                onTap: () => context.go('/home'),
              ),
              
              // المنتجات
              ListTile(
                leading: const Icon(Icons.shopping_bag),
                title: const Text('المنتجات'),
                onTap: () => context.go('/products'),
              ),
              
              // السلة
              ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: const Text('سلة التسوق'),
                onTap: () => context.go('/cart'),
              ),
              
              // الطلبات
              ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text('طلباتي'),
                onTap: () => context.go('/orders'),
              ),
              
              const Divider(),
              
              // خيارات المالك
              if (user.isOwner) ...[
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('لوحة التحكم'),
                  onTap: () => context.go('/admin/dashboard'),
                ),
                
                ListTile(
                  leading: const Icon(Icons.add_business),
                  title: const Text('إضافة منتج'),
                  onTap: () => context.go('/admin/add-product'),
                ),
                
                ListTile(
                  leading: const Icon(Icons.inventory),
                  title: const Text('إدارة المنتجات'),
                  onTap: () => context.go('/admin/products'),
                ),
                
                const Divider(),
              ],
              
              // الملف الشخصي
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('الملف الشخصي'),
                onTap: () => context.go('/profile'),
              ),
              
              // الإعدادات
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('الإعدادات'),
                onTap: () => context.go('/settings'),
              ),
              
              // تسجيل الخروج
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  context.read<AuthBloc>().add(LogoutEvent());
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) return const SizedBox.shrink();
        
        return CustomCard(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً، ${state.user.name}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.user.isOwner 
                        ? 'مرحباً بك في لوحة إدارة متجرك'
                        : 'اكتشف أحدث الألبسة التقليدية والعصرية',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.waving_hand,
                size: 40,
                color: AppColors.primary,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOwnerStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomCard(
                backgroundColor: AppColors.success.withOpacity(0.1),
                child: Column(
                  children: [
                    const Icon(Icons.shopping_bag, size: 32, color: AppColors.success),
                    const SizedBox(height: 8),
                    Text(
                      '0',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('منتج'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomCard(
                backgroundColor: AppColors.info.withOpacity(0.1),
                child: Column(
                  children: [
                    const Icon(Icons.receipt, size: 32, color: AppColors.info),
                    const SizedBox(height: 8),
                    Text(
                      '0',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('طلب'),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    final categories = [
      {'name': 'الثياب التقليدية', 'icon': Icons.mosque},
      {'name': 'الثياب العصرية', 'icon': Icons.checkroom},
      {'name': 'الأحذية', 'icon': Icons.face_retouching_natural},
      {'name': 'الإكسسوارات', 'icon': Icons.watch},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الفئات',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Container(
                margin: const EdgeInsets.only(left: 16),
                child: CustomCard(
                  onTap: () {
                    // TODO: الانتقال لصفحة الفئة
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        size: 32,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name'] as String,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المنتجات المميزة',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
              onPressed: () => context.go('/products'),
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BlocBuilder<ProductBloc, ProductState>(
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
              if (state.products.isEmpty) {
                return const CustomErrorWidget(
                  message: 'لا توجد منتجات متاحة',
                  icon: Icons.inventory_2_outlined,
                );
              }
              
              final featuredProducts = state.products.take(4).toList();
              
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: featuredProducts.length,
                itemBuilder: (context, index) {
                  final product = featuredProducts[index];
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
                        
                        // السعر
                        Text(
                          '${product.price.toStringAsFixed(0)} ل.س',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated && state.user.isOwner) {
          return FloatingActionButton(
            onPressed: () => context.go('/admin/add-product'),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: AppColors.white),
          );
        }
        return null;
      },
    );
  }
}