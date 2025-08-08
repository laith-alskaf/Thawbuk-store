import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../bloc/category/category_bloc.dart';
import '../../bloc/category/category_event.dart';
import '../../bloc/category/category_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/navigation_helper.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../widgets/products/product_card.dart';
import '../../widgets/shared/unified_app_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(GetProductsEvent());
    context.read<CategoryBloc>().add(GetCategoriesEvent());
    
    // تحميل السلة فقط للمستخدمين المسجلين
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CartBloc>().add(GetCartEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return Scaffold(
          appBar: const UnifiedAppBar(
            title: 'الرئيسية',
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<ProductBloc>().add(GetProductsEvent());
              // تحديث السلة فقط للمستخدمين المسجلين
              if (authState is AuthAuthenticated) {
                context.read<CartBloc>().add(GetCartEvent());
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  if (authState is AuthAuthenticated)
                    _buildWelcomeSection(authState.user),
                  
                  const SizedBox(height: 24),

                  // Categories Section
                  _buildCategoriesSection(),
                  
                  const SizedBox(height: 24),

                  // Featured Products Section
                  Text(
                    'المنتجات المميزة',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),

                  // Products Grid
                  BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      if (state is ProductLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (state is ProductsLoaded) {
                        return _buildProductsGrid(state.products);
                      } else if (state is ProductError) {
                        return Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.message,
                                style: TextStyle(color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<ProductBloc>().add(GetProductsEvent());
                                },
                                child: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return const Center(
                          child: Text('لا توجد منتجات'),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/products'),
            child: const Icon(Icons.store),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(UserEntity user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرحباً ${user.name}!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اكتشف أجمل الأزياء التقليدية والعصرية',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التصنيفات',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              if (state is CategoryLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CategoriesLoaded) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    return GestureDetector(
                      onTap: () {
                        context.push('/products?category=${category.id}');
                      },
                      child: Container(
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.category, // Default icon
                              size: 32,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category.displayName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else if (state is CategoryError) {
                return Center(child: Text(state.message));
              } else {
                return const Center(child: Text('لا توجد تصنيفات'));
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductsGrid(List<ProductEntity> products) {
    if (products.isEmpty) {
      return const Center(
        child: Text('لا توجد منتجات'),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length > 4 ? 4 : products.length, // Show only 4 on home
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => context.push('/app/product/${product.id}'),
          onAddToCart: () {
            // التحقق من تسجيل الدخول قبل الإضافة للسلة
            if (NavigationHelper.addToCart(context)) {
              context.read<CartBloc>().add(
                    AddToCartEvent(
                      productId: product.id,
                      quantity: 1,
                    ),
                  );
              NavigationHelper.showSuccessMessage(context, 'تم إضافة المنتج للسلة');
            }
          },
          onToggleWishlist: () {
            // التحقق من تسجيل الدخول قبل الإضافة للمفضلة
            NavigationHelper.addToFavorites(context);
          },
        );
      },
    );
  }

  /// بناء قائمة الملف الشخصي بناءً على حالة تسجيل الدخول
  Widget _buildProfileMenu(BuildContext context, AuthState authState) {
    if (authState is AuthAuthenticated) {
      // المستخدم مسجل دخول - عرض القائمة الكاملة
      return PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'profile':
              NavigationHelper.goToProfile(context);
              break;
            case 'orders':
              NavigationHelper.goToOrders(context);
              break;
            case 'favorites':
              NavigationHelper.goToFavorites(context);
              break;
            case 'settings':
              context.push('/settings');
              break;
            case 'admin':
              context.push('/admin/dashboard');
              break;
            case 'logout':
              NavigationHelper.logout(context);
              break;
          }
        },
        itemBuilder: (context) {
          final items = <PopupMenuEntry<String>>[
            const PopupMenuItem(
              value: 'profile',
              child: ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('الملف الشخصي'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'orders',
              child: ListTile(
                leading: Icon(Icons.list_alt),
                title: Text('طلباتي'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'favorites',
              child: ListTile(
                leading: Icon(Icons.favorite),
                title: Text('المفضلة'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('الإعدادات'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ];

          // إضافة قائمة الإدارة للمالكين
          if (authState.user.role == 'admin' || authState.user.role == 'superAdmin') {
            items.add(
              const PopupMenuItem(
                value: 'admin',
                child: ListTile(
                  leading: Icon(Icons.dashboard),
                  title: Text('لوحة الإدارة'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            );
          }

          items.add(
            const PopupMenuItem(
              value: 'logout',
              child: ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.red),
                title: Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          );

          return items;
        },
        child: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            authState.user.name.substring(0, 1).toUpperCase() ,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else {
      // المستخدم غير مسجل دخول - عرض أزرار تسجيل الدخول والتسجيل
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => NavigationHelper.goToLogin(context),
            child: const Text('دخول'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => NavigationHelper.goToRegister(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('تسجيل'),
          ),
        ],
      );
    }
  }
}
