import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../shared/custom_button.dart';

class LoginRequiredDialog extends StatelessWidget {
  final String? feature;

  const LoginRequiredDialog({
    Key? key,
    this.feature,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة تحذيرية جميلة
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.lock_outline,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // العنوان
            Text(
              'تسجيل الدخول مطلوب',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // الرسالة
            Text(
              _getFeatureMessage(feature),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 30),
            
            // الأزرار
            Row(
              children: [
                // زر تسجيل الدخول
                Expanded(
                  child: CustomButton(
                    text: 'تسجيل الدخول',
                    onPressed: () {
                      context.pop(); // إغلاق الـ dialog
                      context.pushReplacement('/login'); // التوجه لتسجيل الدخول
                    },
                    backgroundColor: AppColors.primary,
                    icon: Icons.login,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // زر إنشاء حساب
                Expanded(
                  child: CustomButton(
                    text: 'إنشاء حساب',
                    onPressed: () {
                      context.pop(); // إغلاق الـ dialog
                      context.pushReplacement('/register'); // التوجه للتسجيل
                    },
                    isOutlined: true,
                    backgroundColor: AppColors.white,
                    textColor: AppColors.primary,
                    icon: Icons.person_add,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // زر الإلغاء
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'متابعة كزائر',
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFeatureMessage(String? feature) {
    switch (feature) {
      case 'cart':
        return 'لإضافة المنتجات إلى السلة والشراء، يجب عليك تسجيل الدخول أو إنشاء حساب جديد.';
      case 'favorites':
        return 'لحفظ المنتجات المفضلة لديك، يجب عليك تسجيل الدخول أو إنشاء حساب جديد.';
      case 'orders':
        return 'لعرض طلباتك وتتبعها، يجب عليك تسجيل الدخول أو إنشاء حساب جديد.';
      case 'profile':
        return 'لإدارة حسابك وبياناتك الشخصية، يجب عليك تسجيل الدخول أو إنشاء حساب جديد.';
      case 'checkout':
        return 'لإتمام عملية الشراء، يجب عليك تسجيل الدخول أو إنشاء حساب جديد.';
      case 'reviews':
        return 'لكتابة تقييم للمنتج، يجب عليك تسجيل الدخول أو إنشاء حساب جديد.';
      default:
        return 'للاستفادة من جميع ميزات التطبيق، يجب عليك تسجيل الدخول أو إنشاء حساب جديد.';
    }
  }
}