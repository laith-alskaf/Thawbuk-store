import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../navigation/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // تحميل المنتجات والفئات
    context.read<ProductBloc>().add(LoadProductsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            // البانر الرئيسي
            SliverToBoxAdapter(
              child: _buildHeroBanner(),
            ),
            
            // الفئات
            SliverToBoxAdapter(
              child: _buildCategoriesSection(),
            ),
            
            // المنتجات المميزة
            SliverToBoxAdapter(
              child: _buildFeaturedProductsSection(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildCartButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('ثوبك'),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // فتح صفحة البحث
            context.goNamed('products');
          },
        ),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthenticatedState) {
              return IconButton(
                icon: const Icon(Icons.account_circle),
                onPressed: () {
                  context.goNamed('profile');
                },
              );
            }
            return IconButton(
              icon: const Icon(Icons.login),
              onPressed: () {
                context.goNamed('login');
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.checkroom,
                  size: 60,
                  color: AppColors.white,
                ),
                const SizedBox(height: 10),
                Text(
                  'ثوبك',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('الرئيسية'),
            onTap: () {
              Navigator.pop(context);
              context.goNamed('home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('المنتجات'),
            onTap: () {
              Navigator.pop(context);
              context.goNamed('products');
            },
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthenticatedState) {
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.shopping_cart),
                      title: const Text('سلة التسوق'),
                      onTap: () {
                        Navigator.pop(context);
                        context.goNamed('cart');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('الملف الشخصي'),
                      onTap: () {
                        Navigator.pop(context);
                        context.goNamed('profile');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('تسجيل خروج'),
                      onTap: () {
                        Navigator.pop(context);
                        context.read<AuthBloc>().add(LogoutEvent());
                      },
                    ),
                  ],
                );
              }
              return ListTile(
                leading: const Icon(Icons.login),
                title: const Text('تسجيل الدخول'),
                onTap: () {
                  Navigator.pop(context);
                  context.goNamed('login');
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 20,
            top: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أحدث التشكيلات',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'اكتشف الأزياء التراثية الأصيلة',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.goNamed('products');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('تصفح الآن'),
                ),
              ],
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
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'الفئات',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5, // مؤقتاً
            itemBuilder: (context, index) {
              return Container(
                width: 100,
                margin: const EdgeInsets.only(left: 12),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.checkroom,
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'فئة ${index + 1}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المنتجات المميزة',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextButton(
                onPressed: () {
                  context.goNamed('products');
                },
                child: const Text('عرض الكل'),
              ),
            ],
          ),
        ),
        BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoadingState) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            if (state is ProductLoadedState) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: state.products.length > 4 ? 4 : state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return _buildProductCard(product);
                },
              );
            }
            
            return const SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(dynamic product) {
    return Card(
      child: InkWell(
        onTap: () {
          context.goNamed(
            'productDetails',
            pathParameters: {'id': 'product-1'}, // مؤقتاً
          );
        },
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppConstants.borderRadius),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image,
                    size: 50,
                    color: AppColors.grey,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'منتج تجريبي',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '150 ريال',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag),
          label: 'المنتجات',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'المفضلة',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'الحساب',
        ),
      ],
    );
  }

  Widget _buildCartButton() {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        int itemCount = 0;
        if (state is CartLoadedState) {
          itemCount = state.cart.totalItems;
        }

        return FloatingActionButton(
          onPressed: () {
            context.goNamed('cart');
          },
          backgroundColor: AppColors.secondary,
          child: Stack(
            children: [
              const Icon(Icons.shopping_cart),
              if (itemCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$itemCount',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onRefresh() async {
    context.read<ProductBloc>().add(LoadProductsEvent());
    // يمكن إضافة المزيد من التحديثات هنا
  }
}