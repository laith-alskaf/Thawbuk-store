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
import '../../../domain/entities/user_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../widgets/products/product_card.dart';

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
    context.read<CartBloc>().add(GetCartEvent());
    context.read<CategoryBloc>().add(GetCategoriesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.store,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'ثوبك',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            foregroundColor: AppColors.black,
            elevation: 2,
            shadowColor: Colors.grey.withOpacity(0.3),
            centerTitle: false,
            actions: [
              // Cart Icon
              BlocBuilder<CartBloc, CartState>(
                builder: (context, cartState) {
                  int itemCount = 0;
                  if (cartState is CartLoaded) {
                    itemCount = cartState.cart.itemsCount;
                  }

                  return Badge(
                    label: Text(itemCount.toString()),
                    isLabelVisible: itemCount > 0,
                    child: IconButton(
                      icon: const Icon(Icons.shopping_bag), // أيقونة حقيبة تسوق أوضح
                      onPressed: () => context.push('/cart'),
                    ),
                  );
                },
              ),
              // Profile Menu
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'profile':
                      context.push('/profile');
                      break;
                    case 'settings':
                      context.push('/settings');
                      break;
                    case 'orders':
                      context.push('/orders');
                      break;
                    case 'admin':
                      context.push('/admin/dashboard');
                      break;
                    case 'logout':
                      context.read<AuthBloc>().add(LogoutEvent());
                      break;
                  }
                },
                itemBuilder: (context) {
                  final items = <PopupMenuEntry<String>>[
                    const PopupMenuItem(
                      value: 'profile',
                      child: ListTile(
                        leading: Icon(Icons.account_circle), // أيقونة حساب أوضح
                        title: Text('الملف الشخصي'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'settings',
                      child: ListTile(
                        leading: Icon(Icons.tune), // أيقونة إعدادات أوضح
                        title: Text('الإعدادات'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'orders',
                      child: ListTile(
                        leading: Icon(Icons.list_alt), // أيقونة قائمة أوضح للطلبات
                        title: Text('طلباتي'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ];

                  // Add admin menu for owners
                  if (authState is AuthAuthenticated && authState.user.isOwner) {
                    items.add(
                      const PopupMenuItem(
                        value: 'admin',
                        child: ListTile(
                          leading: Icon(Icons.dashboard), // أيقونة لوحة تحكم أوضح
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
                        leading: Icon(Icons.exit_to_app), // أيقونة خروج أوضح
                        title: Text('تسجيل الخروج'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  );

                  return items;
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<ProductBloc>().add(GetProductsEvent());
              context.read<CartBloc>().add(GetCartEvent());
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
            'مرحباً ${user.name ?? 'بك'}!',
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
          onTap: () => context.push('/product/${product.id}'),
          onAddToCart: () {
            context.read<CartBloc>().add(
                  AddToCartEvent(
                    productId: product.id,
                    quantity: 1,
                  ),
                );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إضافة المنتج للسلة'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          onToggleWishlist: () {
            // TODO: Implement wishlist functionality
          },
        );
      },
    );
  }
}
