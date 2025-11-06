import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer';

import '../core/services/app_initialization_service.dart';
import '../core/cache/cache_initialization_service.dart';
import '../core/di/dependency_injection.dart';
import '../domain/entities/user_entity.dart';
import 'pages/splash/smart_splash_screen.dart';
import 'app.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/theme/theme_cubit.dart';
import 'bloc/cart/cart_bloc.dart';
import 'bloc/wishlist/wishlist_bloc.dart';
import 'bloc/product/product_bloc.dart';
import 'bloc/category/category_bloc.dart';

/// التطبيق مع التهيئة الذكية والتخزين المؤقت المتقدم
class AppWithSmartInitialization extends StatefulWidget {
  const AppWithSmartInitialization({super.key});

  @override
  State<AppWithSmartInitialization> createState() => _AppWithSmartInitializationState();
}

class _AppWithSmartInitializationState extends State<AppWithSmartInitialization> {
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      log('🔧 Starting app initialization process...');
      
      // تهيئة التطبيق باستخدام خدمة التهيئة الذكية
      await AppInitializationService.instance.initialize();
      
      setState(() {
        _isInitialized = true;
      });
      
      log('✅ App initialization completed successfully');
      
    } catch (e) {
      log('❌ App initialization failed: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // في حالة وجود خطأ
    if (_hasError) {
      return _buildErrorView();
    }
    
    // في حالة عدم اكتمال التهيئة
    if (!_isInitialized) {
      return _buildInitializationView();
    }
    
    // التطبيق مهيأ بنجاح - عرض التطبيق الكامل
    return _buildMainApp();
  }

  Widget _buildErrorView() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'خطأ في تهيئة التطبيق',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage ?? 'حدث خطأ غير متوقع',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _errorMessage = null;
                      _isInitialized = false;
                    });
                    _initializeApp();
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitializationView() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _buildSplashWithMinimalProviders(),
    );
  }

  Widget _buildMainApp() {
    return MultiBlocProvider(
      providers: [
        // الـ Blocs الأساسية
        BlocProvider<ThemeCubit>(
          create: (context) => getIt<ThemeCubit>(),
        ),
        
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>(),
        ),
        
        BlocProvider<ProductBloc>(
          create: (context) => getIt<ProductBloc>(),
        ),
        
        BlocProvider<CategoryBloc>(
          create: (context) => getIt<CategoryBloc>(),
        ),
        
        BlocProvider<CartBloc>(
          create: (context) => getIt<CartBloc>(),
        ),
        
        BlocProvider<WishlistBloc>(
          create: (context) => getIt<WishlistBloc>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              // تحديث نظام التخزين المؤقت حسب حالة المصادقة
              _updateCacheForAuthState(authState);
              
              return const App();
            },
          );
        },
      ),
    );
  }

  Widget _buildSplashWithMinimalProviders() {
    // نوفر فقط الـ providers الضرورية لشاشة البداية
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>(),
        ),
      ],
      child: const SmartSplashScreen(),
    );
  }

  void _updateCacheForAuthState(AuthState authState) {
    // تحديث نظام التخزين المؤقت حسب حالة المصادقة
    if (authState is AuthAuthenticated) {
      // مستخدم مسجل الدخول
      initializeCacheForUser(authState.user).catchError((e) {
        log('⚠️ Error updating cache for authenticated user: $e');
      });
    } else if (authState is AuthUnauthenticated) {
      // تسجيل خروج
      clearCacheOnLogout().catchError((e) {
        log('⚠️ Error clearing cache on logout: $e');
      });
    }
  }

  @override
  void dispose() {
    // تنظيف الموارد إذا لزم الأمر
    super.dispose();
  }
}

/// تهيئة التخزين المؤقت للمستخدم المسجل
Future<void> initializeCacheForUser(UserEntity user) async {
  try {
    final cacheService = CacheInitializationService.instance;
    await cacheService.initializeForUser(user);
  } catch (e) {
    log('❌ Error initializing cache for user: $e');
  }
}

/// مسح التخزين المؤقت عند تسجيل الخروج
Future<void> clearCacheOnLogout() async {
  try {
    final cacheService = CacheInitializationService.instance;
    await cacheService.initializeForGuest();
  } catch (e) {
    log('❌ Error clearing cache on logout: $e');
  }
}

/// مؤشر حالة التهيئة للتطوير
class InitializationStatusIndicator extends StatelessWidget {
  final bool isInitialized;
  final bool hasError;
  final String? errorMessage;

  const InitializationStatusIndicator({
    super.key,
    required this.isInitialized,
    required this.hasError,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getStatusColor().withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatusIcon(),
              size: 12,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              _getStatusText(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (hasError) return Colors.red;
    if (isInitialized) return Colors.green;
    return Colors.orange;
  }

  IconData _getStatusIcon() {
    if (hasError) return Icons.error;
    if (isInitialized) return Icons.check_circle;
    return Icons.hourglass_empty;
  }

  String _getStatusText() {
    if (hasError) return 'Error';
    if (isInitialized) return 'Ready';
    return 'Init...';
  }
}

/// معالج الأخطاء العام للتطبيق
class AppErrorHandler {
  static void handleError(dynamic error, StackTrace stackTrace) {
    log('🚨 App Error: $error\n$stackTrace');
    
    // هنا يمكن إضافة منطق إرسال الأخطاء لخدمات المراقبة
    // مثل Firebase Crashlytics, Sentry, إلخ.
    
    // في الوضع التطويري، اطبع التفاصيل
    if (kDebugMode) {
      FlutterError.presentError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        context: ErrorDescription('App initialization error'),
      ));
    }
  }
}

