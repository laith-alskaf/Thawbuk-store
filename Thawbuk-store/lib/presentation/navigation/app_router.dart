import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_bloc.dart';
import '../pages/splash/splash_page.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/home/home_page.dart';
import '../pages/products/products_page.dart';
import '../pages/products/product_detail_page.dart';
import '../pages/cart/cart_page.dart';
import '../pages/orders/orders_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/admin/add_product_page.dart';
import '../pages/admin/admin_products_page.dart';
import '../pages/admin/admin_dashboard_page.dart';

class AppRouter {
  late final GoRouter router;

  AppRouter() {
    router = GoRouter(
      initialLocation: '/splash',
      routes: [
        // Splash
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),

        // Auth Routes
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),

        // Main App Routes
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        
        // Products
        GoRoute(
          path: '/products',
          name: 'products',
          builder: (context, state) => const ProductsPage(),
        ),
        GoRoute(
          path: '/product/:id',
          name: 'product-detail',
          builder: (context, state) {
            final productId = state.pathParameters['id']!;
            return ProductDetailPage(productId: productId);
          },
        ),

        // Cart
        GoRoute(
          path: '/cart',
          name: 'cart',
          builder: (context, state) => const CartPage(),
        ),

        // Orders
        GoRoute(
          path: '/orders',
          name: 'orders',
          builder: (context, state) => const OrdersPage(),
        ),

        // Profile
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),

        // Admin Routes
        GoRoute(
          path: '/admin/dashboard',
          name: 'admin-dashboard',
          builder: (context, state) => const AdminDashboardPage(),
        ),
        GoRoute(
          path: '/admin/add-product',
          name: 'admin-add-product',
          builder: (context, state) => const AddProductPage(),
        ),
        GoRoute(
          path: '/admin/products',
          name: 'admin-products',
          builder: (context, state) => const AdminProductsPage(),
        ),
      ],
      
      // Redirect logic
      redirect: (context, state) {
        final authBloc = context.read<AuthBloc>();
        final authState = authBloc.state;
        
        final isGoingToLogin = state.location == '/login';
        final isGoingToRegister = state.location == '/register';
        final isGoingToSplash = state.location == '/splash';
        
        // If on splash, let it handle the navigation
        if (isGoingToSplash) return null;
        
        if (authState is AuthUnauthenticated) {
          if (isGoingToLogin || isGoingToRegister) return null;
          return '/login';
        }
        
        if (authState is AuthAuthenticated) {
          if (isGoingToLogin || isGoingToRegister) return '/home';
          
          // Admin route protection
          final isGoingToAdmin = state.location.startsWith('/admin');
          if (isGoingToAdmin && !authState.user.isOwner) {
            return '/home';
          }
        }
        
        return null;
      },
      
      // Error handling
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'صفحة غير موجودة',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('العودة للرئيسية'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}