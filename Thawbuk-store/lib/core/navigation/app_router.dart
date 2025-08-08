// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:thawbuk_store/core/di/dependency_injection.dart';
// import 'package:thawbuk_store/presentation/bloc/auth/auth_bloc.dart';
// import 'package:thawbuk_store/presentation/pages/product/product_details_page.dart';

// // Core
// // BLoCs
// // import '../../presentation/blocs/product/product_bloc.dart';
// // import '../../presentation/blocs/category/category_bloc.dart';
// // import '../../presentation/blocs/cart/cart_bloc.dart';
// // import '../../presentation/blocs/wishlist/wishlist_bloc.dart';

// // Pages
// import '../../presentation/pages/splash/splash_page.dart';
// import '../../presentation/pages/auth/login_page.dart';
// import '../../presentation/pages/auth/register_page.dart';
// import '../../presentation/pages/auth/forgot_password_page.dart';
// import '../../presentation/pages/auth/verify_email_page.dart';
// import '../../presentation/pages/home/home_page.dart';
// import '../../presentation/pages/products/products_page.dart';
// import '../../presentation/pages/categories/categories_page.dart';
// import '../../presentation/pages/cart/cart_page.dart';
// import '../../presentation/pages/wishlist/wishlist_page.dart';
// import '../../presentation/pages/profile/profile_page.dart';
// import '../../presentation/pages/orders/orders_page.dart';
// import '../../presentation/pages/search/search_page.dart';

// // Admin Pages
// import '../../presentation/pages/admin/admin_dashboard_page.dart';
// import '../../presentation/pages/admin/admin_products_page.dart';
// import '../../presentation/pages/admin/admin_categories_page.dart';
// import '../../presentation/pages/admin/admin_orders_page.dart';
// import '../../presentation/pages/admin/all_products_page.dart';
// import '../../presentation/pages/admin/admin_profile_page.dart';
// import '../../presentation/pages/admin/admin_settings_page.dart';
// import '../../presentation/pages/admin/add_product_page.dart';

// // Layouts
// import '../../presentation/layouts/main_layout.dart';
// import '../../presentation/layouts/admin_layout.dart';

// class AppRouter {
//   static final _rootNavigatorKey = GlobalKey<NavigatorState>();
//   static final _shellNavigatorKey = GlobalKey<NavigatorState>();
//   static final _adminShellNavigatorKey = GlobalKey<NavigatorState>();

//   static GoRouter get router => _router;

//   static final GoRouter _router = GoRouter(
//     navigatorKey: _rootNavigatorKey,
//     initialLocation: '/splash',
//     debugLogDiagnostics: true,
//     routes: [
//       // Splash Screen
//       GoRoute(
//         path: '/splash',
//         name: 'splash',
//         builder: (context, state) {
//           print('Router: Creating BlocProvider for SplashPage');
//           return BlocProvider(
//             create: (context) {
//               print('Router: Getting AuthBloc from DI');
//               final authBloc = getIt<AuthBloc>();
//               print('Router: AuthBloc obtained: $authBloc');
//               return authBloc;
//             },
//             child: const SplashPage(),
//           );
//         },
//       ),

//       // Auth Routes
//       GoRoute(
//         path: '/auth/login',
//         name: 'login',
//         builder: (context, state) => BlocProvider(
//           create: (context) => getIt<AuthBloc>(),
//           child: const LoginPage(),
//         ),
//       ),

//       GoRoute(
//         path: '/auth/register',
//         name: 'register',
//         builder: (context, state) => BlocProvider(
//           create: (context) => getIt<AuthBloc>(),
//           child: const RegisterPage(),
//         ),
//       ),

//       GoRoute(
//         path: '/auth/forgot-password',
//         name: 'forgot-password',
//         builder: (context, state) => BlocProvider(
//           create: (context) => getIt<AuthBloc>(),
//           child: const ForgotPasswordPage(),
//         ),
//       ),

//       GoRoute(
//         path: '/auth/verify-email',
//         name: 'verify-email',
//         builder: (context, state) {
//           final email = state.uri.queryParameters['email'] ?? '';
//           return BlocProvider(
//             create: (context) => getIt<AuthBloc>(),
//             child: VerifyEmailPage(email: email),
//           );
//         },
//       ),

//       // Customer Shell Route
//       ShellRoute(
//         navigatorKey: _shellNavigatorKey,
//         builder: (context, state, child) {
//           return MultiBlocProvider(
//             providers: [
//               BlocProvider(create: (context) => getIt<AuthBloc>()),
//               // BlocProvider(create: (context) => getIt<CartBloc>()),
//               // BlocProvider(create: (context) => getIt<WishlistBloc>()),
//             ],
//             child: MainLayout(child: child,currentIndex: 0,),
//           );
//         },
//         routes: [
//           // Home
//           GoRoute(
//             path: '/home',
//             name: 'home',
//             builder: (context, state) => MultiBlocProvider(
//               providers: [
//                 // BlocProvider(create: (context) => getIt<ProductBloc>()),
//                 // BlocProvider(create: (context) => getIt<CategoryBloc>()),
//               ],
//               child: const HomePage(),
//             ),
//           ),

