import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports
import '../../core/navigation/navigation_service.dart';
import '../../core/di/dependency_injection.dart';
import '../../domain/entities/product_entity.dart';

// Bloc imports
import '../bloc/auth/auth_bloc.dart';
import '../bloc/store/store_bloc.dart';

// Shell imports
import 'shells/main_app_shell.dart';
import 'shells/admin_shell.dart';

// Page imports
import '../pages/splash/splash_page.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/auth/email_verification_page.dart';

// Main app pages
import '../pages/home/home_page.dart';
import '../pages/products/products_page.dart';
import '../pages/cart/cart_page.dart';
import '../pages/favorites/favorites_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/products/product_detail_page.dart';
import '../pages/orders/orders_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/store/store_profile_page.dart';

// Admin pages
import '../pages/admin/admin_dashboard_page.dart';
import '../pages/admin/admin_products_page.dart';
import '../pages/admin/add_product_page.dart';
import '../pages/admin/all_products_page.dart';
import '../pages/admin/admin_profile_page.dart';
import '../pages/admin/products_analytics_page.dart';
import '../pages/admin/store_profile_page.dart' as admin_store;
import '../pages/admin/admin_settings_page.dart';

/// Router محسن مع shell routes ونظام تنقل هرمي واضح
class AppRouterImproved {
  late final GoRouter _router;
  GoRouter get router => _router;

