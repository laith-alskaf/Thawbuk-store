import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_bloc.dart';
import '../pages/splash/splash_page.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/auth/verify_email_page.dart';
import '../pages/home/home_page.dart';
import '../pages/products/products_page.dart';
import '../pages/products/product_detail_page.dart';
import '../pages/cart/cart_page.dart';
import '../pages/orders/orders_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/settings/settings_page.dart';
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
        GoRoute(
          path: '/verify-email/:email',
          name: 'verify-email',
          builder: (context, state) {
            final email = state.pathParameters['email']!;
            return VerifyEmailPage(email: email);
          },
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
          builder: (context, state) {
            final category = state.uri.queryParameters['category'];
            return ProductsPage(category: category);
          },
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

        // Settings
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsPage(),
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

        final isGoingToLogin = state.matchedLocation == '/login';
        final isGoingToRegister = state.matchedLocation == '/register';
        final isGoingToSplash = state.matchedLocation == '/splash';
        final isGoingHome = state.matchedLocation == '/home';

        // If on splash, let it handle the navigation
        if (isGoingToSplash) return null;

        if (authState is AuthGuest) {
          final protectedRoutes = ['/cart', '/orders', '/profile', '/admin'];
          if (protectedRoutes.any((route) => state.matchedLocation.startsWith(route))) {
            // Show a dialog and redirect to login
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('تسجيل الدخول مطلوب'),
                  content: const Text('الرجاء تسجيل الدخول أو إنشاء حساب جديد للمتابعة.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go('/login');
                      },
                      child: const Text('تسجيل الدخول'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go('/register');
                      },
                      child: const Text('إنشاء حساب'),
                    ),
                  ],
                ),
              );
            });
            return '/home'; // Stay on the current page while the dialog is shown
          }
          return null;
        }

        if (authState is AuthUnauthenticated) {
          if (isGoingToLogin || isGoingToRegister) return null;
          return '/login';
        }

        if (authState is AuthAuthenticated) {
          if (isGoingToLogin || isGoingToRegister) return '/home';

          // Admin route protection
          final isGoingToAdmin = state.matchedLocation.startsWith('/admin');
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
