import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../pages/splash/splash_page.dart';
import '../pages/home/home_page.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/product/products_page.dart';
import '../pages/product/product_details_page.dart';
import '../pages/cart/cart_page.dart';
import '../pages/profile/profile_page.dart';

class AppRouter {
  GoRouter get router => _router;

  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String products = '/products';
  static const String productDetails = '/product-details';
  static const String cart = '/cart';
  static const String profile = '/profile';

  final GoRouter _router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: products,
        name: 'products',
        builder: (context, state) => const ProductsPage(),
      ),
      GoRoute(
        path: '$productDetails/:id',
        name: 'productDetails',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return ProductDetailsPage(productId: productId);
        },
      ),
      GoRoute(
        path: cart,
        name: 'cart',
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
}