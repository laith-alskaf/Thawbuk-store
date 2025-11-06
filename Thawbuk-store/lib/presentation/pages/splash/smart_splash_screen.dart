import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer';

import '../../../core/services/app_initialization_service.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/cache/cache_initialization_service.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../navigation/app_router_improved.dart';
import '../../widgets/loading_indicator.dart';

/// شاشة البداية الذكية مع التحميل المتقدم
class SmartSplashScreen extends StatefulWidget {
  const SmartSplashScreen({super.key});

  @override
  State<SmartSplashScreen> createState() => _SmartSplashScreenState();
}

class _SmartSplashScreenState extends State<SmartSplashScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _logoController;
  late AnimationController _progressController;
  late Animation<double> _logoAnimation;
  late Animation<double> _progressAnimation;
  
  String _currentStep = 'تهيئة التطبيق...';
  double _progress = 0.0;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _logoController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      log('🚀 Starting smart app initialization...');

      // خطوة 1: تهيئة النظام الأساسي
      await _updateProgress('تهيئة النظام الأساسي...', 0.2);
      await AppInitializationService.instance.initialize();

      // خطوة 2: تحميل حالة المصادقة
      await _updateProgress('فحص حالة تسجيل الدخول...', 0.4);
      await _checkAuthenticationState();

      // خطوة 3: تحميل البيانات الأساسية
      await _updateProgress('تحميل البيانات الأساسية...', 0.6);
      await _preloadEssentialData();

      // خطوة 4: إعداد التخزين المؤقت
      await _updateProgress('إعداد التخزين الذكي...', 0.8);
      await _configureCacheSystem();

      // خطوة 5: اكتمال التهيئة
      await _updateProgress('اكتمال التهيئة...', 1.0);
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        await _navigateToApp();
      }

    } catch (e) {
      log('❌ App initialization error: $e');
      setState(() {
        _hasError = true;
        _errorMessage = _getErrorMessage(e);
      });
    }
  }

  Future<void> _updateProgress(String step, double progress) async {
    if (!mounted) return;
    
    setState(() {
      _currentStep = step;
      _progress = progress;
    });
    
    _progressController.reset();
    _progressController.forward();
    
    // تأخير قصير لإظهار التقدم
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _checkAuthenticationState() async {
    try {
      // فحص حالة المصادقة المحفوظة
      final authBloc = context.read<AuthBloc>();
      authBloc.add(CheckAuthStatusEvent());
      
      // انتظار قصير للحصول على النتيجة
      await Future.delayed(const Duration(milliseconds: 500));
      
    } catch (e) {
      log('⚠️ Error checking auth state: $e');
      // لا نريد إيقاف التطبيق بسبب هذا الخطأ
    }
  }

  Future<void> _preloadEssentialData() async {
    try {
      // تحميل البيانات الأساسية في الخلفية
      // هذا سيتم عبر المستودعات المحسنة
      log('📦 Preloading essential data...');
      
      // تحميل الفئات
      // تحميل المنتجات المميزة
      // تحميل إعدادات التطبيق
      
    } catch (e) {
      log('⚠️ Error preloading data: $e');
      // نكمل دون هذه البيانات
    }
  }

  Future<void> _configureCacheSystem() async {
    try {
      final cacheService = CacheInitializationService.instance;
      
      // التأكد من أن النظام مهيأ بشكل صحيح
      if (!cacheService.isInitialized) {
        throw Exception('Cache system not properly initialized');
      }
      
      log('✅ Cache system configured successfully');
    } catch (e) {
      log('❌ Error configuring cache system: $e');
      rethrow;
    }
  }

  Future<void> _navigateToApp() async {
    try {
      final router = getIt<AppRouterImproved>();
      
      // تحديد الصفحة المناسبة حسب حالة المصادقة
      final authState = context.read<AuthBloc>().state;
      
      if (authState is AuthAuthenticated) {
        // مستخدم مسجل الدخول
        log('👤 Navigating to authenticated app for: ${authState.user.email}');
        router.router.go('/home');
      } else {
        // زائر أو غير مسجل الدخول
        log('👥 Navigating to guest app');
        router.router.go('/welcome');
      }
      
    } catch (e) {
      log('❌ Error navigating to app: $e');
      // في حالة الخطأ، انتقل للصفحة الرئيسية
      Navigator.of(context).pushReplacementNamed('/welcome');
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('network')) {
      return 'خطأ في الاتصال بالإنترنت. يرجى التحقق من اتصالك والمحاولة مرة أخرى.';
    } else if (error.toString().contains('cache')) {
      return 'خطأ في تهيئة نظام التخزين. سيتم تشغيل التطبيق بدون تخزين محلي.';
    } else {
      return 'حدث خطأ غير متوقع. يرجى إعادة تشغيل التطبيق.';
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: _buildLogo(),
              ),
              
              Expanded(
                flex: 2,
                child: _hasError ? _buildErrorView() : _buildProgressView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: AnimatedBuilder(
        animation: _logoAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _logoAnimation.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
                    size: 60,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'ثوبك',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'متجرك للأزياء التراثية والعصرية',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  Text(
                    _currentStep,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  
                  Stack(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 6,
                        width: MediaQuery.of(context).size.width * 0.8 * _progress,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  Text(
                    '${(_progress * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 40),
          
          // مؤشر التحميل الدوار
          const LoadingIndicator(
            color: Colors.white,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          
          Text(
            'حدث خطأ في التهيئة',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            _errorMessage ?? 'خطأ غير محدد',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _errorMessage = null;
                      _progress = 0.0;
                    });
                    _initializeApp();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('إعادة المحاولة'),
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    // تشغيل التطبيق بدون تهيئة كاملة
                    await _navigateToApp();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('المتابعة'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}