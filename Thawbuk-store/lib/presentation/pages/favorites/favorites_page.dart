import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/guards/auth_guard.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/shared/custom_button.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (!AuthGuard.isAuthenticated(context)) {
          return _buildGuestView(context);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('المفضلة'),
            backgroundColor: Colors.white,
            foregroundColor: AppColors.black,
            elevation: 1,
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 80,
                  color: AppColors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'لا توجد منتجات مفضلة',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'ابدأ بإضافة منتجات إلى قائمة المفضلة',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.black,
        elevation: 1,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.favorite,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'سجل دخولك لحفظ المفضلة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              const Text(
                'احفظ منتجاتك المفضلة واحصل عليها بسهولة في أي وقت',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.grey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // أزرار التسجيل
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'تسجيل الدخول',
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'إنشاء حساب',
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/register');
                      },
                      isOutlined: true,
                      backgroundColor: Colors.white,
                      textColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}