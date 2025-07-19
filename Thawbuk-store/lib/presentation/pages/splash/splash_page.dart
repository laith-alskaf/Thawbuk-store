import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../navigation/app_router.dart';
import '../../../core/theme/app_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthStatus();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  void _checkAuthStatus() {
    Future.delayed(const Duration(milliseconds: 3000), () {
      // فحص حالة المصادقة
      context.read<AuthBloc>().add(CheckAuthStatusEvent());
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthenticatedState) {
            context.goNamed('home');
          } else if (state is UnauthenticatedState) {
            context.goNamed('home'); // يمكن للزوار التصفح
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Column(
                      children: [
                        // شعار التطبيق
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.checkroom,
                            size: 80,
                            color: AppColors.primary,
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // اسم التطبيق
                        Text(
                          'ثوبك',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 48,
                          ),
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // الشعار
                        Text(
                          'حيث يلتقي التراث بالموضة',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.white.withOpacity(0.9),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 80),
              
              // مؤشر التحميل
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}