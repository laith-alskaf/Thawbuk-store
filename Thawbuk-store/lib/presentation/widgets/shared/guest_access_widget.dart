import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import 'custom_button.dart';

/// مكون موحد لعرض رسالة للزوار في الصفحات المحمية
class GuestAccessWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final List<Widget>? additionalContent;

  const GuestAccessWidget({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.additionalContent,
  });

  /// Factory للسلة
  factory GuestAccessWidget.cart() {
    return GuestAccessWidget(
      title: 'تحتاج إلى تسجيل الدخول',
      message: 'سجل دخولك لحفظ منتجاتك في سلة التسوق\nوإتمام عمليات الشراء بسهولة',
      icon: Icons.shopping_cart_outlined,
      primaryButtonText: 'تسجيل الدخول',
      secondaryButtonText: 'إنشاء حساب جديد',
    );
  }

  /// Factory للمفضلة
  factory GuestAccessWidget.favorites() {
    return GuestAccessWidget(
      title: 'تحتاج إلى تسجيل الدخول',
      message: 'سجل دخولك لحفظ منتجاتك المفضلة\nوالوصول إليها في أي وقت',
      icon: Icons.favorite_outline,
      primaryButtonText: 'تسجيل الدخول',
      secondaryButtonText: 'إنشاء حساب جديد',
    );
  }

  /// Factory للطلبات
  factory GuestAccessWidget.orders() {
    return GuestAccessWidget(
      title: 'تحتاج إلى تسجيل الدخول',
      message: 'سجل دخولك لعرض تاريخ طلباتك\nوتتبع حالة الشحن',
      icon: Icons.history,
      primaryButtonText: 'تسجيل الدخول',
      secondaryButtonText: 'إنشاء حساب جديد',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة الصفحة
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // رسالة رئيسية
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // رسالة وصفية
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.grey,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // محتوى إضافي
            if (additionalContent != null) ...[
              ...additionalContent!,
              const SizedBox(height: 24),
            ],
            
            // أزرار العمل
            Column(
              children: [
                // زر رئيسي
                if (primaryButtonText != null)
                  CustomButton(
                    text: primaryButtonText!,
                    icon: Icons.login,
                    onPressed: onPrimaryPressed ?? () => context.push('/auth/login'),
                  ),
                
                if (primaryButtonText != null && secondaryButtonText != null)
                  const SizedBox(height: 16),
                
                // زر ثانوي
                if (secondaryButtonText != null)
                  CustomButton(
                    text: secondaryButtonText!,
                    icon: Icons.person_add,
                    isOutlined: true,
                    onPressed: onSecondaryPressed ?? () => context.push('/auth/register'),
                  ),
                
                const SizedBox(height: 24),
                
                // زر متابعة التسوق
                TextButton.icon(
                  onPressed: () => context.push('/app/products'),
                  icon: const Icon(Icons.store, color: AppColors.grey),
                  label: const Text(
                    'متابعة التسوق',
                    style: TextStyle(
                      color: AppColors.grey,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}