//           // Products
//           GoRoute(
//             path: '/products',
//             name: 'products',
//             builder: (context, state) => const ProductsPage(),
//             routes: [
//               GoRoute(
//                 path: ':productId',
//                 name: 'product-details',
//                 builder: (context, state) {
//                   final productId = state.pathParameters['productId']!;
//                   return ProductDetailsPage(productId: productId);
//                 },
//               ),
//             ],
//           ),

//           // Categories
//           GoRoute(
//             path: '/categories',
//             name: 'categories',
//             builder: (context, state) => const CategoriesPage(),
//             routes: [
//               GoRoute(
//                 path: ':categoryId/products',
//                 name: 'category-products',
//                 builder: (context, state) {
//                   final categoryId = state.pathParameters['categoryId']!;
//                   final categoryName = state.uri.queryParameters['name'] ?? '';
//                   return ProductsPage(
//                     categoryId: categoryId,
//                     categoryName: categoryName,
//                   );
//                 },
//               ),
//             ],
//           ),

//           // Cart
//           GoRoute(
//             path: '/cart',
//             name: 'cart',
//             builder: (context, state) => const CartPage(),
//           ),

//           // Wishlist
//           GoRoute(
//             path: '/wishlist',
//             name: 'wishlist',
//             builder: (context, state) => const WishlistPage(),
//           ),

//           // Orders
//           GoRoute(
//             path: '/orders',
//             name: 'orders',
//             builder: (context, state) => const OrdersPage(),
//           ),

//           // Profile
//           GoRoute(
//             path: '/profile',
//             name: 'profile',
//             builder: (context, state) => BlocProvider(
//               create: (context) => getIt<AuthBloc>(),
//               child: const ProfilePage(),
//             ),
//           ),

//           // Search
//           GoRoute(
//             path: '/search',
//             name: 'search',
//             builder: (context, state) {
//               return const SearchPage();
//             },
//           ),
//         ],
//       ),

//       // Admin Shell Route
//       ShellRoute(
//         navigatorKey: _adminShellNavigatorKey,
//         builder: (context, state, child) {
//           return BlocProvider(
//             create: (context) => getIt<AuthBloc>(),
//             child: AdminLayout(child: child, currentIndex: 0),
//           );
//         },
//         routes: [
//           // Admin Dashboard
//           GoRoute(
//             path: '/admin/dashboard',
//             name: 'admin-dashboard',
//             builder: (context, state) => const AdminDashboardPage(),
//           ),

//           // Admin Products
//           GoRoute(
//             path: '/admin/products',
//             name: 'admin-products',
//             builder: (context, state) => const AdminProductsPage(),
//           ),

//           // Admin Categories
//           GoRoute(
//             path: '/admin/categories',
//             name: 'admin-categories',
//             builder: (context, state) => const AdminCategoriesPage(),
//           ),

//           // Admin Orders
//           GoRoute(
//             path: '/admin/orders',
//             name: 'admin-orders',
//             builder: (context, state) => const AdminOrdersPage(),
//           ),
//         ],
//       ),

//       // Additional Admin Routes (outside shell for full-screen experience)
//       GoRoute(
//         path: '/admin/all-products',
//         name: 'admin-all-products',
//         builder: (context, state) => const AllProductsPage(),
//       ),
      
//       GoRoute(
//         path: '/admin/profile',
//         name: 'admin-profile',
//         builder: (context, state) => const AdminProfilePage(),
//       ),
      
//       GoRoute(
//         path: '/admin/settings',
//         name: 'admin-settings',
//         builder: (context, state) => const AdminSettingsPage(),
//       ),
      
//       GoRoute(
//         path: '/admin/add-product',
//         name: 'admin-add-product',
//         builder: (context, state) => const AddProductPage(),
//       ),
//     ],

//     // Error Page
//     errorBuilder: (context, state) => Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.error_outline,
//               size: 64,
//               color: Colors.red,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'صفحة غير موجودة',
//               style: Theme.of(context).textTheme.headlineSmall,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'المسار: ${state.uri}',
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () => context.go('/home'),
//               child: const Text('العودة للرئيسية'),
//             ),
//           ],
//         ),
//       ),
//     ),

//     // Redirect Logic
//     redirect: (context, state) {
//       final isOnSplash = state.uri.toString() == '/splash';
//       final isOnAuth = state.uri.toString().startsWith('/auth');
      
//       // السماح بالوصول لشاشة البداية وصفحات المصادقة
//       if (isOnSplash || isOnAuth) {
//         return null;
//       }

//       // يمكن إضافة منطق إعادة التوجيه هنا حسب حالة المصادقة
//       return null;
//     },
//   );

//   // Navigation Helpers
//   static void goToHome() => _router.go('/home');
//   static void goToLogin() => _router.go('/auth/login');
//   static void goToRegister() => _router.go('/auth/register');
//   static void goToAdminDashboard() => _router.go('/admin/dashboard');
  
//   static void goToProductDetails(String productId) =>
//       _router.go('/products/$productId');
  
//   static void goToCategoryProducts(String categoryId, String categoryName) =>
//       _router.go('/categories/$categoryId/products?name=$categoryName');
  
//   static void goToSearch([String? query]) {
//     final queryParam = query != null ? '?q=$query' : '';
//     _router.go('/search$queryParam');
//   }

//   static void goToVerifyEmail(String email) =>
//       _router.go('/auth/verify-email?email=$email');

//   // Back Navigation
//   static void pop() => _router.pop();
//   static bool canPop() => _router.canPop();
// }