  AppRouterImproved() {
    _router = GoRouter(
      initialLocation: '/splash',
      debugLogDiagnostics: true,
      
      // Global error handling
      onException: (context, state, router) {
        debugPrint('Router Exception: ${state.error}');
        router.go('/splash');
      },
      
      // Global redirect logic
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        return _handleGlobalRedirect(authState, state);
      },
      
      routes: [
        // Splash route (standalone)
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),

        // Auth routes (standalone)
        GoRoute(
          path: '/auth/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/login',
          name: 'login-short',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/auth/register',
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/auth/verify-email',
          name: 'verify-email',
          builder: (context, state) {
            final email = state.uri.queryParameters['email'];
            final token = state.uri.queryParameters['token'];
            final auto = state.uri.queryParameters['auto'] == 'true';
            return EmailVerificationPage(
              email: email,
              token: token,
              autoVerify: auto,
            );
          },
        ),

        // Main App Shell Route
        ShellRoute(
          builder: (context, state, child) => MainAppShell(child: child),
          routes: [
            GoRoute(
              path: '/app/home',
              name: 'app-home',
              pageBuilder: (context, state) => _buildPage(
                child: const HomePage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/app/products',
              name: 'app-products',
              pageBuilder: (context, state) => _buildPage(
                child: const ProductsPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/app/cart',
              name: 'app-cart',
              pageBuilder: (context, state) => _buildPage(
                child: const CartPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/app/favorites',
              name: 'app-favorites',
              pageBuilder: (context, state) => _buildPage(
                child: const FavoritesPage(),
                state: state,
              ),
            ),
          ],
        ),

        // Profile route (standalone - accessible via AppBar menu)
        GoRoute(
          path: '/app/profile',
          name: 'app-profile',
          builder: (context, state) => const ProfilePage(),
        ),

        // Admin redirect route (standalone)
        GoRoute(
          path: '/admin',
          name: 'admin',
          redirect: (context, state) => '/admin/dashboard',
        ),

        // Admin Shell Route
        ShellRoute(
          builder: (context, state, child) => AdminShell(child: child),
          routes: [
            GoRoute(
              path: '/admin/dashboard',
              name: 'admin-dashboard',
              pageBuilder: (context, state) => _buildPage(
                child: const AdminDashboardPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/admin/products',
              name: 'admin-products',
              pageBuilder: (context, state) => _buildPage(
                child: const AdminProductsPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/admin/add-product',
              name: 'admin-add-product',
              pageBuilder: (context, state) => _buildPage(
                child: const AddProductPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/admin/all-products',
              name: 'admin-all-products',
              pageBuilder: (context, state) => _buildPage(
                child: const AllProductsPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/admin/profile',
              name: 'admin-profile',
              pageBuilder: (context, state) => _buildPage(
                child: const AdminProfilePage(),
                state: state,
              ),
            ),
          ],
        ),

        // Standalone routes (push/pop navigation)
        
        // Product detail (can be accessed from both app and admin)
        GoRoute(
          path: '/product/:id',
          name: 'product-detail',
          builder: (context, state) {
            final productId = state.pathParameters['id']!;
            return ProductDetailPage(productId: productId);
          },
        ),

        // Orders page
        GoRoute(
          path: '/orders',
          name: 'orders',
          builder: (context, state) => const OrdersPage(),
        ),

        // Settings page
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),

        // Store profile page
        GoRoute(
          path: '/store/:id',
          name: 'store-profile',
          builder: (context, state) {
            final storeId = state.pathParameters['id']!;
            return BlocProvider(
              create: (context) => getIt<StoreBloc>(),
              child: UserStoreProfilePage(storeId: storeId),
            );
          },
        ),

        // Admin standalone routes
        GoRoute(
          path: '/admin/edit-product',
          name: 'admin-edit-product',
          builder: (context, state) {
            final product = state.extra as ProductEntity?;
            return _buildEditProductPage(product);
          },
        ),

        GoRoute(
          path: '/admin/products-analytics',
          name: 'admin-products-analytics',
          builder: (context, state) => const ProductsAnalyticsPage(),
        ),

        GoRoute(
          path: '/admin/store-profile',
          name: 'admin-store-profile',
          builder: (context, state) => const admin_store.StoreProfilePage(),
        ),

        GoRoute(
          path: '/admin/settings',
          name: 'admin-settings',
          builder: (context, state) => const AdminSettingsPage(),
        ),
      ],
    );

    // Set router in navigation service
    NavigationService.instance.setRouter(_router);
  }

  /// Handle global redirect logic
  String? _handleGlobalRedirect(AuthState authState, GoRouterState state) {
    final isLoggedIn = authState is AuthAuthenticated;
    final isGuest = authState is AuthGuest;
    final hasAccess = isLoggedIn || isGuest; // المستخدم لديه إذن للوصول (مسجل أو زائر)
    final isOnAuthRoute = state.uri.path.startsWith('/auth');
    final isOnSplash = state.uri.path == '/splash';
    final isOnAdminRoute = state.uri.path.startsWith('/admin');
    final isOnMainAppRoute = state.uri.path.startsWith('/app');

    // Allow splash page always
    if (isOnSplash) return null;

    // Redirect to login if no access (not logged in and not guest) and not on auth route
    if (!hasAccess && !isOnAuthRoute) {
      return '/auth/login';
    }

    // Redirect to home if logged in and on auth route (but allow guests to access auth)
    if (isLoggedIn && isOnAuthRoute) {
      return '/app/home';
    }

    // Block admin access for non-owners and guests
    if (isOnAdminRoute) {
      if (isGuest) {
        // الزوار لا يمكنهم الوصول للوحة الإدارة
        return '/app/home';
      } else if (authState is AuthAuthenticated) {
        final user = authState.user;
        if (!user.isOwner) {
          return '/app/home';
        }
      } else {
        // غير مصرح
        return '/auth/login';
      }
    }

    // Block guest from accessing profile (requires login)
    if (isGuest && state.uri.path == '/app/profile') {
      return '/auth/login';
    }

    // Default root redirect
    if (state.uri.path == '/') {
      return hasAccess ? '/app/home' : '/auth/login';
    }

    return null; // No redirect needed
  }

  /// Build page with consistent styling and transitions
  Page<void> _buildPage({
    required Widget child,
    required GoRouterState state,
    String? name,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      name: name ?? state.name,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: animation.drive(
            Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(
              CurveTween(curve: Curves.easeInOut),
            ),
          ),
          child: child,
        );
      },
    );
  }

  /// Build edit product page with proper app bar
  Widget _buildEditProductPage(ProductEntity? product) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل المنتج'),
        backgroundColor: const Color(0xFF2E7D32), // AppColors.primary
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: AddProductPage(product: product),
    );
  }
}

/// Custom transition page for better animation control
class CustomTransitionPage<T> extends Page<T> {
  final Widget child;
  final Transitionsbuilder transitionsBuilder;

  const CustomTransitionPage({
    required this.child,
    required this.transitionsBuilder,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: transitionsBuilder,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

typedef Transitionsbuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
);